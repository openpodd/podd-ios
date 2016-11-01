//
//  ReportImageSyncCommand.m
//  poddreport
//
//  Created by Opendream-iOS on 2/10/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <Reachability.h>
#import "ReportImageSyncCommand.h"
#import "ConfigurationManager.h"

@import Photos;

static NSString * const ImageContentType = @"image/jpeg";

@interface ReportImageSyncCommand () <NSURLSessionDataDelegate> {
    BOOL executing;
    BOOL finished;
}

@property (weak, nonatomic, nullable) ConfigurationManager *configuration;
@property (weak, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic, nonnull) NSString *guid;
@end

@implementation ReportImageSyncCommand

- (instancetype _Nonnull)initWithGuid:(NSString *)guid managedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext configuration:(ConfigurationManager * _Nonnull)configuration {
    
    if (self = [super init]) { 
        executing = NO;
        finished = NO;
        
        _configuration = configuration;
        _managedObjectContext = managedObjectContext;
        _guid = guid;
    }
    return self;
}

- (BOOL)isConcurrent {
    
    return YES;
}

- (BOOL)isExecuting {
    
    return executing;
}

- (BOOL)isFinished {
    
    return finished;
}

- (void)finish {
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    finished = YES;
    executing = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (NSURL *)endpoint {
    
    NSString *path = [self.configuration.endpoint stringByAppendingString:@"/reportImages/"]; 
    return [NSURL URLWithString:path];
}

- (NSString * _Nonnull)bucketName {
    
    return @"podd";
}

- (void)start {
    
    if (self.isCancelled) {
        [self finish];
        return;
    }
    
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        [self finish];
        return;
    }
    
    if (!AWSServiceManager.defaultServiceManager.defaultServiceConfiguration) {
        [self finish];
        return;
    }
    
    ReportImageManagedObject *reportImage = [self selectReportImageFromGuid:self.guid];
    if (reportImage.isUploaded || reportImage.isSubmitted) {
        [self finish];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    BOOL shouldUplaodS3 = self.shouldUploadToS3;
    if (shouldUplaodS3) {
        [self prepareDataForUpload:reportImage completion:^(NSData *imageData, NSData *thumbnailImageData) {
            [self uploadS3:imageData thumbnailData:thumbnailImageData guid:reportImage.guid reportGuid:reportImage.reportGuid];
        }];
    } else {
        [self postReportImageToServer];
    }
}

- (BOOL)shouldUploadToS3 {
    
    ReportImageManagedObject *reportImage = [self selectReportImageFromGuid:self.guid];
    BOOL isUploaded = reportImage.isUploaded.boolValue;
    return !(isUploaded);
}

- (void)prepareDataForUpload:(ReportImageManagedObject *)reportImage completion:(void (^)(NSData *, NSData *))completionBlock {
    
    if ([reportImage.imageUrl hasPrefix:@"assets-library"]) {
        PHAsset *asset = [[PHAsset
                           fetchAssetsWithALAssetURLs:@[reportImage.referenceURL] 
                           options:nil] lastObject];
        
        PHImageRequestOptions *option = [PHImageRequestOptions new]; 
        [option setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
        [option setSynchronous:YES];
        
        PHImageRequestOptions *thumbnailOption = [PHImageRequestOptions new]; 
        [thumbnailOption setResizeMode:PHImageRequestOptionsResizeModeExact];
        [thumbnailOption setSynchronous:YES];
        
        dispatch_group_t group = dispatch_group_create();
        
        __block NSData *largeImageData, *thumbnailImageData;
        
        // Large Image Data
        dispatch_group_enter(group);
        
        [[PHImageManager defaultManager]
         requestImageDataForAsset:asset
         options:option
         resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
             largeImageData = imageData;
             dispatch_group_leave(group);
        }];
        
        
        // Thumbnail Image Data
        dispatch_group_enter(group);
        
        [[PHImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:ThumbnailImageSize
         contentMode:PHImageContentModeAspectFill
         options:thumbnailOption
         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
             thumbnailImageData = UIImageJPEGRepresentation(result, 1);
             dispatch_group_leave(group);
        }];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"group notify");
            completionBlock(largeImageData, thumbnailImageData);
        });
        
    } else {
        NSData *data = [NSData dataWithContentsOfFile:reportImage.imageUrl];
        completionBlock(data, nil);
    }
}

- (void)uploadS3:(NSData *)data thumbnailData:(NSData *)thumbnailData guid:(NSString *)guid reportGuid:(NSString *)reportGuid {
    
    assert(data);
    assert(guid);
    assert(reportGuid);
    
    NSString *fileKey = guid;
    NSString *thumbnailFileKey = [guid stringByAppendingString:@"-thumbnail"];
    
    NSString *imageTemporaryFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileKey];
    NSString *thumbnailImageTemporaryFile = [NSTemporaryDirectory() stringByAppendingPathComponent:thumbnailFileKey];
    
    NSError *fileError;
    
    // write large image file
    BOOL writeToFile = [data 
                        writeToFile:imageTemporaryFile
                        options:NSDataWritingAtomic
                        error:&fileError];
    
    // write thumbnail image file
    writeToFile = writeToFile && [thumbnailData
                                  writeToFile:thumbnailImageTemporaryFile
                                  options:NSDataWritingAtomic
                                  error:&fileError];
    
    
    if (writeToFile && fileError == nil) {
        NSNumber *imageFileSize = @(data.length);
        NSNumber *thumbnailImageFileSize = @(thumbnailData.length);
        NSURL *imageTemporaryUrl = [NSURL fileURLWithPath:imageTemporaryFile];
        NSURL *thumbnailImageTemporaryUrl = [NSURL fileURLWithPath:thumbnailImageTemporaryFile];
        
        // Prepare PutObject requests
        AWSS3TransferManagerUploadRequest *request, *thumbnailRequest;
        request = [self createUploadRequestWithUrl:imageTemporaryUrl key:guid fileSize:imageFileSize];
        thumbnailRequest = [self createUploadRequestWithUrl:thumbnailImageTemporaryUrl key:thumbnailFileKey fileSize:thumbnailImageFileSize];
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        [[[transferManager upload:request] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"Error %@", task.error);
                [self finish];
                
            } else {
                NSString *imageUrl = [self constructImagePathFromKey:fileKey];
                ReportImageManagedObject *reportImage = [self selectReportImageFromGuid:guid];
                reportImage.linkImageUrl = imageUrl;
                [self.managedObjectContext save:nil];
            }
            
            return [transferManager upload:thumbnailRequest];
            
        }] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"ThumbnailError %@", task.error);
                [self finish];
                
            } else {
                NSString *imageUrl = [self constructImagePathFromKey:thumbnailFileKey];
                ReportImageManagedObject *reportImage = [self selectReportImageFromGuid:guid];
                reportImage.linkThumbnailUrl = imageUrl;
                reportImage.isUploaded = @YES;
                [self.managedObjectContext save:nil];
                [self postReportImageToServer];
            }
            return nil;
        }];
        
    } else {
        NSLog(@"ReportImageSyncCommandError write-file-error %@", fileError);
        [self finish];
    }
}

- (AWSS3TransferManagerUploadRequest *)createUploadRequestWithUrl:(NSURL *)url key:(NSString *)key fileSize:(NSNumber *)fileSize {
    
    AWSS3TransferManagerUploadRequest *request = [AWSS3TransferManagerUploadRequest new];
    request.bucket = self.bucketName;
    request.ACL = AWSS3BucketCannedACLPublicRead;
    request.key = key;
    request.body = url;
    request.contentType = ImageContentType;
    request.contentLength = fileSize;
    [request setUploadProgress:
     ^(int64_t bytesSent
       , int64_t totalBytesSent
       , int64_t totalBytesExpectedToSend) {
         NSLog(@"url %@ uploading %llu/%llu", url, totalBytesSent, totalBytesExpectedToSend);
     }]; 
    
    return request;
}

- (NSString *)constructImagePathFromKey:(NSString *)key {
   
    NSString *path = [NSString stringWithFormat:
                      @"http://s3-ap-southeast-1.amazonaws.com/%@/%@"
                      ,self.bucketName
                      ,key];
    return path;
}

- (void)postReportImageToServer {
    
    NSString *guid = self.guid;
    ReportImageManagedObject *reportImage = [self selectReportImageFromGuid:guid];
    NSString *imageUrl = reportImage.linkImageUrl;
    NSString *thumbnailUrl = reportImage.linkThumbnailUrl;
    NSString *reportGuid = reportImage.reportGuid;
    
    assert(guid);
    assert(imageUrl);
    assert(thumbnailUrl);
    assert(reportGuid);
    
    NSDictionary *payload = @{ @"guid": guid
                               ,@"reportGuid": reportGuid
                               ,@"imageUrl": imageUrl
                               ,@"thumbnailUrl": thumbnailUrl
                             };
    
    NSData *body = [NSJSONSerialization
                    dataWithJSONObject:payload
                    options:NSJSONWritingPrettyPrinted
                    error:nil];
    
    NSURL *url = self.endpoint;
    NSString *authentication = [@"Token " stringByAppendingString:self.configuration.authenticationToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Content-Type": @"application/json", @"Authorization": authentication};
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        NSError *_error = error;
        NSInteger statusCode = _response.statusCode;
        
        if (statusCode >= 200 && statusCode < 300) {
            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            NSLog(@"ReportImageTask End %@", responseData);
            [self updateStatus:guid];
            return;
        }
        
        if (statusCode < 500) {
            NSUInteger errorCode = InvalidFormData;
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"responseString": responseString
                                 }];
        }
        
        if (statusCode >= 500) {
            NSUInteger errorCode = APIInternalServerError;
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _error = [NSError 
                      errorWithDomain:PODDDomain
                      code:errorCode
                      userInfo:@{
                                 @"url": _response.URL,
                                 @"httpStatusCode": @(statusCode),
                                 @"responseString": responseString
                                 }]; 
        }
        
        NSLog(@"ReportTask Error %@", _error);
        [self finish];
    }];
    
    [task resume];
    NSLog(@"sending request %@\nBody %@"
          , request
          , [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
}

- (void)updateStatus:(NSString *)guid {
    
    assert(guid);
    assert(self.managedObjectContext);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportImage"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        ReportImageManagedObject *reportImage = results.firstObject;
        reportImage.submitStatus = @(ReportSubmitStatusDone);
        
        [self.managedObjectContext save:nil];
    });
    [self finish];
}

- (ReportImageManagedObject * _Nullable)selectReportImageFromGuid:(NSString *)guid {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReportImage"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    ReportImageManagedObject *reportImage = results.firstObject;
    return reportImage;
}


@end
