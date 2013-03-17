//
//  IEViewController.m
//  StoryboardInjectionExample
//
//  Created by Paul Taykalo on 3/17/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import "IEViewController.h"

@interface IEViewController ()

@end

@implementation IEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   NSLog(@"Current Label : %@", self.label);
   NSLog(@"Labale text : %@", self.label.text);
   
}

@end
