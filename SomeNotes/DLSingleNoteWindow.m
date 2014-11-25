//
//  DLSingleNoteWindow.m
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLSingleNoteWindow.h"
#import "DLPadView.h"
#import "DLNote.h"
#import "DLTextView.h"

@interface DLSingleNoteWindow () <NSTextViewDelegate, NSSharingServicePickerDelegate>
{
    NSDictionary *attr;
    NSDateFormatter *dateFormatter;
    DLNote *curretNote;
}

@end

@implementation DLSingleNoteWindow

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //configure share button
    [shareButton sendActionOn:NSLeftMouseDownMask];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    attr = @{NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],
             NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0],
             NSParagraphStyleAttributeName:paragraphStyle};
    
    dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    self.timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
    
    textView.backgroundColor = [NSColor windowBackgroundColor];
    [textView.enclosingScrollView setBackgroundColor:[NSColor windowBackgroundColor]];
    [textView.enclosingScrollView setDrawsBackground:YES];
    
    self.backgroundView.backgroundColor = [NSColor windowBackgroundColor];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentNote:) name:DLChangeCurrentNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterEditingMode:) name:DLEnteringEditingModeNotification object:nil];

}

- (void)changeCurrentNote:(NSNotification *)notification
{
    if (curretNote) {
        curretNote.content = textView.attributedString;
        curretNote = notification.object;
        //set textview attributedstring
        textView.string = @"";
        if (curretNote.content) {
            [textView.textStorage appendAttributedString:curretNote.content];
        }
    }
    else {
        curretNote = notification.object;
        textView.string = @"";
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)edit:(id)sender
{
    curretNote.content = textView.attributedString;
    [[NSNotificationCenter defaultCenter]postNotificationName:DLAddNewNoteNotification object:nil];
    textView.string = @"";
}


- (void)share:(id)sender
{
    if(curretNote && curretNote.content) {
        NSArray *items = @[curretNote.content];
        NSSharingServicePicker *picker = [[NSSharingServicePicker alloc]initWithItems:items];
        picker.delegate = self;
        [picker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
    }
}


- (void)enterEditingMode:(NSNotification *)notification
{
    if (!curretNote) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:[NSNull null]];
    }
}

#pragma mark - NSTextViewDelegate


- (void)textDidEndEditing:(NSNotification *)notification
{
    curretNote.content = textView.attributedString;
    [[NSNotificationCenter defaultCenter] postNotificationName:DLExitingEditingModeNotification object:nil];
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
    //change current note's modified date and resort tableview
    [[NSNotificationCenter defaultCenter] postNotificationName:DLModifyNoteNotification object:curretNote];
}

- (void)textDidChange:(NSNotification *)notification
{
    curretNote.content = textView.attributedString;
    NSString *title = nil;
    NSScanner *scanner = [NSScanner scannerWithString:textView.string];
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    [scanner scanUpToString:@"\n" intoString:&title];
    [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:title?[title copy]:[NSNull null]];
}

@end
