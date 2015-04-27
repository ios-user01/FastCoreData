//
//  NSFetchedRequest+CategoryUtils.m
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 31/01/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import "NSFetchRequest+CategoryUtils.h"


@implementation NSFetchRequest (CategoryUtils)

+ (instancetype)fetchRequestWithEntity:(Class)entity context:(NSManagedObjectContext *)context
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:NSStringFromClass(entity) inManagedObjectContext:context]];
    return request;
}

@end
