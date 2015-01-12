//
//  DVSChangePasswordViewSpec.m
//  Devise
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SPEC_BEGIN(DVSChangePasswordViewSpec)

describe(@"tapping save button", ^{
    
    void (^tapSaveAndWaitForError)() = ^void() {
        [tester tapViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Save")];
        [tester dvs_waitForErrorView];
        [tester dvs_closeErrorPopup];
    };
    
    __block id<OHHTTPStubsDescriptor> stub = nil;
    
    beforeAll(^{
        stub = [OHHTTPStubs dvs_stubUserChangePasswordRequestsWithOptions:nil];
        [tester dvs_login];
        
    });
    
    afterAll(^{
        [OHHTTPStubs removeStub:stub];
        [tester dvs_tapLogOutButton];
    });
    
    beforeEach(^{
        [tester tapViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Change password")];
        [tester waitForViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Current password field")];
    });
    
    afterEach(^{
        [tester tapViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Home")];
        [tester waitForViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Change password")];
    });
    
    it(@"should show error message when current password field is empty", ^{
        tapSaveAndWaitForError();
    });
    
    context(@"when current password field don't match", ^{
        
        beforeEach(^{
            [tester enterText:@"$eC" intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Current password field")];
        });
        
        it(@"should show error message", ^{
            tapSaveAndWaitForError();
        });
    });
    
    context(@"when new password is empty", ^{
        
        beforeEach(^{
            [tester enterText:DVSValidPassword intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Current password field")];
        });
        
        it(@"should show error message", ^{
            tapSaveAndWaitForError();
        });
    });
    
    context(@"when provide new password", ^{
        
        beforeEach(^{
            [tester enterText:DVSValidPassword intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Current password field")];
            [tester enterText:@"n3w_pa$$word" intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"New password field")];
        });
        
        it(@"should show error if password not confirmed", ^{
            tapSaveAndWaitForError();
        });
        
        it(@"should show error if password confirm don't match", ^{
            [tester enterText:@"not_n3w_pa$$word" intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Confirm password field")];
            tapSaveAndWaitForError();
        });
        
    });
    
    context(@"when all fields are valid", ^{
        
        beforeEach(^{
            [tester enterText:DVSValidPassword intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Current password field")];
            [tester enterText:@"n3w_pa$$word" intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"New password field")];
            [tester enterText:@"n3w_pa$$word" intoViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Confirm password field")];
        });
        
        it(@"should show success message", ^{
            [tester tapViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Save")];
            [tester waitForViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Password changed")];
            [tester tapViewWithAccessibilityLabel:DVSAccessibilityLabel(@"Close")];
        });
    });
});

SPEC_END