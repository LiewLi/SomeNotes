//
//  DLPadView.h
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString *DLChangeCurrentNoteNotification = @"DLChangeCurrentNoteNotification ";

@interface DLPadView : NSViewController
@property (nonatomic, weak)IBOutlet NSTableView *tableView;
@property (nonatomic, weak)IBOutlet NSScrollView *scrollView;
@property (nonatomic, weak)IBOutlet NSSearchField *searchField;
- (IBAction)updateFilter:(id)sender;
@end
