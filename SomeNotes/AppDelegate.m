//
//  AppDelegate.m
//  SomeNotes
//
//  Created by liewli on 11/11/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "AppDelegate.h"
#import "DLPadView.h"
#import "DLSingleNoteWindow.h"

@interface AppDelegate () <NSSplitViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong)DLPadView *padView;
@property (nonatomic, strong)DLSingleNoteWindow *singleNoteView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _padView = [[DLPadView alloc]init];
    _singleNoteView = [[DLSingleNoteWindow alloc]init];
    
    self.splitView.vertical = YES;
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
    NSRect winFrame = self.window.frame;
    winFrame.size.width = 700;
    winFrame.size.height = 500;
    [self.window setFrame:winFrame display:NO];
    [self.window setMinSize:NSMakeSize(400, 400)];
    

    
    
    [self.splitView addSubview:_padView.view];
    NSRect frame = _padView.view.frame;
    frame.size.width = 200;
    _padView.view.frame = frame;
    [self.splitView addSubview:_singleNoteView.view];
    
    [self.splitView adjustSubviews];
    
    [self initializeCoreDataStack];
    
}

- (void)initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Note" withExtension:@"momd"];
    NSAssert(!modelURL, @"Failed to find model url.");
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    NSAssert(!mom, @"Failed to initialize model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(!psc, @"Failed to create persistent store coordinator");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // add perisistent store
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *storeURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        storeURL = [storeURL URLByAppendingPathComponent:@"SomeNotes.sqlite"];
        
        __autoreleasing NSError *error;
        
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        
        if (!error) {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
    });
    
    self.moc = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.moc setPersistentStoreCoordinator:psc];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - NSSPlitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return  NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return 200;
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    NSSize size = self.splitView.frame.size;
    return size.width - 200;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    if (view == self.padView.view) {
       // if (view.frame.size.width <= 200) {
            return NO;
        //}
    }
    
    return YES;
}


@end
