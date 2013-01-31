//
//  FFUserProfile.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFUserProfile.h"

NSString * const FFUserProfileUserKey             = @"FFUserProfileUserKey";
NSString * const FFUserProfileUserRandomStringKey = @"FFUserProfileUserRandomStringKey";
NSString * const FFUserProfileFFCityKey           = @"FFUserProfileFFCityKey";
NSString * const FFUserProfileMetaKey             = @"FFUserProfileMetaKey";

@interface FFUserProfile()
@property (nonatomic, strong) FFMetaData *metaData;
@end

@implementation FFUserProfile

- (void)encodeWithCoder:(NSCoder *)encoder {

  [encoder encodeObject:self.user forKey:FFUserProfileUserKey];
  [encoder encodeObject:self.randomString forKey:FFUserProfileUserRandomStringKey];
  [encoder encodeObject:self.city forKey:FFUserProfileFFCityKey];

  FFMetaData *metaData = [[FatFractal main] metaDataForObj:self];

  self.metaData = metaData;

  [encoder encodeObject:self.metaData forKey:FFUserProfileFFCityKey];
}

- (id)initWithCoder:(NSCoder *)decoder {

  self = [super init];

  if (self) {

    self.user         = [decoder decodeObjectForKey:FFUserProfileUserKey];
    self.randomString = [decoder decodeObjectForKey:FFUserProfileUserRandomStringKey];
    self.city         = [decoder decodeObjectForKey:FFUserProfileFFCityKey];
    self.metaData     = [decoder decodeObjectForKey:FFUserProfileMetaKey];

    if (self.metaData) {
      [[FatFractal main] setMetaData:self.metaData forObj:self];
    }
  }

  return self;
}

@end
