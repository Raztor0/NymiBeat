#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPSignInWithNymiPatternViewController.h"
#import "UIKit+PivotalSpecHelper.h"

SPEC_BEGIN(PPSignInWithNymiPatternViewControllerSpec)

__block PPSignInWithNymiPatternViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block id<PPSignInWithNymiPatternViewControllerDelegate> delegate;
__block NSArray *nymiPattern;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    subject = [injector getInstance:[PPSignInWithNymiPatternViewController class]];
    
    delegate = [KWMock mockForProtocol:@protocol(PPSignInWithNymiPatternViewControllerDelegate)];
    nymiPattern = @[
                    [NSNumber numberWithBool:YES],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:YES],
                    [NSNumber numberWithBool:YES],
                    ];
    [subject setupWithPattern:nymiPattern delegate:delegate];
    
    [subject view];
});

describe(@"PPSignInWithNymiPatternViewControllerDelegate", ^{
    context(@"when the user enters the correct pattern", ^{
        it(@"should notify the delegate", ^{
            [[(id)delegate should] receive:@selector(patternViewControllerDidEnterCorrectPattern:)];
            [subject.dotButton1 tap];
            [subject.dotButton4 tap];
            [subject.dotButton5 tap];
        });
    });
});

SPEC_END