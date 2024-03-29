/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self

    AppController.shared.show(in: UIWindow(frame: UIScreen.main.bounds))
    registerForPushNotifications()

    return true
  }
  
  @available(iOS 9.0, *)
  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
      return GIDSignIn.sharedInstance().handle(url,
                                               sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                               annotation: [:])
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation)
  }

  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    // ...
    if let error = error {
      // ...
      return
    }
    
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { (authResult, error) in
      if let error = error {
        // ...
        return
      }
      // User is signed in
      // ...
      let name = GIDSignIn.sharedInstance().currentUser.profile?.name
//        showMissingNameAlert()
      AppSettings.displayName = name
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    // Perform any operations when the user disconnects from app here.
    // ...
  }

  func registerForPushNotifications() {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) {
        [weak self] granted, error in
        
        print("Permission granted: \(granted)")
        guard granted else { return }
        self?.getNotificationSettings()
    }
  }
  
  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }
  
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register: \(error)")
  }

}

