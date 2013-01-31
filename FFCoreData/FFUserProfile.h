//
//  FFUserProfile.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FFUserProfileUserKey;
extern NSString * const FFUserProfileUserRandomStringKey;
extern NSString * const FFUserProfileFFCityKey;
extern NSString * const FFUserProfileMetaKey;

@class FFCity;

@interface FFUserProfile : NSObject <NSCoding>

@property (nonatomic, strong) FFUser *user;
@property (nonatomic, copy) NSString *randomCode;
@property (nonatomic, strong) FFCity *homeCity;

@end
