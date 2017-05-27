//
//  NDLClusterAnnotation.h
//  NDLAnnotationClustering
//
//  Created by denkeni on 10/01/2017.
//  Modified from TBClusterAnnotation.h
//  Copyright © 2017 Nandalu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NDLClusterAnnotation : NSObject <MKAnnotation> {
@protected
    NSString *_title;
    NSString *_subtitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSArray *annotationData;

/// annotationData type: [NSDictionary]
- (instancetype)initWithData:(NSArray*)annotationData;

@end
