//
//  InterestsViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "InterestsViewController.h"
#import "AMTagListView.h"
#import "Colours.h"
#include "DataTransferViewController.h"

@interface InterestsViewController ()


@end

@implementation InterestsViewController

NSMutableArray *selectedItems;
NSMutableDictionary *interests;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    interests = [[NSMutableDictionary alloc] init];
    selectedItems = [[NSMutableArray alloc]init];
    
    AMTagListView *tagListView = [[AMTagListView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:tagListView];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://rendezvouswith.me/interests"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableArray *JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        for (NSMutableDictionary *dict in JSONData)
        {
            
            NSString *hobbyName = dict[@"name"];
            NSNumber *hobbyID = dict[@"id"];
            interests[hobbyName] = hobbyID;
            
            [tagListView addTag:hobbyName];
        }
        
        [tagListView setTapHandler:^(AMTagView *tapHandler) {
            if (tapHandler.isToggled) {
                [tapHandler setTagColor:kTagColour];
                tapHandler.isToggled = false;
                [self removefromSelectedWithStr: tapHandler.tagText];
                
            }
            else
            {
                [tapHandler setTagColor:kTagSelectedColour];
                tapHandler.isToggled = true;
                [selectedItems addObject:tapHandler.tagText];
            }
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)removefromSelectedWithStr:(NSString *)str
{
    for (int i = 0; i < selectedItems.count; i++) {
        if ([selectedItems[i] isEqualToString:str]) {
            [selectedItems removeObjectAtIndex:i];
            //done
            return;
        }
    }
}

- (IBAction)Next:(id)sender
{
    if (selectedItems.count == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please Choose Interests" message:@"This app only works if you select at least 1 interest." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
        return;
    }
    
    UIAlertView *pair = [[UIAlertView alloc] initWithTitle:@"Would you like to pair?" message:nil delegate:self cancelButtonTitle:@"Solo" otherButtonTitles:@"Pair", nil];
    
    [pair show];
    
    return;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { //pair
        //DataTransfer
        [self performSegueWithIdentifier:@"DataTransfer" sender:self];
    } else {
        //DataTransfer
        [self performSegueWithIdentifier:@"DataTransferSolo" sender:self];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"DataTransfer"]) {
        DataTransferViewController *dest = (DataTransferViewController *)[segue destinationViewController];
        //the sender is what you pass into the previous method
        NSMutableArray *entriesToSend = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < selectedItems.count; i++)
        {
            entriesToSend[i] = interests[selectedItems[i]];
        }
        dest.idsToSend = entriesToSend;
        dest.pair = YES;
    } else if ([[segue identifier] isEqualToString: @"DataTransferSolo"]) {
        DataTransferViewController *dest = (DataTransferViewController *)[segue destinationViewController];
        //the sender is what you pass into the previous method
        NSMutableArray *entriesToSend = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < selectedItems.count; i++)
        {
            entriesToSend[i] = interests[selectedItems[i]];
        }
        dest.idsToSend = entriesToSend;
        dest.pair = NO;
    }
}


- (IBAction)Back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
