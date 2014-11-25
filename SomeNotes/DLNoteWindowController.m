//
//  DLNoteWindowController.m
//  SomeNotes
//
//  Created by liewli on 11/25/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLNoteWindowController.h"

@interface DLNoteWindowController () <NSTextViewDelegate>
{
    NSDictionary *attr;
    NSDateFormatter *dateFormatter;
}


@end

@implementation DLNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    attr = @{NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:11],
             NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0],
             NSParagraphStyleAttributeName:paragraphStyle};
    
    dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *time = [dateFormatter stringFromDate:self.note.modifiedDate];
    
    timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
    
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
    NSRect winFrame = self.window.frame;
    winFrame.size.width = 300;
    winFrame.size.height = 400;
    [self.window setFrame:winFrame display:YES];
    [self.window setMinSize:NSMakeSize(200, 300)];
    
    self.window.title = self.note.title;
    
    textView.string = @"";
    [textView.textStorage appendAttributedString:self.note.content];
    
    
    [self.window makeKeyAndOrderFront:self];
}


#pragma mark - NSTextViewDelegate
- (void)textDidChange:(NSNotification *)notification
{
    self.note.content = textView.attributedString;
    self.note.modifiedDate = [NSDate date];
    NSString *time = [dateFormatter stringFromDate:self.note.modifiedDate];
    
    timeLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:time attributes:attr];
    
    
    NSString *title = nil;
    NSScanner *scanner = [NSScanner scannerWithString:textView.string];
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    [scanner scanUpToString:@"\n" intoString:&title];
    [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.window.title = title?:@"New Note";
    self.note.title = title?:@"New Note";
    [[NSNotificationCenter defaultCenter] postNotificationName:DLModifyNoteNotification object:self.note];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteNeedsRefreshNotification object:self.note];
    
}


- (void)textDidBeginEditing:(NSNotification *)notification
{
    //change current note's modified date and resort tableview
    [[NSNotificationCenter defaultCenter] postNotificationName:DLModifyNoteNotification object:self.note];
}


- (void)textDidEndEditing:(NSNotification *)notification
{
    self.note.content = textView.attributedString;
    [[NSNotificationCenter defaultCenter] postNotificationName:DLExitingEditingModeNotification object:nil];
}




@end
