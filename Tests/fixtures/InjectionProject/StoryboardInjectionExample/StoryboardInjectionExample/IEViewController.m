//
//  IEViewController.m
//  StoryboardInjectionExample
//
//  Created by Paul Taykalo on 3/17/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import "IEViewController.h"

@interface UIViewController (Private)

- (void)updateOnResourceInjection:(NSString *)resource;

@end

@interface IEViewController ()

@end

@implementation IEViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"Start button frame : %@", NSStringFromCGRect(self.startButton.frame));
}


@end
