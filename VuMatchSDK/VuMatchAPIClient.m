//
//  VuMatchAPIClient.m
//  VuMatchSDK
//
//  Created by Vufind on 11/24/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import "VuMatchAPIClient.h"
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "VuMatchRecommendation.h"


@implementation VuMatchAPIClient
static AWSAnonymousCredentialsProvider *awsCP = nil;
static AWSServiceConfiguration *awsSC = nil;
static AWSS3TransferManager *awsTransferManager = nil;
@synthesize appKey = _appKey;
@synthesize appToken = _appToken;
@synthesize customerId = _customerId;

-(instancetype)initWithCustomerId:(NSString *)customerId andAppKey:(NSString *)appKey2 andAppToken:(NSString *)appToken{
    self = [super init];
    if (self) {
        _appKey = appKey2;
        _appToken = appToken;
        _customerId = customerId;
    }
    if (!awsCP)
        awsCP = [[AWSAnonymousCredentialsProvider alloc] init];
    if (!awsSC)
        awsSC = [AWSServiceConfiguration configurationWithRegion:AWSRegionSAEast1 credentialsProvider:awsCP];
    if (!awsTransferManager)
        awsTransferManager = [[AWSS3TransferManager alloc] initWithConfiguration:awsSC identifier:@"VuMatchUploads"];
    
    return self;
}


-(void)postImage:(UIImage *)image inCategory:(NSString *)categoryName withDelegate:(id<VuMatchAPIClientDelegate>)apiDelegate {

    NSString *path = [self copyImageToCache:image withSize:IMAGE_SCALE_SIZE];

    if (!path) {
        NSError *error = [NSError errorWithDomain:@"VuMatchAPIClientError" code:2010 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Cannot read the image specified or cannot access device cache storage", @"Message", nil]];
        [apiDelegate vuMatchAPIClient:self didFinishWithError:error];
        return;
    }
    [self uploadToS3FromPath:path forCategory:categoryName withDelegate:apiDelegate];
    
}


- (void) uploadToS3FromPath:(NSString *) filePath forCategory:(NSString *)category withDelegate:(id<VuMatchAPIClientDelegate>)apiDelegate {
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSString *extension = [filePath pathExtension];
    
    extension = [extension length] == 0 ? extension : [@"." stringByAppendingString:extension];
    
    //[AWSServiceManager defaultServiceManager].defaultServiceConfiguration = [[AWSServiceConfiguration alloc] init];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"vufind.shop";
    uploadRequest.key = [NSString stringWithFormat:@"%@%f%@", S3_FILE_KEY, [[NSDate date] timeIntervalSince1970], extension];
    uploadRequest.body = fileURL;
    
    //AWSAnonymousCredentialsProvider *awsCP = [[AWSAnonymousCredentialsProvider alloc] init];
    //AWSServiceConfiguration *awsSC = [AWSServiceConfiguration configurationWithRegion:AWSRegionSAEast1 credentialsProvider:awsCP];
    
    //AWSS3TransferManager *transferManager = [[AWSS3TransferManager alloc] initWithConfiguration:awsSC identifier:@"VuMatchUploads"];
    
    [[awsTransferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                          withBlock:^id(BFTask *task) {
                                                              if (task.error) {
                                                                  if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                      switch (task.error.code) {
                                                                          case AWSS3TransferManagerErrorCancelled:
                                                                          case AWSS3TransferManagerErrorPaused:
                                                                              break;
                                                                              
                                                                          default:
                                                                              NSLog(@"Error: %@", task.error);
                                                                              [apiDelegate vuMatchAPIClient:self didFinishWithError:task.error];
                                                                              break;
                                                                      }
                                                                  } else {
                                                                      // Unknown error.
                                                                      NSLog(@"Error: %@", task.error);
                                                                      [apiDelegate vuMatchAPIClient:self didFinishWithError:task.error];
                                                                  }
                                                              }
                                                              
                                                              if (task.result) {
                                                                  //AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                                  // The file uploaded successfully.
                                                                  //NSLog(@"FileUploaded:%@", [self generateS3URLForKey:uploadRequest.key]);
                                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                      [self callVuMatchAPIForImageURL:[self generateS3URLForKey:uploadRequest.key] inCategory:category withDelegate:apiDelegate];
                                                                  });
                                                                  
                                                              }
                                                              return nil;
                                                          }];
    
}

- (NSString *) generateS3URLForKey:(NSString *) fileKey {
    return [NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@", S3_BUCKET_NAME, fileKey];
}

-(NSString *) copyImageToCache:(UIImage *) image withSize:(NSInteger) size{
    CGSize oldSize = [image size];
    if (oldSize.width > size && oldSize.height > size) {
        CGSize newSize = CGSizeMake(size, size);
        if (oldSize.width < oldSize.height) {
            newSize.height = oldSize.height * size / oldSize.width;
        } else {
            newSize.width = oldSize.width * size / oldSize.height;
        }
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData * imageData = UIImagePNGRepresentation(image);
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:IMAGE_FILE_NAME_FORMAT, [[NSDate date] timeIntervalSince1970]]];
    BOOL result = [imageData writeToFile:path atomically:YES];
    
    if (result)
        return path;
    
    return nil;
}

-(void)callVuMatchAPIForImageURL:(NSString *) imageURL inCategory:(NSString *) category  withDelegate:(id<VuMatchAPIClientDelegate>)apiDelegate {
    NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:VUMATCH_API_URL_FORMAT, _customerId, category, imageURL, _appKey, _appToken]]];
    //NSLog(@"Response:%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    if (error) {
        return;
    }
    NSNumber *result = json[@"Status"];
    if (![result boolValue]) {
        NSNumber *errorCode = nil;
        NSString *errorMessage = nil;
        NSDictionary *errorJson = json[@"Error"];
        if (errorJson) {
            errorCode = errorJson[@"Code"];
            errorMessage = errorJson[@"Message"];
        } else {
            errorCode = [[NSNumber alloc] initWithInt:2020];
            errorMessage = @"An error has been occurred while contacting VuMatch API";
        }
        NSError *error = [[NSError alloc] initWithDomain:@"VuMatchAPIError" code:[errorCode integerValue] userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:@"Message"]];
        
        [self performSelectorOnMainThread:@selector(callBackOnErrorFor:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:apiDelegate, @"Delegate", error, @"Error", nil] waitUntilDone:NO];
        return;
    }
    
    NSString *dataString = json[@"Data"][@"VufindRecommends"];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\\" withString:@"****"];
    NSMutableArray *recommendations = [[NSMutableArray alloc] init];
    NSArray * matchesArray = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    for (NSDictionary *matchItem in matchesArray) {
        VuMatchRecommendation *recommendation = [VuMatchRecommendation initWithId:matchItem[@"id"] andScore:matchItem[@"score"]];
        [recommendations addObject:recommendation];
    }
    //[apiDelegate vuMatchAPIClient:self didFinishWithRecommendations:recommendations];
    [self performSelectorOnMainThread:@selector(callBackOnSuccessFor:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:apiDelegate, @"Delegate", recommendations, @"Recommendations", nil] waitUntilDone:NO];
}

-(void) callBackOnSuccessFor:(NSDictionary *) info {
    id<VuMatchAPIClientDelegate> apiDelegate = info[@"Delegate"];
    [apiDelegate vuMatchAPIClient:self didFinishWithRecommendations:info[@"Recommendations"]];
}

-(void) callBackOnErrorFor: (NSDictionary *) info {
    id<VuMatchAPIClientDelegate> apiDelegate = info[@"Delegate"];
    [apiDelegate vuMatchAPIClient:self didFinishWithError:info[@"Error"]];
}

@end
