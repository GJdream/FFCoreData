//
//  FFCity.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCity.h"

NSString * const FFCityNameKey = @"FFCityNameKey";
NSString * const FFCityMetaKey = @"FFCityMetaKey";

@interface FFCity()
@property (nonatomic, strong) FFMetaData *metaData;
@end

@implementation FFCity

- (void)encodeWithCoder:(NSCoder *)encoder {

  [encoder encodeObject:self.name forKey:FFCityNameKey];

  FFMetaData *metaData = [[FatFractal main] metaDataForObj:self];
//
  self.metaData = metaData;
//
  [encoder encodeObject:self.metaData forKey:FFCityMetaKey];
}

- (id)initWithCoder:(NSCoder *)decoder {

  self = [super init];

  if (self) {

    self.name     = [decoder decodeObjectForKey:FFCityNameKey];
    self.metaData = [decoder decodeObjectForKey:FFCityMetaKey];

    if (self.metaData) {
      [[FatFractal main] setMetaData:self.metaData forObj:self];
    }
  }
  
  return self;
}

@end
