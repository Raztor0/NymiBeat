//
//  PPSignInWithNymiViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSignInWithNymiViewController.h"
#import "PPStoryboardNames.h"
#import "UIView+ConstraintHelpers.h"


@interface PPSignInWithNymiViewController ()

@property (nonatomic, strong) PPSignInWithNymiDiscoveryModeViewController *discoveryModeViewController;
@property (nonatomic, strong) PPSignInWithNymiPatternViewController *patternViewController;
@property (nonatomic, strong) NclWrapper *nclWrapper;

@property (nonatomic, assign) int nymiHandle;

@property (nonatomic, assign) BOOL nymiBandProvisioned;

@end

@implementation PPSignInWithNymiViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"discoveryModeViewController", @"patternViewController", @"nclWrapper", nil];
    [properties bindProperty:@"discoveryModeViewController" toKey:[PPSignInWithNymiDiscoveryModeViewController class]];
    [properties bindProperty:@"patternViewController" toKey:[PPSignInWithNymiPatternViewController class]];
    [properties bindProperty:@"nclWrapper" toKey:[NclWrapper class]];
    return properties;
}

+ (BSInitializer *)bsInitializer {
    return [BSInitializer initializerWithClass:self
                                 classSelector:@selector(controllerWithInjector:)
                                  argumentKeys:
            @protocol(BSInjector),
            nil];
}

+ (instancetype)controllerWithInjector:(id<BSInjector>)injector {
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPSignInWithNymiStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.discoveryModeViewController setupWithDelegate:self];
    [self addChildViewController:self.discoveryModeViewController];
    [self.scrollView addSubview:self.discoveryModeViewController.view];
    [self.discoveryModeViewController didMoveToParentViewController:self];
    
//    [self addChildViewController:self.patternViewController];
//    [self.scrollView addSubview:self.patternViewController.view];
//    [self.patternViewController didMoveToParentViewController:self];
    
    //    [self.scrollView constrainHorizontallyToFitSuperview:self.discoveryModeViewController.view];
    //    [self.scrollView constrainRightOfView:self.discoveryModeViewController.view toLeftOfView:self.patternViewController.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.nclWrapper setEventTypeToWaitFor:NCL_EVENT_INIT];
    [self.nclWrapper setNclDelegate:self];
    [self.nclWrapper waitNclForEvent];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height);

    
}

#pragma mark - NclEventProtocol

- (void)incomingNclEvent:(NclEvent)nclEvent {
    if (!self.nymiBandProvisioned) {
        switch (nclEvent.type) {
            case NCL_EVENT_INIT: {
                // initialized, event, have to check it if it was successful before we move to discovery
                if (nclEvent.init.success) {
                    [self.nclWrapper setEventTypeToWaitFor:NCL_EVENT_DISCOVERY];
                    [self.nclWrapper discoverNymiBand];
                    [self.nclWrapper waitNclForEvent];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        NSLog(@"error: %d", nclGetErrorCode());
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error initializing the NCL. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                    });
                }
                break;
            }
                
            case NCL_EVENT_DISCOVERY: {
                [self.nclWrapper
                 setEventTypeToWaitFor:NCL_EVENT_AGREEMENT];
                [self.nclWrapper agreeNymiBand:(nclEvent.discovery.nymiHandle)];
                [self.nclWrapper waitNclForEvent];
                break;
            }
                
            case NCL_EVENT_AGREEMENT: {
                self.nymiHandle = nclEvent.agreement.nymiHandle;
                NSArray *nymiPattern = @[
                                         [NSNumber numberWithBool:nclEvent.agreement.leds[0][0]],
                                         [NSNumber numberWithBool:nclEvent.agreement.leds[0][1]],
                                         [NSNumber numberWithBool:nclEvent.agreement.leds[0][2]],
                                         [NSNumber numberWithBool:nclEvent.agreement.leds[0][3]],
                                         [NSNumber numberWithBool:nclEvent.agreement.leds[0][4]],
                                         ];
                
                [self.patternViewController setupWithPattern:nymiPattern delegate:self];
                
                [self.scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
                break;
            }
                
            case NCL_EVENT_PROVISION: {
                //                [self updateUiText:(@"Nymi Band provisioned\nTap Nymi button to move to validate steps\n")];
                [self.nclWrapper disconnectNymiBand:(nclEvent.provision.nymiHandle)];
                self.nymiBandProvisioned = YES;
                
                // the NEA should persist the provsion, for this simple example, the NCL wrapper keeps the current provision
                // it is used to find the same Nymi Band on subsequent calls
                break;
            }
            default:
                break;
        }
    }
    
    else { // if already provisioned, we just have to find the nymi and validate
        switch (nclEvent.type) {
            case NCL_EVENT_FIND: {
                [self.nclWrapper setEventTypeToWaitFor:NCL_EVENT_VALIDATION];
                [self.nclWrapper validateNymiBand:(nclEvent.find.nymiHandle)];
                [self.nclWrapper waitNclForEvent];
                [self.nclWrapper stopScan];
                break;
            }
                
            case NCL_EVENT_VALIDATION: {
                [self.nclWrapper disconnectNymiBand:(nclEvent.validation.nymiHandle)];
                break;
            }
            default: {
                break;
            }
        }
    }
}

#pragma mark - PPSignInWithNymiDiscoveryModeViewControllerDelegate

- (void)discoveryModeViewControllerDidTapContinueButton:(PPSignInWithNymiDiscoveryModeViewController *)viewController {
    
}

#pragma mark - PPSignInWithNymiPatternViewControllerDelegate

- (void)patternViewControllerDidEnterCorrectPattern:(PPSignInWithNymiPatternViewController *)viewController {
    [self.nclWrapper setEventTypeToWaitFor:NCL_EVENT_PROVISION];
    [self.nclWrapper provisionNymiBand:(self.nymiHandle)];
    [self.nclWrapper waitNclForEvent];
}

@end
