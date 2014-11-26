//
//  DLAttributedStringTransformer.m
//  SomeNotes
//
//  Created by liewli on 11/26/14.
//  Copyright (c) 2014 li liew. All rights reserved.
//

#import "DLAttributedStringTransformer.h"

@implementation DLAttributedStringTransformer

+ (Class)transformedValueClass
{
    return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    //TODO: transform
    return nil;
}

- (id)reverseTransformedValue:(id)value
{
    //TODO: reverse transform
    return nil;
}

@end
