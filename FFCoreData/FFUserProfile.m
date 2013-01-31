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
  [encoder encodeObject:self.randomCode forKey:FFUserProfileUserRandomStringKey];
  [encoder encodeObject:self.homeCity forKey:FFUserProfileFFCityKey];

  FFMetaData *metaData = [[FatFractal main] metaDataForObj:self];

  NSLog(@"metaData with encode: %@", metaData);

  self.metaData = metaData;

  [encoder encodeObject:self.metaData forKey:FFUserProfileFFCityKey];
}

- (id)initWithCoder:(NSCoder *)decoder {

  self = [super init];

  if (self) {

    self.user         = [decoder decodeObjectForKey:FFUserProfileUserKey];
    self.randomCode = [decoder decodeObjectForKey:FFUserProfileUserRandomStringKey];
    self.homeCity         = [decoder decodeObjectForKey:FFUserProfileFFCityKey];
    self.metaData     = [decoder decodeObjectForKey:FFUserProfileMetaKey];

    if (self.metaData) {
        NSLog(@"metaData after init: %@", self.metaData);
      [[FatFractal main] setMetaData:self.metaData forObj:self];
    }
  }

  return self;
}

@end
