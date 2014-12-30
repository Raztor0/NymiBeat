//
//  PPSignInWithNymiPatternViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-29.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSignInWithNymiPatternViewController.h"
#import "PPStoryboardNames.h"

@interface PPSignInWithNymiPatternViewController ()

@property (nonatomic, strong) NSArray *nymiPattern;
@property (nonatomic, strong) NSMutableArray *patternArray;

@property (nonatomic, weak) id<PPSignInWithNymiPatternViewControllerDelegate> delegate;

@end

@implementation PPSignInWithNymiPatternViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"patternArray", nil];
    [properties bindProperty:@"patternArray" toKey:[NSMutableArray class]];
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
    
    self.patternArray = [NSMutableArray arrayWithArray:@[
                                                         [NSNumber numberWithBool:NO],
                                                         [NSNumber numberWithBool:NO],
                                                         [NSNumber numberWithBool:NO],
                                                         [NSNumber numberWithBool:NO],
                                                         [NSNumber numberWithBool:NO],
                                                         ]];
}

- (void)setupWithPattern:(NSArray*)nymiPattern delegate:(id<PPSignInWithNymiPatternViewControllerDelegate>)delegate {
    self.nymiPattern = nymiPattern;
    self.delegate = delegate;
}

#pragma mark - IBActions

- (IBAction)didPressDotButton:(UIButton*)button {
    NSUInteger patternIndex = 0;
    if(button == self.dotButton1) {
        patternIndex = 0;
    } else if(button == self.dotButton2) {
        patternIndex = 1;
    } else if(button == self.dotButton3) {
        patternIndex = 2;
    } else if(button == self.dotButton4) {
        patternIndex = 3;
    } else if(button == self.dotButton5) {
        patternIndex = 4;
    } else {
        NSAssert(NO, @"Invalid pattern button pressed");
    }
    
    BOOL dotState = [[[self patternArray] objectAtIndex:patternIndex] boolValue];
    self.patternArray[patternIndex] = [NSNumber numberWithBool:!dotState];
    
    [self checkPattern];
}

- (void)checkPattern {
    BOOL patternIsCorrect = YES;
    for(int i = 0; i < [self.nymiPattern count]; i++) {
        BOOL userPattern = [[self.patternArray objectAtIndex:i] boolValue];
        BOOL nymiPattern = [[self.nymiPattern objectAtIndex:i] boolValue];
        if(userPattern != nymiPattern) {
            patternIsCorrect = NO;
            break;
        }
    }
    
    if(patternIsCorrect) {
        [self.delegate patternViewControllerDidEnterCorrectPattern:self];
    }
}

@end
