//
//  DYCIViewController.m
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DYCIViewController.h"
#import "UIView+SFAdditions.h"

@interface DYCIViewController ()<UIWebViewDelegate>

@end


@implementation DYCIViewController {

   UILabel * _textLabel;
   UILabel * _topLabel;
   UILabel * _bottomLabel;

}




#pragma mark - View Controllers methods

- (void)viewDidLoad {
   [super viewDidLoad];
   [self createGUI];
}


- (NSUInteger)supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait;
}


- (void)createGUI {

   [[self view] setBackgroundColor:[UIColor whiteColor]];


   int textLabelWidth = 280;

   _textLabel = [UILabel new];
   _textLabel.numberOfLines = 0;
   _textLabel.alpha = 1;
   _textLabel.font = [UIFont boldSystemFontOfSize:12];
   [_textLabel setTextColor:[UIColor whiteColor]];
   [_textLabel setBackgroundColor:[UIColor clearColor]];
   _textLabel.text =
    @"Hi there!\n"
     "Seems you've been able to run DYCI project!\n"
     "Congratulations\n"
     "The most hard work is already done.\n"
     "First, make sure you're installed DYCI\n"
     "There will be no magic, if you don't\n"
     "But if you do...\n"
     "Open DYCIViewController.m\n"
     "Uncomment level #1 lines...\n"
     "And press ^X (Product|Recompile and inject) in Xcode";

   [_textLabel sizeToFit];
   _textLabel.width = textLabelWidth;
   _textLabel.center = self.view.center;
   [[self view] addSubview:_textLabel];



//   //Level #1
//   _textLabel.text =
//    @"If all went right\n"
//     "Then you were able to see small green dot\n"
//     "And this means that you can see this text\n"
//     "In your Iphone Simulator!\n"
//     "If not.. than make sure that you\n"
//     "Correctly installed DYCI\n"
//     "\n"
//     "Move to level #2";
//   [_textLabel sizeToFit];
//   _textLabel.width = textLabelWidth;
//   _textLabel.center = self.view.center;


//   // Level #2
//   _textLabel.text =
//    @"Level #2\n"
//     "You can add any code you want\n"
//     "All methods will be updated immediately\n"
//     "If you didn't uncommented webview delegate methods\n"
//     "Uncomment them and Inject your code again\n"
//     "\n"
//     "Move to level #3";
//   [_textLabel sizeToFit];
//   _textLabel.width = textLabelWidth;
//   _textLabel.center = self.view.center;
//
//   UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
//   webView.delegate = self;
//   webView.alpha = 0.5;
//   [webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithString:@"http://dyci.github.com/dyci-main/"]]];
//   webView.scalesPageToFit = YES;
//   [[self view] addSubview:webView];


//   // Level #3
//   _textLabel.text =
//    @"Level #3\n"
//     "There's one thing you need to know\n"
//     "You can add any code, and any methods\n"
//     "And all will be fine\n"
//     "Even debugger will understand that you're using new code\n"
//     "But there's a little problem with methods removing\n"
//     "Try to remove UIWebView delegate methods\n"
//     "\n"
//     "Move to level #4";
//   [_textLabel sizeToFit];
//   _textLabel.width = textLabelWidth;
//   _textLabel.center = self.view.center;


//   // Level #4
//   _textLabel.text =
//    @"Level #4\n"
//     "As you can see (hopefully)\n"
//     "Delegate methode are still being called\n"
//     "It's because of\n"
//     "One does not simply remove methods in Objective-C 2.0\n"
//     "If you know how to do it:)\n"
//     "You can find us on Github\n"
//     "In the \"worst\" case.. Just start your app again:)"
//     "\n"
//     "That's all folks! Have fun with dyci:)!";
//   [_textLabel sizeToFit];
//   _textLabel.width = textLabelWidth;
//   _textLabel.center = self.view.center;


   UIView * textLabelMessageBackground = [UIView new];
   textLabelMessageBackground.layer.cornerRadius = 10;
   [textLabelMessageBackground setBackgroundColor:[UIColor blackColor]];
   textLabelMessageBackground.frame = UIEdgeInsetsInsetRect(_textLabel.frame, UIEdgeInsetsMake(-10, -10, -10, -10));
   [[self view] insertSubview:textLabelMessageBackground belowSubview:_textLabel];

}


//// Level #2
//#pragma  mark - UIWebView Delegate
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//   NSLog(@"Web view finished to load");
//}
//
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//   NSLog(@"%s", sel_getName(_cmd));
//   return YES;
//}
//
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//   NSLog(@"%s", sel_getName(_cmd));
//}
//
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//   NSLog(@"%s", sel_getName(_cmd));
//}



#pragma mark - DYCI Support

/*
These methods
- (void)updateOnClassInjection
- (void)updateOnResourceInjection:(NSString *)resourcePath

Will be called on EACH instance of this class (DYCIViewController) when new class logic will be available
Actually in case, if you can each time recreate new object, you don't need these two methods
But, it case, if you need to update objects that are ALREADY in memory, you should use the,

 */
- (void)updateOnClassInjection {

   // "Emulating" viewDidLoad method
   // Cleaning up all views and
   NSArray * subviews = [[self view] subviews];
   for (UIView * v in subviews) {
      [v removeFromSuperview];
   }

   [self createGUI];
}


- (void)updateOnResourceInjection:(NSString *)resourcePath {

   // "Emulating" viewDidLoad method
   // Cleaning up all views and
   NSArray * subviews = [[self view] subviews];
   for (UIView * v in subviews) {
      [v removeFromSuperview];
   }

   [self createGUI];
}


@end
