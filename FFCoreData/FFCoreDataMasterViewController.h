//
//  CWMasterViewController.h
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/27/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class FFCoreDataDetailViewController;

@interface FFCoreDataMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) FFCoreDataDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
