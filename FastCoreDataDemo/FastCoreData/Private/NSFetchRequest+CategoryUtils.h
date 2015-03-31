//
//  NSFetchedRequest+CategoryUtils.h
//  NSMutableDictionary+Utils
//
//  Created by Tiago Flores on 31/01/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchRequest  (CategoryUtils)

+ (instancetype)fetchRequestWithEntity:(Class)entity context:(NSManagedObjectContext *)context;

@end
