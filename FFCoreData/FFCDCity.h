//
//  FFCDCity.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FFCDUserProfile;

@interface FFCDCity : NSManagedObject

@property (nonatomic, strong) NSData *ffcity;
@property (nonatomic, strong) FFCDUserProfile *profile;
@property (nonatomic, copy) NSString *ffurl;

@end
