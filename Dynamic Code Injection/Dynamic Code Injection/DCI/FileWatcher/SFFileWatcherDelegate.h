//
//  SFFileWatcherDelegate.h
//  Dynamic Code Injection
//
//  Created by adenisov on 16.10.12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SFFileWatcherDelegate<NSObject>

@optional

- (void)newFileWasFoundAtPath:(NSString *)filePath;

@end
