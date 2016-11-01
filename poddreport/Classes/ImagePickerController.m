//
//  ImagePickerController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ImagePickerController.h"
#import "ReportImageCollectionViewCell.h"
#import "ReportImageManagedObject.h"
#import "ReportType.h"
#define DefaultImage [UIImage imageNamed:@"nav-logo"]

@import PhotosUI;
@import AssetsLibrary;

@interface ImagePickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic, nonnull) NSArray<ReportImageManagedObject *> *items;
@property (weak, nonatomic, nullable) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic, nullable) IBOutlet UIView *noResultsView;
@property (copy, nonatomic, nonnull) NSString *reportGuid;
@property (assign, nonatomic) BOOL canEdit;
@end

@interface ImagePickerController (CoreDataHelper)
- (NSArray * _Nullable)findReportImageByURL:(NSString * _Nonnull)url;
- (NSArray * _Nullable)findReportImageByPredicate:(NSPredicate * _Nonnull)predicate;
- (void)insertReportImageByURL:(NSString * _Nonnull)url;
@end

@implementation ImagePickerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self loadManagedObjectContext];
    [self loadReportGuid];
    [self loadReportImages];
    [self loadReportStatus];
}

- (void)loadManagedObjectContext {
    
    self.managedObjectContext = self.navigationController.managedObjectContext;
}

- (void)loadReportGuid {
    
    self.reportGuid = self.navigationController.currentReportGuid;
    NSLog(@"reportGuid %@", self.reportGuid);
}

- (void)loadReportImages {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reportGuid == %@", _reportGuid];
    NSArray *results = [self findReportImageByPredicate:predicate];
    self.items = results;
    [self reloadNoResultsView];
    [self.collectionView reloadData];
}

- (void)loadReportStatus {
    
    self.canEdit = !self.navigationController.isSubmitted;
    self.title = self.navigationController.reportType.name;
}

#pragma mark - Actions

- (IBAction)openCamera:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)openPhotoLibrary:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:0.2576 green:0.1478 blue:0.4422 alpha:1.0];
        NSDictionary *titleFontAttributes = @{ 
                                              NSFontAttributeName: [UIFont fontWithName:@"SukhumvitSet-Light" size:21],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              };
        imagePicker.navigationBar.titleTextAttributes = titleFontAttributes;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        NSArray *results = [self findReportImageByURL:url.absoluteString];
        
        BOOL isExist = results.count > 0;
        if (!isExist) {
            [self insertReportImageByURL:url.absoluteString];
        }
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [self loadReportImages];
        }];
        return;
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), &info);
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [[[ALAssetsLibrary alloc] init] 
     enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         
         // Filter photo
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSIndexSet *lastIndexSet = [NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1];
        
        // Only first group
        *stop = YES;
        
        // Check existing
        if (group != nil) {
            [group enumerateAssetsAtIndexes:lastIndexSet options:NSEnumerationReverse usingBlock:
             ^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                 
                 // Ony first image
                 *innerStop = YES;
                 
                 if (alAsset) {
                     if (innerStop) {
                        NSURL *url = [[alAsset defaultRepresentation] url];
                        [self insertReportImageByURL:url.absoluteString];
                     }
                 }
                return;
             }];
        }
        return;
         
    } failureBlock:^(NSError *error) {
        [self openPhotoLibrary:nil];
    }];
}

- (IBAction)nextPage:(id)sender {
    
    [self.navigationController nextPage];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const cellIdentifier = @"PhotoCellIdentifier";
    ReportImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ReportImageManagedObject *reportImage = [self.items objectAtIndex:indexPath.row];
    
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[reportImage.referenceURL] options:nil] lastObject];
    if (asset) {
        
        CGSize size = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.imageView.image = result;
        }];
        
    } else {
        cell.imageView.image = DefaultImage;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ReportImageManagedObject *reportImage = [self.items objectAtIndex:indexPath.row];
    if (reportImage.submitStatus.intValue == ReportSubmitStatusWaiting) {
        [self.managedObjectContext deleteObject:reportImage];
        [self.managedObjectContext save:nil];
        [self loadReportImages];
    }
}

#pragma mark - UICollectionView Layout

#define COLLECTION_CELL_COLUMN 3

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    CGFloat size = collectionView.bounds.size.width / COLLECTION_CELL_COLUMN;
    return CGSizeMake(size, size);
}

#pragma mark - No results view

- (void)reloadNoResultsView {
    
    self.noResultsView.hidden = self.items.count > 0;
}

@end


@implementation ImagePickerController (CoreDataHelper)

- (NSArray * _Nullable)findReportImageByURL:(NSString * _Nonnull)url {
    
    return [self findReportImageByPredicate:
            [NSPredicate predicateWithFormat:
             @"imageUrl == %@ AND reportGuid == %@"
             , url
             , self.reportGuid]];
}

- (NSArray * _Nullable)findReportImageByPredicate:(NSPredicate * _Nonnull)predicate {
    
    NSFetchRequest *imageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportImage"];
    imageFetchRequest.predicate = predicate;
    NSArray *imageResults = [self.managedObjectContext 
                             executeFetchRequest:imageFetchRequest
                             error:nil]; 
    return imageResults;
}

- (void)insertReportImageByURL:(NSString * _Nonnull)url {
    
    ReportImageManagedObject *newItem = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"ReportImage"
                                         inManagedObjectContext:self.managedObjectContext];
    newItem.guid = [[NSUUID UUID] UUIDString];
    newItem.reportGuid = self.reportGuid;
    newItem.imageUrl = url;
    
    [self.managedObjectContext save:nil];
    [self loadReportImages];
}

@end