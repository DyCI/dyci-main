//
//  SFDYCIResultView.m
//  SFDYCIPlugin
//
//  Created by Paul Taykalo on 10/14/12.
//
//

#import "SFDYCIResultView.h"

@implementation SFDYCIResultView

@synthesize success = _success;

- (void)drawRect:(NSRect)dirtyRect {
    //// Color Declarations
    NSColor *color1 = [NSColor colorWithCalibratedRed:0.09 green:0.77 blue:0.01 alpha:1];
    NSColor *color2 = [NSColor colorWithCalibratedRed:0.82 green:0.00 blue:0.00 alpha:1];

    //// Gradient Declarations
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor lightGrayColor] endingColor:[NSColor whiteColor]];
    NSGradient *gradient2 = [[NSGradient alloc] initWithStartingColor:[NSColor darkGrayColor] endingColor:[NSColor lightGrayColor]];

    //// Shadow Declarations
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowOffset:NSMakeSize(0, 0)];
    [shadow setShadowBlurRadius:5];

    //// Oval Drawing
    NSBezierPath *ovalPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 50, 50)];
    [gradient drawInBezierPath:ovalPath angle:-90];

    //// Oval 2 Drawing
    NSBezierPath *oval2Path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(6, 6, 37, 37)];
    [gradient2 drawInBezierPath:oval2Path angle:-90];


    //// Oval 3 Drawing
    NSBezierPath *oval3Path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(9, 9, 31, 31)];
    [(_success ? color1 : color2) setFill];
    [oval3Path fill];

    ////// Oval 3 Inner Shadow
    NSRect oval3BorderRect = NSInsetRect([oval3Path bounds], -shadow.shadowBlurRadius, -shadow.shadowBlurRadius);
    oval3BorderRect = NSOffsetRect(oval3BorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
    oval3BorderRect = NSInsetRect(NSUnionRect(oval3BorderRect, [oval3Path bounds]), -1, -1);

    NSBezierPath *oval3NegativePath = [NSBezierPath bezierPathWithRect:oval3BorderRect];
    [oval3NegativePath appendBezierPath:oval3Path];
    [oval3NegativePath setWindingRule:NSEvenOddWindingRule];

    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow *innerShadow = [shadow copy];
        CGFloat xOffset = innerShadow.shadowOffset.width + round(oval3BorderRect.size.width);
        CGFloat yOffset = innerShadow.shadowOffset.height;
        innerShadow.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [innerShadow set];
        [[NSColor grayColor] setFill];
        [oval3Path addClip];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:-round(oval3BorderRect.size.width) yBy:0];
        [[transform transformBezierPath:oval3NegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];

}

@end
