//
//  Owner.h
//  CategoryUtilsDemo
//
//  Created by Tiago Flores on 02/02/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dog;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSDate * birthDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Dog *dog;

@end
