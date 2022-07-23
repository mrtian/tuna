#import "Tuna3Plugin.h"
#if __has_include(<tuna3/tuna3-Swift.h>)
#import <tuna3/tuna3-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tuna3-Swift.h"
#endif

@implementation Tuna3Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTuna3Plugin registerWithRegistrar:registrar];
}
@end
