//
//  ReportFeedTableViewController.m
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportFeedTableViewController.h"
#import "ReportFeedTableViewCell.h"
#import "ReportFeedItem.h"
#import "ReportFeedDetailTableViewController.h"
#import "ConfigurationManager.h"

@interface ReportFeedTableViewController () <NSURLSessionDataDelegate> {
    NSDateFormatter *_dateFormatter;
}
@property (strong, nonatomic) NSArray<ReportFeedItem *> *items;
@property (strong, nonatomic, nullable) NSURLSession *session;
@property (copy, nonatomic, nullable) NSString *nextPage;
@property (assign, nonatomic, getter=isLoading) BOOL loading;
@end

@interface ReportFeedTableViewController (ImageCache)
- (NSURLCache *)prepareImageCachce;
@end

@implementation ReportFeedTableViewController

- (NSURLSession * _Nullable)session {
    
    if (!_session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        sessionConfiguration.URLCache = self.prepareImageCachce;
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return _session;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.items = [NSArray new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 420;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"วันที่ dd MMM yyyy"];
    [_dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierBuddhist]];
    [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    
    [self.refreshControl beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self requestUpdate];
}

- (IBAction)refresh:(id)sender {
    
    [self.refreshControl beginRefreshing];
    [self requestUpdate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
    });
}

- (void)requestUpdate {
    
    ConfigurationManager *configuration = [ConfigurationManager sharedConfiguration];
    NSString *path = [configuration.endpoint stringByAppendingString:@"/reports/?negative=true"];
    [self requestURL:[NSURL URLWithString:path]];
    self.nextPage = nil;
}

- (void)requestNext {
    
    if (!self.nextPage) {
        NSLog(@"end");
        return;
    }
    
    ConfigurationManager *configuration = [ConfigurationManager sharedConfiguration];
    NSString *path = [configuration.endpoint stringByAppendingString:@"/reports/"];
    path = [path stringByAppendingFormat:@"%@&%@", self.nextPage, @"negative=true"];
    [self requestURL:[NSURL URLWithString:path]];
}

- (void)requestURL:(NSURL *)url {
    
    if (self.isLoading) {
        NSLog(@"loading");
        return;
    } 
        
    ConfigurationManager *configuration = [ConfigurationManager sharedConfiguration];
    NSString *authentication = [@"Token " stringByAppendingString:configuration.authenticationToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task;
    task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
            ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (!data || error) {
                    return;
                }
                
                NSDictionary *responseJSON = [NSJSONSerialization 
                                            JSONObjectWithData:data
                                            options:NSJSONReadingMutableLeaves
                                            error:NULL];

                NSString *nextPage = responseJSON[@"next"];
                if ([nextPage isKindOfClass:[NSNull class]]) {
                  nextPage = nil;
                }

                NSArray *items = responseJSON[@"results"];
                NSMutableArray *parsedItems = [NSMutableArray new];

                for (NSDictionary *item in items) {
                    ReportFeedItem *feedItem = [[ReportFeedItem alloc] initWithDictionary:item];
                    if (feedItem) {
                        [parsedItems addObject:feedItem];
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.nextPage) {
                        self.items = [self.items arrayByAddingObjectsFromArray:parsedItems];
                        
                    } else {
                        self.items = parsedItems;
                    }
                    
                    self.nextPage = nextPage;
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.loading = NO;
                    });
                });
            }];
    
    self.loading = YES;
    [task resume];
    
#if DEBUG
    NSLog(@"GET %@", url);
#endif
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.items.count == 0) {
        self.tableView.hidden = YES;
    } else {
        self.tableView.hidden = NO;
    }
    
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.items.count - 1) {
        NSLog(@"loadmore…");
        [self requestNext];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const CellIdentifier = @"ReportFeedCellIdentifier";
    ReportFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ReportFeedItem *item = [self.items objectAtIndex:indexPath.row];
    [self configureCell:cell withItem:item atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(ReportFeedTableViewCell * _Nonnull)cell withItem:(ReportFeedItem * _Nonnull)item atIndexPath:(NSIndexPath *)indexPath {
    
    cell.displayNameLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"By", nil), item.createdByName];
    cell.reportTypeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Report", nil), item.reportTypeName];
    cell.reportLocationLabel.text = item.administrationAreaAddress;
    cell.reportDateLabel.text = [_dateFormatter stringFromDate:item.incidentDate];
    cell.reportDescriptionLabel.attributedText = item.reportDescriptionAttributedString;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *imageName = @"etc";
        NSDictionary *reportType = @{ @"ปกติ": @"normal"
                                      ,@"สัตว์ป่วย/ตาย": @"animal-sick-death"
                                      ,@"สัตว์กัด": @"animal-bite"
                                      ,@"โรคเกี่ยวกับสัตว์และคน": @"human"
                                      ,@"อาหารปลอดภัย": @"food"
                                      ,@"คุ้มครองผู้บริโภค": @"human2"
                                      ,@"สิ่งแวดล้อม": @"environment"
                                      ,@"ภัยธรรมชาติ": @"disaster"
                                      };
        if ([reportType valueForKey:item.reportTypeName]) {
            imageName = reportType[item.reportTypeName];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.reportTypeIconImageView.image = [UIImage imageNamed:imageName];
        });
    }); 
    
    if (item.firstImageThumbnail && [item.firstImageThumbnail length] > 0) {
        cell.reportImageHeightLayoutConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
        
        NSURL *thumbnailUrl = [NSURL URLWithString:item.firstImageThumbnail];
        NSCachedURLResponse *cachedResponse = [self.session.configuration.URLCache 
                                               cachedResponseForRequest:
                                               [NSURLRequest requestWithURL:thumbnailUrl]];
        if (cachedResponse.data) {
            NSLog(@"cache found %@", thumbnailUrl);
            UIImage *downloadedImage = [UIImage imageWithData:cachedResponse.data];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.reportImageView.image = downloadedImage;
            });
            
        } else {
            NSLog(@"imageTask %@", thumbnailUrl);
            [[self.session dataTaskWithURL:thumbnailUrl completionHandler:
              ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                  if (error) {
                      return;
                  }
                  
                  UIImage *downloadedImage = [UIImage imageWithData:data];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      cell.reportImageView.image = downloadedImage;
                  });
            }] resume];
        }
        
    } else {
        cell.reportImageHeightLayoutConstraint.constant = 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id item = [self.items objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReportFeedDetailIdentifier" sender:item];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ReportFeedDetailIdentifier"]) {
        ReportFeedDetailTableViewController *detailController = (ReportFeedDetailTableViewController *)[segue destinationViewController];
        [detailController setItem:sender];
    }
}

@end

@implementation ReportFeedTableViewController (ImageCache)

- (NSURLCache *)prepareImageCachce {

    NSUInteger cacheSizeInBytes = 50 * 1024 * 1024;
    NSUInteger cacheDiskSizeInBytes = 250 * 1024 * 1024;
    NSURLCache *imageCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeInBytes diskCapacity:cacheDiskSizeInBytes diskPath:self.cachePath];
    return imageCache;
}

- (NSString *)cachePath {
    
    NSURL *applicationUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *cachePath = [applicationUrl.path stringByAppendingPathComponent:@"/cache"];
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    return cachePath;
}

@end