//
//  DLBackgroundView.m
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLBackgroundView.h"

@implementation DLBackgroundView

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    if (backgroundColor != _backgroundColor) {
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.backgroundColor == nil) {
        [[NSColor whiteColor] setFill];
    }
    else {
        [self.backgroundColor setFill];
    }
    
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
    
}

@end
