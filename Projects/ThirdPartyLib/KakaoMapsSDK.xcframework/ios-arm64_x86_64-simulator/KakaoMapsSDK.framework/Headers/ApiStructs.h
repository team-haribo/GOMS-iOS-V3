//
//  ApiStructs.h
//  KakaoMapAPI
//
//  Created by narr on 2020/07/30.
//  Copyright © 2020 Kakao. All rights reserved.
//

#ifndef ApiStructs_h
#define ApiStructs_h

#import <Foundation/Foundation.h>
#import "ApiEnums.h"

/// Internal
@protocol APIManagerProtocol<NSObject>
@end

/// Gui의 Fade-In & Fade-Out 효과의 옵션을 지정하는 구조체.
struct FadeInOutOptions{
    /// Fade-In 효과 지속시간
    unsigned int    fadeInTime;
    /// Fade-Out 효과 지속시간
    unsigned int    fadeOutTime;
    /// Fade-In / Fade-Out 사이에서 Gui가 표시가 유지되는 시간.
    unsigned int    retentionTime;
};

/// CameraAnimationOption을 지정하는 구조체.
struct CameraAnimationOptions{
    ///autoElevation 여부. true로 설정할경우 일정거리 이상 이동할때 카메라 높이를 조절하여 보여준다.
    BOOL autoElevation;
    /// 동작중인 이동 애니메이션이 있을 경우, 이어서 실행할지에 대한 여부. false인 경우 기존 이동 애니메이션은 취소된다.
    BOOL consecutive;
    /// 애니메이션 지속 시간.
    NSUInteger durationInMillis;
};

/// CameraTransform의 변화량값을 지정하는 구조체.
struct CameraTransformDelta{
    /// Longitude 값 변화량
    double deltaLon;
    /// Latitude 값 변화량
    double deltaLat;
};

/// Poi가 나타나고 사라질 때 transition 효과를 지정하는 구조체
struct PoiTransition{
    /// Poi가 나타날 때 transition 효과
    TransitionType entrance;
    /// Poi가 사라질 때 transition 효과
    TransitionType exit;
};

/// Gui의 Image 크기를 나타내기 위한 구조체.
struct GuiSize{
    /// 이미지 width
    NSUInteger width;
    /// 이미지 height
    NSUInteger height;
};

/// Gui의 가변 크기를 위한 inset
struct GuiEdgeInsets{
    /// inset top
    NSUInteger top;
    /// inset left
    NSUInteger left;
    /// inset bottom
    NSUInteger bottom;
    /// inset right
    NSUInteger right;
};

/// GuiComponent 내부 패딩값을 지정하기 위한 구조체.
///
/// left, right, top, bottom 방향으로 패딩값을 주어 GuiComponent내부에 패딩 공간을 지정할 수 있다.
struct GuiPadding{
    /// padding left
    int left;
    /// padding right
    int right;
    /// padding top
    int top;
    /// padding bottom
    int bottom;
};

/// Gui 및 GuiComponent의 수직/수평방향 정렬을 지정하기 위한 구조체
struct GuiAlignment{
    /// 세로방향 alignment
    VerticalAlign   vAlign;
    /// 가로방향 alignment
    HorizontalAlign hAlign;
};

/// 애니메이션 효과 옵션 지정을 위한 구조체
struct AnimationInterpolation{
    /// 애니메이션 지속시간(ms)
    unsigned int duration;
    
    /// 애니메이션 method type.
    InterpolationMethodType method;
};

/// 평면좌표계 표현을 위한 구조체
struct CartesianCoordinate{
    /// x
    double x;
    /// y
    double y;
};

/// 경위도좌표계 표현을 위한 구조체
struct GeoCoordinate{
    /// longitude
    double longitude;
    /// latitude
    double latitude;
};

/// 3차원 벡터를 표현하기 위한 구조체
struct Vector3{
    /// x
    double x;
    /// y
    double y;
    /// z
    double z;
};

/// 2차원 벡터를 표현하기 위한 구조체
struct Vector2{
    /// x
    double x;
    /// y
    double y;
};

/// Euler각을 표현하기 위한 구조체
struct EulerAngle{
    /// yaw
    double yaw;
    /// pitch
    double pitch;
    /// roll
    double roll;
};

/// RouteLine상의 특정 지점 정보를 표현하기 위한 구조체
struct RPInfo {
    /// longitude
    double lon;
    /// latitude
    double lat;
    /// 방향(radian)
    double orientation;
};

#endif /* ApiStructs_h */
