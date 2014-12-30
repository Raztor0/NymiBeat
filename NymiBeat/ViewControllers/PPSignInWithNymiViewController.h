//
//  PPSignInWithNymiViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPSignInWithNymiDiscoveryModeViewController.h"
#import "PPSignInWithNymiPatternViewController.h"
#import "NclWrapper.h"

@interface PPSignInWithNymiViewController : UIViewController <PPSignInWithNymiDiscoveryModeViewControllerDelegate, PPSignInWithNymiPatternViewControllerDelegate, NclEventProtocol>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
