//
//  DLTextView.m
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTextView.h"
#include "DLSingleNoteWindow.h"

static NSString *DLTextViewRestoreKey = @"DLTextViewRestoreKey";

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

//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//  
//    [coder encodeObject:self.attributedString forKey:DLTextViewRestoreKey];
//      [super encodeRestorableStateWithCoder:coder];
//}
//
//- (void)restoreStateWithCoder:(NSCoder *)coder
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//  
//    self.string = @"";
//    NSAttributedString *attrString = [coder decodeObjectForKey:DLTextViewRestoreKey];
//    [self.textStorage appendAttributedString:attrString];
//      [super restoreStateWithCoder:coder];
//}

@end
