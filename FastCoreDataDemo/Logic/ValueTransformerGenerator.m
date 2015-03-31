//
//  ValueTransformerGenerator.m
//  CategoryUtilsDemo
//
//  Created by Tiago Flores on 02/02/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import "ValueTransformerGenerator.h"
#import "CA_ValueTransformer.h"

@implementation ValueTransformerGenerator

+ (NSValueTransformer *) stringToIntegerTransfomer {
    NSValueTransformer *transformer = [CA_ValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *value) {
        if (value) {
            return @([value integerValue]);
        }
        
        return nil;
    } reverseBlock:^id(NSNumber *value) {
        return [value stringValue];
    }];
    
    return transformer;
}

+ (NSValueTransformer *)stringToDateTransformer {
    return [CA_ValueTransformer  reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    return dateFormatter;
}

@end
