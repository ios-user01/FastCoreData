//
//  NLCoreData.m
//  
//  Created by Tiago Flores
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//  

#import <CoreData/CoreData.h>
#import "CA_CoreData.h"

@interface CA_CoreData ()

- (void)addPersistentStore;

@end

@implementation CA_CoreData

#pragma mark - Lifecycle

+ (CA_CoreData *)shared {
	static dispatch_once_t onceToken;
	__strong static id instance = nil;
	
	dispatch_once(&onceToken, ^{
		
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (void)useDatabaseFile:(NSString *)filePath {
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"%@ File does not exis at path: %@", self, filePath);
		return;
	}
	
	NSError* error = nil;
	
	if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:[self storePath] error:&error]) {
        NSLog(@"Could not copy file at file Path : %@", filePath);
	}
}

- (BOOL)resetDatabase {
	NSArray* stores = [[self storeCoordinator] persistentStores];
	
	if (![stores count])
		return YES;
	
	NSError* storeError = nil;
	
	if (![[self storeCoordinator] removePersistentStore:stores[0] error:&storeError]) {
        NSLog(@"Persistent Store error = %@ ", [storeError localizedDescription]);

		return NO;
	}
	
	NSFileManager* fm	= [NSFileManager defaultManager];
	NSString* storePath	= [self storePath];
	NSError* fileError	= nil;
	
	if (![fm fileExistsAtPath:storePath])
		return YES;
	
	if (![fm removeItemAtPath:storePath error:&fileError]) {
        NSLog(@"FileManage error = %@ ", fileError);
		[self addPersistentStore];
		return NO;
	}
	
	[self setManagedObjectModel:nil];
	[self setStoreCoordinator:nil];
	[NSManagedObjectContext rebuildAllContexts];
	
	return YES;
}

#pragma mark - Helpers

- (void)addPersistentStore {
	NSError* error = nil;
	
	if (![[self storeCoordinator] addPersistentStoreWithType:[self persistentStoreType] configuration:nil URL:[self storeURL] options:[self persistentStoreOptions] error:&error]) {
		NSLog(@"metaData: %@", [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:[self storeURL] error:nil]);
		NSLog(@"source and dest equivalent? %i", [[[error userInfo] valueForKeyPath:@"sourceModel"] isEqual:[[error userInfo] valueForKeyPath:@"destinationModel"]]);
		NSLog(@"failreason: %@", [[error userInfo] valueForKeyPath:@"reason"]);
        NSLog(@"Persistent Store error = %@ ", [error localizedDescription]);
	}
}

#pragma mark - Properties

- (NSString *)modelName {
	if (_modelName)
		return _modelName;
	
	_modelName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	
	return _modelName;
}

- (NSString *)storePath {
	NSArray* paths			= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString* pathComponent = [[self modelName] stringByAppendingString:@".sqlite"];
	
	return [[paths lastObject] stringByAppendingPathComponent:pathComponent];
}

- (NSURL *)storeURL {
	NSArray* urls			= [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
	NSString* pathComponent	= [[self modelName] stringByAppendingString:@".sqlite"];
	
	return [[urls lastObject] URLByAppendingPathComponent:pathComponent];
}

- (void)setStoreEncrypted:(BOOL)storeEncrypted {
    
	NSString* encryption		= storeEncrypted ? NSFileProtectionComplete : NSFileProtectionNone;
	NSDictionary* attributes	= @{NSFileProtectionKey: encryption};
	NSError* error;
	
	if (![[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:[self storePath] error:&error]) {
        NSLog(@"Encryption Error = %@ ", [error localizedDescription]);
	}
}

- (BOOL)storeExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self storePath]];
}

- (BOOL)isStoreEncrypted {
	NSError* error				= nil;
	NSDictionary* attributes	= [[NSFileManager defaultManager] attributesOfItemAtPath:[self storePath] error:&error];
	
	if (!attributes) {
          NSLog(@"Encryption Error = %@ ", [error localizedDescription]);
		return NO;
	}
	
	return [attributes[NSFileProtectionKey] isEqualToString:NSFileProtectionComplete];
}

- (NSDictionary *)persistentStoreOptions {
	if (_persistentStoreOptions)
		return _persistentStoreOptions;
	
	_persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
	
	return _persistentStoreOptions;
}

- (NSString *)persistentStoreType {
	if (_persistentStoreType)
		return _persistentStoreType;
	
	_persistentStoreType = NSSQLiteStoreType;
	
	return _persistentStoreType;
}

- (NSPersistentStoreCoordinator *)storeCoordinator {
	if (_storeCoordinator)
		return _storeCoordinator;
	
	_storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	[self addPersistentStore];
	
	return _storeCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel)
		return _managedObjectModel;
	
	NSURL* url			= [[NSBundle mainBundle] URLForResource:[self modelName] withExtension:@"mom"];
	_managedObjectModel	= [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	
	return _managedObjectModel;
}

@end
