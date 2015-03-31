//
//  ValueTransformerGenerator.h
//  CategoryUtilsDemo
//
//  Created by Tiago Flores on 02/02/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueTransformerGenerator : NSObject

+ (NSValueTransformer *) stringToIntegerTransfomer;
+ (NSValueTransformer *)stringToDateTransformer;

@end
