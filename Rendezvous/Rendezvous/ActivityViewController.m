//
//  ActivityViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-02-01.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ActivityViewController.h"
#import "MapAnnotation.h"

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


@interface ActivityViewController () {
    int current;
}

@end


@implementation YelpData

@end

@implementation ActivityViewController

@synthesize map, name, open, rating, address, imageView;


NSArray *yelpLocations;
MapAnnotation *anot;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    yelpLocations = [[NSArray alloc]init];
    
    
    [imageView.layer setBorderColor: [[UIColor colorWithRed:136/255.0f green:204/255.0f blue:136/255.0f alpha:1] CGColor]];
    [imageView.layer setBorderWidth: 2.0];
    
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
    NSURL *url = [[NSURL alloc] initWithString:location];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
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
             
             current = 0;
             [self setLocation:current];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
             
             
             //UPDATE GUI ACCORDINGLY
         });
         
     }];
}

-(void)setLocation:(int)i
{
    if (yelpLocations.count !=0) {
        name.text = ((YelpData *)yelpLocations[i]).name;
        address.text = ((YelpData *)yelpLocations[i]).address;
        rating.text = [NSString stringWithFormat:@"%.01f Stars", ((YelpData *)yelpLocations[i]).rating];
        open.text = ((YelpData *)yelpLocations[i]).isClosed ? @"Closed" : @"Open";
        
        NSString *imageURL = ((YelpData *)yelpLocations[i]).imageUrl;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                imageView.image = image;
            });
        });
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address.text
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     for (CLPlacemark* aPlacemark in placemarks)
                     {
                         [map setRegion:MKCoordinateRegionMake(aPlacemark.location.coordinate, MKCoordinateSpanMake(0.60001, 0.60001 )) animated:YES];
                         anot = [[MapAnnotation alloc]initWithTitle:name.text  AndCoordinate:aPlacemark.location.coordinate];
                         [map addAnnotation:anot];
                     }
                     
                 }];
}

-(void)removeAnnotation
{
    [map removeAnnotation:anot];
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

- (IBAction)Back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swipeUp:(id)sender {
    current++;
    if (current == yelpLocations.count) {
        current = 0;
    }
    [self removeAnnotation];
    [self setLocation:current];
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

