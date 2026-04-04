//
//  NativeEventDelegate.h
//  VectorMapAPI_swift
//
//  Created by 백주현 on 2016. 8. 30..
//  Copyright © 2016년 Kakao. All rights reserved.
//

#ifndef NativeEventDelegate_h
#define NativeEventDelegate_h

#import "ApiEnums.h"

@class MapPoint;

@protocol NativeEventDelegate<NSObject>
@optional
- (void)onTerrainClicked:(ClickType)type
                position:(MapPoint * _Nonnull)point;

- (void)onViewClicked:(ClickType)type
                point:(CGPoint)point;

- (void)onLabelItem:(NSString * _Nonnull)labelID
            ofLayer:(NSString * _Nonnull)layerID
            clicked:(ClickType)clickType
           position:(MapPoint * _Nonnull)point;

- (void)onGuiClicked:(NSString * _Nonnull)guiName
       componentName:(NSString * _Nonnull)componentName;

- (void)onGui:(NSString * _Nonnull)guiName
componentName:(NSString * _Nonnull)componentName
    animation:(AnimationState)state;

- (void)onGuiMoveEvent:(NSString * _Nonnull)guiName
              position:(MapPoint * _Nonnull)position;

- (void)onFocusChanged:(BOOL)focus point:(MapPoint * _Nonnull)point;

- (void)onMoveStarted:(MoveBy)moveBy;

- (void)onMoveEnded:(MoveBy)moveBy;

- (void)onCameraCallback:(BOOL)finished;

- (void)onZoneCreated:(NSString * _Nonnull)viewName
             zoneType:(NSString * _Nonnull)zoneType
               zoneId:(NSString * _Nonnull)zoneId
         zoneDetailId:(NSString * _Nonnull)zoneDetailId
          zoneDetails:(NSArray * _Nonnull)zoneDetails
        zoneLinkInfos:(NSDictionary * _Nonnull)zoneLinkInfo;

- (void)onZoneRemoved:(NSString * _Nonnull)viewName
             zoneType:(NSString * _Nonnull)zoneType
               zoneId:(NSString * _Nonnull)zoneId
         zoneDetailId:(NSString * _Nonnull)zoneDetailId
          zoneDetails:(NSArray * _Nonnull)zoneDetails;

-( void )onRoadviewRequestResultReceived:(NSString * _Nonnull)panoID
                                position:(MapPoint * _Nonnull)position
                               prevItems:(NSArray * _Nonnull)prevItems
                               addresses:(NSArray * _Nonnull)addresses;

//-( void )onStoreviewRequestResultReceived:(NSString * _Nonnull)panoID
//                                 position:(MapPoint * _Nonnull)position
//                                  address:(NSString * _Nonnull)address
//                                placeName:(NSString * _Nonnull)placeName
//                                 spotlist:(NSArray * _Nonnull)spotlist
//                                 spotName:(NSString * _Nonnull)spotName;

- (void)onNoResult;

- (void)onRequestFailed;

- (void)onInvalidRequest;

- (void)onPanoramaUpdated:(NSString * _Nonnull)panoID;
@end


#endif /* NativeEventDelegate_h */
