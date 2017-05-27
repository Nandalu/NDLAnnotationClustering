//
//  NDLClusterAnnotation.m
//  NDLAnnotationClustering
//
//  Created by denkeni on 10/01/2017.
//  Modified from TBClusterAnnotation.m
//  Copyright © 2017 Nandalu. All rights reserved.
//

#import "NDLClusterAnnotation.h"

@implementation NDLClusterAnnotation

- (instancetype)initWithData:(NSArray*)annotationData
{
    self = [super init];
    if (self) {
        // Retrieve all dataDicts contained in this clusterAnnotation
        // (a clusterAnnotation may contain more than 1 dataDict)
        NSMutableArray *coordinates = [[NSMutableArray alloc] init];
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *subtitles = [[NSMutableArray alloc] init];
        NSUInteger count = annotationData.count;

        for (NSDictionary *dataDict in annotationData) {
            CLLocationDegrees lat = [[dataDict objectForKey:@"lat"] doubleValue];
            CLLocationDegrees lng = [[dataDict objectForKey:@"lng"] doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
            [coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];

            NSString *title = [dataDict objectForKey:@"title"];
            NSString *subtitle = [dataDict objectForKey:@"subtitle"];
            if (title) {
                [titles addObject:title];
            }
            if (subtitle) {
                [subtitles addObject:subtitle];
            }
        }

        // Presentation of all dataDicts contained in this clusterAnnotation
        CLLocationDegrees totalLat = 0;
        CLLocationDegrees totalLng = 0;
        for (NSValue *coordinateValue in coordinates) {
            CLLocationCoordinate2D coordinate = coordinateValue.MKCoordinateValue;
            totalLat += coordinate.latitude;
            totalLng += coordinate.longitude;
        }
        self.coordinate = CLLocationCoordinate2DMake(totalLat / count, totalLng / count);

        if (count == 1) {
            self.title = titles.lastObject;
            self.subtitle = subtitles.lastObject;
        } else {
            self.title = [NSString stringWithFormat:@"Here are %ld data points.", (unsigned long)count];
            self.subtitle = @"Zoom in map to see more";
        }

        self.count = count;
        self.annotationData = annotationData;
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    if ([self hash] != [object hash]) {
        return false;
    }
    if ([object isKindOfClass:[NDLClusterAnnotation class]]) {
        if (![self.annotationData isEqualToArray:((NDLClusterAnnotation*)object).annotationData]) {
            return false;
        }
    }
    return true;
}

@end
