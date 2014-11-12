//
//  DLNote.h
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLNote : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong)NSDate *createdDate;
@property (nonatomic, strong)NSDate *modifiedDate;
@property (nonatomic, copy) NSString *title;
@end
