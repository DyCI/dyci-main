//
// SFDYCIClangProxyRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SFDYCIRecompilerProtocol.h"

@class DYCI_CCPXCodeConsole;

/*
Dyci proxy recompiler that is using dyci-recpmpile.py python script
This recompiler uses index pythons script, which is used index files with parameters those were captured
by proxied clang

Can recompile all things those were originally intended to
 */
@interface SFDYCIClangProxyRecompiler : NSObject <SFDYCIRecompilerProtocol>

@end