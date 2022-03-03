//
//  BxmapFlutterStreamManager.m
//  bxmap_location
//
//  Created by kangk on 2022/3/2.
//

#import "BxmapFlutterStreamManager.h"

@implementation BxmapFlutterStreamManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BxmapFlutterStreamManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[BxmapFlutterStreamManager alloc] init];
        BxmapFlutterStreamHandler *streamHandler = [[BxmapFlutterStreamHandler alloc] init];
        manager.streamHandler = streamHandler;
    });
    return  manager;
}
@end

@implementation BxmapFlutterStreamHandler
- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}
- (FlutterError *)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return  nil;
}
@end
