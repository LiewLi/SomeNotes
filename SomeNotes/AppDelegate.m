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
#import "DLAttributedStringTransformer.h"

static NSString * DLAtttributedStringTransformer = @"DLAtttributedStringTransformer";

@interface AppDelegate () <NSSplitViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong)DLPadView *padView;
@property (nonatomic, strong)DLSingleNoteWindow *singleNoteView;

@end

@implementation AppDelegate

+(void)initialize
{
    DLAttributedStringTransformer *transformer = [[DLAttributedStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:DLAtttributedStringTransformer];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _singleNoteView = [[DLSingleNoteWindow alloc]init];
    _padView = [[DLPadView alloc]init];
    
    
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
    
//    [self.window setRestorable:YES];
//    self.window.identifier = @"SomeNotesWindow";
//    [self.window setRestorationClass:[self class]];
    
    
}



#pragma mark - Resume NSWindowRestoration
//+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
//    completionHandler(appDelegate.window, NULL);
//}




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
