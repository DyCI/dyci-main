//
// Created by Paul Taykalo on 11/1/14.
//

#import <Foundation/Foundation.h>
#import "SFDYCIRecompilerProtocol.h"


/*
The recompiler that contrains of N other recompilers
And uses fall-back strategy.
If this recompiler returns NO than no underlying recompilers were able to recomple specified file
 */
@interface SFDYCICompositeRecompiler : NSObject <SFDYCIRecompilerProtocol>

@property(nonatomic, readonly) NSArray *compilers;

- (instancetype)initWithCompilers:(NSArray *)compilers;

@end