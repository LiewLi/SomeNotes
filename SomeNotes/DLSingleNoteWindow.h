//
//  DLSingleNoteWindow.h
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLBackgroundView.h"
#import "DLNote.h"

static  NSString *DLNoteChangeTitleNotification = @"DLNoteChangeTitleNotification";
static  NSString *DLAddNewNoteNotification = @"DLAddNewNoteNotification";
static NSString *DLEnteringEditingModeNotification = @"DLEnteringEditingModeNotification";
static NSString *DLExitingEditingModeNotification = @"DLExitingEditingModeNotification";

@interface DLSingleNoteWindow : NSViewController
{
    IBOutlet NSTextView *textView;
}

- (IBAction)share:(id)sender;

- (IBAction)edit:(id)sender;

@property (nonatomic, weak)IBOutlet NSTextField *timeLabel;
@property (nonatomic, weak)IBOutlet DLBackgroundView *backgroundView;

@end
