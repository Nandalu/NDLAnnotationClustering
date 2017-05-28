//
//  NDLCoordinateQuadTree.h
//  NDLAnnotationClustering
//
//  Created by denkeni on 10/01/2017.
//  Modified from TBCoordinateQuadTree.h
//  Copyright © 2017 Nandalu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NDLCoordinateQuadTree : NSObject

/**
    [Input] dataDictArray type: [NSDictionary]
                       example:
    @[@{@"lat": @24, @"lng": @120, @"title": @"Hello", @"subtitle": @"hello"},
      @{@"lat": @24, @"lng": @121, @"title": @"World", @"subtitle": @"world"},
      @{@"lat": @24, @"lng": @122, @"title": @"!", @"subtitle": @"!"}
    ]
 */
- (void)buildTreeWith:(NSArray*)dataDictArray
          WorldMinLat:(CLLocationDegrees)minLat
          worldMaxLat:(CLLocationDegrees)maxLat
          worldMinLng:(CLLocationDegrees)minLng
          worldMaxLng:(CLLocationDegrees)maxLng
           completion:(void (^)(void))completion;

/// [Output] clusteredAnnotations type: [NDLClusterAnnotation]
- (NSArray*)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;
/// [Output] clusteredAnnotationsDataArray type: [[NSDictionary]]
- (NSArray*)clusteredAnnotationsDataArrayWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;

@end
