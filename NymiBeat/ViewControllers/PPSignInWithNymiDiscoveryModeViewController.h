//
//  PPSignInWithNymiDiscoveryModeViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPSignInWithNymiDiscoveryModeViewController;

@protocol PPSignInWithNymiDiscoveryModeViewControllerDelegate <NSObject>
@required
- (void)discoveryModeViewControllerDidTapContinueButton:(PPSignInWithNymiDiscoveryModeViewController*)viewController;

@end

@interface PPSignInWithNymiDiscoveryModeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

- (void)setupWithDelegate:(id<PPSignInWithNymiDiscoveryModeViewControllerDelegate>)delegate;

@end
