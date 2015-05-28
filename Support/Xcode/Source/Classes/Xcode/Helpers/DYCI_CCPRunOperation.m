//
//  DYCI_CCPRunOperation.m
//
//  Copyright (c) 2013 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "DYCI_CCPRunOperation.h"
#import "DYCI_CCPXCodeConsole.h"

@interface DYCI_CCPRunOperation () {
    BOOL isExecuting;
    BOOL isFinished;
}

@property (retain) DYCI_CCPXCodeConsole * xcodeConsole;

@property (retain) NSTask* task;
@property (retain) id taskStandardOutDataAvailableObserver;
@property (retain) id taskStandardErrorDataAvailableObserver;
@property (retain) id taskTerminationObserver;

@end

@implementation DYCI_CCPRunOperation

- (id)initWithTask:(NSTask*)task
{
    self = [super init];
    if (self) {
        self.xcodeConsole = [DYCI_CCPXCodeConsole consoleForKeyWindow];
        self.task = task;
    }
    return self;
}

- (BOOL)isExecuting
{
    return isExecuting;
}

- (void)setIsExecuting:(BOOL)_isExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    isExecuting = _isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished
{
    return isFinished;
}

- (void)setIsFinished:(BOOL)_isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    isFinished = _isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start
{
    if (self.isCancelled) {
        self.isFinished = YES;
        return;
    }

    if (!NSThread.isMainThread) {
        [self performSelector:@selector(start) onThread:NSThread.mainThread withObject:nil waitUntilDone:NO];
        return;
    }

    self.isExecuting = YES;
    [self main];
}

- (void)main
{
    if (self.isCancelled) {
        self.isExecuting = NO;
        self.isFinished = YES;
    }
    else {
        [self runOperation];
    }
}

#pragma mark - NSTask

- (void)runOperation
{
    @try {
        NSPipe* standardOutputPipe = NSPipe.pipe;
        self.task.standardOutput = standardOutputPipe;
        NSPipe* standardErrorPipe = NSPipe.pipe;
        self.task.standardError = standardErrorPipe;
        NSFileHandle* standardOutputFileHandle = standardOutputPipe.fileHandleForReading;
        NSFileHandle* standardErrorFileHandle = standardErrorPipe.fileHandleForReading;

        __block NSMutableString* standardOutputBuffer = [NSMutableString string];
        __block NSMutableString* standardErrorBuffer = [NSMutableString string];

        self.taskStandardOutDataAvailableObserver = [NSNotificationCenter.defaultCenter addObserverForName:NSFileHandleDataAvailableNotification
                                                                                                    object:standardOutputFileHandle
                                                                                                     queue:NSOperationQueue.mainQueue
                                                                                                usingBlock:^(NSNotification* notification) {
                                                                                                    NSFileHandle *fileHandle = notification.object;
                                                                                                    NSString *data = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSUTF8StringEncoding];
                                                                                                    if (data.length > 0) {
                                                                                                        [standardOutputBuffer appendString:data];
                                                                                                        [fileHandle waitForDataInBackgroundAndNotify];
                                                                                                        standardOutputBuffer = [self writePipeBuffer:standardOutputBuffer];
                                                                                                    } else {
                                                                                                        [self appendLine:standardOutputBuffer];
                                                                                                        [NSNotificationCenter.defaultCenter removeObserver:self.taskStandardOutDataAvailableObserver];
                                                                                                        self.taskStandardOutDataAvailableObserver = nil;
                                                                                                        [self checkAndSetFinished];
                                                                                                    }
                                                                                                }];

        self.taskStandardErrorDataAvailableObserver = [NSNotificationCenter.defaultCenter addObserverForName:NSFileHandleDataAvailableNotification
                                                                                                      object:standardErrorFileHandle
                                                                                                       queue:NSOperationQueue.mainQueue
                                                                                                  usingBlock:^(NSNotification* notification) {
                                                                                                      NSFileHandle *fileHandle = notification.object;
                                                                                                      NSString *data = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSUTF8StringEncoding];
                                                                                                      if (data.length > 0) {
                                                                                                          [standardErrorBuffer appendString:data];
                                                                                                          [fileHandle waitForDataInBackgroundAndNotify];
                                                                                                          standardErrorBuffer = [self writePipeBuffer:standardErrorBuffer];
                                                                                                      } else {
                                                                                                          [self appendLine:standardErrorBuffer];
                                                                                                          [NSNotificationCenter.defaultCenter removeObserver:self.taskStandardErrorDataAvailableObserver];
                                                                                                          self.taskStandardErrorDataAvailableObserver = nil;
                                                                                                          [self checkAndSetFinished];
                                                                                                      }
                                                                                                  }];

        self.taskTerminationObserver = [NSNotificationCenter.defaultCenter addObserverForName:NSTaskDidTerminateNotification
                                                                                       object:self.task
                                                                                        queue:NSOperationQueue.mainQueue
                                                                                   usingBlock:^(NSNotification* notification) {
                                                                                       [NSNotificationCenter.defaultCenter removeObserver:self.taskTerminationObserver];
                                                                                       self.taskTerminationObserver = nil;
                                                                                       self.task = nil;
                                                                                       [self checkAndSetFinished];
                                                                                   }];

        [standardOutputFileHandle waitForDataInBackgroundAndNotify];
        [standardErrorFileHandle waitForDataInBackgroundAndNotify];

        [self.xcodeConsole debug:[NSString stringWithFormat:@"%@ %@\n\n", self.task.launchPath, [self.task.arguments componentsJoinedByString:@" "]]];
        [self.task launch];
    }
    @catch (NSException* exception)
    {
        [self.xcodeConsole appendText:exception.description color:NSColor.redColor];
        [self.xcodeConsole appendText:@"\n"];
        self.isExecuting = NO;
        self.isFinished = YES;
    }
}

- (NSMutableString*)writePipeBuffer:(NSMutableString*)buffer
{
    NSArray* lines = [buffer componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
    if (lines.count > 1) {
        for (int i = 0; i < lines.count - 1; i++) {
            NSString* line = lines[i];
            [self appendLine:line];
        }
        return [lines[lines.count - 1] mutableCopy];
    }
    return buffer;
}

- (void)appendLine:(NSString*)line
{
    NSColor* color;

    if ([line hasPrefix:@"ERROR"])
        color = NSColor.redColor;
    else if ([line hasPrefix:@"WARNING"])
        color = NSColor.orangeColor;
    else if ([line hasPrefix:@"DEBUG"])
        color = NSColor.grayColor;
    else if ([line hasPrefix:@"INFO"])
        color = [NSColor colorWithDeviceRed:0.0 green:0.5 blue:0.0 alpha:1.0];

    [self.xcodeConsole debug:[line stringByAppendingString:@"\n"] color:color];
}

- (void)checkAndSetFinished
{
    if (self.taskStandardOutDataAvailableObserver == nil
        && self.taskStandardErrorDataAvailableObserver == nil
        && self.task == nil) {
        self.isExecuting = NO;
        self.isFinished = YES;
    }
}

@end
