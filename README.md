# FastCoreData

Intended to help you getting your CoreData IOS applications off the ground quickly, by offering categories classes and class methods that wrap a lot of the boilerplate that’s involved when writing IOS apps which use CoreData.

<p align="center">
  <img src="http://zbutton.files.wordpress.com/2011/03/macosx_data_coredata_20090925.png" alt="Sublime's custom image"/>
</p>

 
### Version
1.0.0

### CoreData Categories
--------
### Initialization

 You need to set the model name before first use. Typically in application:didFinishLaunchingWithOptions:
 ```objc
[[CA_CoreData shared] setModelName:@"CategoryUtilsModel"];
```
### Contexts

You can get main Context as follows:
 ```sh
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
```
If want background context instead you can do::
 ```objc
NSManagedObjectContext* backgroundContext = [NSManagedObjectContext backgroundContext];
```
The background context is run on private dispatch queues, so any operations on them should be wrapped in a performBlock:
NSManagedObjectContext* context = [NSManagedObjectContext backgroundContext];
 ```objc
NSManagedObjectContext* context = [NSManagedObjectContext backgroundContext];
[context performBlock:^{
    // insert or fetch new data in background.
}];
```
To savé background context to the main context:
 ```objc
 [backgroundContext saveToMainContext];
```
### Insert
----------

You can insert objects passing dictionary (see Transformers Section below) as an argument as follows:
 ```objc
NSMutableDictionary *dog = [NSMutableDictionary new];
    dog[@"name"] = @"Snopy";
    dog[@"age"] = @"7";
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
[Dog CA_insertFromJsonDictionary:dogDictionary inManagedObjectContext:mainContext error:nil];
```
And you can do the reverse operation:
 ```sh
 NSDictionary *diciontaryFromManagedObject = [aDog CA_dictionaryFromManagedObject];
inManagedObjectContext:mainContext error:nil];
```
### Fetch
--------

If have a Dog Entity and you need to get all the dogs:
 ```objc
[Dog CA_fetchAllInContext:mainContext];
```
If you want a dog that has the name "Snopy":
 ```objc
NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",@"Snopy"];
NSArray *dustyDogs = [Dog CA_fetchByPredicate:predicate inContext:mainContext];
Dog *dustyDog = [dustyDogs objectAtIndex:0];
```
### Delete
-------

If you want delete all dogs:
 ```objc
NSManagedObjectContext* mainContext = [NSManagedObjectContext mainContext];
 [Dog CA_deleteAllInContext:mainContext];
```

### Transformers
--------

If you want to automatically persist data in JSON format with the aid of CA_insertFromJsonDictionary method then you must create transformers to conversions of dates and numbers

Steps to create a integer transformer:

1 - In CoreData model add the following fields to the user info of a property type integer:

 ```objc
Key: JsonTransformerName (Always the same)
Value: IntegerTransformer
```

2 - Create a conversion method

 ```objc
+ (NSValueTransformer *) stringToIntegerTransfomer {
    NSValueTransformer *transformer = [CA_ValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *value) {
        if (value) {
            return @([value integerValue]);
        }
        
        return nil;
    } reverseBlock:^id(NSNumber *value) {
        return [value stringValue];
    }];
    
    return transformer;
}
```

3 -  Register transformer

```objc
NSValueTransformer aStringToIntegerTransfomer = [ValueTransformerGenerator stringToIntegerTransfomer];
    [NSValueTransformer setValueTransformer:aStringToIntegerTransfomer forName:@"IntegerTransformer"];
```
