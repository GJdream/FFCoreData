//
//  FFCoreDataUtils.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataUtils.h"

@implementation FFCoreDataUtils

+ (void)persistObject:(id)obj atFilename:(NSString *)filename {

  NSString *archivePath = [DocumentsDirectory() stringByAppendingPathComponent:filename];

  [NSKeyedArchiver archiveRootObject:obj toFile:archivePath];
}

+ (id)loadObjectFromFilename:(NSString *)filename {

  NSString *archivePath = [DocumentsDirectory() stringByAppendingPathComponent:filename];

  return [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
}

@end
