//
//  AppDelegate.swift
//  SharpsellCoreDemo
//
//  Created by Surya on 19/12/21.
//

import UIKit
import SharpsellCore
import AVFoundation
import FirebaseCore

//import Firebase


let defaults = UserDefaults.standard

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property Declaration
    static var sharpSellcore = SharpSellWrapper()
    var window: UIWindow?
    
    //MARK: App Delegate FunctionsMoEngagePluginBaseMoEngagePluginBase
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        FirebaseApp.configure()
        
        //Calling Sharpsell flutter engine
        Sharpsell.services.createFlutterEngine()
        NSLog(">>>>>>> didFinishLaunchingWithOptions")
        setupNotifications(application)
        if let userActivity = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any],
               let activity = userActivity["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity,
//               activity.activityType == NSUserActivityTypeBrowsingWeb,
               let incomingURL = activity.webpageURL {
                
                NSLog("App launched from killed state with Universal Link: \(incomingURL.absoluteString)")
                // Handle the URL here or set a flag/variable to handle it after app fully launches
                handleUniversalLink(url: incomingURL)
                return true
            }
//        AVCaptureDevice.requestAccess(for: .audio) { granted in
//            if (granted){
//                print("Granted")
//            }else {
//                print("Not - Granted")
//            }
//        }
        
        
        
//        switch AVAudioSession.sharedInstance().recordPermission {
//            case .granted:
//                print("Permission granted")
//            case .denied:
//                print("Permission denied")
//            case .undetermined:
//                print("Request permission here")
//                AVAudioSession.sharedInstance().requestRecordPermission({ granted in
//                    if (granted){
//                        print("Granted")
//                    }else {
//                        print("Not - Granted")
//                    }
//                })
//            @unknown default:
//                print("Unknown case")
//            }
        
    
        if defaults.bool(forKey: "isUserLoggedIn"){
            let cockpitVC = CockpitViewController()
            let navigationController = UINavigationController(rootViewController: cockpitVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            setLoginPageAsRootVc()
        }
        

        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    //MARK: Custom Functions
    
    func handleUniversalLink(url: URL) {
        if (url.absoluteString.contains("enparadigmtech.com") || url.absoluteString.contains("sharpselltech.com")) {
            var dvcArgs: Dictionary = [String: Any]()
            do {
                dvcArgs = ["route": url.absoluteString.replacingOccurrences(of: "sharpsell://", with: "https://")]
            } catch {
                NSLog("Not me error")
            }
            NSLog(">>>>>>>> url 2 - \(dvcArgs)")
            let sharpsellOpenDataInString = Sharpsell.services.convertJsonToString(dict: dvcArgs) ?? ""
            NSLog(">>>>>>>> url 3 - \(sharpsellOpenDataInString)")
            
            Sharpsell.services.open(arguments: sharpsellOpenDataInString) { flutterViewController in
                flutterViewController.navigationController?.navigationBar.isHidden = true
                flutterViewController.modalPresentationStyle = .fullScreen
                
                Sharpsell.services.getTopMostViewController { topMostViewController in
                    if topMostViewController is UINavigationController {
                        let topVC = topMostViewController as! UINavigationController
                        topVC.pushViewController(flutterViewController, animated: true)
                    } else {
                        topMostViewController.present(flutterViewController, animated: true, completion: nil)
                    }
                } onFailure: {
                    NSLog("Sharpsell Parent App - Failed to get top most view controller")
                }
                
            } onFailure: { message, errorType in
                NSLog("Sharpsell Parent App - Failed to open sharpsell from notification ❌")
            }
        }
    }

    fileprivate func setupNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
//        Messaging.messaging().delegate = self
    }
    
    func setLoginPageAsRootVc(){
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController: vc)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    
    
}


extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        NSLog("Sharpsell Parent App: userNotificationCenter - willPresent")
        NSLog("Sharpsell Parent App: userNotificationCenter - \(userInfo)")
//        NSLog(userInfo)
        return [[.alert, .sound]]
    }
    
    // This function will be called on click on the sharpsell notifcation
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let notificationInfo = response.notification.request.content.userInfo
        
        //For Sharpsell this function will be called on click of the notifications
        
        NSLog("Sharpsell Parent App: did recived notfications on userNotificationCenter - didReceive")
        NSLog("Sharpsell Parent App: - \(notificationInfo)")
        if let app_extra = notificationInfo["app_extra"] as? [AnyHashable : Any],let moe_deeplink = app_extra["moe_deeplink"] as? String{
            Sharpsell.services.setNotificationDataWhenDidReceive(center, response)
            let dvcArgs = ["route" : moe_deeplink]
            var sharpsellOpenDataInString = Sharpsell.services.convertJsonToString(dict: dvcArgs) ?? ""
            
            Sharpsell.services.open(arguments: sharpsellOpenDataInString) { flutterViewController in
                flutterViewController.navigationController?.navigationBar.isHidden = true
                flutterViewController.modalPresentationStyle = .fullScreen

                Sharpsell.services.getTopMostViewController { topMostViewController in
                    if topMostViewController is UINavigationController{
                        let topVC = topMostViewController as! UINavigationController
                        topVC.pushViewController(flutterViewController, animated: true)
                    } else {
                        topMostViewController.present(flutterViewController, animated: true, completion: nil)
                    }
                } onFailure: {
                    NSLog("Sharpsell Parent App - Failed to get top most view controller")
                }

            } onFailure: { message, errorType in
                NSLog("Sharpsell Parent App - Failed to open sharpsell from notification ❌")
            }
        } else {
            
            Sharpsell.services.handleNotificationRedirection(notificationData: notificationInfo) { notificationData in
                NSLog("Sharpsell Parent App- Notification opend Successfull 🥳")
                NSLog("Sharpsell Parent App : notificationData - \(notificationData)")
                
                Sharpsell.services.setNotificationDataWhenDidReceive(center, response)
                
                Sharpsell.services.open(arguments: notificationData) { flutterViewController in
                    flutterViewController.navigationController?.navigationBar.isHidden = true
                    flutterViewController.modalPresentationStyle = .fullScreen
                    
                    Sharpsell.services.getTopMostViewController { topMostViewController in
                        Sharpsell.services.getTopMostViewController { topMostViewController in
                            if topMostViewController is UINavigationController{
                                let topVC = topMostViewController as! UINavigationController
                                topVC.pushViewController(flutterViewController, animated: true)
                            } else {
                                topMostViewController.present(flutterViewController, animated: true, completion: nil)
                            }
                        } onFailure: {
                            NSLog("Sharpsell Parent App - Failed to get top most view controller")
                        }
                        
                    } onFailure: {
                        NSLog("Sharpsell Parent App - Failed to open sharpsell from notification ❌")
                    }
                    
                } onFailure: { message, errorType in
                    NSLog("Sharpsell Parent App - Failed to handle notfication ❌")
                }
            } onFailure: { message, errorType in
                NSLog("Sharpsell Parent App - Failed to handle notfication ❌")
            }
        }
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare(scheme) == .orderedSame,
            let view = url.host {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            handleUniversalLink(url: url)
        }
        return true
    }
    
    public func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        print(">>>>>>> web URL - \(userActivity.webpageURL)")
        if let url = userActivity.webpageURL {
            NSLog(">>>>>>> web URL - \(url.absoluteString)")
            var view = url.lastPathComponent
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            handleUniversalLink(url: url)
        }
        return true;
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Sharpsell.services.setPushTokenWhenDidRegisterForRemoteNotifications(with: deviceToken)
    }
    
    
    // This will be called when notification is triggred from the fcm server
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("Sharpsell Parent App: did recive silent notifications - didReceiveRemoteNotification")
        NSLog("Sharpsell Parent App: userInfo - \(userInfo)")
        
        Sharpsell.services.isSharpsellNotification(notificationPayLoad: userInfo) { isSharpsellNotification in
            Sharpsell.services.setNotificationDataWhenDidReceiveRemoteNotification(application, userInfo)
            if isSharpsellNotification{
                Sharpsell.services.showNotification(notificationPayLoad: userInfo) {
                    NSLog("Sharpsell Parent App- Notification showed successfully 🥳")
                } onFailure: { message, errorType in
                    NSLog("Sharpsell Parent App: showNotification Failed - \(errorType) and  \(message)")
                }
            }
            
        } onFailure: { message, errorType in
            NSLog("Sharpsell Parent App - error in validation sharpsell notifccation - \(message)")
        }
    }
    
    
}

//MARK: Notification Delegate
//extension AppDelegate: MessagingDelegate{
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        NSLog("Sharpsell Parent App: Firebase registration token from iOS: \(String(describing: fcmToken))")
//        
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//        
//        if let token = fcmToken {
//            print(token)
//            defaults.set(String(describing: token), forKey: "fcmToken")
//        } else {
//            NSLog("Sharpsell Parent App: Firebase token is empty ⚠️")
//        }
//    }
//    
//}
