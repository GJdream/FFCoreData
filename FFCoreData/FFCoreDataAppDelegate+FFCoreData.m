//
//  CWAppDelegate+FFCoreData.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataAppDelegate+FFCoreData.h"

@implementation FFCoreDataAppDelegate (FFCoreData)

+ (BOOL)isFirstSync {
  return [[NSUserDefaults standardUserDefaults] boolForKey:FFCoreDataAppFirstSyncKey];
}

@end
