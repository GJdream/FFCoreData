//
//  FFCoreDataGlobals.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/30/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline NSString *CachesDirectory() {

  static NSString *_cachePath = nil;
  static dispatch_once_t oncePred;

  dispatch_once(&oncePred, ^{
    _cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  });

	return _cachePath;
}

static inline NSString *LibraryDirectory() {

  static NSString *_libraryPath = nil;
  static dispatch_once_t oncePred;

  dispatch_once(&oncePred, ^{
    _libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  });

	return _libraryPath;
}

static inline NSString *DocumentsDirectory() {

  static NSString *_docPath = nil;
  static dispatch_once_t oncePred;

  dispatch_once(&oncePred, ^{
    _docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  });

	return _docPath;
}

static inline NSString *TemporaryDirectory() {

	static NSString *_tempPath = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		_tempPath = NSTemporaryDirectory();
	});

	return _tempPath;
}

