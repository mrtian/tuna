import Flutter
import UIKit

public class SwiftTuna3Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tuna3", binaryMessenger: registrar.messenger())
    let instance = SwiftTuna3Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getPlatformVersion":
        result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
      case "getIpV4":
        result(getWiFiAddress())
      case "getIpV6":
        result(getWiFiAddress())
      case "getPackageInfo":
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let packageName = Bundle.main.bundleIdentifier
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        var ret:Dictionary<String,Any> = Dictionary()
        ret["appName"] = appName
        ret["packageName"]  = packageName
        ret["version"] = appVersion
        ret["buildNumber"] = buildNumber
    
        result(ret)
      case "getIosDeviceInfo":
        let device = UIDevice.current
        var un = utsname()
        uname(&un)
        
        
        var ret:Dictionary<String,Any> = Dictionary()
        ret["name"] = device.name
        ret["systemName"] = device.systemName
        ret["systemVersion"] = device.systemVersion
        ret["model"] = device.model
        ret["localizedModel"] = device.localizedModel
        ret["identifierForVendor"] = device.identifierForVendor?.uuidString ?? ""
        ret["isPhysicalDevice"] = self.isDevicePhysical()
        
        var _utsname:Dictionary<String,Any> = Dictionary()
        _utsname["sysname"] = String(bytes: Data(bytes: &un.sysname, count: Int(_SYS_NAMELEN)), encoding: .ascii)
        _utsname["nodename"] = String(bytes: Data(bytes: &un.nodename, count: Int(_SYS_NAMELEN)), encoding: .ascii)
        _utsname["release"] = String(bytes: Data(bytes: &un.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)
        _utsname["version"] = String(bytes: Data(bytes: &un.version, count: Int(_SYS_NAMELEN)), encoding: .ascii)
        _utsname["machine"] = String(bytes: Data(bytes: &un.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)
        ret["utsname"] = _utsname

        result(ret);
      default:
        result(FlutterMethodNotImplemented)
    }
  }
  
  private func isDevicePhysical() -> String {
    if((TARGET_OS_SIMULATOR) != 0){
       return "true"
    }
    return "false"
  }

  public func getWiFiAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address

  }
}
