//
//  DLNote.h
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLNote : NSObject <NSCopying>
//@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSAttributedString *content;
@property (nonatomic, strong)NSDate *modifiedDate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy)NSString *UUID;
@end
