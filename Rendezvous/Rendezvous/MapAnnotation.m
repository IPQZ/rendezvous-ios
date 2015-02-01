//
//  MapAnnotation.m
//  Rendezvous
//
//  Created by Phil Bystrican on 2015-02-01.
//  Copyright (c) 2015 IPQZ. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation


@synthesize coordinate=_coordinate;

@synthesize title=_title;

-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    _title = title;
    _coordinate = coordinate;
    return self;
}

@end
