//
//  ViewController.m
//  VuMatchSDKSample
//
//  Created by Vufind on 11/17/14.
//  Copyright (c) 2014 Vufind Inc. All rights reserved.
//

#import "ViewController.h"

// Replace the following 4 constanst with your correct values
#define CUSTOMER_ID @""
#define APP_KEY @""
#define APP_TOKEN @""
#define CATEGORY_NAME @""

@interface ViewController ()
@property (nonatomic, strong) NSArray * recommendationsArray;
@end

@implementation ViewController

@synthesize recommendationsTable;
@synthesize recommendationsArray;
@synthesize activityIndicator;
@synthesize errorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.recommendationsTable.delegate = self;
    self.recommendationsTable.dataSource = self;
    recommendationsArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickImage:(id)sender
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker  dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        [activityIndicator startAnimating];
        [errorLabel setText:@""];
        
        VuMatchAPIClient *vuMatchAPIClient = [[VuMatchAPIClient alloc] initWithCustomerId:CUSTOMER_ID andAppKey:APP_KEY andAppToken:APP_TOKEN];
        [vuMatchAPIClient postImage:image inCategory:CATEGORY_NAME withDelegate:self];
    }
}



#pragma mark - Table View DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!recommendationsArray)
        return 0;
    return [recommendationsArray count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendationCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecommendationCell"];
    }
    
    NSString *skuId = ((VuMatchRecommendation*)[recommendationsArray objectAtIndex:indexPath.row]).skuId;
    NSNumber *score = ((VuMatchRecommendation*)[recommendationsArray objectAtIndex:indexPath.row]).score;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", skuId, score];
    
    return cell;
}

#pragma mark - VuMatch API Delegate

-(void)vuMatchAPIClient:(VuMatchAPIClient *)apiClient didFinishWithRecommendations:(NSArray *)recommendations {
    self.recommendationsArray = recommendations;
    [self.recommendationsTable reloadData];
    [activityIndicator stopAnimating];
}

-(void)vuMatchAPIClient:(VuMatchAPIClient *)apiClient didFinishWithError:(NSError *)error {
    self.recommendationsArray = nil;
    [self.recommendationsTable reloadData];
    [activityIndicator stopAnimating];
    NSLog(@"Error: %@", error);
}

#pragma end

@end
