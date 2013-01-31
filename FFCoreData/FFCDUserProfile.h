//
//  FFCDUserProfile.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FFCDUserProfile : NSManagedObject

@property (nonatomic, strong) NSData *ffuserProfile;
@property (nonatomic, copy) NSString *sortDesc;
@property (nonatomic, strong) NSManagedObject *city;

@end
