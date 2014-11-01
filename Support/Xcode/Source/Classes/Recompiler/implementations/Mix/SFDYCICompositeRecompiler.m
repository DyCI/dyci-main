//
// Created by Paul Taykalo on 11/1/14.
//

#import "SFDYCICompositeRecompiler.h"
#import "SFDYCIErrorFactory.h"


@implementation SFDYCICompositeRecompiler

- (instancetype)initWithCompilers:(NSArray *)compilers {
    self = [super init];
    if (self) {
        _compilers = compilers;
    }
    return self;
}

- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError *error))completionBlock {
    for (id<SFDYCIRecompilerProtocol> recompiler in self.compilers) {
        if ([recompiler canRecompileFileAtURL:fileURL]) {
            [recompiler recompileFileAtURL:fileURL completion:completionBlock];
            return;
        }
    }

    if (completionBlock) {
        completionBlock([SFDYCIErrorFactory noRecompilerFoundErrorForFileURL:fileURL]);
    }
}

- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL {
    for (id<SFDYCIRecompilerProtocol> recompiler in self.compilers) {
        if ([recompiler canRecompileFileAtURL:fileURL]) {
            return YES;
        }
    }
    return NO;
}


@end