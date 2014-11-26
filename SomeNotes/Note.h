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

@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * title;

@end
