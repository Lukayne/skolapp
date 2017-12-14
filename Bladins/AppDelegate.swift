//
//  AppDelegate.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseMessaging
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var didReceiveAlarmId: String?
    var activeAlarm: Alarm?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("didFinishLaunchingWithOptions")
        
        FirebaseApp.configure()
        Database.setLoggingEnabled(true)
        
        // Setup navigationbar
        let barAppearance = UINavigationBar.appearance()
        barAppearance.isTranslucent = false
        barAppearance.barTintColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
        barAppearance.tintColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
        barAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.custom(hexString: "FAFAFA", alpha: 1).value]
        barAppearance.setBackgroundImage(#imageLiteral(resourceName: "red_bar"), for: .default)
        
        // Determine initial viewcontroller
        checkAuthorization { (success, response, error) in
            guard success, let uid = response as? String else {
                print(error ?? "No success")
                self.switchToLogin()
                return
            }
            if self.activeAlarm != nil {
                print("Alarm has successfully been prefetched")
            }
            if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
                if  let school = notification["gcm.notification.school"] as? String,
                    let alarmId = notification["gcm.notification.alarm"] as? String {
                    print("AlarmId received: ", alarmId)
                    print("School: ", school)
                    _ = Alarm(id: alarmId, school: School(name: school), completion: { (success, response, error) in
                        guard success, let alarm = response as? Alarm else {
                            print("No success")
                            return
                        }
                        print("Alarm found")
                        _ = User(id: uid, completion: { (success, response, error) in
                            guard success, let user = response as? User else {
                                print(error ?? "GetUser fail")
                                return
                            }
                            self.switchToAlarm(alarm: alarm, me: user, completion: { (success, response, error) in
                                guard success else {
                                    print("SwitchToAlarm fail")
                                    self.switchToMain(userId: uid, completion: { (success, response, error) in
                                        guard success, error == nil else {
                                            print("SwitchToMain fail")
                                            return
                                        }
                                    })
                                    return
                                }
                            })
                        })
                    })
                } else {
                    print("Couldn't cast school or alarmId")
                }
            } else {
                print("No Alarm")
                self.switchToMain(userId: uid, completion: {(success, response, error) in
                    guard success, error == nil else {
                        print(error ?? "No success")
                        self.switchToLogin()
                        return
                    }
                })
            }
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        // Firebase configuration
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func checkAuthorization(completion: @escaping (Bool, Any?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, nil, nil)
            return
        }
        user.reload(completion: { (error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            let ref = Database.database().reference()
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if let users = snapshot.value as? NSDictionary {
                    if let uids = users.allKeys as? [String] {
                        if uids.contains(user.uid) {
                            completion(true, user.uid, nil)
                        } else {
                            completion(false, nil, nil)
                        }
                    } else {
                        completion(false, nil, nil)
                    }
                } else {
                    completion(false, nil, nil)
                }
                
            }, withCancel: { (error) in
                completion(false, nil, error)
            })
        })
        
    }
    
    func switchToMain(userId: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        _ = User(id: userId, completion: { (success, response, error) in
            guard success, let user = response as? User else {
                completion(false, nil, error)
                return
            }
            user.school?.getAlarmOptions(completion: { (success, response, error) in
                guard success else {
                    completion(false, response, error)
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "Main") as! NavigationController
                navigationController.me = user
                print(user.school?.alarmTypes?.count ?? "No alarmTypes found")
                self.switchViewControllerWithTransition(navigationController)
                completion(true, nil, nil)
            })
        })
        
    }
    
    func switchToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        switchViewControllerWithTransition(loginViewController)
    }
    
    func switchToAlarm(alarm: Alarm, me: User, completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let alarmViewController = storyboard.instantiateViewController(withIdentifier: "Alarm") as? AlarmViewController {
            alarmViewController.me = me
            alarmViewController.alarm = alarm
            alarmViewController.didLaunchFromRemoteNotification = true
            self.switchViewControllerWithTransition(alarmViewController)
            completion(true, nil, nil)
        } else {
            completion(false, nil, nil)
        }
        
    }
    
    func switchViewControllerWithTransition(_ vc: UIViewController) {
        guard let window = self.window else {
            return
        }
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        vc.view.frame = rootViewController.view.frame
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreDataTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: Remote-notification configuration
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let notification = userInfo as? [String: AnyObject] {
            if  let school = notification["gcm.notification.school"] as? String,
                let alarmId = notification["gcm.notification.alarm"] as? String {
                print("AlarmId received: ", alarmId)
                print("School: ", school)
                _ = Alarm(id: alarmId, school: School(name: school), completion: { (success, response, error) in
                    guard success, let alarm = response as? Alarm else {
                        print("No success")
                        return
                    }
                    self.activeAlarm = alarm
                })
            }
        }
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        print("didReceiveRemoteNotification")
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        
        completionHandler(.newData)
        
    }
    
}



@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //    // Receive displayed notifications for iOS 10 devices.
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                willPresent notification: UNNotification,
    //                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //        let userInfo = notification.request.content.userInfo
    //
    //        // With swizzling disabled you must let Messaging know about the message, for Analytics
    //        // Messaging.messaging().appDidReceiveMessage(userInfo)
    //        // Print message ID.
    //        if let messageID = userInfo[gcmMessageIDKey]  {
    //            print("Message ID: \(messageID)")
    //        }
    //
    //        // Print full message.
    //        print(userInfo)
    //
    //        // Change this to your preferred presentation option
    //        completionHandler([])
    //    }
    
    // De två nedanstående funktionerna gör så att man får pushmeddelande fast man är i appen.
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        /*
         let dict = notification.request.content.userInfo["aps"] as! NSDictionary
         let d : [String : Any] = dict["alert"] as! [String : Any]
         let body : String = d["body"] as! String
         let title : String = d["title"] as! String
         print(d["alarm"])
         */
        
        // Visa bara notifikation om användaren inte själv skapat alarmet.
        //        self.showAlertAppDelegate(title: title,message:body,buttonTitle:"ok",window:self.window!)
        
    }
//    func showAlertAppDelegate(title: String,message : String,buttonTitle: String,window: UIWindow){
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
//        window.rootViewController?.present(alert, animated: false, completion: nil)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
}

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("WARNING!: Handle firebase registration token refresh: \(fcmToken)")
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        let ref = Database.database().reference()
        
//        let VC: CreateUserViewController = CreateUserViewController()
//        let token: [String : AnyObject] = [Messaging.messaging().fcmToken! : Messaging.messaging().fcmToken as AnyObject]
//        VC.postToken(token: token)
    }
    
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
}
