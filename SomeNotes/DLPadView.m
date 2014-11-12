//
//  DLPadView.m
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLPadView.h"
#import "DLNoteCellView.h"
#import "DLSingleNoteWindow.h"
#import "DLNote.h"


@interface DLPadView ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSDictionary *titleAttr;
    NSDictionary *timeAttr;
    NSMutableArray *notes;
    NSDateFormatter *dateFormatter;
    BOOL active;
    NSColor *activeColor;
    NSColor *inactiveColor;
}

@end

@implementation DLPadView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    
    activeColor = [NSColor colorWithCalibratedRed:1.0 green:195.0/255 blue:10.0/225 alpha:1.0];
    inactiveColor = [NSColor colorWithCalibratedRed:1.0 green:232.0/255 blue:152.0/255 alpha:1.0];
    
    dateFormatter = [[NSDateFormatter alloc]init];
   // dateFormatter.timeStyle = NSDateFormatterShortStyle;
   // dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    notes = [[NSMutableArray alloc]init]; //TODO: Load From FS
   
    active = YES; // active Mode
    
    titleAttr = @{NSFontAttributeName:[NSFont boldSystemFontOfSize:13.0]};
    timeAttr = @{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0]};
    
    self.tableView.headerView = nil;
    self.tableView.focusRingType = NSFocusRingTypeNone;
    [self.tableView setIntercellSpacing:NSMakeSize(0.0, 0.0)];
    self.scrollView.contentInsets = NSEdgeInsetsMake(0, 20, 0, 20);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteTitleChange:)name:DLNoteChangeTitleNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addNote:) name:DLAddNewNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeInactive:) name:DLEnteringEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive:) name:DLExitingEditingModeNotification object:nil];
    
}

- (void)becomeActive:(NSNotification *)notification
{
    if (!active) {
        active = YES;
        [self refreshTableView];
    }
    else active = YES;
   
}

- (void)becomeInactive:(NSNotification *)notification
{
    if (active) {
        active = NO;
        [self refreshTableView];
    }
    else active = NO;
}

- (void)addNote:(NSNotificationCenter *)notification
{
    if (notes.count == 0) {
        [self addNewNote];
    }
    else {
        [self checkIfNeedDelete];
        [self addNewNote];
    }
}

- (BOOL)checkIfNeedDelete
{
    if (notes.count) {
        DLNote *note = notes[0];
        if (!note.content || [note.content isEqualToString:@""]) {
            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideUp];
            [notes removeObjectAtIndex:0];
             return YES;
        }
    }
    return NO;
}

- (void)addNewNote
{
    DLNote *note = [[DLNote alloc]init];
    note.title = @"New Note";
    note.createdDate = [NSDate date];
    note.modifiedDate = [NSDate date];
    [notes insertObject:note atIndex:0];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
}

- (void)noteTitleChange:(NSNotification *)notification
{
    NSString *title = nil;
    if (notification.object == [NSNull null]) {
        title = @"New Note";
    }
    else {
        title = notification.object;
    }
    
    if (notes.count <= 0) {
        [self addNewNote];
    }
    else {
        DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:self.tableView.selectedRow makeIfNecessary:NO];
        DLNote *note = notes[self.tableView.selectedRow];
        note.title = title;
        cellView.titleLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:title attributes:titleAttr];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSTableViewDataSource, NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return notes.count;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    DLNote *note = notes[row];
    DLNoteCellView *cellView = [tableView makeViewWithIdentifier:CellIdentifier owner:self];
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:note.title attributes:titleAttr];
    
    NSTimeInterval timeLapse = [[NSDate date]  timeIntervalSinceDate:note.createdDate];
    if (timeLapse >= 86400) {
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    else {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    
    NSAttributedString *time = [[NSAttributedString alloc]initWithString:[dateFormatter stringFromDate:note.createdDate] attributes:timeAttr];
    cellView.titleLabel.attributedStringValue = title;
    cellView.timeLabel.attributedStringValue = time;
    return cellView;
    
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 44;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    active = YES;
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
    if (self.tableView.selectedRow > 0) {
      [self checkIfNeedDelete];
    }
  
    if (self.tableView.selectedRow >= 0) {
        [self refreshTableView];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLChangeCurrentNoteNotification object:notes[self.tableView.selectedRow]];
    }
    
}


- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
    NSInteger selectedRowNumber = [aTableView selectedRow];
    if (selectedRowNumber > 0) {
        [aTableView setNeedsDisplayInRect:[aTableView rectOfRow:selectedRowNumber-1]];
    }
    return YES;
}

- (void)refreshTableView
{
    if (notes.count) {
        for (int i = 0; i < notes.count; ++i) {
            if (i != self.tableView.selectedRow) {
                DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
                cellView.backgroundColor = [NSColor whiteColor];
            }
        }
        
        DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:self.tableView.selectedRow makeIfNecessary:NO];
        cellView.backgroundColor = active ? activeColor : inactiveColor;
    }
}
@end
