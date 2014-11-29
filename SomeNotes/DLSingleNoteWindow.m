//
//  DLSingleNoteWindow.m
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLSingleNoteWindow.h"
#import "DLPadView.h"
//#import "DLNote.h"
#import "DLTextView.h"

@interface DLSingleNoteWindow () <NSTextViewDelegate, NSSharingServicePickerDelegate>
{
    NSDictionary *attr;
    NSDateFormatter *dateFormatter;
    Note *currentNote;
}

@end

@implementation DLSingleNoteWindow


- (void)awakeFromNib
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentNote:) name:DLChangeCurrentNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterEditingMode:) name:DLEnteringEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:DLSingleNoteWindowRefresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteRemovedFromContext:) name:DLNoteRemovedFromContext object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //configure share button
    [shareButton sendActionOn:NSLeftMouseDownMask];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    attr = @{NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:11],
             NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0],
             NSParagraphStyleAttributeName:paragraphStyle};
    
    dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    self.timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
    
    textView.backgroundColor = [NSColor windowBackgroundColor];
    [textView.enclosingScrollView setBackgroundColor:[NSColor windowBackgroundColor]];
    [textView.enclosingScrollView setDrawsBackground:YES];
    
    
    self.backgroundView.backgroundColor = [NSColor windowBackgroundColor];
}

- (void)noteRemovedFromContext:(NSNotification *)notification
{
    if (currentNote == notification.object) {
        currentNote = nil;
    }
}

- (void)changeCurrentNote:(NSNotification *)notification
{
    if (currentNote) {
        currentNote.content = textView.attributedString;
    }
    currentNote = notification.object;
    textView.string = @"";
    if (currentNote.content) {
        [textView.textStorage appendAttributedString:currentNote.content];
    }

  //  [textView invalidateRestorableState];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)edit:(id)sender
{
    currentNote.content = textView.attributedString;
    [[NSNotificationCenter defaultCenter]postNotificationName:DLAddNewNoteNotification object:nil];
    textView.string = @"";
}


- (void)share:(id)sender
{
    if(currentNote && currentNote.content) {
        NSArray *items = @[currentNote.content];
        NSSharingServicePicker *picker = [[NSSharingServicePicker alloc]initWithItems:items];
        picker.delegate = self;
        [picker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
    }
}


- (void)enterEditingMode:(NSNotification *)notification
{
    if (!currentNote) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:[NSNull null]];
    }
}

- (void)refresh:(NSNotification *)notification
{
    if (currentNote) {
        NSString *time = [dateFormatter stringFromDate:currentNote.modifiedDate];
        self.timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
        textView.string = @"";
        [textView.textStorage appendAttributedString:currentNote.content];
        
    }
}


#pragma mark - NSTextViewDelegate


- (void)textDidEndEditing:(NSNotification *)notification
{
    currentNote.content = textView.attributedString;
    [[NSNotificationCenter defaultCenter] postNotificationName:DLExitingEditingModeNotification object:nil];
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
    //change current note's modified date and resort tableview
    [[NSNotificationCenter defaultCenter] postNotificationName:DLModifyNoteNotification object:currentNote];
}

- (void)textDidChange:(NSNotification *)notification
{
    currentNote.content = textView.attributedString;
    
    currentNote.modifiedDate = [NSDate date];
    NSString *time = [dateFormatter stringFromDate:currentNote.modifiedDate];
    
    self.timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
    NSString *title = nil;
    NSScanner *scanner = [NSScanner scannerWithString:textView.string];
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    [scanner scanUpToString:@"\n" intoString:&title];
    [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:title?[title copy]:[NSNull null]];
}

@end
