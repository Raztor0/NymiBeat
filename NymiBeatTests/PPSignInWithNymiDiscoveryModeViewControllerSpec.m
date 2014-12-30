#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPSignInWithNymiDiscoveryModeViewController.h"
#import "UIKit+PivotalSpecHelper.h"


SPEC_BEGIN(PPSignInWithNymiDiscoveryModeViewControllerSpec)

__block PPSignInWithNymiDiscoveryModeViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block id<PPSignInWithNymiDiscoveryModeViewControllerDelegate> delegate;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    delegate = [KWMock mockForProtocol:@protocol(PPSignInWithNymiDiscoveryModeViewControllerDelegate)];
    
    subject = [injector getInstance:[PPSignInWithNymiDiscoveryModeViewController class]];
    [subject setupWithDelegate:delegate];
    [subject view];
});

describe(@"tapping the continue button", ^{
    it(@"should notify the delegate", ^{
        [[(id)delegate should] receive:@selector(discoveryModeViewControllerDidTapContinueButton:) withArguments:subject, nil];
        [subject.continueButton tap];
    });
});

SPEC_END