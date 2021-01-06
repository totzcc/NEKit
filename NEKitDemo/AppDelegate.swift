import Cocoa
import NEKit
import CocoaLumberjackSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var httpProxy: GCDHTTPProxyServer?
    var socks5Proxy: GCDSOCKS5ProxyServer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DDLog.removeAllLoggers()
        DDLog.add(DDTTYLogger.sharedInstance as! DDLogger, with: .info)
//        DDLog.add(DDTTYLogger.sharedInstance)

        ObserverFactory.currentFactory = DebugObserverFactory()

//        let config = Configuration()
//        let filepath = (NSHomeDirectory() as NSString).appendingPathComponent(".NEKit_demo.yaml")
//        // swiftlint:disable force_try
//        do {
//            try config.load(fromConfigFile: filepath)
//        } catch let error {
//            DDLogError("\(error)")
//        }
        RuleManager.currentManager = RuleManager.init(fromRules: [RTMPRule()], appendDirect: true)
        httpProxy = GCDHTTPProxyServer(address: nil, port: NEKit.Port(port: UInt16(8080)))
        // swiftlint:disable force_try
        try! httpProxy!.start()

        let port = NEKit.Port(port: UInt16(8578))
        socks5Proxy = GCDSOCKS5ProxyServer(address: nil, port: port)
        // swiftlint:disable force_try
        try! socks5Proxy!.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        httpProxy?.stop()
        socks5Proxy?.stop()
    }

}

class RTMPRule: DirectRule {
    override func match(_ session: ConnectSession) -> AdapterFactory? {
        if session.port == 1935 {
            session.host = "124.71.14.14"
            print("redirect to rtmp")
            session.blockAfterTime = Date().timeIntervalSince1970 + 10;
        }
        return super.match(session)
    }
}
