//
// SFDYCIClangProxyRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "SFDYCIClangProxyRecompiler.h"


@implementation SFDYCIClangProxyRecompiler

- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError * error))completionBlock {
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/python"];
    NSString * dyciDirectoryPath = [@"~" stringByExpandingTildeInPath];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@".dyci"];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@"scripts"];

    [task setCurrentDirectoryPath:dyciDirectoryPath];

    NSString * dyciRecompile = [dyciDirectoryPath stringByAppendingPathComponent:@"dyci-recompile.py"];

    NSArray * arguments = [NSArray arrayWithObjects:dyciRecompile, [fileURL path], nil];
    [task setArguments:arguments];


    // Setting up pipes for standart and error outputs
    NSPipe * outputPipe = [NSPipe pipe];
    NSFileHandle * outputFile = [outputPipe fileHandleForReading];
    [task setStandardOutput:outputPipe];

    NSPipe * errorPipe = [NSPipe pipe];
    NSFileHandle * errorFile = [errorPipe fileHandleForReading];
    [task setStandardError:errorPipe];

    // Setting up termination handler
    [task setTerminationHandler:^(NSTask * tsk) {

        NSData * outputData = [outputFile readDataToEndOfFile];
        NSString * outputString = [[NSString alloc] initWithData:outputData
                                                        encoding:NSUTF8StringEncoding];
        if (outputString && [outputString length]) {
            NSLog(@"script returned OK:\n%@", outputString);
        }

        NSData * errorData = [errorFile readDataToEndOfFile];
        NSString * errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        if (errorString && [errorString length]) {
            NSLog(@"script returned ERROR:\n%@", errorString);
        }

        // TODO : Need to add correct notification if something went wrong
        if (tsk.terminationStatus != 0) {
            NSError * injectionError =
              [NSError errorWithDomain:@"com.stanfy.dyci" code:-1 userInfo:@{ NSLocalizedDescriptionKey : (errorString ?: @"<Unknown error>") }];
            if (completionBlock) {
                completionBlock(injectionError);
            }

        } else {
            if (completionBlock) {
                completionBlock(nil);
            }
        }

        tsk.terminationHandler = nil;

    }];


    // Starting task
    [task launch];

}

@end