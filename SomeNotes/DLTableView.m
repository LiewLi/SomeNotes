//
//  DLTableView.m
//  SomeNotes
//
//  Created by liewli on 11/25/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLTableView.h"

@implementation DLTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    NSPoint mousePoint = [self convertPoint:event.locationInWindow fromView:nil];
    
    NSInteger row = [self rowAtPoint:mousePoint];
    
    if (row >= 0) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    }
    
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    NSMenu *contextMenu = [[NSMenu alloc]init];
    [contextMenu insertItemWithTitle:@"Open" action:@selector(openNote:) keyEquivalent:@"" atIndex:0];
    [contextMenu insertItemWithTitle:@"Delete" action:@selector(deleteNote:) keyEquivalent:@"" atIndex:1];
    
    [contextMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
    
    [contextMenu insertItemWithTitle:@"New Note" action:@selector(newNote:) keyEquivalent:@"" atIndex:3];
    
    return contextMenu;
}

@end
