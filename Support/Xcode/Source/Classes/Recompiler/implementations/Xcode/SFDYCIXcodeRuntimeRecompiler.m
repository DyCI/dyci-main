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
#import "DSUnixTask.h"
#import "DSUnixTaskSubProcessManager.h"
#import "SFDYCIErrorFactory.h"
#import "SFDYCIClangParamsExtractor.h"
#import "SFDYCIClangParams.h"


@interface SFDYCIXcodeRuntimeRecompiler ()

@property(nonatomic, strong) DSUnixTaskAbstractManager * taskManager;
@property(nonatomic, strong) SFDYCIClangParamsExtractor * clangParamsExtractor;

@end

@implementation SFDYCIXcodeRuntimeRecompiler

- (id)init {
    self = [super init];
    if (self) {
        self.taskManager =  [DSUnixTaskSubProcessManager sharedManager];
        self.clangParamsExtractor = [SFDYCIClangParamsExtractor new];
    }
    return self;
}


- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError *error))completionBlock {

    SFDYCIXCodeHelper *xcode = [SFDYCIXCodeHelper instance];
    XC(PBXTarget) target = [xcode targetInOpenedProjectForFileURL:fileURL];
    if (!target) {
        // TODO : Custom error
        [self failWithError:nil completionBlock:completionBlock];
        return;
    }

    XC(PBXTargetBuildContext) buildContext = target.targetBuildContext;
    NSArray *commands = [buildContext commands];
    NSLog(@"Commands : %@", commands);
    [commands enumerateObjectsUsingBlock:^(XC(XCDependencyCommand) command, NSUInteger idx, BOOL *stop) {
        NSLog(@"Command #%lu of classs %@ : %@", idx, [(id) command class], command);

        NSArray *ruleInfo = [command ruleInfo];
        NSLog(@"Command : %@", ruleInfo);
        if ([[ruleInfo firstObject] isEqualToString:@"CompileC"]) {
            /**
            * Commands can contain build rules for multiple file so
            * make sure you got the right one.
            */
            NSString *sourcefile_path = ruleInfo[2];
            if (![sourcefile_path isEqualToString:fileURL.path]) {
                return;
            }

            NSLog(@"Found command that was originally created this file. Rerunning it");
            NSLog(@"We should actually run %@ %@", command.commandPath, command.arguments);
            NSLog(@"Command tool specification : %@", [command toolSpecification]);

            [self runCompilationCommand:command completion:^(NSError *error) {
                if (error != nil) {
                    completionBlock(error);
                } else {
                    [self createDynamiclibraryWithCommand:command completion:completionBlock];
                }
            }];
            return;

        }

        // Linker arguments
        if ([[ruleInfo firstObject] isEqualToString:@"Ld"]) {
            /*
             * Xcode doesn't pass object files (.o) directly to the linker (it uses
             * a dependency info file instead) so the only thing we can do here is to grab
             * the linker arguments.
             */
            NSLog(@"\nLinker: %@ %@", command.commandPath, command.arguments);
        }
    }];

}


#pragma mark - Running command

- (void)runCompilationCommand:(id<CDRSXcode_XCDependencyCommand>)command completion:(void (^)(NSError *))completion {
    DSUnixTask * task = [self.taskManager task];
    [task setLaunchPath:command.commandPath];
    [task setArguments:command.arguments];
    [task setEnvironment:command.environment];
    [task setWorkingDirectory:command.workingDirectoryPath];

    [task setLaunchHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task started %@ + %@", command.commandPath, command.arguments);
    }];

    [task setFailureHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task failed %@ + %@", command.commandPath, command.arguments);
        NSLog(@"Task failed %i", taskLauncher.terminationStatus);
        NSLog(@"Task failed %@", taskLauncher.standardError);
        if (completion) {
            completion([SFDYCIErrorFactory compilationErrorWithMessage:[taskLauncher.standardError copy]]);
        }
    }];

    [task setTerminationHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task terminated %i", taskLauncher.terminationStatus);
        if (completion) {
            completion(nil);
        }
    }];

    // Showing up handlers
    [task launch];

}


#pragma mark - Creating Dylib

- (void)createDynamiclibraryWithCommand:(id <CDRSXcode_XCDependencyCommand>)command completion:(void (^)(NSError *))completion {

    SFDYCIClangParams * clangParams = [self.clangParamsExtractor extractParamsFromArguments:command.arguments];
    NSLog(@"Clang params extracted : %@", clangParams);

    NSString * libraryName = [NSString stringWithFormat:@"dyci%d.dylib", arc4random_uniform(10000000)];

    /*
     + ["-arch"] + [clangParams['arch']]\
     + ["-dynamiclib"]\
     + ["-isysroot"] + [clangParams['isysroot']]\
     + clangParams['LParams']\
     + clangParams['FParams']\
     + [clangParams['object']]\
     + ["-install_name"] + ["/usr/local/lib/" + libraryName]\
     + ['-Xlinker']\
     + ['-objc_abi_version']\
     + ['-Xlinker']\
     + ["2"]\
     + ["-ObjC"]\
     + ["-undefined"]\
     + ["dynamic_lookup"]\
     + ["-fobjc-arc"]\
     + ["-fobjc-link-runtime"]\
     + ["-Xlinker"]\
     + ["-no_implicit_dylibs"]\
     + [clangParams['minOSParam']]\
     + ["-single_module"]\
     + ["-compatibility_version"]\
     + ["5"]\
     + ["-current_version"]\
     + ["5"]\
     + ["-o"]\
     + [DYCI_ROOT_DIR + "/" + libraryName]
     */
    NSMutableArray * dlybArguments = [NSMutableArray array];
    [dlybArguments addObjectsFromArray:
      @[
        @"-arch", clangParams.arch,
        @"-dynamiclib",
        @"-isysroot", clangParams.isysroot,
      ]
    ];
    [dlybArguments addObjectsFromArray:clangParams.LParams];
    [dlybArguments addObjectsFromArray:clangParams.FParams];

    [dlybArguments addObjectsFromArray:
      @[
        clangParams.objectCompilationPath,
        @"-install_name", [NSString stringWithFormat:@"/usr/local/lib/%@", libraryName],
        @"-Xlinker",
        @"-objc_abi_version",
        @"-Xlinker",
        @"2",
        @"-ObjC",
        @"-undefined",
        @"dynamic_lookup",
        @"-fobjc-arc",
        @"-fobjc-link-runtime",
        @"-Xlinker",
        @"-no_implicit_dylibs",
        clangParams.minOSParams,
        @"-single_module",
        @"-compatibility_version",
        @"5",
        @"-current_version",
        @"5",
        @"-o",
        [[@"~/.dyci" stringByExpandingTildeInPath] stringByAppendingPathComponent:libraryName]
        //, @"-v"
      ]
    ];


    DSUnixTask * task = [self.taskManager task];
    [task setLaunchPath:command.commandPath];
    [task setArguments:dlybArguments];
    [task setEnvironment:command.environment];
    [task setWorkingDirectory:command.workingDirectoryPath];

    [task setLaunchHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task started %@ + %@", command.commandPath, dlybArguments);
    }];

    [task setFailureHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task failed %@ + %@", command.commandPath, dlybArguments);
        NSLog(@"Task failed %i", taskLauncher.terminationStatus);
        NSLog(@"Task failed %@", taskLauncher.standardError);
        if (completion) {
            completion([SFDYCIErrorFactory compilationErrorWithMessage:[taskLauncher.standardError copy]]);
        }
    }];

    [task setTerminationHandler:^(DSUnixTask * taskLauncher) {
        NSLog(@"Task terminated %i", taskLauncher.terminationStatus);
        if (completion) {
            completion(nil);
        }
    }];

    // Showing up handlers
    [task launch];

}


#pragma mark - Compilation

- (void)failWithError:(NSError *)error completionBlock:(void (^)(NSError *))block {
  if (block) {
      block(error);
  }
}


#pragma mark - SFDYCIRecompilerProtocol

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