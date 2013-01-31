//
//  CWAppDelegate+FFCoreData.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataAppDelegate+FFCoreData.h"

@implementation FFCoreDataAppDelegate (FFCoreData)

+ (NSDate *)lastSyncDate {
  return [[NSUserDefaults standardUserDefaults] valueForKey:FFCoreDataAppLastSyncKey];
}

+ (void)saveLastSyncDate:(NSDate *)date {

  [[NSUserDefaults standardUserDefaults] setObject:date
                                            forKey:FFCoreDataAppLastSyncKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
