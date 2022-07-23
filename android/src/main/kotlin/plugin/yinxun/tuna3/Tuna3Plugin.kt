package plugin.yinxun.tuna3

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.content.pm.FeatureInfo
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.net.NetworkInterface
import java.util.*
import kotlin.collections.HashMap

/** Tuna3Plugin */
class Tuna3Plugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var applicationContext : Context
  private lateinit var contentResolver: ContentResolver

  private val EMPTY_STRING_LIST = arrayOf<String>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tuna3")
    channel.setMethodCallHandler(this)
    contentResolver = flutterPluginBinding.applicationContext.contentResolver
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if(call.method == "getIpV4"){
      result.success(getIPAddress(true))
    }else if(call.method == "getIpV6"){
      result.success(getIPAddress(false))
    }else if(call.method =="getPackageInfo"){
      var pm = applicationContext.packageManager
      var info = pm.getPackageInfo(applicationContext.packageName, 0)
      var ret = hashMapOf<String,Any>()
      ret["appName"] = info.applicationInfo.loadLabel(pm).toString()
      ret["packageName"] = applicationContext.packageName
      ret["version"] = info.versionName
      ret["buildNumber"] = info.versionCode.toString()
      result.success(ret)
    }else if(call.method=="getAndroidDeviceInfo"){
      result.success(getAndroidDeviceInfo())
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private  fun getAndroidDeviceInfo(): HashMap<String, Any>{
    var ret = hashMapOf<String, Any>()
    ret["board"] = Build.BOARD
    ret["bootloader"] = Build.BOOTLOADER
    ret["brand"] = Build.BRAND
    ret["device"] = Build.DEVICE
    ret["display"] = Build.DISPLAY
    ret["fingerprint"] = Build.FINGERPRINT
    ret["hardware"] = Build.HARDWARE
    ret["host"] = Build.HOST
    ret["id"] = Build.ID
    ret["manufacturer"] = Build.MANUFACTURER
    ret["model"] = Build.MODEL
    ret["product"] = Build.PRODUCT

//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//      ret["supported32BitAbis"] =  listOf(Build.SUPPORTED_32_BIT_ABIS)
//      ret["supported64BitAbis"] =  listOf(Build.SUPPORTED_64_BIT_ABIS)
//      ret["supportedAbis"] =  listOf(Build.SUPPORTED_ABIS)
//    } else {
//      ret["supported32BitAbis"] =  listOf(EMPTY_STRING_LIST)
//      ret["supported64BitAbis"] =  listOf(EMPTY_STRING_LIST)
//      ret["supportedAbis"] =  listOf(EMPTY_STRING_LIST)
//    }

    ret["tags"] = Build.TAGS
    ret["type"] = Build.TYPE
    ret["isPhysicalDevice"] =  !isEmulator()
    ret["androidId"] = getAndroidId()

//    ret["systemFeatures"] =  listOf(getSystemFeatures())

    val version: MutableMap<String, Any> = HashMap()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      version["baseOS"] = Build.VERSION.BASE_OS
      version["previewSdkInt"] = Build.VERSION.PREVIEW_SDK_INT
      version["securityPatch"] = Build.VERSION.SECURITY_PATCH
    }
    version["codename"] = Build.VERSION.CODENAME
    version["incremental"] = Build.VERSION.INCREMENTAL
    version["release"] = Build.VERSION.RELEASE
    version["sdkInt"] = Build.VERSION.SDK_INT

    ret["version"] =  version

    return ret

  }

  private fun getIPAddress(useIPv4: Boolean): String {
    try {
      val interfaces = Collections.list(NetworkInterface.getNetworkInterfaces())
      for (intf in interfaces) {
        val addrs = Collections.list(intf.inetAddresses)
        for (addr in addrs) {
          if (!addr.isLoopbackAddress) {
            val sAddr = addr.hostAddress
            //boolean isIPv4 = InetAddressUtils.isIPv4Address(sAddr);
            val isIPv4 = sAddr.indexOf(':') < 0

            if (useIPv4) {
              if (isIPv4)
                return sAddr
            } else {
              if (!isIPv4) {
                val delim = sAddr.indexOf('%') // drop ip6 zone suffix
                return if (delim < 0) sAddr.toUpperCase() else sAddr.substring(0, delim).toUpperCase()
              }
            }
          }
        }
      }
    } catch (e: Exception) {
      print(e);
    }
    return ""
  }

  private fun getSystemFeatures(): Array<String>? {
    val featureInfos: Array<FeatureInfo> =  applicationContext.packageManager.systemAvailableFeatures
            ?: return EMPTY_STRING_LIST
    val features = arrayOfNulls<String>(featureInfos.size)
    for (i in featureInfos.indices) {
      features[i] = featureInfos[i].name
    }
    return features as Array<String>
  }

  /**
   * Returns the Android hardware device ID that is unique between the device + user and app
   * signing. This key will change if the app is uninstalled or its data is cleared. Device factory
   * reset will also result in a value change.
   *
   * @return The android ID
   */
  @SuppressLint("HardwareIds")
  private fun getAndroidId(): String {
    return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
  }

  /**
   * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
   * detection systems
   */
  private fun isEmulator(): Boolean {
    return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
            || Build.FINGERPRINT.startsWith("generic")
            || Build.FINGERPRINT.startsWith("unknown")
            || Build.HARDWARE.contains("goldfish")
            || Build.HARDWARE.contains("ranchu")
            || Build.MODEL.contains("google_sdk")
            || Build.MODEL.contains("Emulator")
            || Build.MODEL.contains("Android SDK built for x86")
            || Build.MANUFACTURER.contains("Genymotion")
            || Build.PRODUCT.contains("sdk_google")
            || Build.PRODUCT.contains("google_sdk")
            || Build.PRODUCT.contains("sdk")
            || Build.PRODUCT.contains("sdk_x86")
            || Build.PRODUCT.contains("vbox86p")
            || Build.PRODUCT.contains("emulator")
            || Build.PRODUCT.contains("simulator"))
  }
}
