//
//  BxmapFlutterStreamManager.h
//  bxmap_location
//
//  Created by kangk on 2022/3/2.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class BxmapFlutterStreamHandler;
@interface BxmapFlutterStreamManager : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic, strong) BxmapFlutterStreamHandler *streamHandler;
@end

@interface BxmapFlutterStreamHandler : NSObject<FlutterStreamHandler>
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;
@end

NS_ASSUME_NONNULL_END
