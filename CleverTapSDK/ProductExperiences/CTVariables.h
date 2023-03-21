//
//  CTVariables.h
//  CleverTapSDK
//
//  Created by Nikola Zagorchev on 12.03.23.
//  Copyright © 2023 CleverTap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTVarCache.h"
#import "CleverTapInstanceConfig.h"
#import "CTDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTVariables : NSObject

@property(strong, nonatomic) CTVarCache *varCache;

- (instancetype)initWithConfig:(CleverTapInstanceConfig *)config deviceInfo: (CTDeviceInfo*)deviceInfo;

- (CTVar *)define:(NSString *)name
             with:(nullable NSObject *)defaultValue
             kind:(nullable NSString *)kind
NS_SWIFT_NAME(define(name:value:kind:));

- (CTVar *)getVariable:(NSString *)name;
- (void)handleVariablesResponse:(NSDictionary *)varsResponse;
- (void)onVariablesChanged:(CleverTapVariablesChangedBlock _Nonnull )block;
- (void)onceVariablesChanged:(CleverTapVariablesChangedBlock _Nonnull )block;
- (NSDictionary*)flatten:(NSDictionary*)map varName:(NSString*)varName;
- (NSDictionary*)varsPayload;
- (void)addVarListeners;

@end

NS_ASSUME_NONNULL_END