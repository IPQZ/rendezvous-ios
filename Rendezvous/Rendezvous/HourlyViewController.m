//
//  HourlyViewController.m
//  Rendezvous
//
//  Created by zkmb on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "HourlyViewController.h"
#import "HobbyTableViewCell.h"
#import "AppDelegate.h"

@interface HourlyViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HourlyViewController

@synthesize hobbyData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    hobbyData = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).hobbyArray;
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return hobbyData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HobbyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hobbiesCell" forIndexPath:indexPath];
    cell.hobbyName.text = hobbyData[indexPath.row];
    NSLog(@"%@",hobbyData[indexPath.row]);
    return cell;
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
