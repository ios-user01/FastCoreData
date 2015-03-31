//
//  NSManagedObject+CategoryUtils.m
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 31/12/14.
//  Copyright (c) 2014 zar. All rights reserved.
//

#import "NSManagedObject+CategoryUtils.h"
#import "NSManagedObjectsArray+CategoryUtils.h"
#import "NSFetchRequest+CategoryUtils.h"
#import "NSAttributeDescription+CategoryUtils.h"
#import "NSEntityDescription+CategoryUtils.h"
#import "NSPropertyDescription+CategoryUtils.h"
#import "NSDictionary+CategoryUtils.h"

@implementation NSManagedObject (CategoryUtils)


+ (id)CA_insertFromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(JsonDictionary);
    
    NSString *entityName = NSStringFromClass([self class]);
    return [[self CA_insertObjectsForEntityName:entityName fromJsonArray:@[JsonDictionary] inManagedObjectContext:context error:error] firstObject];
}

+ (id)CA_insertObjectForEntityName:(NSString *)entityName fromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(JsonDictionary);
    
    return [[self CA_insertObjectsForEntityName:entityName fromJsonArray:@[JsonDictionary] inManagedObjectContext:context error:error] firstObject];
}

+ (NSArray *)CA_insertObjectsForEntityName:(NSString *)entityName fromJsonArray:(NSArray *)JsonArray inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(entityName);
    NSParameterAssert(JsonArray);
    NSParameterAssert(context);
    
    NSError * __block tmpError = nil;
    NSMutableArray * __block managedObjects = [NSMutableArray arrayWithCapacity:JsonArray.count];
    
    if (JsonArray.count == 0) {
        // Return early and avoid any processing in the context queue
        return managedObjects;
    }
    
    [context performBlockAndWait:^{
        for (NSDictionary *dictionary in JsonArray) {
            if ([dictionary isEqual:NSNull.null]) {
                continue;
            }
            
            if (![dictionary isKindOfClass:NSDictionary.class]) {
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Cannot serialize value %@. Expected a Json dictionary.", @""), dictionary];
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: message
                                           };
                
                tmpError = [NSError errorWithDomain:@"domain" code:10 userInfo:userInfo];
                
                break;
            }
            
            NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            NSDictionary *propertiesByName = managedObject.entity.propertiesByName;
            
            [propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSPropertyDescription *property, BOOL *stop) {
                if ([property isKindOfClass:NSAttributeDescription.class]) {
                    *stop = ![self CA_serializeAttribute:(NSAttributeDescription *)property fromJsonDictionary:dictionary inManagedObject:managedObject merge:NO error:&tmpError];
                } else if ([property isKindOfClass:NSRelationshipDescription.class]) {
                    *stop = ![self CA_serializeRelationship:(NSRelationshipDescription *)property fromJsonDictionary:dictionary inManagedObject:managedObject merge:NO error:&tmpError];
                }
            }];
            
            if (tmpError == nil) {
                [managedObjects addObject:managedObject];
            } else {
                [context deleteObject:managedObject];
                break;
            }
        }
    }];
    
    if (error != nil) {
        *error = tmpError;
    }
    
    return managedObjects;
}


+ (id)CA_mergeFromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(JsonDictionary);
    
    NSString *entityName = NSStringFromClass([self class]);
    return [[self CA_mergeObjectsForEntityName:entityName fromJsonArray:@[JsonDictionary] inManagedObjectContext:context error:error] firstObject];
}


+ (id)CA_mergeObjectForEntityName:(NSString *)entityName fromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(JsonDictionary);
    
    return [[self CA_mergeObjectsForEntityName:entityName fromJsonArray:@[JsonDictionary] inManagedObjectContext:context error:error] firstObject];
}

+ (NSArray *)CA_mergeObjectsForEntityName:(NSString *)entityName fromJsonArray:(NSArray *)JsonArray inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSParameterAssert(entityName);
    NSParameterAssert(JsonArray);
    NSParameterAssert(context);
    
    NSError * __block tmpError = nil;
    NSMutableArray * __block managedObjects = [NSMutableArray arrayWithCapacity:JsonArray.count];
    
    if (JsonArray.count == 0) {
        // Return early and avoid any processing in the context queue
        return managedObjects;
    }
    
    [context performBlockAndWait:^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        
        NSAttributeDescription *identityAttribute = [entity CA_identityAttribute];
        NSAssert(identityAttribute != nil, @"An identity attribute must be specified in order to merge objects");
        
        NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:JsonArray.count];
        for (NSDictionary *dictionary in JsonArray) {
            if ([dictionary isEqual:NSNull.null]) {
                continue;
            }
            
            if (![dictionary isKindOfClass:NSDictionary.class]) {
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Cannot serialize value %@. Expected a Json dictionary.", @""), dictionary];
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: message
                                           };
                
                tmpError = [NSError errorWithDomain:@"domain error" code:10 userInfo:userInfo];
                return;
            }
            
            id identifier = [dictionary CA_valueForJsonAttribute:identityAttribute];
            if (identifier != nil) {
                [identifiers addObject:identifier];
            }
            
        }
        
        NSDictionary *existingObjects = [self CA_fetchObjectsForEntity:entity withIdentifiers:identifiers inManagedObjectContext:context error:&tmpError];
        
        for (NSDictionary *dictionary in JsonArray) {
            if ([dictionary isEqual:NSNull.null]) {
                continue;
            }
            
            NSManagedObject *managedObject = nil;
            id identifier = [dictionary CA_valueForJsonAttribute:identityAttribute];
            
            if (identifier) {
                managedObject = existingObjects[identifier];
            }
            
            if (!managedObject) {
                managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            }
            
            NSDictionary *propertiesByName = managedObject.entity.propertiesByName;
            
            [propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSPropertyDescription *property, BOOL *stop) {
                if ([property isKindOfClass:NSAttributeDescription.class]) {
                    *stop = ![self CA_serializeAttribute:(NSAttributeDescription *)property fromJsonDictionary:dictionary inManagedObject:managedObject merge:YES error:&tmpError];
                } else if ([property isKindOfClass:NSRelationshipDescription.class]) {
                    *stop = ![self CA_serializeRelationship:(NSRelationshipDescription *)property fromJsonDictionary:dictionary inManagedObject:managedObject merge:YES error:&tmpError];
                }
            }];
            
            if (tmpError == nil) {
                [managedObjects addObject:managedObject];
            } else {
                [context deleteObject:managedObject];
                break;
            }
        }
    }];
    
    if (error != nil) {
        *error = tmpError;
    }
    
    return managedObjects;
}


+ (BOOL)CA_serializeAttribute:(NSAttributeDescription *)attribute fromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObject:(NSManagedObject *)managedObject merge:(BOOL)merge error:(NSError *__autoreleasing *)error {
    
    if (attribute == nil) {
        return YES;
    }
    
    NSString *keyPath = attribute.name;
    
    if (keyPath == nil) {
        return YES;
    }
    
    id value = [JsonDictionary valueForKeyPath:keyPath];
    
    if (merge && value == nil) {
        return YES;
    }
    
    if ([value isEqual:NSNull.null]) {
        value = nil;
    }
    
    if (value != nil) {
        NSValueTransformer *transformer = [attribute CA_jsonTransformer];
        if (transformer) {
            value = [transformer transformedValue:value];
        }
    }
    
    if ([managedObject validateValue:&value forKey:attribute.name error:error]) {
        [managedObject setValue:value forKey:attribute.name];
        return YES;
    }
    
    return NO;
}

+ (BOOL)CA_serializeRelationship:(NSRelationshipDescription *)relationship fromJsonDictionary:(NSDictionary *)JsonDictionary inManagedObject:(NSManagedObject *)managedObject merge:(BOOL)merge error:(NSError *__autoreleasing *)error {
    
    if (relationship == nil) {
        return YES;
    }
    
    NSString *keyPath = relationship.name;
    
    if (keyPath == nil) {
        return YES;
    }
    
    id value = [JsonDictionary valueForKeyPath:keyPath];
    
    if (merge && value == nil) {
        return YES;
    }
    
    if ([value isEqual:NSNull.null]) {
        value = nil;
    }
    
    if (value != nil) {
        NSString *entityName = relationship.destinationEntity.name;
        NSManagedObjectContext *context = managedObject.managedObjectContext;
        NSError *tmpError = nil;
        
        if ([relationship isToMany]) {
            if (![value isKindOfClass:[NSArray class]]) {
                if (error) {
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Cannot serialize '%@' into a to-many relationship. Expected a Json array.", @""), relationship.name];
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: message
                                               };
                    
                    //*error = [NSError errorWithDomain:GRTJsonSerializationErrorDomain code:GRTJsonSerializationErrorInvalidJsonObject userInfo:userInfo];
                    *error = [NSError errorWithDomain:@"domain Error" code:10 userInfo:userInfo];
                }
                
                return NO;
            }
            
        
             NSArray *objects = merge
             ? [self CA_mergeObjectsForEntityName:entityName fromJsonArray:value inManagedObjectContext:context error:&tmpError]
             : [self CA_insertObjectsForEntityName:entityName fromJsonArray:value inManagedObjectContext:context error:&tmpError];
             
            
            value = [relationship isOrdered] ? [NSOrderedSet orderedSetWithArray:objects] : [NSSet setWithArray:objects];
        } else {
            if (![value isKindOfClass:[NSDictionary class]]) {
                if (error) {
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Cannot serialize '%@' into a to-one relationship. Expected a Json dictionary.", @""), relationship];
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: message
                                               };
                    
                    *error = [NSError errorWithDomain:@"domain "code:10 userInfo:userInfo];
                }
                
                return NO;
            }
            
            
            value = merge
            ? [self CA_mergeObjectForEntityName:entityName fromJsonDictionary:value inManagedObjectContext:context error:&tmpError]
            : [self CA_insertObjectForEntityName:entityName fromJsonDictionary:value inManagedObjectContext:context error:&tmpError];
        }
        
        if (tmpError != nil) {
            if (error) {
                *error = tmpError;
            }
            return NO;
        }
    }
    
    if ([managedObject validateValue:&value forKey:relationship.name error:error]) {
        [managedObject setValue:value forKey:relationship.name];
        return YES;
    }
    
    return NO;
}



- (NSDictionary *)CA_dictionaryFromManagedObject {
    // Keeping track of in process relationships avoids infinite recursion when serializing inverse relationships
    NSMutableSet *trackedRelationships = [NSMutableSet set];
    NSManagedObject *managedObject = self;
    return [NSManagedObject CA_dictionaryFromManagedObject:managedObject trackedRelationships :trackedRelationships ];
}


+ (NSDictionary *)CA_dictionaryFromManagedObject:(NSManagedObject *)managedObject trackedRelationships :(NSMutableSet *)trackedRelationships {
    NSMutableDictionary * __block dictionary = nil;
    NSManagedObjectContext *context = managedObject.managedObjectContext;
    
    if (!managedObject) {
        return nil;
    }
    
    [context performBlockAndWait:^{
        NSDictionary *propertiesByName = managedObject.entity.propertiesByName;
        dictionary = [NSMutableDictionary dictionaryWithCapacity:propertiesByName.count];
        
        [propertiesByName enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSPropertyDescription *property, BOOL *stop) {
            NSString *propertyName = property.name;
            
            if (propertyName == nil) {
                return;
            }
            
            id value = [managedObject valueForKey:propertyName];
            
            if ([property isKindOfClass:NSAttributeDescription.class]) {
                
                NSAttributeDescription *attribute = (NSAttributeDescription *)property;
                NSValueTransformer *transformer = [attribute CA_jsonTransformer];
                
                if (transformer != nil && [transformer.class allowsReverseTransformation]) {
                    value = [transformer reverseTransformedValue:value];
                }
                
                
            } else if ([property isKindOfClass:NSRelationshipDescription.class]) {
                
                NSRelationshipDescription *relationshipDescription = (NSRelationshipDescription *)property;
                
                if ([trackedRelationships containsObject:relationshipDescription.inverseRelationship]) {
                    // Skip if the inverse relationship is being serialized
                    return;
                }
                
                [trackedRelationships addObject:relationshipDescription];
                
                value = [NSManagedObject CA_getDictionaryValueFromManagedObject:managedObject withRelationshipDescription:relationshipDescription trackedRelationships:trackedRelationships];
            }
            
            
            if (value == nil) {
                value = NSNull.null;
            }
            
            [dictionary setValue:value forKeyPath:propertyName];
        }];
    }];
    
    return dictionary;
}


+ (id) CA_getDictionaryValueFromManagedObject:(NSManagedObject *)managedObject withRelationshipDescription:(NSRelationshipDescription *) relationshipDescription  trackedRelationships :(NSMutableSet *)trackedRelationships {
    id value;
    
    id relationshipObject = [managedObject valueForKey:relationshipDescription.name];

    if ([relationshipDescription isToMany]) {
        NSArray *objects = [relationshipObject isKindOfClass:NSOrderedSet.class] ? [relationshipObject array] : [relationshipObject allObjects];
        value  = [NSArray CA_dictionaryArrayFromManagedObjects:objects trackedRelationships :trackedRelationships ];
        
    } else {
        value = [NSManagedObject CA_dictionaryFromManagedObject:relationshipObject trackedRelationships :trackedRelationships ];
    }
    
    return value;
}

+ (NSArray *) CA_fetchAllInContext:(NSManagedObjectContext *)context {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntity:[self class] context:context];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    
    return ([objects count] > 0) ? objects : nil;
}

+ (NSArray *) CA_fetchByPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *) context {

    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntity:[self class] context:context];
    
    if (predicate != nil) {
        [fetchRequest setPredicate: predicate];
    }

    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    
    return ([objects count] > 0) ? objects : nil;
}


/**
* Useful method for efficiently fetch data in batchs
* See Pre-fetching section in:
* https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdPerformance.html
* @param attributeName A NSString attribute of Entity. Eg: employeeId
* @param groupOfValues A NsArray of attributes values. Eg: List of employeeIds
* @return A group of entities
*/
+ (NSArray *) CA_fetchInBatchByAttribute:(NSString *)attributeName arrayOfValues:(NSArray *) arrayOfValues inContext:(NSManagedObjectContext *) context {
     NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntity:[self class] context:context];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(self.%@ IN %@)", attributeName, arrayOfValues]];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    
    return ([objects count] > 0) ? objects : nil;
}



+ (NSDictionary *)CA_fetchObjectsForEntity:(NSEntityDescription *)entity withIdentifiers:(NSArray *)identifiers inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    NSString *identityKey = [[entity CA_identityAttribute] name];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", identityKey, identifiers];
    
    NSArray *objects = [context executeFetchRequest:fetchRequest error:error];
    
    if (objects.count > 0) {
        NSMutableDictionary *objectsByIdentifier = [NSMutableDictionary dictionaryWithCapacity:objects.count];
        
        for (NSManagedObject *object in objects) {
            id identifier = [object valueForKey:identityKey];
            objectsByIdentifier[identifier] = object;
        }
        
        return objectsByIdentifier;
    }
    
    return nil;
}

+ (void) CA_deleteAllInContext:(NSManagedObjectContext *)context  {
    
    NSError *error;
    NSArray *objects = [self CA_fetchAllInContext:context];
    
    for (NSManagedObject *managedObject in objects) {
        [context deleteObject:managedObject];
    }
    
    if (!  [context save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",self,error);
    }
}

+ (void) CA_deleteByPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *) context {
    
    NSError *error;
    NSArray *objects = [self CA_fetchByPredicate:predicate inContext:(NSManagedObjectContext *) context];
    
    for (NSManagedObject *managedObject in objects) {
        [context deleteObject:managedObject];
    }
    
    if (!  [context save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",self,error);
    }

}


@end
