//
//  CTCustomTemplateInAppDataTest.m
//  CleverTapSDKTests
//
//  Created by Nikola Zagorchev on 10.05.24.
//  Copyright © 2024 CleverTap. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CTCustomTemplateInAppData.h"
#import "CTInAppNotification.h"
#import "CTConstants.h"

@interface CTCustomTemplateInAppDataTest : XCTestCase

@end

@implementation CTCustomTemplateInAppDataTest

- (void)testCreateWithJSON {
    NSDictionary *json = @{
        CLTAP_INAPP_TEMPLATE_ID: @"templateId",
        CLTAP_INAPP_TEMPLATE_NAME: @"templateName",
        CLTAP_INAPP_TYPE: @"custom-code",
        CLTAP_INAPP_TEMPLATE_DESCRIPTION: @"templateDescription",
        CLTAP_INAPP_VARS: @{
            @"key1": @"value1",
            @"key2": @"value2"
        }
    };
    CTCustomTemplateInAppData *customTemplate = [CTCustomTemplateInAppData createWithJSON:json];
    
    XCTAssertEqualObjects(customTemplate.templateName, @"templateName");
    XCTAssertEqualObjects(customTemplate.templateId, @"templateId");
    XCTAssertEqualObjects(customTemplate.templateDescription, @"templateDescription");
    XCTAssertEqualObjects(customTemplate.args, (@{
        @"key1": @"value1",
        @"key2": @"value2"
    }));
}

- (void)testCreateWithJSONNotCustomCode {
    NSDictionary *json = @{
        CLTAP_INAPP_TEMPLATE_ID: @"templateId",
        CLTAP_INAPP_TEMPLATE_NAME: @"templateName",
        CLTAP_INAPP_TYPE: @"interstitial",
        CLTAP_INAPP_TEMPLATE_DESCRIPTION: @"templateDescription",
        CLTAP_INAPP_VARS: @{
            @"key1": @"value1",
            @"key2": @"value2"
        }
    };
    CTCustomTemplateInAppData *customTemplate = [CTCustomTemplateInAppData createWithJSON:json];
    XCTAssertNil(customTemplate);
}

- (void)testCreateWithJSONNoType {
    NSDictionary *json = @{
        CLTAP_INAPP_TEMPLATE_ID: @"templateId",
        CLTAP_INAPP_TEMPLATE_NAME: @"templateName",
        CLTAP_INAPP_TEMPLATE_DESCRIPTION: @"templateDescription",
        CLTAP_INAPP_VARS: @{
            @"key1": @"value1",
            @"key2": @"value2"
        }
    };
    CTCustomTemplateInAppData *customTemplate = [CTCustomTemplateInAppData createWithJSON:json];
    XCTAssertNil(customTemplate);
}

- (void)testCreateFromInAppNotification {
    NSDictionary *json = @{
        @"templateDescription": @"",
        @"templateId": @"6633c400e2a2f07007c031a5",
        @"templateName": @"templateName",
        @"ti": @1715349815,
        @"type": @"custom-code",
        @"vars": @{
            @"number": @123,
            @"string": @"hello",
        },
        @"wzrk_id": @"1715349815_20240510"
    };
    
    CTInAppNotification *inApp = [[CTInAppNotification alloc] initWithJSON:json];
    CTCustomTemplateInAppData *customTemplateData = inApp.customTemplateInAppData;
    XCTAssertEqualObjects(customTemplateData.templateName, @"templateName");
    XCTAssertEqualObjects(customTemplateData.templateId, @"6633c400e2a2f07007c031a5");
    XCTAssertEqualObjects(customTemplateData.templateDescription, @"");
    XCTAssertEqualObjects(customTemplateData.args, (@{
        @"number": @123,
        @"string": @"hello",
    }));
}

@end