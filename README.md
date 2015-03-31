# CategoryUtils

 Intended to help you getting your IOS applications off the ground quickly, by offering categories classes that wrap a lot of the boilerplate that’s involved when writing IOS apps.
 
### Version
1.0.0

### CoreData Categories
--------
### Initialization

 You need to set the model name before first use. Typically in application:didFinishLaunchingWithOptions:
 ```sh
[[CA_CoreData shared] setModelName:@"CategoryUtilsModel"];
```
### Contexts

You can get main Context as follows:
 ```sh
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
```
If want background context instead you can do::
 ```sh
NSManagedObjectContext* backgroundContext = [NSManagedObjectContext backgroundContext];
```
The background context is run on private dispatch queues, so any operations on them should be wrapped in a performBlock:
NSManagedObjectContext* context = [NSManagedObjectContext backgroundContext];
 ```sh
NSManagedObjectContext* context = [NSManagedObjectContext backgroundContext];
[context performBlock:^{
    // insert or fetch new data in background.
}];
```
To savé background context to the main context:
 ```sh
 [backgroundContext saveToMainContext];
```
### Insert
----------

You can insert objects passing a NSDictionary (e.g: JSON from some webservice) as an argument as follows:
 ```sh
NSMutableDictionary *dog = [NSMutableDictionary new];
    dog[@"name"] = @"Snopy";
    dog[@"age"] = @"7";
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
[Dog CA_insertFromJsonDictionary:dogDictionary inManagedObjectContext:mainContext];
```
And you can do the reverse operation:
 ```sh
 NSDictionary *diciontaryFromManagedObject = [aDog CA_dictionaryFromManagedObject];
inManagedObjectContext:mainContext error:nil];
```
### Fetch
--------

If have a Dog Entity and you need to get all the dogs:
 ```sh
[Dog CA_fetchAllInContext:mainContext];
```
If you want a dog that has the name "Snopy":
 ```sh
NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",@"Snopy"];
NSArray *dustyDogs = [Dog CA_fetchByPredicate:predicate inContext:mainContext];
Dog *dustyDog = [dustyDogs objectAtIndex:0];
```
### Delete
-------

If you want delete all dogs:
 ```sh
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
[Dog CA_deleteAllInContext:mainContext];
```
