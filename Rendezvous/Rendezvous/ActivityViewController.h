//
//  ActivityViewController.h
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-02-01.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ActivityViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) IBOutlet MKAnnotationView *map;

-(void)getYelpApiStuff:(NSString *)hobbyName;

@end

@interface YelpData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) double rating;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) bool isClosed;

@end
