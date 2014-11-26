//
//  DLNoteWindowController.h
//  SomeNotes
//
//  Created by liewli on 11/25/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLNote.h"
#import "DLSingleNoteWindow.h"
#import "Note.h"

static NSString *DLNoteNeedsRefreshNotification = @"DLNoteNeedRefreshNotification";

@interface DLNoteWindowController : NSWindowController
{
    IBOutlet NSTextField *timeLabel;
    IBOutlet NSButton *shareButton;
    IBOutlet NSTextView *textView;
}

@property (nonatomic, strong)Note *note;

@end
