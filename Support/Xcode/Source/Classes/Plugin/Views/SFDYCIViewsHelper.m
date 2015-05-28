//
// Created by Paul Taykalo on 11/1/14.
//

#import <AppKit/AppKit.h>
#import "SFDYCIViewsHelper.h"
#import "SFDYCIResultView.h"


@implementation SFDYCIViewsHelper

- (void)showSuccessResult {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showResultViewWithSuccess:YES];
    });
}

- (void)showError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{

        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to inject code"];
        [alert setInformativeText:[error localizedDescription]];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showResultViewWithSuccess:NO];
    });
}


- (void)showResultViewWithSuccess:(BOOL)success {
    SFDYCIResultView *resultView = [[SFDYCIResultView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    resultView.success = success;

    // Adding result view on window
    [[[NSApp keyWindow] contentView] addSubview:resultView];

    // Performing animations
    resultView.alphaValue = 0.0;

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {

        context.duration = 1;
        [[resultView animator] setAlphaValue:1.0];

    }                   completionHandler:^{

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 1;
            [[resultView animator] setAlphaValue:0.0];
        }                   completionHandler:^{
            [resultView removeFromSuperview];
        }];
    }];
}


@end