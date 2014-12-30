//
//  PPSignInWithNymiDiscoveryModeViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSignInWithNymiDiscoveryModeViewController.h"
#import "PPStoryboardNames.h"

@interface PPSignInWithNymiDiscoveryModeViewController ()

@property (nonatomic, weak) id<PPSignInWithNymiDiscoveryModeViewControllerDelegate> delegate;

@end

@implementation PPSignInWithNymiDiscoveryModeViewController

//+ (BSPropertySet *)bsProperties {
//    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"spinner", @"networkClient", nil];
//    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
//    [properties bindProperty:@"networkClient" toKey:[PPNetworkClient class]];
//    return properties;
//}

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
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Public

- (void)setupWithDelegate:(id<PPSignInWithNymiDiscoveryModeViewControllerDelegate>)delegate {
    self.delegate = delegate;
}

#pragma mark - IBActions

- (IBAction)didTapContinueButton:(UIButton *)sender {
    [self.delegate discoveryModeViewControllerDidTapContinueButton:self];
}

@end
