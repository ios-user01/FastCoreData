//
//  NSManagedObjectContext+CategoryUtils.m
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

#import "NSManagedObjectContext+CategoryUtils.h"
#import "CA_CoreData.h"

static dispatch_once_t*			_storeContextTokenRef;
static dispatch_once_t*			_mainContextTokenRef;
static dispatch_once_t*			_backgroundContextTokenRef;
static NSManagedObjectContext*	_storeContext;
static NSManagedObjectContext*	_mainContext;
static NSManagedObjectContext*	_backgroundContext;

@implementation NSManagedObjectContext (CategoryUtils)

@dynamic
undoEnabled;

#pragma mark - Lifecycle

- (BOOL)save
{
	if (![self hasChanges]) return YES;
	
	NSError* error = nil;
	
	if (![self save:&error]) {
		NSLog(@"NSManagedObjectContext Error: %@", [error userInfo]);
		
		NSArray* details = [[error userInfo] objectForKey:@"NSDetailedErrors"];
		
		for (NSError* err in details)
			NSLog(@"Error %li: %@", (long)[err code], [err userInfo]);
		return NO;
	}
	
	return YES;
}

- (BOOL) saveToMainContext {
    return [self saveNested];
}

- (BOOL)saveNested {
	if ([self save]) {
		
		NSManagedObjectContext* context = [self parentContext];
		
		if (!context)
			return YES;
		
		__block BOOL save = NO;
		
		if (context)
			[context performBlockAndWait:^{
				
				save = [context saveNested];
			}];
		
		return save;
	}
	
	return NO;
}

- (void)saveNestedAsynchronous {
	[self saveNestedAsynchronousWithCallback:nil];
}

- (void)saveNestedAsynchronousWithCallback:(CA_CoreDataSaveCompleteBlock)block {
	if ([self save]) {
		
		NSManagedObjectContext* context = [self parentContext];
		
		if (context)
			[context performBlock:^{
				
				[context saveNestedAsynchronousWithCallback:block];
			}];
		else if (block)
			block(YES);
	}
	else if (block)
		block(NO);
}

+ (void)rebuildAllContexts {
    if (_mainContextTokenRef)
        *_mainContextTokenRef = 0;

    if (_storeContextTokenRef)
        *_storeContextTokenRef = 0;

    if (_backgroundContextTokenRef)
        *_backgroundContextTokenRef	= 0;

	_mainContext		= nil;
	_storeContext		= nil;
	_backgroundContext	= nil;
}

+ (NSManagedObjectContext *)mainContext {
	static dispatch_once_t token	= 0;
	_mainContextTokenRef			= &token;
	
	dispatch_once(&token, ^{
		
		_mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_mainContext setParentContext:[self storeContext]];
	});
	
	return _mainContext;
}

+ (NSManagedObjectContext *)storeContext {
	static dispatch_once_t token	= 0;
	_storeContextTokenRef			= &token;
	
	dispatch_once(&token, ^{
		
		_storeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		[_storeContext setPersistentStoreCoordinator:[[CA_CoreData shared] storeCoordinator]];
	});
	
	return _storeContext;
}

+ (NSManagedObjectContext *)backgroundContext {
	static dispatch_once_t token	= 0;
	_backgroundContextTokenRef		= &token;
	
	dispatch_once(&token, ^{
		
		_backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		[_backgroundContext setParentContext:[self mainContext]];
	});
	
	return _backgroundContext;
}

#pragma mark - Properties

- (void)setUndoEnabled:(BOOL)undoEnabled {
	if (undoEnabled && ![self isUndoEnabled])
		[self setUndoManager:[[NSUndoManager alloc] init]];
	else if (!undoEnabled)
		[self setUndoManager:nil];
}

- (BOOL)isUndoEnabled {
	return !![self undoManager];
}

+ (NSArray*) objectIDsForManagedObjects:(NSArray*)objects {
    NSMutableArray *objectsIds = nil;
    
    if (objects) {
        objects = [NSMutableArray new];
        [objects enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger idx, BOOL *stop) {
            [objectsIds addObject:[object objectID]];
        }];
    }

    return objectsIds;
}

- (NSArray*)objectsWithIDs:(NSArray*)objectIDs {
    NSMutableArray *objects = nil;
    if(objectIDs) {
        objects = [NSMutableArray new];
        [objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
            NSManagedObject *object = [self objectWithID:objectID];
            [objects addObject:object];
        }];
    }

    return objects;
}


@end
