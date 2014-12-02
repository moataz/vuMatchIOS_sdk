//
//  VuMatchRecommendation.m
//  VuMatchSDK
//
//  Created by Vufind on 11/24/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import "VuMatchRecommendation.h"

@implementation VuMatchRecommendation
@synthesize skuId;
@synthesize score;
+(instancetype)initWithId:(NSString *)skuId andScore:(NSNumber *)score {
    VuMatchRecommendation *object = [[VuMatchRecommendation alloc] init];
    object.skuId = skuId;
    object.score = score;
    return object;
}
@end
