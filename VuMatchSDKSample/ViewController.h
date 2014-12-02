//
//  ViewController.h
//  VuMatchSDKSample
//
//  Created by Vufind on 11/17/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VuMatchSDK.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, VuMatchAPIClientDelegate>
-(IBAction) pickImage:(id)sender;
@property (nonatomic, strong) IBOutlet UITableView *recommendationsTable;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@end

