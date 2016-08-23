//
//  Adjust.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJTrackingPixel.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// see README for details
#endif

NSString * const ADJEnvironmentSandbox      = @"sandbox";
NSString * const ADJEnvironmentProduction   = @"production";

@interface Adjust()

@property (nonatomic, retain) id<ADJLogger> logger;
@property (nonatomic, retain) id<ADJActivityHandler> activityHandler;

@end

#pragma mark -
@implementation Adjust

+ (void)appDidLaunch:(ADJConfig *)adjustConfig {
    [[Adjust getInstance] appDidLaunch:adjustConfig];
}

+ (void)trackEvent:(ADJEvent *)event {
    [[Adjust getInstance] trackEvent:event];
}

+ (void)trackSubsessionStart {
    [[Adjust getInstance] trackSubsessionStart];
}

+ (void)trackSubsessionEnd {
    [[Adjust getInstance] trackSubsessionEnd];
}

+ (void)setEnabled:(BOOL)enabled {
    [[Adjust getInstance] setEnabled:enabled];
}

+ (BOOL)isEnabled {
    return [[Adjust getInstance] isEnabled];
}

+ (void)appWillOpenUrl:(NSURL *)url {
    [[Adjust getInstance] appWillOpenUrl:url];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    [[Adjust getInstance] setDeviceToken:deviceToken];
}

+ (void)setOfflineMode:(BOOL)enabled {
    [[Adjust getInstance] setOfflineMode:enabled];
}

+ (void)sendAdWordsRequest {
    [[Adjust getInstance] sendAdWordsRequest];
}

+ (NSString*)idfa {
    return [[Adjust getInstance] idfa];
}

+ (NSURL*)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [[Adjust getInstance] convertUniversalLink:url scheme:scheme];
}

+ (id)getInstance {
    static Adjust *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id) init {
    self = [super init];
    if (self == nil) return nil;

    self.activityHandler = nil;
    self.logger = [ADJAdjustFactory logger];

    return self;
}

- (void)appDidLaunch:(ADJConfig *)adjustConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }

    [adjustConfig setSdkPrefix:@"xamarin4.8.0"];
    self.activityHandler = [ADJAdjustFactory activityHandlerWithConfig:adjustConfig];
}

- (void)trackEvent:(ADJEvent *)event {
    if (![self checkActivityHandler]) return;
    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) return;
    [self.activityHandler applicationDidBecomeActive];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) return;
    [self.activityHandler applicationWillResignActive];
}

- (void)setEnabled:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setEnabled:enabled];
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) return NO;
    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    if (![self checkActivityHandler]) return;
    [self.activityHandler  appWillOpenUrl:url];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setDeviceToken:deviceToken];
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setOfflineMode:enabled];
}

- (void)sendAdWordsRequest {
    [ADJTrackingPixel present];
}

- (NSString*)idfa {
    return [ADJUtil idfa];
}

- (NSURL*)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [ADJUtil convertUniversalLink:url scheme:scheme];
}

#pragma mark - private

- (BOOL) checkActivityHandler {
    if (self.activityHandler == nil) {
        [self.logger error:@"Please initialize Adjust by calling 'appDidLaunch' before"];
        return NO;
    } else {
        return YES;
    }
}

@end
