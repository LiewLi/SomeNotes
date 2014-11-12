//
//  DLNoteCellView.h
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DLBackgroundView.h"

static NSString * CellIdentifier = @"DLNoteCellView";

@interface DLNoteCellView : DLBackgroundView
@property (nonatomic, weak)IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak)IBOutlet NSTextField *timeLabel;
@property (nonatomic, assign) BOOL isSelected;
@end
