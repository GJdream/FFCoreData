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

@property (nonatomic, strong) NSManagedObjectContext *privateWriterContext;

- (NSString *)sharedDocumentsPath;

@end

@implementation FFCoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainManagedObjectContext          = _mainObjectContext;
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
                                             inManagedObjectContext:self.mainManagedObjectContext];

  [fetchRequest setEntity:entity];

  NSError *error;
  NSArray *items = [self.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                         error:&error];

  for (NSManagedObject *managedObject in items) {

    [self.mainManagedObjectContext deleteObject:managedObject];

    NSLog(@"%@ object deleted",entityDescription);
  }

  if (![self.mainManagedObjectContext save:&error]) {
    NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
  }
}

- (void)saveContext:(BOOL)wait {

  if (![self.mainManagedObjectContext hasChanges]) {
    return;
  }

  [self.mainManagedObjectContext performBlock:^{

    /**
     * Push the mainContextObject to the parent for asynchronous writing.
     *
     * @see
     * http://www.cocoanetics.com/2012/07/multi-context-coredata/
     */

    NSError *error;

    if (![self.mainManagedObjectContext save:&error]) {

      NSDictionary *errorNotificationMainContextInfo = @{@"context" : @"mainManagedObjectContext"};

      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveFailedNotification
                                                            object:error
                                                          userInfo:errorNotificationMainContextInfo];
      });

    } else {

      NSDictionary *saveNotificationMainContextInfo = @{@"context" : @"mainManagedObjectContext"};

      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveNotification
                                                            object:nil
                                                          userInfo:saveNotificationMainContextInfo];
      });
    }

    void (^savePrivate) (void) = ^{

      NSError *error = nil;

      if (![self.privateWriterContext save:&error]) {

        NSDictionary *errorNotificationPrivateContextInfo = @{@"context" : @"privateWriterContext"};

        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveFailedNotification
                                                              object:error
                                                            userInfo:errorNotificationPrivateContextInfo];
        });

      } else {

        NSDictionary *saveNotificationPrivateContextInfo = @{@"context" : @"privateWriterContext"};

        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveNotification
                                                              object:nil
                                                            userInfo:saveNotificationPrivateContextInfo];
        });
      }
    };

    /**
     * However, there are some situations in which we might want to block on 
     * the save and others where we might want it to be asynchronous. For 
     * example, when we are going into the background or terminating the 
     * applica- tion, we will want to block. If we are doing a save while the 
     * application is still running, we would want to be asynchronous. 
     * Fortunately, the -saveContext: method accepts a boolean that lets us 
     * know which method to call.
     *
     * @source: CoreData 2nd Edition by Marcus Zarra
     */

    if ([self.privateWriterContext hasChanges]) {
      if (wait) {
        [self.privateWriterContext performBlockAndWait:savePrivate];
      } else {
        [self.privateWriterContext performBlock:savePrivate];
      }
    }
  }];
}

- (BOOL)saveWithChildContext:(NSManagedObjectContext *)childContext
           childContextBlock:(void(^)())block
                  shouldWait:(BOOL)wait {

  if (!childContext) {
    return NO;
  }

  if (self.mainManagedObjectContext == childContext) {
    return NO;
  }

  childContext.parentContext = self.mainManagedObjectContext;

  void (^saveChild) (void) = ^{

    NSError *error = nil;

    if (block) {
      block();
    }

    if (![childContext save:&error]) {

      NSDictionary *errorNotificationChildContextInfo = @{@"context" : @"childWriterContext"};

      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveFailedNotification
                                                            object:error
                                                          userInfo:errorNotificationChildContextInfo];
      });

    } else {

      NSDictionary *saveNotificationChildContextInfo = @{@"context" : @"childWriterContext"};

      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FFCoreDataManagerDidSaveNotification
                                                            object:nil
                                                          userInfo:saveNotificationChildContextInfo];
      });
    }

    [self saveContext:NO];
  };

  if (wait) {
    [childContext performBlockAndWait:saveChild];
  } else {
    [childContext performBlock:saveChild];
  }
  
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

- (NSManagedObjectContext *)privateWriterContext {

  if (_privateWriterContext) {
    return _privateWriterContext;
  }

  _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

  [_privateWriterContext setPersistentStoreCoordinator:_persistentStoreCoordinator];

  return _privateWriterContext;
}

- (NSManagedObjectContext*)mainManagedObjectContext {

	if (_mainObjectContext) {
		return _mainObjectContext;
  }

	/**
   * Create the main context only on the main thread
   */

	if (![NSThread isMainThread]) {

    dispatch_async(dispatch_get_main_queue(), ^{
      [self mainManagedObjectContext];
    });

    return _mainObjectContext;
	}

	_mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

  _mainObjectContext.parentContext = self.privateWriterContext;
  
	return _mainObjectContext;
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
