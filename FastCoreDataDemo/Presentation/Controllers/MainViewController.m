//
//  ViewController.m
//  CategoryUtilsDemo
//
//  Created by Tiago Flores on 02/02/15.
//  Copyright (c) 2015 zar. All rights reserved.
//

#import "MainViewController.h"
#import "Dog.h"
#import "NSManagedObjectsArray+CategoryUtils.h"
#import "NSManagedObject+CategoryUtils.h"
#import "NSManagedObjectContext+CategoryUtils.h"
#import "Owner.h"
#import "ValueTransformerGenerator.h"

@interface MainViewController ()
{
    NSValueTransformer *aStringToIntegerTransfomer;
    NSValueTransformer *aStringToDateTransfomer;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTransformers];
    [self deleteAllDogs];
    [self doTests];
}

- (void) setTransformers {
     aStringToIntegerTransfomer = [ValueTransformerGenerator stringToIntegerTransfomer];
    [NSValueTransformer setValueTransformer:aStringToIntegerTransfomer forName:@"IntegerTransformer"];
    
    aStringToDateTransfomer = [ValueTransformerGenerator stringToDateTransformer];
    [NSValueTransformer setValueTransformer:aStringToDateTransfomer forName:@"DateTransformer"];
}

- (void) deleteAllDogs {
    NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
    [Dog CA_deleteAllInContext:mainContext];
}
- (void) doTests {
    NSDictionary *dogWithTwoOwners = [self getDogWithTwoOwners];
    /*  insert dictionary into database In background Context and print values*/
    [self testOne:dogWithTwoOwners];
    
    NSDictionary *dogWithoutOwner = [self getDogWithoutOwner];
    [self testTwo:dogWithoutOwner];
}


- (NSDictionary *) getDogWithoutOwner {
    NSMutableDictionary *dogWithoutOwner = [NSMutableDictionary new];
    dogWithoutOwner[@"name"] = @"Dusty";
    dogWithoutOwner[@"breed"] = @"Poodle";
    dogWithoutOwner[@"age"] = @"7";
    return dogWithoutOwner;
}

- (void) testOne:(NSDictionary *) dogDictionary {
    NSLog(@"| Test One |");
    NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
    [Dog CA_insertFromJsonDictionary:dogDictionary inManagedObjectContext:mainContext error:nil];
    [mainContext save];
    
    NSArray *allDogs = [Dog CA_fetchAllInContext:mainContext];
    long numberOfDogs = [allDogs count];
    
    for (int i = 0; i < numberOfDogs; i++) {
        Dog *aDog = [allDogs objectAtIndex:i];
        NSLog(@"Dog(%d) attributes values are: Name = %@ ; Age = %ld", i, aDog.name, [aDog.age longValue]);
        NSArray *dogOwners = [aDog.owners allObjects];
        long numberOfOwners = dogOwners.count;
        for (int j = 0; j < numberOfOwners; j++) {
            Owner *aOwner = [dogOwners objectAtIndex:j];
             NSLog(@"Owner(%d) attributes values are: Name = %@ ; Birth Date = %@ ", j, aOwner.name, aOwner.birthDate);
        }
    }
    
}

- (NSDictionary *) getDogWithTwoOwners {
    NSMutableDictionary *bobOwner = [NSMutableDictionary new];
    bobOwner[@"name"] = @"Bob";
    bobOwner[@"birthDate"] = @"12-5-1988";
    NSMutableDictionary *aliceOwner = [NSMutableDictionary new];
    aliceOwner[@"name"] = @"Alice";
    aliceOwner[@"birthDate"] = @"2-12-1986";
    NSArray *owners = @[bobOwner, aliceOwner];
    
    NSMutableDictionary *dogWithTwoOwners= [NSMutableDictionary new];
    dogWithTwoOwners[@"name"] = @"Mickey";
    dogWithTwoOwners[@"breed"] = @"Pinscher";
    dogWithTwoOwners[@"age"] = @"1";
    dogWithTwoOwners[@"owners"] = owners;
    
    return dogWithTwoOwners;
}

- (void) testTwo:(NSDictionary *) dogDictionary {
    NSLog(@"| Test Two |");
    NSManagedObjectContext* context = [NSManagedObjectContext backgroundContext];
    
    [context performBlock:^{
        [Dog CA_insertFromJsonDictionary:dogDictionary inManagedObjectContext:context error:nil];
        [context saveToMainContext];
        
        NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Dusty"];
        NSArray *dustyDogs = [Dog CA_fetchByPredicate:predicate inContext:mainContext];
        Dog *dustyDog = [dustyDogs objectAtIndex:0];
        NSLog(@"Dog(0) attributes values are: Name = %@ ; Age = %ld", dustyDog.name, [dustyDog.age longValue]);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
