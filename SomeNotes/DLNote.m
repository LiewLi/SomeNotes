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
        return [_content isEqualToString:((DLNote *)other).content];
    }
}

- (NSUInteger)hash
{
    return [_content hash];
}
@end
