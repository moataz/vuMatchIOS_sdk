//
//  VuMatchAPIClient.h
//  VuMatchSDK
//
//  Created by Vufind on 11/24/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VUMATCH_API_URL_FORMAT @"http://api3.vufind.com/vumatch/vumatch_getscores.php?customer_id=%@&cat=%@&url=%@&app_key=%@&token=%@"
#define S3_BUCKET_NAME @"vufind.shop"
#define S3_FILE_KEY @"VuMatchiOSUpload"
#define IMAGE_FILE_NAME_FORMAT @"VuMatch-Upload%f.png"
#define IMAGE_SCALE_SIZE 320

@class VuMatchAPIClient;

/**
 *  Implement this protocol to handle VuMatchAPIClient response in case of success or failure
 */
@protocol VuMatchAPIClientDelegate <NSObject>
@required

/**
 *  This method will be called in case of success with an array of recommendations returned from VuMatch API.
 *  @param apiClient VuMacthAPICLient object that uses the delegate.
 *  @param recommendationArray Array of VuMatchRecommendation objects represent the recommendations returned from VuMatch API.
 */
-(void) vuMatchAPIClient:(VuMatchAPIClient *) apiClient didFinishWithRecommendations:(NSArray *) recommendationArray;

/**
 *  This method will be called in case of failure with an NSError object describes the error.
 *  @param apiClient VuMacthAPICLient object that uses the delegate.
 *  @param error NSError object represents the problem.
 */
-(void) vuMatchAPIClient:(VuMatchAPIClient *) apiClient didFinishWithError:(NSError *)error;

@end

/**
 *  Use this interface to contact VuMatch API.
 */
@interface VuMatchAPIClient : NSObject

@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, copy, readonly) NSString *appToken;
@property (nonatomic, copy, readonly) NSString *customerId;

/**
 *  Initialize an instance of VuMatchAPIClient with a customer id, application key, and application token.
 *
 *  @param customerId Your customer id registered to VuMatch API.
 *  @param appKey Your application key registered to VuMatch API.
 *  @param appToken Your application token registered to VuMatch API.
 *  @return An instance of VuMatchAPIClient
 */
-(instancetype) initWithCustomerId:(NSString *) customerId andAppKey:(NSString *) appKey andAppToken:(NSString *) appToken;

/**
 *  Post an image to VuMatch API and get a list of recommendations.
 *
 *  @param image UIImage object of the image to be posted.
 *  @param categoryName The products category name.
 *  @param apiDelegate An object implement protocol "VuMatchAPIClientDelegate" that handles the response in case of success or failure.
 */
-(void) postImage:(UIImage *) image inCategory:(NSString *) categoryName withDelegate:(id<VuMatchAPIClientDelegate>) apiDelegate;
@end
