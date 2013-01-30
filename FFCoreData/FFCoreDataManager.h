//
//  WNCoreDataManager.h
//  WhoNote
//
//  Created by Cory D. Wiles on 1/24/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const FFCoreDataManagerDidSaveNotification;
extern NSString * const FFCoreDataManagerDidSaveFailedNotification;

static inline NSString *LibraryDirectory() {

  static NSString *_libraryPath = nil;
  static dispatch_once_t oncePred;

  dispatch_once(&oncePred, ^{
    _libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  });

	return _libraryPath;
}

@interface FFCoreDataManager : NSObject

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FFCoreDataManager *)sharedManager;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

@end
