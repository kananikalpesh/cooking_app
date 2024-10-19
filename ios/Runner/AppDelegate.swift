import UIKit
import Flutter
import Firebase
import PushKit
import flutter_voip_push_notification
import flutter_call_kit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate  {
    
    var voipToken: Data?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let voipChannel = FlutterMethodChannel(name: "co.inhomecooking.app/voip",
                                              binaryMessenger: controller.binaryMessenger)
  
    voipChannel.setMethodCallHandler{ [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
      guard call.method == "getVoipToken" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getVoipToken(result: result)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [PKPushType.voIP]
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        application.applicationIconBadgeNumber = 0
    }

   
    /* Add PushKit delegate method */
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void){
        // Register VoIP push token (a property of PKPushCredentials) with server
        
        if type == .voIP && UIApplication.shared.applicationState != .active{
            FlutterVoipPushNotificationPlugin.didReceiveIncomingPush(with: payload, forType: type.rawValue)
            
            let CC_CALLER_USER_NAME: String = "callerUserName"
            let CC_CALL_TYPE_STRING: String = "callTypeString"
            let CC_CALL_TYPE : String = "callType";
            
            let callerName = payload.dictionaryPayload[CC_CALLER_USER_NAME]  as? String
            let callType = payload.dictionaryPayload[CC_CALL_TYPE_STRING] as? String
            let hasVideo = payload.dictionaryPayload[CC_CALL_TYPE]
            FlutterCallKitPlugin.reportNewIncomingCall(UUID().uuidString.lowercased(), handle: callType, handleType: "-", hasVideo: (hasVideo as? String == "1"), localizedCallerName: callerName, fromPushKit: true)
        }
        
    }
    
    
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        // Process the received push
        voipToken = pushCredentials.token
        FlutterVoipPushNotificationPlugin.didUpdate(pushCredentials, forType: type.rawValue);
        
    }
    
    func getVoipToken(result:FlutterResult){
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        result((voipRegistry.pushToken(for: .voIP) ?? voipToken)?.map { String(format: "%02.2hhx", $0) }.joined())
    }
    
}
