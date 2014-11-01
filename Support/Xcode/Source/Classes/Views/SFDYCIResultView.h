//
//  SFDYCIResultView.h
//  SFDYCIPlugin
//
//  Created by Paul Taykalo on 10/14/12.
//
//

#import <Cocoa/Cocoa.h>

@interface SFDYCIResultView : NSView {
   
   BOOL _success;
   
}

@property(nonatomic, assign) BOOL success;

@end
