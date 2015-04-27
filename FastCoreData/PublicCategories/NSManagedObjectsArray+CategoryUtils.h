//
//  NSManagedObjectsArray+CategoryUtils.h
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 01/01/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+CategoryUtils.h"

#define NSManagedObjectsArray NSArray

@interface NSManagedObjectsArray (CategoryUtils)


- (NSArray *)CA_dictionaryArrayFromManagedObjects;
+ (NSArray *)CA_dictionaryArrayFromManagedObjects:(NSArray *)managedObjects trackedRelationships :(NSMutableSet *)trackedRelationships ;

@end
