//
//  NSManagedObjectsArray+CategoryUtils.m
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 01/01/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import "NSManagedObjectsArray+CategoryUtils.h"

@implementation NSManagedObjectsArray (CategoryUtils)


- (NSArray *)CA_dictionaryArrayFromManagedObjects {
    // Keeping track of relationships avoids infinite recursion when serializing inverse relationships
    
    NSArray *arrayManagedObjects = self;
    NSMutableSet *trackedRelationships  = [NSMutableSet set];
    return [NSArray CA_dictionaryArrayFromManagedObjects:arrayManagedObjects trackedRelationships :trackedRelationships ];
}


+ (NSArray *)CA_dictionaryArrayFromManagedObjects:(NSArray *)arrayManagedObjects trackedRelationships :(NSMutableSet *)trackedRelationships {
    
    NSMutableArray *dictionaryArray = [NSMutableArray arrayWithCapacity:arrayManagedObjects.count];
    
    for (NSManagedObject *managedObject in arrayManagedObjects) {
            NSDictionary *dictionary = [NSManagedObject CA_dictionaryFromManagedObject:managedObject trackedRelationships:trackedRelationships];
            [dictionaryArray addObject:dictionary];
    }
    
    return dictionaryArray;
}





@end
