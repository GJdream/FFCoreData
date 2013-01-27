//
//  WNCoreDataManager.h
//  WhoNote
//
//  Created by Cory D. Wiles on 1/24/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const WNCoreDataManagerDidSaveNotification;
extern NSString * const WNCoreDataManagerDidSaveFailedNotification;

@interface FFCoreDataManager : NSObject

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FFCoreDataManager *)sharedManager;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

@end
