//
//  DLNoteCellView.m
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLNoteCellView.h"

@implementation DLNoteCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if (!_isSelected) {
        [[NSColor colorWithCalibratedRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0] setFill];
        NSRect seperator = NSMakeRect(20, 0, self.frame.size.width - 40, 1);
        NSRectFill(seperator);
    }
   
}

-(void)setIsSelected:(BOOL)isSelected
{
    if (isSelected != _isSelected) {
        _isSelected = isSelected;
        [self setNeedsDisplay:YES];
    }
}

@end
