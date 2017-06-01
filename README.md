NDLAnnotationClustering
======================

A drop-in map annotation clustering solution, modified from [TBAnnotationClustering](https://github.com/thoughtbot/TBAnnotationClustering).

## Requirements

iOS 9 or later, but earlier iOS version may work.

## Add to Your Project

### CocoaPods

#### Podfile

In light of [this discussion](https://github.com/CocoaPods/CocoaPods/issues/4989#issuecomment-193772935), we encourage this form:

```
pod 'NDLAnnotationClustering', :git => 'https://github.com/Nandalu/NDLAnnotationClustering'
```

Run `pod install`. For first time CocoaPods user, run `pod init` to generate Podfile template automatically.


### Carthage

#### Cartfile
```
github "Nandalu/NDLAnnotationClustering"
```

Follow instructions on [Carthage](https://github.com/Carthage/Carthage).

### Git Submodule

Add as submodule:

```
git submodule add https://github.com/Nandalu/NDLAnnotationClustering
```

Then manually add to your project, like "Apps with Multiple Xcode Projects" as follows:

1. Drag `NDLAnnotationClustering.xcodeproj` into your project.
2. Project settings - Targets - General - Embedded Binaries: add `NDLAnnotationClustering.frameworkiOS`

See more ways on Apple's [Technical Note TN2435: Embedding Frameworks In An App](https://developer.apple.com/library/content/technotes/tn2435/).

## How to Use

### Input

Init NDLCoordinateQuadTree. Input your data in one-dimensional array `[NSDictionary]` format with method below. For each dictionary data, `lat` and `lng` values are required. Callout would be shown with `title` and `subtitle` values provided.
```
- (void)buildTreeWith:(NSArray*)dataDictArray
          WorldMinLat:(CLLocationDegrees)minLat
          worldMaxLat:(CLLocationDegrees)maxLat
          worldMinLng:(CLLocationDegrees)minLng
          worldMaxLng:(CLLocationDegrees)maxLng
           completion:(void (^)(void))completion;
```
World: the map region that covers all of your data points. Data points outside the world will _not_ be used.

### Output

Given map region, all data points within will be clustered, returned as two-dimensional array `[[NSDictionary]]` format, in this method:
```
- (NSArray*)clusteredAnnotationsDataArrayWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;
```
Or, with built-in `NDLClusterAnnotation` as data model, data points will be returned as one-dimensional array `[NDLClusterAnnotation]` format, in this method:
```
- (NSArray*)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;
```
The zoomScale should be given with `self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width`.

## Licenses

All source code is licensed under the MIT License. See [LICENSE](https://github.com/Nandalu/NDLAnnotationClustering/blob/master/LICENSE).
