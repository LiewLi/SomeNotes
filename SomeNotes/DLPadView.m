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
#import "DLNoteWindowController.h"
#import "DLSingleNoteWindow.h"
#import "AppDelegate.h"
#import "Note.h"

@interface DLPadView ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSDictionary *titleAttr;
    NSDictionary *timeAttr;
    NSArray *notes; // soted by modified date
    NSDateFormatter *dateFormatter;
    BOOL active;
    NSColor *activeColor;
    NSColor *inactiveColor;
    NSMutableArray *notesCopy;
    Note *selectedNote;
    NSMutableDictionary *noteWindows;
    BOOL deactiveMode;
    NSManagedObjectContext *moc;
}

@end

@implementation DLPadView


- (void)initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Note" withExtension:@"momd"];
    NSAssert(modelURL, @"Failed to find model url.");
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    NSAssert(mom, @"Failed to initialize model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(psc, @"Failed to create persistent store coordinator");
    
    moc = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
   // dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   // dispatch_async(queue, ^{
        // add perisistent store
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *storeURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        storeURL = [storeURL URLByAppendingPathComponent:@"SomeNotes.sqlite"];
        
        __autoreleasing NSError *error;
        
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        
        if (error) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
       // dispatch_async(dispatch_get_main_queue(), ^{
    
        //    [self.tableView reloadData];
    
  
       // });
        
    //});
    
}

- (void)viewWillDisappear
{
    __autoreleasing NSError *error;
    if (![moc save:&error]) {
        NSLog(@"Save notes to persistent store failed : %@", [error localizedDescription]);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    
    [self initializeCoreDataStack];
    
    noteWindows = [[NSMutableDictionary alloc] init];
    
    activeColor = [NSColor colorWithCalibratedRed:1.0 green:195.0/255 blue:10.0/225 alpha:1.0];
    inactiveColor = [NSColor colorWithCalibratedRed:1.0 green:232.0/255 blue:152.0/255 alpha:1.0];
    
    dateFormatter = [[NSDateFormatter alloc]init];
   // dateFormatter.timeStyle = NSDateFormatterShortStyle;
   // dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    notes = [self fetchNotesWithPredicate:nil];
    
    active = YES; // active Mode
    
    titleAttr = @{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Bold" size:13]};
    timeAttr = @{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0],
                 NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue Light" size:12]};
    
    self.tableView.headerView = nil;
    self.tableView.focusRingType = NSFocusRingTypeNone;
    [self.tableView setIntercellSpacing:NSMakeSize(0.0, 0.0)];
    self.scrollView.contentInsets = NSEdgeInsetsMake(0, 20, 0, 20);
    [self.tableView setDoubleAction:@selector(openNote:)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteTitleChange:)name:DLNoteChangeTitleNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addNote:) name:DLAddNewNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeInactive:) name:DLEnteringEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive:) name:DLExitingEditingModeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateModifiedNote:) name:DLModifyNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteNeedRefresh:) name:DLNoteNeedsRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindow:) name:NSWindowDidBecomeMainNotification object:nil];
    
    
    if (notes.count > 0) {
        [self.tableView reloadData];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
}


- (NSArray *)fetchNotesWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:moc];
    [fetchRequest setEntity:entityDesc];
    
    // sort by modified date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"modifiedDate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    __autoreleasing NSError *error;
    
    NSArray * fetchedNotes = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
   
    return fetchedNotes;
}


- (Note *)addNewNoteToStore
{
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:moc];
    note.modifiedDate = [NSDate date];
    note.title = @"New Note";
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    note.uuid = (__bridge NSString *) CFUUIDCreateString(NULL, uuid);
    notes = [self fetchNotesWithPredicate:nil];
    return note;
}

- (void)deleteNoteFromStore:(Note *)note
{
    [moc deleteObject:note];
    [[NSNotificationCenter defaultCenter] postNotificationName:DLNoteRemovedFromContext object:note];
    [noteWindows removeObjectForKey:note.uuid]; // in case window is open
    notes = [self fetchNotesWithPredicate:nil];
}


#pragma mark - Search Functionality
- (void)updateFilter:(id)sender
{
//    if (notesCopy == nil) {
//        notesCopy = [notes mutableCopy];
//    }
//    NSString *searchString = self.searchField.stringValue;
//    if (!searchString || [searchString isEqualToString:@""]) {
//        notes = notesCopy;
//        notesCopy = nil;
//        [self.tableView reloadData];
//    }
//    else {
//        notes = [notesCopy mutableCopy];
//        [self.tableView reloadData];
//        
//        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
//        [self.tableView beginUpdates];
//        [notes enumerateObjectsUsingBlock:^(DLNote* obj, NSUInteger idx, BOOL *stop) {
//            if ([obj.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location == NSNotFound) {
//                [indexes addIndex:idx];
//            }
//        }];
//        
//        [self.tableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideUp];
//        [notes removeObjectsAtIndexes:indexes];
//        [self.tableView endUpdates];
//        [self refreshTableView];
//    }
    
    NSString *searchString = self.searchField.stringValue;
    if (searchString && ![searchString isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@)", searchString];
        notes = [self fetchNotesWithPredicate:predicate];
    }
    else
        notes = [self fetchNotesWithPredicate:nil];
   [self.tableView reloadData];
}

- (void)updateModifiedNote:(NSNotification *)notification
{
    //resort tableview based on modified date
    Note *note = notification.object;
    NSUInteger index = [notes indexOfObject:note];
    if (index != NSNotFound) {
        DLNoteCellView *cellView = [self.tableView viewAtColumn:0 row:index makeIfNecessary:NO];
        note.modifiedDate = [NSDate date];
        NSAttributedString *date = [self dateForNote:note Since:[NSDate date]];
        cellView.timeLabel.attributedStringValue = date;
        
//        
//        [notes sortUsingComparator:^NSComparisonResult(Note* note1, Note* note2) {
//            return [note2.modifiedDate compare:note1.modifiedDate];
//        }];
        
        notes = [self fetchNotesWithPredicate:nil];
        
        [self.tableView beginUpdates];
        if(index != 0) {
            [self.tableView moveRowAtIndex:index toIndex:0];
        }
        [self.tableView endUpdates];
    }
    

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
        //if (notesCopy) {
           // notes = [notesCopy mutableCopy]?:notes;
           // notesCopy = nil;
        notes = [self fetchNotesWithPredicate:nil];
            [self.tableView reloadData];
            if (selectedNote) {
                NSUInteger row = [notes indexOfObject:selectedNote];
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            }
      //  }
        else [self refreshTableView];
       
    }
    else active = NO;
}

- (void)mainWindow:(NSNotification *)notification
{
    if (self.tableView.window != notification.object) {
        deactiveMode = YES;
    }
    else {
        deactiveMode = NO;
    }
    
    [self refreshTableView];
}


- (void)noteNeedRefresh:(NSNotification *)notification
{
    Note *note = notification.object;
    NSUInteger index = [notes indexOfObject:note];
    if (index != NSNotFound) {
        if (index == self.tableView.selectedRow) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DLSingleNoteWindowRefresh object:nil];
        }
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }

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
        Note *note = notes[0];
        if (!note.content || [note.content.string isEqualToString:@""]) {
//            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideUp];
//           // [notes removeObjectAtIndex:0];
//            [self deleteNoteFromStore:notes[0]];
            
            if (notes.count > 1) {
                [self.tableView beginUpdates];
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideUp];
                //[notes removeObjectAtIndex:row];
                [self deleteNoteFromStore:notes[0]];
                [self.tableView endUpdates];
            }
            else {
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideUp];
                // [notes removeObjectAtIndex:row];
                [self deleteNoteFromStore:notes[0]];
                [[NSNotificationCenter defaultCenter] postNotificationName:DLChangeCurrentNoteNotification object:nil];
                 selectedNote = nil;
            }

            
             return YES;
        }
    }
    return NO;
}

- (void)addNewNote
{
   // DLNote *note = [[DLNote alloc]init];
   // note.title = @"New Note";
   // note.modifiedDate = [NSDate date];
    //[notes insertObject:note atIndex:0];
   Note *note =  [self addNewNoteToStore];
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
        Note *note = notes[self.tableView.selectedRow];
        note.title = title;
        cellView.titleLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:title attributes:titleAttr];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSAttributedString *) dateForNote:(Note *)note Since:(NSDate *)date
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
    Note* note =  notes[self.tableView.selectedRow];
    DLNoteWindowController *wc = noteWindows[note.uuid];
    if (!wc) {
      wc = [[DLNoteWindowController alloc]initWithWindowNibName:@"DLNoteWindowController"];
        noteWindows[note.uuid] = wc;
    }
    wc.note = note;
    [wc showWindow:self];
}

- (void)deleteNote:(id)sender
{
    NSUInteger row = self.tableView.selectedRow;
    NSString *title = ((Note *)notes[row]).title;
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
                [self deleteNoteFromStore:notes[row]];
                [self.tableView endUpdates];
            }
            else {
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
                [self deleteNoteFromStore:notes[row]];
                [[NSNotificationCenter defaultCenter] postNotificationName:DLChangeCurrentNoteNotification object:nil];
                selectedNote = nil;
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
            Note *note = notes[0];
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
    Note *note = notes[row];
    DLNoteCellView *cellView = [tableView makeViewWithIdentifier:CellIdentifier owner:self];
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:note.title attributes:titleAttr];
    
    NSAttributedString *time = [self dateForNote:note Since:[NSDate date]];
    cellView.titleLabel.attributedStringValue = title;
    cellView.timeLabel.attributedStringValue = time;
    
    if ([note isEqualTo:selectedNote]) {
        cellView.backgroundColor = deactiveMode? [NSColor gridColor] :( active ? activeColor : inactiveColor);
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
                cellView.backgroundColor = deactiveMode? [NSColor gridColor] :( active ? activeColor : inactiveColor);
                cellView.isSelected = YES;
               
            }
        }
        
   
    }
}
@end
