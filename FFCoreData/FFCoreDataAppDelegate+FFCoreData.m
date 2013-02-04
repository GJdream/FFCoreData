//
//  CWAppDelegate+FFCoreData.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataAppDelegate+FFCoreData.h"

@implementation FFCoreDataAppDelegate (FFCoreData)

+ (double)lastSyncDate {
  return [[NSUserDefaults standardUserDefaults] doubleForKey:FFCoreDataAppLastSyncKey];
}

+ (void)saveLastSyncDate:(double)ts {

  [[NSUserDefaults standardUserDefaults] setDouble:ts
                                            forKey:FFCoreDataAppLastSyncKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
