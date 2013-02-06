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

@interface FFCoreDataManager : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FFCoreDataManager *)sharedManager;
- (void)saveContext:(BOOL)wait;
- (void)saveWithChildContext:(NSManagedObjectContext *)childContext
           childContextBlock:(void(^)())block
                  shouldWait:(BOOL)wait;
- (void)deleteAllObjects:(NSString *)entityDescription;
@end
