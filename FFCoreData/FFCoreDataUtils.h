//
//  FFCoreDataUtils.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFCoreDataUtils : NSObject
+ (void)persistObject:(id)obj atFilename:(NSString *)filename;
+ (id)loadObjectFromFilename:(NSString *)filename;
@end
