import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        if let window = window {
//            let mainVC = ViewController()
//            window.rootViewController = mainVC
//            window.makeKeyAndVisible()
//        }
        
        if #available(iOS 13.0, *){
            self.window?.overrideUserInterfaceStyle = .light
        }
        sleep(2)
        
        return true
    }

}

