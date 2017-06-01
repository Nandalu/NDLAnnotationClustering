//
//  ViewController.m
//  NDLAnnotationClusteringDemo-ObjC
//
//  Created by denkeni on 18/05/2017.
//  Copyright © 2017 Nandalu. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

#import "NDLClusterAnnotationView.h"
#import <NDLAnnotationClustering/NDLAnnotationClustering.h>

static NSString *const NDLAnnotatioViewReuseID = @"NDLAnnotatioViewReuseID";

@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NDLCoordinateQuadTree *coordinateQuadTree;

@end

@implementation ViewController

- (void)loadView {
    self.mapView = [[MKMapView alloc] init];
    self.mapView.pitchEnabled = false;
    self.mapView.delegate = self;
    self.view = self.mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(23.6, 121.0), 250000.0, 250000.0);
    [self.mapView setRegion:region animated:NO];

    self.coordinateQuadTree = [[NDLCoordinateQuadTree alloc] init];
    __weak ViewController *weakSelf = self;
    [self.coordinateQuadTree buildTreeWith:
     @[@{@"lat": @24, @"lng": @120, @"title": @"Hello", @"subtitle": @"hello"},
       @{@"lat": @24, @"lng": @121, @"title": @"Beautiful", @"subtitle": @"Beautiful"},
       @{@"lat": @24, @"lng": @122, @"title": @"World", @"subtitle": @"world"}
      ]
                                   WorldMinLat:15
                                   worldMaxLat:30
                                   worldMinLng:110
                                   worldMaxLng:130 completion:^{
        NSUInteger annotationNumber = [weakSelf.mapView annotations].count;
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && annotationNumber <= 1)
           ||
           ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse &&
            annotationNumber == 0))
            {
                [weakSelf mapView:weakSelf.mapView regionDidChangeAnimated:YES];    // make sure annotations show up
            }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate (Annotation)

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect: self.mapView.visibleMapRect withZoomScale:scale];
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass: [MKUserLocation class]] ) {
        return nil;
    }

    NDLClusterAnnotationView *annotationView = (NDLClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NDLAnnotatioViewReuseID];
    NDLClusterAnnotation *ndlAnnotaion = (NDLClusterAnnotation *)annotation;

    if (!annotationView) {
        annotationView = [[NDLClusterAnnotationView alloc] initWithAnnotation:ndlAnnotaion reuseIdentifier:NDLAnnotatioViewReuseID];
    }

    annotationView.canShowCallout = YES;
    annotationView.count = [ndlAnnotaion count];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}

#pragma mark Annotations update

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];

    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];

    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;

    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];

    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];

    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];

    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

@end
