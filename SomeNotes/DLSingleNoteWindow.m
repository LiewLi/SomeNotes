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

@interface DLSingleNoteWindow () <NSTextViewDelegate>
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

}

- (void)changeCurrentNote:(NSNotification *)notification
{
    if (curretNote) {
        curretNote.content = textView.string;
        curretNote = notification.object;
        textView.string = curretNote.content?:@"";
    }
    else {
        curretNote = notification.object;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)edit:(id)sender
{
    curretNote.content = textView.string;
    [[NSNotificationCenter defaultCenter]postNotificationName:DLAddNewNoteNotification object:nil];
    textView.string = @"";
}


- (void)share:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


#pragma mark - NSTextViewDelegate

-(void)textViewDidChangeSelection:(NSNotification *)notification
{
    if (!curretNote) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:[NSNull null]];
         [[NSNotificationCenter defaultCenter] postNotificationName:DLEnteringEditingModeNotification object:nil];
    }
}


- (void)textDidEndEditing:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DLExitingEditingModeNotification object:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    NSString *title = nil;
    NSScanner *scanner = [NSScanner scannerWithString:textView.string];
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    [scanner scanUpToString:@"\n" intoString:&title];
    [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteChangeTitleNotification object:title?[title copy]:[NSNull null]];
}

@end
