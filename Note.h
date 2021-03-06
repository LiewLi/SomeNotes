//
//  Note.h
//  SomeNotes
//
//  Created by liewli on 11/26/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, copy) NSAttributedString  *content;
@property (nonatomic, copy) NSDate * modifiedDate;
@property (nonatomic, copy) NSString * uuid;
@property (nonatomic, copy) NSString * title;

@end
