//
//  ActivityViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-02-01.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "ActivityViewController.h"


@interface ActivityViewController ()

@end


@implementation YelpData

@end

@implementation ActivityViewController


NSArray *yelpLocations;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    yelpLocations = [[NSArray alloc]init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

-(void)getYelpApiStuff:(NSString *)hobbyName
{
    CLLocationCoordinate2D coords;
    coords = [locationManager location].coordinate;
    
    NSMutableArray *yelpData = [[NSMutableArray alloc] init];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSString *location = [NSString stringWithFormat:@"http://rendezvous.mybluemix.net/hobby?term=%@&location=[%f,%f]", hobbyName, coords.latitude, coords.longitude];
    NSURL *url = [[NSURL alloc] initWithString:location];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSMutableArray *JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         for (NSMutableDictionary *dict in JSONData)
         {
             YelpData *yelp = [[YelpData alloc] init];
             yelp.name = dict[@"name"];
             yelp.rating = ((NSNumber* )dict[@"rating"]).floatValue;
             yelp.isClosed = dict[@"isclosed"];
             yelp.address = dict[@"address"];
             yelp.imageUrl = dict[@"image"];
             [yelpData addObject:yelp];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
              yelpLocations = [NSArray arrayWithArray: yelpData];
             
             //UPDATE GUI ACCORDINGLY
         });
         
     }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //http://rendezvous.mybluemix.net/hobby?term=hobbygoeshere&location=[LAT,LONG]
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
