//
//  HourlyViewController.m
//  Rendezvous
//
//  Created by zkmb on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HourlyViewController.h"
#import "HobbyTableViewCell.h"
#import "AppDelegate.h"
#import "ActivityViewController.h"

@interface HourlyViewController () {
    
}
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
    [cell.hobbyName setTitle:hobbyData[indexPath.row] forState:UIControlStateNormal];
    
    cell.hobbyName.layer.cornerRadius = 5;
    cell.hobbyName.layer.masksToBounds = YES;
    
    cell.hobbyName.tag = indexPath.row;
    
    
    cell.progress.layer.cornerRadius = 5;
    cell.progress.layer.masksToBounds = YES;
    
    
    NSLog(@"%@", NSStringFromCGRect(cell.progress.frame));
    NSLog(@"%f", [[UIScreen mainScreen] bounds].size.width);
    
    
    [cell.hobbyName addTarget:self action:@selector(Next:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"%@",hobbyData[indexPath.row]);
    return cell;
}


- (IBAction)Next:(id)sender
{
    //DataTransfer
    [self performSegueWithIdentifier:@"Activity" sender:sender];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"Activity"]) {
        ActivityViewController *dest = (ActivityViewController *)[segue destinationViewController];
        int index = 0;
        @try {
            index = (int)((UIButton *) sender).tag;
        } @catch (NSException *e) {}
        [dest getYelpApiStuff:[hobbyData objectAtIndex:index]];
        //the sender is what you pass into the previous method
    }
}


- (IBAction)Back:(id)sender
{
    hobbyData = [[NSMutableArray alloc] init];
    //this is really hacky
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
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
