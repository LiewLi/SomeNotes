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
    NSMutableArray *notes; // soted by modified date
    NSDateFormatter *dateFormatter;
    BOOL active;
    NSColor *activeColor;
    NSColor *inactiveColor;
    NSMutableArray *notesCopy;
    DLNote *selectedNote;
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
    
    titleAttr = @{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Bold" size:13]};
    timeAttr = @{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0],
                 NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue Light" size:12]};
    
    self.tableView.headerView = nil;
    self.tableView.focusRingType = NSFocusRingTypeNone;
    [self.tableView setIntercellSpacing:NSMakeSize(0.0, 0.0)];
    self.scrollView.contentInsets = NSEdgeInsetsMake(0, 20, 0, 20);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteTitleChange:)name:DLNoteChangeTitleNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addNote:) name:DLAddNewNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeInactive:) name:DLEnteringEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive:) name:DLExitingEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateModifiedNote:) name:DLModifyNoteNotification object:nil];
    
}


#pragma mark - Search Functionality
- (void)updateFilter:(id)sender
{
    if (notesCopy == nil) {
        notesCopy = [notes mutableCopy];
    }
    NSString *searchString = self.searchField.stringValue;
    if (!searchString || [searchString isEqualToString:@""]) {
        notes = notesCopy;
        notesCopy = nil;
        [self.tableView reloadData];
    }
    else {
        notes = [notesCopy mutableCopy];
        [self.tableView reloadData];
        
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
        [self.tableView beginUpdates];
        [notes enumerateObjectsUsingBlock:^(DLNote* obj, NSUInteger idx, BOOL *stop) {
            if ([obj.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location == NSNotFound) {
                [indexes addIndex:idx];
            }
        }];
        
        [self.tableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideUp];
        [notes removeObjectsAtIndexes:indexes];
        [self.tableView endUpdates];
        [self refreshTableView];
    }
}

- (void)updateModifiedNote:(NSNotification *)notification
{
    //resort tableview based on modified date
    DLNote *note = notification.object;
    NSUInteger index = [notes indexOfObject:note];
    
    DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:index makeIfNecessary:NO];
    note.modifiedDate = [NSDate date];
    NSAttributedString *date = [self dateForNote:note Since:[NSDate date]];
    cellView.timeLabel.attributedStringValue = date;
    
    
    [notes sortUsingComparator:^NSComparisonResult(DLNote* note1, DLNote* note2) {
        return [note2.modifiedDate compare:note1.modifiedDate];
    }];
    
    
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndex:index toIndex:0];
    [self.tableView endUpdates];
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
        if (notesCopy) {
            notes = [notesCopy mutableCopy]?:notes;
            notesCopy = nil;
            [self.tableView reloadData];
            if (selectedNote) {
                NSUInteger row = [notes indexOfObject:selectedNote];
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            }
        }
        else [self refreshTableView];
       
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
        if (!note.content || [note.content.string isEqualToString:@""]) {
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
    selectedNote = note;
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


- (NSAttributedString *) dateForNote:(DLNote *)note Since:(NSDate *)date
{
    NSTimeInterval timeLapse = [date timeIntervalSinceDate:note.modifiedDate];
    if (timeLapse >= 86400) {
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    else {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    
    NSAttributedString *time = [[NSAttributedString alloc]initWithString:[dateFormatter stringFromDate:note.modifiedDate] attributes:timeAttr];
    
    return time;
}

- (void)openNote:(id)sender
{

}

- (void)deleteNote:(id)sender
{
    NSUInteger row = self.tableView.selectedRow;
    NSString *title = ((DLNote *)notes[row]).title;
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = [NSString stringWithFormat:@"Are you sure you want to delete the note \"%@\"?", title];
    [alert addButtonWithTitle:@"Delete Note"];
    [alert addButtonWithTitle:@"Cancel"];
    
    [alert beginSheetModalForWindow:self.tableView.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
           
            if (notes.count > 1) {
                NSUInteger next;
                if (row == notes.count - 1) {
                    next = row - 1;
                }
                else{
                    next = row + 1;
                }
                [self.tableView beginUpdates];
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:next] byExtendingSelection:NO];
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
                [notes removeObjectAtIndex:row];
                [self.tableView endUpdates];
            }
            else {
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
                [notes removeObjectAtIndex:row];
                [[NSNotificationCenter defaultCenter] postNotificationName:DLChangeCurrentNoteNotification object:nil];
            }
            
        }
    }];
    
   
}

-(void)newNote:(id)sender
{
    [self addNewNote];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(newNote:)) {
        if (notes.count) {
            DLNote *note = notes[0];
            return note.content != nil && ![note.content.string isEqualToString:@""];
        }
    }
    
    return YES;
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
    
    NSAttributedString *time = [self dateForNote:note Since:[NSDate date]];
    cellView.titleLabel.attributedStringValue = title;
    cellView.timeLabel.attributedStringValue = time;
    
    if ([note isEqualTo:selectedNote]) {
        cellView.backgroundColor = active ? activeColor : inactiveColor;
    }
    else {
        cellView.backgroundColor = [NSColor whiteColor];
    }
    
    return cellView;
    
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 44;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
    if (self.tableView.selectedRow > 0) {
      [self checkIfNeedDelete];
    }
  
    if (self.tableView.selectedRow >= 0) {
        selectedNote = notes[self.tableView.selectedRow];
        [self refreshTableView];
        [[NSNotificationCenter defaultCenter] postNotificationName:DLChangeCurrentNoteNotification object:selectedNote];
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
    NSInteger count = notes.count;
    if (count) {
        for (int i = 0; i < notes.count; ++i) {
            DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
            if (![notes[i] isEqualTo:selectedNote]) {
                 cellView.backgroundColor = [NSColor whiteColor];
                if (self.tableView.selectedRow == i + 1) {
                    cellView.isSelected = YES;
                } else {
                    cellView.isSelected = NO;
                }
               
            }
            else {
                cellView.backgroundColor = active ? activeColor : inactiveColor;
                cellView.isSelected = YES;
               
            }
        }
        
   
    }
}
@end
