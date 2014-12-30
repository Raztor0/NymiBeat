//
//  PPSignInWithNymiPatternViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPSignInWithNymiPatternViewController;

@protocol PPSignInWithNymiPatternViewControllerDelegate <NSObject>
@required
- (void)patternViewControllerDidEnterCorrectPattern:(PPSignInWithNymiPatternViewController*)viewController;

@end

@interface PPSignInWithNymiPatternViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *dotButton1;
@property (weak, nonatomic) IBOutlet UIButton *dotButton2;
@property (weak, nonatomic) IBOutlet UIButton *dotButton3;
@property (weak, nonatomic) IBOutlet UIButton *dotButton4;
@property (weak, nonatomic) IBOutlet UIButton *dotButton5;

- (void)setupWithPattern:(NSArray*)nymiPattern delegate:(id<PPSignInWithNymiPatternViewControllerDelegate>)delegate;

@end
