const functions = require('firebase-functions');                                          
const admin = require('firebase-admin');                                                  
admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref()

exports.newAlarm = functions.database
		.ref(`/schools/{school}/alarms/{alarmId}`)
		.onCreate(event => {
	const school = event.params.school
	const alarmId = event.params.alarmId
	if (alarmId != `active`) {
		return event.data.ref.parent.child(`active`).push().set(alarmId)
	}
})                                         

// exports.alarmTrigger = functions.database
// 		.ref(`/schools/{school}/alarms/active/{id}`)
// 		.onCreate(event => {                                                           
//     const alarmId = event.data.val();
//     const school = event.params.school;

//     console.log('AlarmId is: ', alarmId);
//     console.log('School is: ', school);
                                                                                  
//     const payLoad = {                                                                 
//         notification: {                                                               
//             title: 'Ett larm har utlösts på skolan!',                                             
//             body: 'Tryck här för mer information',                                                     
//             badge: '1',                                                               
//             sound: 'Intruder.mp3',
//             alarm: alarmId                                                     
//         }                                                                             
//     };                                                                                

// 	return ref.child(`/schools/${school}/users`).once('value').then(allUsers => {
// 		const userTokens = allUsers.val()
// 		const users = Object.keys(userTokens)
// 		const tokens = users.map(function(key) {
//     		return userTokens[key];
// 		})     
// 		console.log('Users', users)
// 		console.log('Tokens', tokens)  
//         return admin.messaging().sendToDevice(tokens, payLoad).then(response => {

//         });                                                              
//     });                                                                                   

// });

exports.removeInactiveAlarm = functions.database
		.ref(`/schools/{school}/alarms/{id}/isActive`)
		.onUpdate(event => {
	const isActive = event.data.val();
	const school = event.params.school;
	const alarmId = event.params.id;

	// return ref.child(`/schools/${school}/alarms/${alarmId}`).remove()

	return ref.child(`/schools/${school}/alarms/active/`).once('value').then(allActiveAlarms => {
		console.log(allActiveAlarms.val())
		const activeAlarms = allActiveAlarms.val()
		const keys = Object.keys(activeAlarms)
		const vals = keys.map(function(key) {
    		return activeAlarms[key];
		})
		console.log('Keys', keys)
		console.log('Values', vals)
		for (count = 0; count < keys.length; count++) {
			const alarmVal = vals[count]
			if (alarmId == alarmVal) {
				const alarmKey = keys[count]
				console.log('FOUND ALARM: ', alarmKey)
				return ref.child(`/schools/${school}/alarms/active/${alarmKey}`).remove()
			}
		}
	});

});

// exports.addUserToSchool = functions.database
// 		.ref(`/users/{uid}`)
// 		.onCreate(event => {
// 	const uid = event.params.uid
// 	return event.data.ref.child(`school`).once('value').then(school => {
// 		ref.child(`/schools/${school.val()}/users/${uid}`).set(token)
// 	})
// })

exports.removeDeletedUser = functions.auth.user()
		.onDelete(event => {
	const uid = event.data.uid;
	console.log(`User deleted: `, uid);
	return ref.child(`/users/${uid}`).remove();
})

exports.removeUserFromSchool = functions.database
		.ref(`/users/{uid}/`)
		.onDelete(event => {
	const uid = event.params.uid
	const user = event.data.previous.val()
	const school = user['school']
	const groups = user['groups']
	const keys = Object.keys(groups)
	const vals = keys.map(function(key) {
    	return groups[key];
	})
	return ref.child(`/schools/${school}/users/${uid}`).remove().then(response => {
		var promises = []
		for (const val of vals) {
			const groupRef = ref.child(`/schools/${school}/groups/${val}/members`)
			const promise = groupRef.once('value').then(allMembers => {
				const members = allMembers.val()
				console.log(`Members: `, members)
				const memberKeys = Object.keys(members)
				const memberVals = memberKeys.map(function(key) {
    				return members[key];
				})
				console.log(`keys: `, memberKeys)
				console.log(`vals: `, memberVals)
				for (count = 0; count < memberKeys.length; count++) {
					const memberVal = memberVals[count]
					console.log(`MemberVal: `, memberVal)
					console.log(`My Id: `, uid)
					if (uid == memberVal) {
						const memberKey = memberKeys[count]
						console.log('Found user in group: ', val)
						return groupRef.child(`/${memberKey}`).remove()
					}
				}
			})
			promises.push(promise)
		}
		return Promise.all(promises)
	})
	// return ref.child(`/schools/${school}/users/`).once('value').then(allSchoolUsers => {
	// 	console.log('All school-users: ', allSchoolUsers.val())
	// 	const users = allSchoolUsers.val()
	// 	const keys = Object.keys(users)
	// 	const vals = keys.map(function(key) {
 //    		return users[key];
	// 	})
	// 	console.log('Keys: ', keys)
	// 	console.log('Vals: ', vals)
	// 	for (count = 0; count < keys.length; count++) {
	// 		const userVal = vals[count]
	// 		if (userVal == uid) {
	// 			const userKey = keys[count]
	// 			console.log('Found match')
	// 			return ref.child(`schools/${school}/users/${userKey}`).remove()
	// 		}
	// 	}
	// })
})

exports.addGroupFromSettings = functions.database
		.ref(`schools/{school}/settings/groups/{groupId}`)
		.onCreate(event => {
	const school = event.params.school
	const groupId = event.params.groupId
	const groupName = event.data.val()
	return ref.child(`schools/${school}/groups/${groupId}/name`).set(groupName)
})

exports.removeGroupFromSettings = functions.database
		.ref(`schools/{school}/settings/groups/{groupId}`)
		.onDelete(event => {
	const school = event.params.school
	const groupId = event.params.groupId
	return ref.child(`schools/${school}/groups/${groupId}`).remove()
})

exports.memberJoinedGroup = functions.database
		.ref(`users/{userId}/groups/{autoID}`)
		.onCreate(event => {
	const userId = event.params.userId
	const groupId = event.data.val()
	return ref.child(`/users/${userId}/school`).once('value').then(schoolData => {
		const school = schoolData.val()
		return ref.child(`/schools/${school}/groups/${groupId}/members/`).push().set(userId)
	})
})

exports.memberLeftGroup = functions.database
		.ref(`users/{userId}/groups/{autoID}`)
		.onDelete(event => {
	const userId = event.params.userId
	const groupId = event.data.previous.val()
	console.log(`User id: `, userId)
	console.log(`GroupId: `, groupId)
	return ref.child(`/users/${userId}/school`).once('value').then(schoolData => {
		const school = schoolData.val()
		console.log(`School: `, school)
		if (!school) {
			return
		}
		return ref.child(`/schools/${school}/groups/${groupId}/members/`).once('value').then(allMembers => {
			const members = allMembers.val()
			const keys = Object.keys(members)
			const vals = keys.map(function(key) {
    			return members[key];
			})
			console.log(`All members: `, members)
			for (count = 0; count < keys.length; count++) {
				const memberVal = vals[count]
				if (userId == memberVal) {
					const memberKey = keys[count]
					console.log('FOUND MEMBER: ', memberKey)
					return ref.child(`/schools/${school}/groups/${groupId}/members/${memberKey}`).remove()
				}
			}
		})
	})
})

exports.alarmLevelChanged = functions.database
		.ref(`schools/{school}/alarms/{alarmId}/priority/level`)
		.onWrite(event => {
	const school = event.params.school
	const alarmId = event.params.alarmId
	const level = event.data.val()
	const previousLevel = event.data.previous.val()
	if (!level) {
		return
	}
	const payLoad = {                                                                 
        notification: {                                                               
            title: 'Ett larm har utlösts på skolan!',                                             
            body: 'Tryck här för mer information',                                                     
            badge: '1',                                                               
            sound: 'Intruder.mp3',
            alarm: alarmId                                                     
        }                                                                             
    }
	return ref.child(`/schools/${school}/alarms/${alarmId}/`).once('value').then(alarmData => {
		const alarm = alarmData.val()
		if !alarm[`isActive`] {
			return
		}
		const typeName = alarm[`type`]
		return ref.child(`/schools/${school}/settings/alarmTypes/${typeName}`).once('value').then(alarmTypeData => {
			const alarmType = alarmTypeData.val()
			const promises = []
			switch (level) {
			case >= 0:
				// PN Rektor
				if level > previousLevel {
					const promise = return ref.child(`/schools/${school}/`)
					admin.messaging().sendToDevice(token, payLoad)
				}
			case >= 1:
				// PN Gruppadmins
			case >= 2:
				//
			case >= 3:
				//
			}
		})
	})
})

// exports.locationChanged = functions.database
// 		.ref(`schools/{school}/alarms/{id}/location/room/{entity}`)
// 		.onUpdate(event => {
// 	locationUpdated(event)
// })
// exports.locationDeleted = functions.database
// 		.ref(`schools/{school}/alarms/{id}/location/room/{entity}`)
// 		.onDelete(event => {
// 	locationUpdated(event)
// })

// function locationUpdated(event) {
// 	const school = event.params.school
// 	const alarmId = event.params.id
// 	const entity = event.params.entity
// 	const eventRef = event.data.ref.parent
// 	console.log(entity)
// 	switch (entity) {
// 		case `building`:
// 			console.log(`Building changed`)
// 			return eventRef.child(`section`).remove()
// 			break
// 		case `section`:
// 			console.log(`Section changed`)
// 			return eventRef.child(`floor`).remove()
// 			break
// 		case `floor`:
// 			console.log(`Floor changed`)
// 			return eventRef.child(`room`).remove()
// 			break
// 		case `room`:
// 			console.log(`Room changed`)
// 			break
// 		default:
// 			break
// 	}
// }