//
//  ErrorHandler.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "Det finns redan en användare för denna email."
        case .userDisabled:
            return "Ditt konto har spärrats. Kontakta support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Ange en giltig email-adress."
        case .networkError:
            return "Nätverksfel. Vänligen försök igen."
        case .weakPassword:
            return "Ditt lösenord är för svagt."
        default:
            return "Okänt fel har inträffat."
        }
    }
}
