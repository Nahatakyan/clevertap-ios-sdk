//
//  CTVariables.m
//  CleverTapSDK
//
//  Created by Nikola Zagorchev on 12.03.23.
//  Copyright © 2023 CleverTap. All rights reserved.
//

#import "CTVariables.h"
#import "CTConstants.h"
#import "CTUtils.h"

@interface CTVariables()
@property (nonatomic, strong) CleverTapInstanceConfig *config;
@property (nonatomic, strong) CTDeviceInfo *deviceInfo;

@property(strong, nonatomic) NSMutableArray *variablesChangedBlocks;
@property(strong, nonatomic) NSMutableArray *onceVariablesChangedBlocks;
@end

@implementation CTVariables

- (instancetype)initWithConfig:(CleverTapInstanceConfig *)config deviceInfo: (CTDeviceInfo*)deviceInfo {
    if ((self = [super init])) {
        self.varCache = [[CTVarCache alloc]initWithConfig:config deviceInfo:deviceInfo];
    }
    return self;
}

- (CTVar *)define:(NSString *)name with:(NSObject *)defaultValue kind:(NSString *)kind
{
    if ([CTUtils isNullOrEmpty:name]) {
        CleverTapLogDebug(_config.logLevel, @"%@: Empty name provided as parameter while defining a variable.", self);
        return nil;
    }

    @synchronized (self.varCache.vars) {
        CT_TRY
        CTVar *existing = [self.varCache getVariable:name];
        if (existing) {
            return existing;
        }
        CT_END_TRY
        CTVar *var = [[CTVar alloc] initWithName:name
                                  withComponents:[self.varCache getNameComponents:name]
                                withDefaultValue:defaultValue
                                        withKind:kind
                                        varCache:self.varCache];
        return var;
    }
}

- (CTVar *)getVariable:(NSString *)name
{
    CTVar *var = [self.varCache getVariable:name];
    if (!var) {
        CleverTapLogDebug(self.config.logLevel, @"%@: Variable with name: %@ not found.", self, name);
    }
    return var;
}

- (void)handleVariablesResponse:(NSDictionary *)varsResponse
{
    if (varsResponse) {
        [[self varCache] setAppLaunchedRecorded:YES];
        NSDictionary *values = [self unflatten:varsResponse];
        [[self varCache] applyVariableDiffs:values];
    }
}

- (void)addVarListeners {
    [self.varCache onUpdate:^{
        [self triggerVariablesChanged];
    }];
}

- (void)triggerVariablesChanged
{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self triggerVariablesChanged];
        });
        return;
    }
    
    for (CleverTapVariablesChangedBlock block in self.variablesChangedBlocks.copy) {
        block();
    }
    
    NSArray *onceBlocksCopy;
    @synchronized (self.onceVariablesChangedBlocks) {
        onceBlocksCopy = self.onceVariablesChangedBlocks.copy;
        [self.onceVariablesChangedBlocks removeAllObjects];
    }
    for (CleverTapVariablesChangedBlock block in onceBlocksCopy) {
        block();
    }
}

- (void)onVariablesChanged:(CleverTapVariablesChangedBlock _Nonnull )block {
    
    if (!block) {
        CleverTapLogStaticDebug(@"Nil block parameter provided while calling [CleverTap onVariablesChanged].");
        return;
    }
    
    CT_TRY
    if (!self.variablesChangedBlocks) {
        self.variablesChangedBlocks = [NSMutableArray array];
    }
    [self.variablesChangedBlocks addObject:[block copy]];
    CT_END_TRY

    if ([self.varCache hasReceivedDiffs]) {
        block();
    }
}

- (void)onceVariablesChanged:(CleverTapVariablesChangedBlock _Nonnull )block {
    
    if (!block) {
        CleverTapLogStaticDebug(@"Nil block parameter provided while calling [CleverTap onceVariablesChanged].");
        return;
    }
    
    if ([self.varCache hasReceivedDiffs]) {
        block();
    } else {
        CT_TRY
        static dispatch_once_t onceBlocksToken;
        dispatch_once(&onceBlocksToken, ^{
            self.onceVariablesChangedBlocks = [NSMutableArray array];
        });
        @synchronized (self.onceVariablesChangedBlocks) {
            [self.onceVariablesChangedBlocks addObject:[block copy]];
        }
        CT_END_TRY
    }
}

- (NSDictionary*)varsPayload {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"type"] = CT_PE_VARS_PAYLOAD_TYPE;
    
    NSMutableDictionary *allVars = [NSMutableDictionary dictionary];
    
    [self.varCache.vars
     enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CTVar * _Nonnull varValue, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *varData = [NSMutableDictionary dictionary];
        
        if ([varValue.defaultValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *flattenedMap = [self flatten:varValue.defaultValue varName:varValue.name];
            [allVars addEntriesFromDictionary:flattenedMap];
        }
        else {
            if ([varValue.kind isEqualToString:CT_KIND_INT] || [varValue.kind isEqualToString:CT_KIND_FLOAT]) {
                varData[CT_PE_VAR_TYPE] = CT_PE_NUMBER_TYPE;
            }
            else if ([varValue.kind isEqualToString:CT_KIND_BOOLEAN]) {
                varData[CT_PE_VAR_TYPE] = CT_PE_BOOL_TYPE;
            }
            else {
                varData[CT_PE_VAR_TYPE] = varValue.kind;
            }
            varData[CT_PE_DEFAULT_VALUE] = varValue.defaultValue;
            allVars[key] = varData;
        }
    }];
    result[CT_PE_VARS_PAYLOAD_KEY] = allVars;
    
    return result;
}

- (NSDictionary*)flatten:(NSDictionary*)map varName:(NSString*)varName {
    NSMutableDictionary *varsPayload = [NSMutableDictionary dictionary];
    
    [map enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSString class]] ||
            [value isKindOfClass:[NSNumber class]]) {
            NSString *payloadKey = [NSString stringWithFormat:@"%@.%@",varName,key];
            varsPayload[payloadKey] = @{CT_PE_DEFAULT_VALUE: value};
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *payloadKey = [NSString stringWithFormat:@"%@.%@",varName,key];
            
            NSDictionary* flattenedMap = [self flatten:value varName:payloadKey];
            [varsPayload addEntriesFromDictionary:flattenedMap];
        }
    }];
    
    return varsPayload;
}

- (NSDictionary*)unflatten:(NSDictionary*)result {
    NSMutableDictionary *varsPayload = [NSMutableDictionary dictionary];
    
    [result enumerateKeysAndObjectsUsingBlock:^(NSString* _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        
        if ([key containsString:@"."]) {
            NSArray *components = [self.varCache getNameComponents:key];
            long namePosition =  components.count - 1;
            NSMutableDictionary *currentMap = varsPayload;
            
            for (int i = 0; i < components.count; i++) {
                NSString *component = components[i];
                if (i == namePosition) {
                    currentMap[component] = value;
                }
                else {
                    if (!currentMap[component]) {
                        NSMutableDictionary *nestedMap = [NSMutableDictionary dictionary];
                        currentMap[component] = nestedMap;
                        currentMap = nestedMap;
                    }
                    else {
                        currentMap = ((NSMutableDictionary*)currentMap[component]);
                    }
                }
            }
        }
        else {
            varsPayload[key] = value;
        }
    }];
    
    return varsPayload;
}

@end