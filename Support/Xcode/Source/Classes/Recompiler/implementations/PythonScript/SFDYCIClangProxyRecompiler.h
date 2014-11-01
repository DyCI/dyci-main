//
// SFDYCIClangProxyRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SFDYCIRecompilerProtocol.h"

/*
Dyci proxy recompiler that is using dyci-recpmpile.py python script
First version
this recompiler uses index pythons scrip, which is used index files with parameters those were catured
by proxied clang

Can recompile all things those were originally intended to
 */
@interface SFDYCIClangProxyRecompiler : NSObject <SFDYCIRecompilerProtocol>

@end