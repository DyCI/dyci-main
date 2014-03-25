//
// SFDYCIXcodeRuntimeRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "SFDYCIXcodeRuntimeRecompiler.h"
#import "CDRSXcodeInterfaces.h"
#import "CDRSXcodeDevToolsInterfaces.h"
#import "SFDYCIXCodeHelper.h"


@implementation SFDYCIXcodeRuntimeRecompiler {

}

- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError * error))completionBlock {

    if ([self canRecompileFileAtURL:fileURL]) {

        SFDYCIXCodeHelper * xcode = [SFDYCIXCodeHelper instance];
        XC(PBXTarget) target = [xcode targetInOpenedProjectForFileURL:fileURL];
        if (!target) {
            // TODO : Custom error
            [self failWithError:nil completionBlock:completionBlock];
            return;
        }

        XC(PBXTargetBuildContext) buildContext = target.targetBuildContext;
        NSArray * commands = [buildContext commands];
        NSLog(@"Commands : %@", commands);
        [commands enumerateObjectsUsingBlock:^(XC(XCDependencyCommand) command, NSUInteger idx, BOOL *stop) {
            NSLog(@"Command #%lu of classs %@ : %@", idx, [(id)command class], command);

            NSArray * ruleInfo = [command ruleInfo];
            NSLog(@"Command : %@", ruleInfo);
            if ([[ruleInfo firstObject] isEqualToString: @"CompileC"]) {
                /**
                 * Commands can contain build rules for multiple file so
                 * make sure you got the right one.
                 */
                NSString *sourcefile_path = [ruleInfo objectAtIndex:2];
                if ( ! [sourcefile_path isEqualToString: fileURL.path]) {
                    return;
                }

                NSLog(@"Found command that was originally created this file. Rerunning it");
                NSLog(@"We should actually run %@ %@", command.commandPath, command.arguments);
                
                NSLog(@"Command tool specification : %@", [command toolSpecification]);
            }

            // Linker arguments
            if ([[ruleInfo firstObject] isEqualToString: @"Ld"]) {
                /*
                 * Xcode doesn't pass object files (.o) directly to the linker (it uses
                 * a dependency info file instead) so the only thing we can do here is to grab
                 * the linker arguments.
                 */
                NSLog(@"\nLinker: %@ %@", command.commandPath, command.arguments);
            }
        }];
//        {
//            NSArray *rule_info = [obj performSelector: NSSelectorFromString(@"ruleInfo")];
//            // Dump compiler arguments for the file
//            if ([[rule_info firstObject] isEqualToString: @"CompileC"]) {
//                /**
//                 * Commands can contain build rules for multiple file so
//                 * make sure you got the right one.
//                 */
//                NSString *sourcefile_path = [rule_info objectAtIndex: 2];
//                if ( ! [sourcefile_path isEqualToString: @"/Users/rodionovd/Documents/Job/HookBuildParametersPlugin/HookBuildParametersPlugin/HookBuildParametersPlugin.m"]) {
//                    return;
//                }
//                NSString *compiler_path  = [obj valueForKey: @"_commandPath"];
//                NSArray  *compiler_args  = [obj valueForKey: @"_arguments"];
//
//                NSLog(@"\nCompile file '%@' with command line:\n%@ %@",
//                  [sourcefile_path lastPathComponent], [compiler_path lastPathComponent],
//                  [compiler_args componentsJoinedByString:@" "]);
//            }
//            }
//        }];
        return;
    }

    // Fall back to previous recompiler
    [super recompileFileAtURL:fileURL completion:completionBlock];
}


- (void)failWithError:(NSError *)error completionBlock:(void (^)(NSError *))block {
  if (block) {
      block(error);
  }
}


- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL {
    NSString * filePath = [fileURL absoluteString];
    if ([[filePath pathExtension] isEqualToString:@"h"]) {
        filePath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m"];
    }

    if ([[filePath pathExtension] isEqualToString:@"m"]) {
        return YES;
    }

    return NO;
}

@end