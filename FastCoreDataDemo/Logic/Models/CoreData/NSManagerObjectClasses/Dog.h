//
//  Dog.h
//  CategoryUtilsDemo
//
//  Created by Tiago Flores on 02/02/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owner;

@interface Dog : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * breed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *owners;
@end

@interface Dog (CoreDataGeneratedAccessors)

- (void)addOwnersObject:(Owner *)value;
- (void)removeOwnersObject:(Owner *)value;
- (void)addOwners:(NSSet *)values;
- (void)removeOwners:(NSSet *)values;

@end
