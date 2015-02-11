//
//  DataTransferViewController.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-01-31.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "DataTransferViewController.h"
#import "HourlyViewController.h"
#import "AppDelegate.h"


@interface DataTransferViewController ()

@end

@implementation DataTransferViewController


@synthesize pair, devicePeerID, session, serviceAdvertiser, nearbyServiceBrowser, idsToSend, parsedData;

static NSString * const serviceType = @"rendezvous";
NSMutableArray *response;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    response = [[NSMutableArray alloc]init];
    parsedData = [[NSMutableArray alloc]init];
    devicePeerID = [[MCPeerID alloc] initWithDisplayName:@"Test"];
    
    session = [[MCSession alloc] initWithPeer:devicePeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    
    serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:devicePeerID discoveryInfo:nil serviceType:serviceType];
    serviceAdvertiser.delegate = self;
    // (I've set discoveryInfo to nil here, but it can also contain an NSDictionary of data to pass along to browsers who find this advertiser via the browser:foundPeer:withDiscoveryInfo method)
    
    nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:devicePeerID serviceType:serviceType];
    nearbyServiceBrowser.delegate = self;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
    invitationHandler(YES, session);
}


- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"Did not start advertising error: %@", error);
}


// Peer found
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"Session Manager found peer: %@", peerID);
    
    [nearbyServiceBrowser invitePeer:peerID toSession:session withContext:nil timeout:10];
    
}

// Peer lost, ex. out of range
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Session Manager lost peer: %@", peerID);
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Did not start browsing for peers: %@", error);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler {
    NSLog(@"Did receive certificate");
    certificateHandler(true);
}

// To detect changes in the state of your connections with your peers….
- (void)session:(MCSession *)sessionLc peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    switch (state) {
        case MCSessionStateConnected: {
            
            NSLog(@"Connected to %@", peerID);
            dispatch_async(dispatch_get_main_queue(), ^{
                _outputLbl.text = @"Connected!";
            });
            
            //  If you'd like to send your text string as soon as you're connected...
            NSError *error;
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:idsToSend];
            [sessionLc sendData:arrayData toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error:&error];
            
            break;
        } case MCSessionStateConnecting: {
            NSLog(@"Connecting to %@", peerID);
            dispatch_async(dispatch_get_main_queue(), ^{
                _outputLbl.text = @"Connecting...";
            });
            
            break;
        } case MCSessionStateNotConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                _outputLbl.text = @"Searching...";
            });
            break;
        }
    }
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"Did receive data.");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputLbl.text = @"Downloading...";
    });
    
    
    response = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //merge the two arrays
    NSArray *unionOfIds = [response arrayByAddingObjectsFromArray:idsToSend];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:unionOfIds options:kNilOptions error:nil];
    NSString *jsonSring = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSString *location = [NSString stringWithFormat:@"http://rendezvouswith.me/analyze?interests=%@", jsonSring];
    NSURL *url = [[NSURL alloc] initWithString:location];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //this is BAD but will work for the demo
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSMutableArray *JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        for (NSMutableDictionary *dict in JSONData)
        {
            NSString *hobbyName = dict[@"hobby_name"];
            [parsedData addObject:hobbyName];
            
        }
      
        dispatch_async(dispatch_get_main_queue(), ^{
            [self next];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });

    }];
}

- (void)start {
    [serviceAdvertiser startAdvertisingPeer];
    [nearbyServiceBrowser startBrowsingForPeers];
}

- (void)stop {
    [serviceAdvertiser stopAdvertisingPeer];
    [nearbyServiceBrowser stopBrowsingForPeers];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (!pair) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:idsToSend options:kNilOptions error:nil];
        NSString *jsonSring = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        NSString *location = [NSString stringWithFormat:@"http://rendezvouswith.me/analyze?interests=%@", jsonSring];
        NSURL *url = [[NSURL alloc] initWithString:location];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //this is BAD but will work for the demo
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSMutableArray *JSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             for (NSMutableDictionary *dict in JSONData)
             {
                 NSString *hobbyName = dict[@"hobby_name"];
                 [parsedData addObject:hobbyName];
                 
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self next];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             });
             
         }];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputLbl.text = @"Looking for a partner device";
        [self start];
    });
}

- (IBAction)Back:(id)sender
{
    [self stop];
    //DataTransfer
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)next
{
    if (parsedData.count == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!" message:@"No Hobbies!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];

        return;
    }
    
    [self stop];
    //DataTransfer
    [self performSegueWithIdentifier:@"Hobby" sender:self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"Hobby"]) {
        HourlyViewController *dest = (HourlyViewController *)[segue destinationViewController];

        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).hobbyArray = parsedData.copy;
        parsedData = [[NSMutableArray alloc]init];
    }
}


@end
