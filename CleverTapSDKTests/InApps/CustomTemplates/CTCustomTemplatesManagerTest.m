//
//  CTCustomTemplatesManagerTest.m
//  CleverTapSDKTests
//
//  Created by Nikola Zagorchev on 28.02.24.
//  Copyright © 2024 CleverTap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "CTCustomTemplatesManager.h"
#import "CTCustomTemplatesManager+Tests.h"
#import "CTInAppTemplateBuilder.h"
#import "CTAppFunctionBuilder.h"
#import "CTTemplatePresenterMock.h"
#import "CTTestTemplateProducer.h"

@interface CTCustomTemplatesManagerTest : XCTestCase

@end

@implementation CTCustomTemplatesManagerTest

- (void)tearDown {
    [super tearDown];
    [CTCustomTemplatesManager clearTemplateProducers];
}

- (void)testSyncPayload {
    NSMutableSet *templates = [NSMutableSet set];
    CTInAppTemplateBuilder *templateBuilder = [[CTInAppTemplateBuilder alloc] init];
    [templateBuilder setName:@"Template 1"];
    [templateBuilder addArgument:@"b" withBool:NO];
    [templateBuilder addArgument:@"c" withString:@"1 string"];
    [templateBuilder addArgument:@"d" withString:@"2 string"];
    [templateBuilder addArgument:@"e" withDictionary:@{
        @"h": @7,
        @"f": @{
            @"c": @4,
            @"e": @"6 string",
            @"d": @5
        }
    }];
    [templateBuilder addArgument:@"l" withString:@"9 string"];
    [templateBuilder addArgument:@"k" withNumber:@10];
    [templateBuilder addArgument:@"e.w" withNumber:@8];
    [templateBuilder addArgument:@"e.f.a" withNumber:@3];
    [templateBuilder addArgument:@"a" withDictionary: @{
        @"n": @"12 string",
        @"m": @"11 string"
    }];
    [templateBuilder setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilder build]];
    
    CTInAppTemplateBuilder *templateBuilderTemplate2 = [CTInAppTemplateBuilder new];
    [templateBuilderTemplate2 setName:@"Template 2"];
    [templateBuilderTemplate2 addArgument:@"b" withBool:NO];
    [templateBuilderTemplate2 addArgument:@"c" withString:@"1 string"];
    [templateBuilderTemplate2 addArgument:@"a.d" withNumber:@5];
    [templateBuilderTemplate2 addArgument:@"a.c.a" withNumber:@4];
    [templateBuilderTemplate2 addArgument:@"a" withDictionary: @{
        @"b": @"3 string",
        @"a": @"2 string"
    }];
    [templateBuilderTemplate2 setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilderTemplate2 build]];
    
    CTAppFunctionBuilder *functionBuilder = [[CTAppFunctionBuilder alloc] initWithIsVisual:NO];
    [functionBuilder setName:@"Function 1"];
    [functionBuilder addArgument:@"b" withBool:NO];
    [functionBuilder addArgument:@"a" withString:@"1 string"];
    [functionBuilder setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[functionBuilder build]];
    
    CTTestTemplateProducer *producer = [[CTTestTemplateProducer alloc] initWithTemplates:templates];
    [CTCustomTemplatesManager registerTemplateProducer:producer];
    CleverTapInstanceConfig *config = [[CleverTapInstanceConfig alloc] initWithAccountId:@"testAccountId" accountToken:@"testAccountToken"];
    CTCustomTemplatesManager *manager = [[CTCustomTemplatesManager alloc] initWithConfig:config];
    
    NSDictionary *syncPayload = [manager syncPayload];
    
    NSDictionary *expectedPayload = @{
        @"definitions": @{
            @"Function 1": @{
                @"type": @"function",
                @"vars": @{
                    @"b": @{
                        @"defaultValue": @0,
                        @"order": @0,
                        @"type": @"boolean"
                    },
                    @"a": @{
                        @"defaultValue": @"1 string",
                        @"order": @1,
                        @"type": @"string"
                    }
                }
            },
            @"Template 1": @{
                @"type": @"template",
                @"vars": @{
                    @"a.m": @{
                        @"defaultValue": @"11 string",
                        @"order": @11,
                        @"type": @"string"
                    },
                    @"a.n": @{
                        @"defaultValue": @"12 string",
                        @"order": @12,
                        @"type": @"string"
                    },
                    @"b": @{
                        @"defaultValue": @0,
                        @"order": @0,
                        @"type": @"boolean"
                    },
                    @"c": @{
                        @"defaultValue": @"1 string",
                        @"order": @1,
                        @"type": @"string"
                    },
                    @"d": @{
                        @"defaultValue": @"2 string",
                        @"order": @2,
                        @"type": @"string"
                    },
                    @"e.f.a": @{
                        @"defaultValue": @3,
                        @"order": @3,
                        @"type": @"number"
                    },
                    @"e.f.c": @{
                        @"defaultValue": @4,
                        @"order": @4,
                        @"type": @"number"
                    },
                    @"e.f.d": @{
                        @"defaultValue": @5,
                        @"order": @5,
                        @"type": @"number"
                    },
                    @"e.f.e": @{
                        @"defaultValue": @"6 string",
                        @"order": @6,
                        @"type": @"string"
                    },
                    @"e.h": @{
                        @"defaultValue": @7,
                        @"order": @7,
                        @"type": @"number"
                    },
                    @"e.w": @{
                        @"defaultValue": @8,
                        @"order": @8,
                        @"type": @"number"
                    },
                    @"k": @{
                        @"defaultValue": @10,
                        @"order": @10,
                        @"type": @"number"
                    },
                    @"l": @{
                        @"defaultValue": @"9 string",
                        @"order": @9,
                        @"type": @"string"
                    }
                }
            },
            @"Template 2": @{
                @"type": @"template",
                @"vars": @{
                    @"b": @{
                        @"defaultValue": @0,
                        @"order": @0,
                        @"type": @"boolean"
                    },
                    @"c": @{
                        @"defaultValue": @"1 string",
                        @"order": @1,
                        @"type": @"string"
                    },
                    @"a.a": @{
                        @"defaultValue": @"2 string",
                        @"order": @2,
                        @"type": @"string"
                    },
                    @"a.b": @{
                        @"defaultValue": @"3 string",
                        @"order": @3,
                        @"type": @"string"
                    },
                    @"a.c.a": @{
                        @"defaultValue": @4,
                        @"order": @4,
                        @"type": @"number"
                    },
                    @"a.d": @{
                        @"defaultValue": @5,
                        @"order": @5,
                        @"type": @"number"
                    }
                }
            }
        },
        @"type": @"templatePayload"
    };
    
    XCTAssertEqual([syncPayload[@"definitions"] count], 3);
    XCTAssertEqualObjects(syncPayload, expectedPayload);
}

- (void)testSyncPayload2 {
    NSMutableSet *templates = [NSMutableSet set];
    CTInAppTemplateBuilder *templateBuilder = [[CTInAppTemplateBuilder alloc] init];
    [templateBuilder setName:@"Template 1"];
    [templateBuilder addArgument:@"boolean" withBool:NO];
    [templateBuilder addArgument:@"string" withString:@"string"];
    [templateBuilder addArgument:@"number" withNumber:@2];
    [templateBuilder addArgument:@"dictionary" withDictionary:@{
        @"key": @"value"
    }];
    [templateBuilder addFileArgument:@"file"];
    [templateBuilder addActionArgument:@"action"];
    [templateBuilder setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilder build]];
    
    CTTestTemplateProducer *producer = [[CTTestTemplateProducer alloc] initWithTemplates:templates];
    [CTCustomTemplatesManager registerTemplateProducer:producer];
    CleverTapInstanceConfig *config = [[CleverTapInstanceConfig alloc] initWithAccountId:@"testAccountId" accountToken:@"testAccountToken"];
    CTCustomTemplatesManager *manager = [[CTCustomTemplatesManager alloc] initWithConfig:config];
    
    NSDictionary *syncPayload = [manager syncPayload];
    
    NSDictionary *expectedPayload = @{
        @"type": @"templatePayload",
        @"definitions": @{
            @"Template 1": @{
                @"type": @"template",
                @"vars": @{
                    @"boolean": @{
                        @"defaultValue": @0,
                        @"order": @0,
                        @"type": @"boolean"
                    },
                    @"string": @{
                        @"defaultValue": @"string",
                        @"order": @1,
                        @"type": @"string"
                    },
                    @"number": @{
                        @"defaultValue": @2,
                        @"order": @2,
                        @"type": @"number"
                    },
                    @"dictionary.key": @{
                        @"defaultValue": @"value",
                        @"order": @3,
                        @"type": @"string"
                    },
                    @"file": @{
                        @"order": @4,
                        @"type": @"file"
                    },
                    @"action": @{
                        @"order": @5,
                        @"type": @"action"
                    }
                }
            }
        }
    };
    
    XCTAssertEqual([syncPayload[@"definitions"] count], 1);
    XCTAssertEqualObjects(syncPayload, expectedPayload);
}

- (void)testTemplatesRegistered {
    NSMutableSet *templates = [NSMutableSet set];
    
    NSString *templateName1 = @"Template1";
    NSString *templateName2 = @"Template2";
    NSString *functionName1 = @"Function1";
    NSString *functionName2 = @"Function2";
    
    CTInAppTemplateBuilder *templateBuilder1 = [CTInAppTemplateBuilder new];
    [templateBuilder1 setName:templateName1];
    [templateBuilder1 setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilder1 build]];
    
    CTInAppTemplateBuilder *templateBuilder2 = [CTInAppTemplateBuilder new];
    [templateBuilder2 setName:templateName2];
    [templateBuilder2 setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilder2 build]];
    
    CTAppFunctionBuilder *functionBuilder1 = [[CTAppFunctionBuilder alloc] initWithIsVisual:NO];
    [functionBuilder1 setName:functionName1];
    [functionBuilder1 setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[functionBuilder1 build]];
    
    CTAppFunctionBuilder *functionBuilder2 = [[CTAppFunctionBuilder alloc] initWithIsVisual:NO];
    [functionBuilder2 setName:functionName2];
    [functionBuilder2 setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[functionBuilder2 build]];
    
    CTTestTemplateProducer *producer = [[CTTestTemplateProducer alloc] initWithTemplates:templates];
    [CTCustomTemplatesManager registerTemplateProducer:producer];
    
    CleverTapInstanceConfig *config = [[CleverTapInstanceConfig alloc] initWithAccountId:@"testAccountId" accountToken:@"testAccountToken"];
    CTCustomTemplatesManager *manager = [[CTCustomTemplatesManager alloc] initWithConfig:config];
    
    XCTAssertTrue([manager existsTemplateWithName:templateName1]);
    XCTAssertTrue([manager existsTemplateWithName:templateName2]);
    XCTAssertTrue([manager existsTemplateWithName:functionName1]);
    XCTAssertTrue([manager existsTemplateWithName:functionName2]);
    
    XCTAssertFalse([manager existsTemplateWithName:@"non-existent"]);
    
    CleverTapInstanceConfig *config2 = [[CleverTapInstanceConfig alloc] initWithAccountId:@"testAccountId2" accountToken:@"testAccountToken2"];
    CTCustomTemplatesManager *managerWithNewConfig = [[CTCustomTemplatesManager alloc] initWithConfig:config2];
    
    XCTAssertTrue([managerWithNewConfig existsTemplateWithName:templateName1]);
    XCTAssertTrue([managerWithNewConfig existsTemplateWithName:templateName2]);
    XCTAssertTrue([managerWithNewConfig existsTemplateWithName:functionName1]);
    XCTAssertTrue([managerWithNewConfig existsTemplateWithName:functionName2]);
    
    XCTAssertFalse([managerWithNewConfig existsTemplateWithName:@"non-existent"]);
}

- (void)testDuplicateTemplateNameThrows {
    NSMutableSet *templates = [NSMutableSet set];
    CTInAppTemplateBuilder *templateBuilder = [CTInAppTemplateBuilder new];
    [templateBuilder setName:@"Template 1"];
    [templateBuilder setOnPresentWithPresenter:[CTTemplatePresenterMock new]];
    [templates addObject:[templateBuilder build]];
    CTTestTemplateProducer *producer = [[CTTestTemplateProducer alloc] initWithTemplates:templates];
    
    [CTCustomTemplatesManager registerTemplateProducer:producer];
    [CTCustomTemplatesManager registerTemplateProducer:producer];
    
    CleverTapInstanceConfig *config = [[CleverTapInstanceConfig alloc] initWithAccountId:@"testAccountId" accountToken:@"testAccountToken"];
    XCTAssertThrows([[CTCustomTemplatesManager alloc] initWithConfig:config]);
}

@end