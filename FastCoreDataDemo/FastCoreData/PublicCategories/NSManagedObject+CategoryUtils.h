//
//  NSManagedObject+CategoryUtils.h
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 31/12/14.
//  Copyright (c) 2014 zar. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObject (CategoryUtils)

#pragma Dictionary Conversion

- (NSDictionary *) CA_dictionaryFromManagedObject;

+ (NSDictionary *) CA_dictionaryFromManagedObject:(NSManagedObject *)managedObject trackedRelationships :(NSMutableSet *)trackedRelationships  ;

#pragma Insert methods

+ (id)CA_insertFromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error;

#pragma Update methods

+ (id)CA_mergeFromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error;

#pragma Fetch methods

+ (NSArray *) CA_fetchAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *) CA_fetchByPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *) context;

+ (NSArray *) CA_fetchInBatchByAttribute:(NSString *)attributeName arrayOfValues:(NSArray *) arrayOfValues inContext:(NSManagedObjectContext *) context;

#pragma Delete methods

+ (void) CA_deleteAllInContext:(NSManagedObjectContext *)context;

+ (void) CA_deleteByPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *) context;

@end
