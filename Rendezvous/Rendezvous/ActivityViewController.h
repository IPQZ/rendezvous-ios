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
    CLLocationCoordinate2D userCoords;
}

@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *rating;
@property (nonatomic, strong) IBOutlet UILabel *open;

-(void)getYelpApiStuff:(NSString *)hobbyName;
- (IBAction)Back:(id)sender;

@end

@interface YelpData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) double rating;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) bool isClosed;

@end
