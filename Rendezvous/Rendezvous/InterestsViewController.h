//
//  InterestsViewController.h
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InterestsViewController : UIViewController <UIAlertViewDelegate>

- (void)removefromSelectedWithStr:(NSString *)str;
- (IBAction)Next:(id)sender;
- (IBAction)Back:(id)sender;

@end
