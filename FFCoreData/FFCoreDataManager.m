//
//  WNCoreDataManager.m
//  WhoNote
//
//  Created by Cory D. Wiles on 1/24/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataManager.h"

NSString * const FFCoreDataManagerDidSaveNotification       = @"WNCoreDataManagerDidSaveNotification";
NSString * const FFCoreDataManagerDidSaveFailedNotification = @"WNCoreDataManagerDidSaveFailedNotification";

static NSString *WNCoreManagerModelName  = @"FFCoreData";
static NSString *WNCoreManagerSQLiteName = @"FFCoreData.sqlite";

@interface FFCoreDataManager()

- (NSString *)sharedDocumentsPath;

@end

@implementation FFCoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext          = _mainObjectContext;
@synthesize objectModel                = _objectModel;

+ (FFCoreDataManager *)sharedManager {

  static FFCoreDataManager *_defaultManager = nil;
  static dispatch_once_t oncePredicate;

  dispatch_once(&oncePredicate, ^{
    _defaultManager = [[FFCoreDataManager alloc] init];
  });

  return _defaultManager;
}

- (void)deleteAllObjects:(NSString *)entityDescription {

  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity  = [NSEntityDescription entityForName:entityDescription
                                             inManagedObjectContext:self.mainObjectContext];

  [fetchRequest setEntity:entity];

  NSError *error;
  NSArray *items = [self.mainObjectContext executeFetchRequest:fetchRequest
                                                         error:&error];

  for (NSManagedObject *managedObject in items) {

    [self.mainObjectContext deleteObject:managedObject];

    NSLog(@"%@ object deleted",entityDescription);
  }

  if (![self.mainObjectContext save:&error]) {
    NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
  }
}

- (BOOL)save {

	if (![self.mainObjectContext hasChanges]) {
    NSLog(@"no changes found");
		return YES;
  }

	NSError *error = nil;

	if (![self.mainObjectContext save:&error]) {

		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);

    [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveFailedNotification
                                                        object:error];
		return NO;
	}

  NSLog(@"should be saving to notification");

  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveNotification
                                                        object:nil];
  });

  return YES;
}

- (NSManagedObjectModel*)objectModel {

  if (_objectModel) {
		return _objectModel;
  }

	NSBundle *bundle = [NSBundle mainBundle];

	NSString *modelPath = [bundle pathForResource:WNCoreManagerModelName
                                         ofType:@"momd"];

  _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];

	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {

	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
  }

	/**
   * Get the paths to the SQLite file
   */

	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:WNCoreManagerSQLiteName];
	NSURL *storeURL     = [NSURL fileURLWithPath:storePath];

	/**
   * Define the Core Data version migration options
   */

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                           nil];

	/**
   * Attempt to load the persistent store
   */

	NSError *error = nil;

	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];

  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:options
                                                         error:&error]) {

		NSLog(@"Fatal error while creating persistent store: %@", error);

    abort();
	}
  
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {

	if (_mainObjectContext) {
		return _mainObjectContext;
  }

	/**
   * Create the main context only on the main thread
   */

	if (![NSThread isMainThread]) {

//		[self performSelectorOnMainThread:@selector(mainObjectContext)
//                           withObject:nil
//                        waitUntilDone:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self mainObjectContext];
    });

    return _mainObjectContext;
	}

	_mainObjectContext = [[NSManagedObjectContext alloc] init];

	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  
	return _mainObjectContext;
}

- (NSManagedObjectContext*)managedObjectContext {

	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];

  [ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];

	return ctx;
}

#pragma mark - Private Methods

- (NSString*)sharedDocumentsPath {

	static NSString *__sharedDocumentsPath = nil;

  if (__sharedDocumentsPath) {
		return __sharedDocumentsPath;
  }

	/**
   * Compose a path to the <Library>/Database directory
   */

	__sharedDocumentsPath = [LibraryDirectory() stringByAppendingPathComponent:@"Database"];

	/**
   * Ensure the database directory exists
   */

	NSFileManager *manager = [NSFileManager defaultManager];

	BOOL isDirectory;

  if (![manager fileExistsAtPath:__sharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {

    NSError *error     = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                     forKey:NSFileProtectionKey];

		[manager createDirectoryAtPath:__sharedDocumentsPath
		   withIntermediateDirectories:YES
                        attributes:attr
                             error:&error];
		if (error) {
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
	}
  
	return __sharedDocumentsPath;
}

@end
