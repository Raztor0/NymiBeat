#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPSignInWithNymiViewController.h"


SPEC_BEGIN(PPSignInWithNymiViewControllerSpec)

__block PPSignInWithNymiViewController *subject;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    subject = [injector getInstance:[PPSignInWithNymiViewController class]];
    [subject view];
});

describe(@"NclEventProtocol", ^{
    context(@"on init failure", ^{
        __block NclEvent event;
        beforeEach(^{
            event.type = NCL_EVENT_INIT;
            
            NclEventInit init;
            init.success = NO;
            event.init = init;
        });
        
        it(@"should dismiss itself", ^{
            [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
            [subject incomingNclEvent:event];
        });
    });
});

SPEC_END