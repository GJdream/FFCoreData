//
//  CWMasterViewController.m
//  FFCoreData
//
//  Created by Cory D. Wiles on 1/27/13.
//  Copyright (c) 2013 Cory D. Wiles. All rights reserved.
//

#import "FFCoreDataMasterViewController.h"

#import "FFUserProfile.h"
#import "FFCity.h"
#import "FFCoreDataManager.h"
#import "FFCDUserProfile.h"

@interface FFCoreDataMasterViewController ()

@property (nonatomic, strong) FatFractal *ff;
@property (nonatomic, copy) NSArray *content;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)persistFFObject:(id)obj;
@end

@implementation FFCoreDataMasterViewController {
  id _notificationObserverSave;
  id _notificationObserverSaveError;
}

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:_notificationObserverSave];
  [[NSNotificationCenter defaultCenter] removeObserver:_notificationObserverSaveError];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {

    self.title = NSLocalizedString(@"Master", @"Master");

    _ff = [[FatFractal alloc] initWithBaseUrl:@"http://cory.fatfractal.com/coredata/"
                                       sslUrl:@"https://cory.fatfractal.com/coredata/"];

    [_ff registerClass:[FFUserProfile class] forClazz:@"CDProfile"];
    [_ff registerClass:[FFCity class] forClazz:@"CDCity"];
  }

  return self;
}
							
- (void)viewDidLoad {

  [super viewDidLoad];

  _notificationObserverSave = [[NSNotificationCenter defaultCenter] addObserverForName:FFCoreDataManagerDidSaveNotification
                                                                                object:nil
                                                                                 queue:nil
                                                                            usingBlock:^(NSNotification *note) {

                                                                              double ts = [[NSDate date] timeIntervalSince1970] * 1000;

                                                                              [FFCoreDataAppDelegate saveLastSyncDate:ts];
//                                                                              [NSFetchedResultsController deleteCacheWithName:@"FFCDUserProfile"];
//                                                                              [self.tableView reloadData];
                                                                            }];

  _notificationObserverSaveError = [[NSNotificationCenter defaultCenter] addObserverForName:FFCoreDataManagerDidSaveFailedNotification
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification *note) {
//                                                                                   NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
// @todo show alert
                                                                                 }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];

  // this will be come the 'initial data import'
  if (![FFCoreDataAppDelegate lastSyncDate]) {

    [self.ff getArrayFromUri:@"/UserProfiles" onComplete:^(NSError *err, id obj, NSHTTPURLResponse *httpResponse) {

      NSArray *profiles = (NSArray *)obj;

      NSLog(@"profiles from intial fetch: %@", profiles);

      [profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [self persistFFObject:obj];
      }];
    }];

    NSError *error;

    [NSFetchedResultsController deleteCacheWithName:@"FFCDUserProfile"];

    if (![self.fetchedResultsController performFetch:&error]) {

      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

      abort();
    }

    [self.tableView reloadData];

  } else {

    [NSFetchedResultsController deleteCacheWithName:@"FFCDUserProfile"];

    NSError *error = nil;

    if (![self.fetchedResultsController performFetch:&error]) {

      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

      abort();
    }

    /**
     * @todo
     * will _eventual_ add in logic to query webservice for data that has been
     * updated since last check.
     *
     * Need to separate this out better
     */
    double ts = [FFCoreDataAppDelegate lastSyncDate];

    /**
     * ::NOTE::
     *
     * This will _only_ get new items.
     */

    NSString *endPoint = [NSString stringWithFormat:@"/UserProfiles/(updatedAt gt %f)", ts];

    NSLog(@"endpoint: %@", endPoint);

    [self.ff getArrayFromUri:endPoint onComplete:^(NSError *err, id obj, NSHTTPURLResponse *httpResponse) {

      NSArray *profiles = (NSArray *)obj;

      NSLog(@"profiles to check for new information: %@", profiles);

      [profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [self persistFFObject:obj];
      }];
    }];

    [self.tableView reloadData];
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (cell == nil) {

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }

  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"FFCDUserProfile"
                                            inManagedObjectContext:[[FFCoreDataManager sharedManager] mainObjectContext]];

  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sortDesc"
                                                       ascending:NO];

  [fetchRequest setEntity:entity];
  [fetchRequest setShouldRefreshRefetchedObjects:YES];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
  [fetchRequest setFetchBatchSize:20];

  NSFetchedResultsController *theFetchedResultsController =
  [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                      managedObjectContext:[[FFCoreDataManager sharedManager] mainObjectContext]
                                        sectionNameKeyPath:nil
                                                 cacheName:@"FFCDUserProfile"];

  self.fetchedResultsController = theFetchedResultsController;

  _fetchedResultsController.delegate = self;
  
  return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

  UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

  FFCDUserProfile *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

  NSLog(@"mo: %@", object);

  NSData *ffuserProfileData = [object valueForKey:@"ffuserProfile"];

  FFUserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:ffuserProfileData];

  cell.textLabel.text       = profile.user.firstName;
  cell.detailTextLabel.text = object.sortDesc;
}

#pragma mark - Private Methods

- (void)persistFFObject:(id)obj {

  /**
   * Hard coding / assuming the object is FFUserProfile
   */

  FFUserProfile *profile = (FFUserProfile *)obj;

  NSData *dataOnObjectProfile = [NSKeyedArchiver archivedDataWithRootObject:profile];
  NSData *dataOnObjectCity    = [NSKeyedArchiver archivedDataWithRootObject:profile.homeCity];

  NSManagedObjectContext *context = [FFCoreDataManager sharedManager].mainObjectContext;
  NSManagedObject *profileMO      = [NSEntityDescription insertNewObjectForEntityForName:@"FFCDUserProfile"
                                                                  inManagedObjectContext:context];
  NSManagedObject *ffcityMO       = [NSEntityDescription insertNewObjectForEntityForName:@"FFCDCity"
                                                                  inManagedObjectContext:context];

  [profileMO setValue:dataOnObjectProfile forKey:@"ffuserProfile"];
  [profileMO setValue:ffcityMO forKey:@"city"];
  [profileMO setValue:profile.homeCity.name forKey:@"sortDesc"];

  [ffcityMO setValue:dataOnObjectCity forKey:@"ffcity"];
  [ffcityMO setValue:profileMO forKey:@"profile"];

  [[FFCoreDataManager sharedManager] save];
}

@end
