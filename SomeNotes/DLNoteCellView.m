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
    [[NSColor colorWithCalibratedRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0] setFill];
    NSRect seperator = NSMakeRect(20, 0, self.frame.size.width - 40, 1);
    NSRectFill(seperator);
    
}

@end
