//
//  DYCI_CCPXCodeConsole.m
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

#import "DYCI_CCPXCodeConsole.h"

@interface DYCI_CCPXCodeConsole ()

@property (retain, nonatomic) NSTextView* console;
@property (strong, nonatomic) NSString* windowIdentifier;

@end

@implementation DYCI_CCPXCodeConsole

static NSMutableDictionary* sharedInstances;

- (id)initWithIdentifier:(NSString*)identifier
{
    if (self = [super init]) {
        _windowIdentifier = identifier;
    }

    return self;
}

- (NSTextView*)console
{
    if (!_console) {
        _console = [self findConsoleAndActivate];
    }
    return _console;
}

- (void)debug:(id)obj {
    if (self.shouldShowDebugInfo) {
        [self appendText:[NSString stringWithFormat:@"%@\n", obj]];
    }
}

- (void)debug:(id)obj color:(NSColor *)color {
    if (self.shouldShowDebugInfo) {
        [self appendText:[NSString stringWithFormat:@"%@\n", obj] color:color];
    }
}


- (void)log:(id)obj
{
    [self appendText:[NSString stringWithFormat:@"%@\n", obj]];
}



- (void)error:(id)obj
{
    [self appendText:[NSString stringWithFormat:@"%@\n", obj]
               color:[NSColor redColor]];
}

- (void)appendText:(NSString*)text
{
    [self appendText:text color:nil];
}

- (NSWindow*)window
{
    for (NSWindow* window in [NSApp windows]) {
        if ([[window description] isEqualToString:self.windowIdentifier]) {
            return window;
        }
    }
    return nil;
}

- (void)appendText:(NSString*)text color:(NSColor*)originalColor
{
    if (text.length == 0)
        return;

    if (!self.console) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        NSColor * color = originalColor;
        if (!color)
            color = self.console.textColor;

        NSMutableDictionary *attributes = [@{NSForegroundColorAttributeName : color} mutableCopy];
        NSFont *font = [NSFont fontWithName:@"Menlo Regular" size:11];
        if (font) {
            attributes[NSFontAttributeName] = font;
        }
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        NSRange theEnd = NSMakeRange(self.console.string.length, 0);
        theEnd.location += as.string.length;
        [self.console.textStorage beginEditing];
//        if (NSMaxY(self.console.visibleRect) == NSMaxY(self.console.bounds)) {
//            [self.console.textStorage appendAttributedString:as];
//            [self.console scrollRangeToVisible:theEnd];
//        }
//        else {
            [self.console.textStorage appendAttributedString:as];
//        }
        [self.console.textStorage endEditing];
    });
}

#pragma mark - Class Methods

+ (instancetype)consoleForKeyWindow
{
    return [self consoleForWindow:[NSApp keyWindow]];
}

+ (instancetype)consoleForWindow:(NSWindow*)window
{
    if (window == nil)
        return nil;

    NSString* key = [window description];

    if (!sharedInstances)
        sharedInstances = [[NSMutableDictionary alloc] init];

    if (!sharedInstances[key]) {
        DYCI_CCPXCodeConsole * console = [[DYCI_CCPXCodeConsole alloc] initWithIdentifier:key];
        [sharedInstances setObject:console forKey:key];
    }

    return sharedInstances[key];
}

#pragma mark - Console Detection

+ (NSView*)findConsoleViewInView:(NSView*)view
{
    Class consoleClass = NSClassFromString(@"IDEConsoleTextView");
    return [self findViewOfKind:consoleClass inView:view];
}

+ (NSView*)findViewOfKind:(Class)kind
                   inView:(NSView*)view
{
    if ([view isKindOfClass:kind]) {
        return view;
    }

    for (NSView* v in view.subviews) {
        NSView* result = [self findViewOfKind:kind
                                       inView:v];
        if (result) {
            return result;
        }
    }
    return nil;
}

- (NSTextView*)findConsoleAndActivate
{
    NSTextView* console = (NSTextView*)[[self class] findConsoleViewInView:self.window.contentView];
    if (console
        && [self.window isKindOfClass:NSClassFromString(@"IDEWorkspaceWindow")]
        && [self.window.windowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        id editorArea = [self.window.windowController valueForKey:@"editorArea"];
        [editorArea performSelector:@selector(activateConsole:) withObject:self];
    }

    [console.textStorage deleteCharactersInRange:NSMakeRange(0, console.textStorage.length)];

    return console;
}

@end
