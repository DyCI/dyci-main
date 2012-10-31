//
//  DCIViewController.m
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DCIViewController.h"
#import "UIView+SFAdditions.h"

@interface DCIViewController ()<UIWebViewDelegate>

@end

@implementation DCIViewController {

   UILabel * _textLabel;
   UILabel * _topLabel;
   UILabel * _bottomLabel;

}

- (void)updateOnClassInjection {
   [self recreateGUI];
}

- (void)updateOnResourceInjection:(NSString *)resourcePath {
   [self recreateGUI];
}


- (NSUInteger)supportedInterfaceOrientations {
   return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
}


- (void)recreateGUI {
   NSArray * subviews = [[self view] subviews];
   for (UIView * v in subviews) {
      [v removeFromSuperview];
   }

   [[self view] setBackgroundColor:[UIColor whiteColor]];

   _textLabel = [UILabel new];
   _textLabel.numberOfLines = 0;
   _textLabel.text = @"Итиить колотить\n\n\n:)";
   [_textLabel setBackgroundColor:[UIColor blueColor]];




   [self updateTextLabel:_textLabel];
   _textLabel.textAlignment = UITextAlignmentCenter;
   _textLabel.alpha = 1;
   
   [_textLabel sizeToFit];
   _textLabel.center = self.view.center;
   [[self view] addSubview:_textLabel];

   _topLabel = [UILabel new];
   _topLabel.text = [NSString stringWithFormat:@"%f", _textLabel.top];
   [_topLabel sizeToFit];
   _topLabel.center = self.view.center;
   _topLabel.backgroundColor = [UIColor blueColor];
   _topLabel.top = 0;
   _topLabel.height = _textLabel.top;
   [[self view] addSubview:_topLabel];

   _bottomLabel = [UILabel new];
   CGFloat bottomLabelHeight = self.view.height - _textLabel.bottom;
   _bottomLabel.text = [NSString stringWithFormat:@"%f", bottomLabelHeight];
   [_bottomLabel setBackgroundColor:[UIColor redColor]];
   [_bottomLabel sizeToFit];
   _bottomLabel.center = self.view.center;
   _bottomLabel.top = _textLabel.bottom;
   _bottomLabel.alpha = 0.5;
   _bottomLabel.height = bottomLabelHeight + 20;
   [[self view] addSubview:_bottomLabel];

   UIImage * image = [UIImage imageNamed:@"Default"];
   UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
   imageView.width = 100;
   imageView.height = 100;
   [[self view] addSubview:imageView];

//   UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//   webView.delegate = self;
//   webView.width = self.view.width;
//   webView.height = self.view.height;
//   webView.alpha = 0.5;
//   [webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithString:@"http://stanfy.com.ua"]]];
//   [[self view] addSubview:webView];

//   UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//   [button setTitle:@"COOL" forState:UIControlStateNormal];
//   button.width = 200;
//   button.height = 100;
//   [button addTarget:self action:@selector(cool) forControlEvents:UIControlEventTouchUpInside];
//   [[self view] addSubview:button];


}


- (void)cool {
  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"COOL?"
                                                       message:@"COOL!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil];
   [alertView show];
}


- (void)updateTextLabel:(UILabel *)label {
   label.layer.cornerRadius = 1;
   label.shadowColor = [UIColor yellowColor];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
   NSLog(@"Web view finished to load");
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   NSLog(@"%s", sel_getName(_cmd));
   return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
   NSLog(@"%s", sel_getName(_cmd));
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
   NSLog(@"%s", sel_getName(_cmd));
}


@end
