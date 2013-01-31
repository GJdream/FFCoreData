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
NSString * const FFUserProfileUserFilePrefix      = @"FFUserProfile-";

@implementation FFUserProfile

- (void)encodeWithCoder:(NSCoder *)encoder {

  [encoder encodeObject:self.user forKey:FFUserProfileUserKey];
  [encoder encodeObject:self.randomString forKey:FFUserProfileUserRandomStringKey];
  [encoder encodeObject:self.city forKey:FFUserProfileFFCityKey];

  FFMetaData *metaData = [[FatFractal main] metaDataForObj:self];

  NSString *filename = [NSString stringWithFormat:@"%@-%@", FFUserProfileUserFilePrefix, metaData.guid];

  [FFCoreDataUtils persistObject:metaData atFilename:filename];
}

- (id)initWithCoder:(NSCoder *)decoder {

  self = [super init];

  if (self) {

    self.user         = [decoder decodeObjectForKey:FFUserProfileUserKey];
    self.randomString = [decoder decodeObjectForKey:FFUserProfileUserRandomStringKey];
    self.city         = [decoder decodeObjectForKey:FFUserProfileFFCityKey];

    FFMetaData *metaData = (FFMetaData *)[FFCoreDataUtils loadObjectFromFilename:FFUserProfileUserFilePrefix];

    if (metaData) {
      [[FatFractal main] setMetaData:metaData forObj:self];
    }
  }

  return self;
}

@end
