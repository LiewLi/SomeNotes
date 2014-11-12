//
//  DLTextView.m
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTextView.h"
#include "DLSingleNoteWindow.h"

@implementation DLTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)mouseDown:(NSEvent *)theEvent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DLEnteringEditingModeNotification object:nil];
    [super mouseDown:theEvent];
}
@end
