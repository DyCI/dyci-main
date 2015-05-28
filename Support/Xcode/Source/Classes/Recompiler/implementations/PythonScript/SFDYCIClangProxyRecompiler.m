//
// SFDYCIClangProxyRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "SFDYCIClangProxyRecompiler.h"
#import "DYCI_CCPXCodeConsole.h"


@interface SFDYCIClangProxyRecompiler ()
@property(nonatomic, strong) DYCI_CCPXCodeConsole *console;
@end

@implementation SFDYCIClangProxyRecompiler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    }

    return self;
}


- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError * error))completionBlock {
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/python"];

    [task setCurrentDirectoryPath:self.dyciRecompilerDirectoryPath];

    NSArray * arguments = @[self.dyciRecompilerPath, [fileURL path]];
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
        NSString * outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if (outputString && [outputString length]) {
            [self.console debug:[NSString stringWithFormat:@"script returned OK:\n%@", outputString]];
        }

        NSData * errorData = [errorFile readDataToEndOfFile];
        NSString * errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        if (errorString && [errorString length]) {
            [self.console debug:[NSString stringWithFormat:@"script returned ERROR:\n%@", errorString]];
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

- (NSString *)dyciRecompilerDirectoryPath {
    NSString * dyciDirectoryPath = [@"~" stringByExpandingTildeInPath];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@".dyci"];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@"scripts"];
    return dyciDirectoryPath;
}


- (NSString *)dyciRecompilerPath {
    return [self.dyciRecompilerDirectoryPath stringByAppendingPathComponent:@"dyci-recompile.py"];
}


#pragma mark - SFDYCIRecompilerProtocol

- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL {
    return YES;
}


- (DYCI_CCPXCodeConsole *)console {
    if (!_console) {
        _console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    }
    return _console;
}


@end