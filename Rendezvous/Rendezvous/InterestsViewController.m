//
//  InterestsViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "InterestsViewController.h"
#import "AMTagListView.h"

@interface InterestsViewController ()

@end

@implementation InterestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AMTagListView *tagListView = [[AMTagListView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:tagListView];
    
    // Add multiple tags
    [tagListView addTags:@[@"my tag", @"some tag", @"my tag", @"some tag", @"my tag", @"tag", @"some tag", @"my tag", @"some tag", @"my tag", @"tag", @"some tag", @"my tag", @"tag", @"some tag", @"my tag", @"some tag", @"my tag", @"some tag", @"my tag", @"tag", @"some tag", @"tag", @"tag"]];
    
    [tagListView setTapHandler:^(AMTagView *tapHandler) {
        if (tapHandler.isToggled) {
            [tapHandler setTagColor:[UIColor redColor]];
            tapHandler.isToggled = false;
        }
        else
        {
            [tapHandler setTagColor:[UIColor purpleColor]];
            tapHandler.isToggled = true;
        }
    }];
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
