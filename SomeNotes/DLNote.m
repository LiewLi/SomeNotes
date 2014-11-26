//
//  DLNote.m
//  SomeNotes
//
//  Created by liewli on 11/12/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLNote.h"

@implementation DLNote

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if ([other class] != [DLNote class]){
        return NO;
    } else {
        return [_UUID isEqualToString:((DLNote *)other).UUID];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
//        _UUID = [[NSUUID UUID] UUIDString];
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        _UUID = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
    }
    
    return self;
}

- (NSUInteger)hash
{
    return [_content hash];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setContent:[self.content copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setModifiedDate:[self.modifiedDate copyWithZone:zone]];
        [copy setUUID:[self.UUID copyWithZone:zone]];
    }
    return copy;
}
@end
