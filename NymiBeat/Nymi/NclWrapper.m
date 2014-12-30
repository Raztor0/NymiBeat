//
//  NclWrapper.m
//  iOSBasicExample
//
//  Created by Dave Rai on 2014-10-31.
//  Copyright (c) 2014 Nymi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "NclWrapper.h"


NclEvent currentNclEvent;
NclProvision currentProvision;

@interface NclWrapper ()

@property (nonatomic, weak) id<NclEventProtocol> delegate;
@property (nonatomic, assign) NclEventType waitOnEventType;
@property (nonatomic, assign) BOOL correctNclEventReceived;

@end

@implementation NclWrapper

// Call back function used to communicate with the NCL
// passed as a parameter during NCL initialize
void callback(NclEvent event, void* userData);

- (void)setNclDelegate:(id<NclEventProtocol>)nclDelegate {
    if (!self.delegate) {
        // Use nclSetIpAndPort for local testing with the Nymulator
        // when testing with a real iOS device and a nymulator - make sure the IP address is of the machine running the nymulator
        nclSetIpAndPort("127.0.0.1", 9089);         // Comment this line out when using a real Nymi device
        
        // set the delegate before the init call (possible to get the callback prior to actually completing setting the delegate)
        self.delegate = nclDelegate;
        
        // Initialize NCL
        // NCL_MODE_DEV should be changed to NCL_MODE_DEFAULT for testing with actual Nymi device
        NclBool result = nclInit(callback, (__bridge void*)self, "iOS NCL Wrapper", NCL_MODE_DEV, self.errorStream);
        
        // NCL will return non-zero value if initialization call succesful
        // Once NCL is initialized, there will be an event (see event handling in this example)
        if (!result) {
            NSLog(@"FAILURE DURING nclInit");
        }
        else {
            NSLog(@"nclInit returned success, waiting for initialize event from NCL");
        }
    }
}

- (void)setEventTypeToWaitFor:(NclEventType)eventType {
    self.correctNclEventReceived = NO;
    self.waitOnEventType = eventType;
}


- (void)waitNclForEvent {
    if (!self.correctNclEventReceived) {
        [self performSelector:@selector(waitNclForEvent) withObject:nil afterDelay:0.5];
    }
}

// NCL functionality - asynchronous calls to NCL
// results are via callback
- (void) discoverNymiBand
{
    NclBool returnCode;
    returnCode = nclStartDiscovery();
    NSLog(@"Return Code from Discovery %d", returnCode);
}

- (void) agreeNymiBand: (int) withHandle
{
    nclAgree(withHandle);
}

- (void) provisionNymiBand: (int) withHandle
{
    nclProvision(withHandle, NCL_TRUE);
}

- (void) findNymiBand
{
    nclStartFinding(&currentProvision, 1, FALSE);
    
}

- (void) validateNymiBand: (int) withHandle
{
    nclValidate(withHandle);
}

- (void) disconnectNymiBand: (int) withHandle{
    nclDisconnect(withHandle);
}


- (void) stopScan
{
    nclStopScan();
}



// This is the main event handling function for NCL
// NCL generates events with a type and data. In addition, the original user data is returned.
// In this example - the pointer to this view controler was passed when nclInit was called

void callback(NclEvent event, void* userData) {
    
    // Convert userData from a C pointer to Objective-C pointer back to the view from where NCL was initialized
    NclWrapper* wrapper = (__bridge NclWrapper*)userData;
    
    // Listen for events
    switch(event.type){
        case NCL_EVENT_ERROR: {
            NSLog(@"NCL_EVENT_ERROR");
            break;
        }
            
        case NCL_EVENT_INIT: {
            NSLog(@"%@", [NSString stringWithFormat: @"NCL_EVENT_INIT %s", event.init.success ? "success" : "failure"]);
            
            break;
        }
            
        case NCL_EVENT_DISCOVERY: {
            NSLog(@"NCL_EVENT_DISCOVERY RRSI: %d", event.discovery.rssi);
            NSLog(@"%@", [NSString stringWithFormat: @"NCL_EVENT_DISCOVERY Nymi handle: %d", event.discovery.nymiHandle]);
            
            break;
            
        } case NCL_EVENT_FIND: {
            NSLog(@"NCL_EVENT_FIND RRSI: %d", event.find.rssi);
            NSLog(@"NCL_EVENT_FIND provision id: %@", provisionIdToString (event.find.provisionId));
            NSLog(@"NCL_EVENT_FIND nymiHandle: %d", event.find.nymiHandle);
            
            break;
            
        } case NCL_EVENT_AGREEMENT: {
            NSLog(@"%@", [NSString stringWithFormat:
                          @"NCL_EVENT_AGREE Nymi handle: %d LEDs: %d%d%d%d%d %d%d%d%d%d",
                          event.agreement.nymiHandle,
                          event.agreement.leds[0][0],
                          event.agreement.leds[0][1],
                          event.agreement.leds[0][2],
                          event.agreement.leds[0][3],
                          event.agreement.leds[0][4],
                          event.agreement.leds[1][0],
                          event.agreement.leds[1][1],
                          event.agreement.leds[1][2],
                          event.agreement.leds[1][3],
                          event.agreement.leds[1][4]]);
            
            break;
        }
            
        case NCL_EVENT_PROVISION:{
            NSLog(@"%@", [NSString stringWithFormat: @"NCL_EVENT_PROVISION Nymi handle: %d", event.provision.nymiHandle]);
            NSLog(@"%@", [NSString stringWithFormat: @"NCL_EVENT_PROVISION Nymi provision key: %@", provisionIdToString(event.provision.provision.key)]);
            NSLog(@"%@", [NSString stringWithFormat: @"NCL_EVENT_PROVISION Nymi provision id: %@", provisionIdToString(event.provision.provision.id)]);
            
            currentProvision = event.provision.provision;
            
            break;
        }
        case NCL_EVENT_VALIDATION: {
            NSLog(@"%@",  [NSString stringWithFormat:
                           @"NCL_EVENT_VALIDATION Nymi handle: %d",
                           event.validation.nymiHandle
                           ]);
            break;
        }
            
        case NCL_EVENT_DISCONNECTION: {
            NSLog(@"%@",  [NSString stringWithFormat:
                           @"NCL_EVENT_DISCONNECTION Nymi handle: %d reason: %@",
                           event.disconnection.nymiHandle,
                           [NclWrapper disconnectionReasonToString:event.disconnection.reason]
                           ]);
            break;
        }
        case NCL_EVENT_ECG: {
            NSLog(@"%@",  [NSString stringWithFormat:
                           @"NCL_EVENT_ECG Nymi handle: %d samples: %d %d %d %d %d %d %d %d",
                           event.ecg.nymiHandle,
                           event.ecg.samples[0],
                           event.ecg.samples[1],
                           event.ecg.samples[2],
                           event.ecg.samples[3],
                           event.ecg.samples[4],
                           event.ecg.samples[5],
                           event.ecg.samples[6],
                           event.ecg.samples[7]
                           ]);
            break;
        }
        case NCL_EVENT_RSSI: {
            NSLog(@"%@",  [NSString stringWithFormat:
                           @"NCL_EVENT_RSSI Nymi handle: %d RSSI: %d",
                           event.rssi.nymiHandle,
                           event.rssi.rssi
                           ]);
            break;
        }
        default: {
            break;
        }
    }
    
    if (event.type == wrapper.waitOnEventType) {
        wrapper.correctNclEventReceived = YES;
        if ([wrapper.delegate respondsToSelector:@selector(incomingNclEvent:)]) {
            [wrapper.delegate incomingNclEvent:event];
        }
    }
}

// helper methods
// more helper functions
NSString* provisionIdToString(NclProvisionId provisionId){
    NSMutableString* result=[[NSMutableString alloc] init];
    for(unsigned i=0; i<NCL_PROVISION_ID_SIZE; ++i)
        [result appendFormat: @"%x ", provisionId[i]];
    return result;
}

+ (NSString*)disconnectionReasonToString:(NclDisconnectionReason)reason {
    switch(reason){
        case NCL_DISCONNECTION_LOCAL:
            return @"NCL_DISCONNECTION_LOCAL";
        case NCL_DISCONNECTION_TIMEOUT:
            return @"NCL_DISCONNECTION_TIMEOUT";
        case NCL_DISCONNECTION_FAILURE:
            return @"NCL_DISCONNECTION_FAILURE";
        case NCL_DISCONNECTION_REMOTE:
            return @"NCL_DISCONNECTION_REMOTE";
        case NCL_DISCONNECTION_CONNECTION_TIMEOUT:
            return @"NCL_DISCONNECTION_CONNECTION_TIMEOUT";
        case NCL_DISCONNECTION_LL_RESPONSE_TIMEOUT:
            return @"NCL_DISCONNECTION_LL_RESPONSE_TIMEOUT";
        case NCL_DISCONNECTION_OTHER:
            return @"NCL_DISCONNECTION_OTHER";
        default: break;
    }
    return @"invalid disconnection reason, something bad happened";
}

@end