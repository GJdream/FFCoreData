//
//  FatFractal+WNAdditions.h
//  WhoNote
//
//  Created by Cory D. Wiles on 1/16/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <FFEF/FatFractal.h>

@interface FatFractal (FFCoreData)
- (id)objectFromDictionary:(NSDictionary *)dict;
- (id)dictionaryFromObject:(id)obj
          alreadyProcessed:(NSMutableArray *)done
                     level:(int)level
                blobFields:(NSMutableArray *)blobFields
                     error:(NSError **)error;
- (void)setMetaData:(FFMetaData *)md forObj:(id)obj;
@end
