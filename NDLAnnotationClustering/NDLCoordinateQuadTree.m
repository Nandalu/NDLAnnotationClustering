//
//  NDLCoordinateQuadTree.m
//  NDLAnnotationClustering
//
//  Created by denkeni on 10/01/2017.
//  Modified from TBCoordinateQuadTree.m
//  Copyright © 2017 Nandalu. All rights reserved.
//

#import "NDLCoordinateQuadTree.h"
#import "NDLClusterAnnotation.h"
#import "TBQuadTree.h"

TBQuadTreeNodeData TBDataFromDataDict(NSDictionary *dataDict)
{
    double longitude = [[dataDict valueForKey:@"lng"] doubleValue];
    double latitude = [[dataDict valueForKey:@"lat"] doubleValue];
    CFDictionaryRef annotationInfoCFDict = CFBridgingRetain(dataDict);
    TBQuadTreeNodeData result = TBQuadTreeNodeDataMake(latitude, longitude, (void*)annotationInfoCFDict);
    return result;
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));

    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;

    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;

    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));

    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));

    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);

    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;

        default:
            return 88;
    }
}


@interface NDLCoordinateQuadTree ()

@property (assign, nonatomic) TBQuadTreeNode* root;

@end

@implementation NDLCoordinateQuadTree

- (void)buildTreeWith:(NSArray*)dataDictArray
          WorldMinLat:(CLLocationDegrees)minLat
          worldMaxLat:(CLLocationDegrees)maxLat
          worldMinLng:(CLLocationDegrees)minLng
          worldMaxLng:(CLLocationDegrees)maxLng
           completion:(void (^)(void))completion
{
    @autoreleasepool {
        NSInteger count = dataDictArray.count;
        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            NSDictionary *dataDict = dataDictArray[i];
            dataArray[i] = TBDataFromDataDict(dataDict);
        }

        TBBoundingBox world = TBBoundingBoxMake(minLat, minLng, maxLat, maxLng);
        _root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);

        if (completion) {   // in case of nil block inside block = EXC_BAD_ACCESS
            completion();
        }
    }
}

- (NSArray*)clusteredAnnotationsWithinMapRect:(MKMapRect)rect
                                withZoomScale:(double)zoomScale
{
    NSArray *annotationsDataArray = [self clusteredAnnotationsDataArrayWithinMapRect:rect
                                                                       withZoomScale:zoomScale];
    NSMutableArray *clusterAnnotationArray = [NSMutableArray array];
    for (NSArray *annotationData in annotationsDataArray) {
        NDLClusterAnnotation *clusterAnnotation = [[NDLClusterAnnotation alloc] initWithData:annotationData];
        [clusterAnnotationArray addObject:clusterAnnotation];
    }
    return [NSArray arrayWithArray:clusterAnnotationArray];
}

- (NSArray*)clusteredAnnotationsDataArrayWithinMapRect:(MKMapRect)rect
                                          withZoomScale:(double)zoomScale
{
    if (!self.root) {
        return nil;
    }
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;

    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

    NSMutableArray *annotationsDataArray = [NSMutableArray array];
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            NSMutableArray *annotationData = [NSMutableArray array];
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                CFDictionaryRef annotationInfoCFDict = data.data;
                NSDictionary *annotationDataDict = (__bridge NSDictionary *)(annotationInfoCFDict);
                [annotationData addObject:annotationDataDict];
            });
            [annotationsDataArray addObject:annotationData];
        }
    }

    return [NSArray arrayWithArray:annotationsDataArray];
}

@end
