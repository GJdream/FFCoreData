//
//  FFCity.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCity.h"

NSString * const FFCityNameKey = @"FFCityNameKey";
NSString * const FFCityFilePrefix = @"FFCity-";

@implementation FFCity

- (void)encodeWithCoder:(NSCoder *)encoder {

  [encoder encodeObject:self.name forKey:FFCityNameKey];

  FFMetaData *metaData = [[FatFractal main] metaDataForObj:self];

  NSString *filename = [NSString stringWithFormat:@"%@-%@", FFCityFilePrefix, metaData.guid];

  [FFCoreDataUtils persistObject:metaData atFilename:filename];
}

- (id)initWithCoder:(NSCoder *)decoder {

  self = [super init];

  if (self) {

    self.name = [decoder decodeObjectForKey:FFCityNameKey];

    FFMetaData *metaData = (FFMetaData *)[FFCoreDataUtils loadObjectFromFilename:FFCityFilePrefix];

    if (metaData) {
      [[FatFractal main] setMetaData:metaData forObj:self];
    }
  }
  
  return self;
}

@end
