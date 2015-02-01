//
//  ActivityViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-02-01.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "ActivityViewController.h"

@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end


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
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    userCoords = [locationManager location].coordinate;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self startStandardUpdates];
}

-(void)getYelpApiStuff:(NSString *)hobbyName
{
    
    [self startStandardUpdates];
    
    CLLocationCoordinate2D coords = [locationManager location].coordinate;
    NSMutableArray *yelpData = [[NSMutableArray alloc] init];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSString *location = [NSString stringWithFormat:@"http://rendezvous.mybluemix.net/hobby?term=%@&location=[%f,%f]",
                          [hobbyName urlencode], coords.latitude, coords.longitude];
    NSLog(@"%@", location);
    NSURL *url = [[NSURL alloc] initWithString:location];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         
         NSMutableArray *JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         NSLog(@"%@", data);
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


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [errorAlert show];
    
    NSLog(@"Error: %@",error.description);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *crnLoc = [locations lastObject];
    
    userCoords = crnLoc.coordinate;
    
     NSLog(@"%f %f", crnLoc.coordinate.longitude, crnLoc.coordinate.latitude);
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

