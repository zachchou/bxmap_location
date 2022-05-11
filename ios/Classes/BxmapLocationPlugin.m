#import "BxmapLocationPlugin.h"
#import <TencentLBS/TencentLBS.h>
#import "BxmapFlutterStreamManager.h"

@interface BxmapFlutterLocationManager : TencentLBSLocationManager
@property (nonatomic, assign) BOOL onceLocation;
@property (nonatomic, copy) FlutterResult flutterResult;
@property (nonatomic, strong) NSString *pluginKey;
@property (nonatomic, copy) NSString *fullAccuracyPurposeKey;
@end

@implementation BxmapFlutterLocationManager

- (instancetype)init {
    if ([super init] == self) {
        _onceLocation = false;
        _fullAccuracyPurposeKey = nil;
    }
    return  self;
}

@end

@interface BxmapLocationPlugin()<TencentLBSLocationManagerDelegate>
@property (nonatomic, strong) NSMutableDictionary<NSString*, BxmapFlutterLocationManager*> *pluginsDict;
@end

@implementation BxmapLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bxmap_location"
            binaryMessenger:[registrar messenger]];
  BxmapLocationPlugin* instance = [[BxmapLocationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"bxmap_location_stream" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:[[BxmapFlutterStreamManager sharedInstance] streamHandler]];
}
- (instancetype)init {
    if ([super init] == self) {
        _pluginsDict = [[NSMutableDictionary alloc] init];
    }
    return  self;
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
      NSLog(@"call.method: %@", call.method);
      NSLog(@"call.arguments: %@", call.arguments);
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"setApiKey" isEqualToString:call.method]) {
      NSLog(@"call.arguments: %@", call.arguments);
      NSString *apiKey = call.arguments[@"ios"];
      if (apiKey && [apiKey isKindOfClass:[NSString class]]) {
          BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
          manager.apiKey = apiKey;
          result(@YES);
      } else {
          result(@NO);
      }
  } else if ([@"startLocation" isEqualToString:call.method]) {
      [self startLocation:call result:result];
  } else if ([@"stopLocation" isEqualToString:call.method]) {
      [self stopLocation:call];
  } else if ([@"setLocationOption" isEqualToString:call.method]) {
      [self setLocationOption:call];
  } else if ([@"destroy" isEqualToString:call.method]) {
      [self destroyLocation:call];
  } else if ([@"getSystemAccuracyAuthorization" isEqualToString:call.method]) {
      [self getSystemAccuracyAuthorization:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getSystemAccuracyAuthorization:(FlutterMethodCall*)call result:(FlutterResult)result {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
    if (@available(iOS 14.0, *)) {
        BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
        TencentLBSAccuracyAuthorization accAuthor = manager.accuracyAuthorization;
        result(@(accAuthor));
    }
#else
    if (result) {
        result(@(0)); //如果不是iOS14,则定位精度权限默认为高精度
    }
#endif
}

- (void)setLocationOption:(FlutterMethodCall*)call {
    BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
    if (!manager) {
        return;
    }
    
    NSNumber *onceLocation = call.arguments[@"onceLocation"];
    if (onceLocation) {
        manager.onceLocation = [onceLocation boolValue];
    }
}

- (void)startLocation:(FlutterMethodCall*)call result:(FlutterResult)result {
    BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
    if (!manager) {
        return;
    }
    
    if (manager.onceLocation) {
        [manager requestLocationWithCompletionBlock:^(TencentLBSLocation * _Nullable location, NSError * _Nullable error) {
            [self handlePlugin:manager.pluginKey lbsLocation:location error:error];
        }];
    } else {
        [manager setFlutterResult:result];
        [manager startUpdatingLocation];
    }
}

- (void)stopLocation:(FlutterMethodCall*)call {
    BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
    if (!manager) {
        return;
    }
    
    [manager setFlutterResult:nil];
    [[self locManagerWithCall:call] stopUpdatingLocation];
    
}

- (void)destroyLocation:(FlutterMethodCall*)call {
    BxmapFlutterLocationManager *manager = [self locManagerWithCall:call];
    if (!manager) {
        return;
    }
    
    @synchronized (self) {
        if (manager.pluginKey) {
            [_pluginsDict removeObjectForKey:manager.pluginKey];
        }
    }
}

- (BxmapFlutterLocationManager*)locManagerWithCall:(FlutterMethodCall*)call {
    if (!call || !call.arguments || !call.arguments[@"pluginKey"] || [call.arguments[@"pluginKey"] isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    
    NSString *pluginKey = call.arguments[@"pluginKey"];
    
    BxmapFlutterLocationManager *manager = nil;
    @synchronized (self) {
        manager = [_pluginsDict objectForKey:pluginKey];
    }
    if (!manager) {
        manager = [[BxmapFlutterLocationManager alloc] init];
        manager.pluginKey = pluginKey;
        manager.delegate = self;
        @synchronized (self) {
            [_pluginsDict setObject:manager forKey:pluginKey];
        }
    }
    NSLog(@"_pluginsDict: %@", _pluginsDict);
    return  manager;
}

- (void)handlePlugin:(NSString *)pluginKey lbsLocation:(TencentLBSLocation *)location error:(NSError *)error {
    if (!pluginKey || ![[[BxmapFlutterStreamManager sharedInstance] streamHandler] eventSink]) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[self getFormatTime:[NSDate date]] forKey:@"callBackTime"];
    [dic setObject:pluginKey forKey:@"pluginKey"];
    
    if (location) {
        [dic setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.latitude] forKey:@"latitude"];
        [dic setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.longitude] forKey:@"longitude"];
        [dic setValue:[NSNumber numberWithDouble:location.location.horizontalAccuracy] forKey:@"accuracy"];
        [dic setValue:[NSNumber numberWithDouble:location.location.altitude] forKey:@"altitude"];
        [dic setValue:[NSNumber numberWithDouble:location.location.course] forKey:@"bearing"];
        [dic setValue:[NSNumber numberWithDouble:location.location.speed] forKey:@"speed"];
        
        if (location.name) {
            [dic setValue:location.name forKey:@"name"];
        }
        
        if (location.address) {
            [dic setValue:location.address forKey:@"address"];
        }
        
        if (location.nation) {
            [dic setValue:location.nation forKey:@"nation"];
        }
        if (location.province) {
            [dic setValue:location.province forKey:@"province"];
        }
        if (location.city) {
            [dic setValue:location.city forKey:@"city"];
        }
        
        if (location.district) {
            [dic setValue:location.district forKey:@"district"];
        }
        
        if (location.town) {
            [dic setValue:location.town forKey:@"town"];
        }
        
        if (location.village) {
            [dic setValue:location.village forKey:@"village"];
        }
        
        if (location.street) {
            [dic setValue:location.street forKey:@"street"];
        }
    } else {
        [dic setValue:@"-1" forKey:@"errorCode"];
        [dic setValue:@"location is null" forKey:@"errorInfo"];
    }
    
    if (error) {
        [dic setObject:@(error.code) forKey:@"errorCode"];
        [dic setObject:error.description forKey:@"errorInfo"];
    }
    
    [[BxmapFlutterStreamManager sharedInstance] streamHandler].eventSink(dic);
}

- (NSString *)getFormatTime:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}


@end
