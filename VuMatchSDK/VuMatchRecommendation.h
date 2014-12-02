//
//  VuMatchRecommendation.h
//  VuMatchSDK
//
//  Created by Vufind on 11/24/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An interface represents VuMatch API recommendation.
 */
@interface VuMatchRecommendation : NSObject

/**
 *  The SKU id of the product recommended.
 */
@property (nonatomic, copy) NSString *skuId;

/**
 *  A floating point value represents the recommendation score.
 */
@property (nonatomic, copy) NSNumber *score;

/**
 *  Create and Initialize a new instance of VuMatchRecommendation object that represents the VuMatch API recommendation.
 *  @param skuId The SKU id of the product recommended.
 *  @param score A floating point value represents the recommendation score.
 *  @return A new instance of VuMatchRecommendation with the skuId and score provided.
 */
+(instancetype) initWithId:(NSString*) skuId andScore:(NSNumber *)score;
@end
