//
//  KMController.h
//  KakaoMapAPI
//
//  Copyright © 2016년 DaumKakao. All rights reserved.
//

#ifndef MapController_h
#define MapController_h

#define POI_UPDATE_BASE_TIME 6
#define CONFIG_UPDATE_TIMEOUT 1000
#define DEFAULT_HEIGHT 1500.76

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KMViewContainer.h"

@class ViewBase;
@class ViewInfo;

/// KMController 이벤트 delegate
@protocol MapControllerDelegate <NSObject>
@required
/// 엔진 생성 및 초기화, 시작 이후 엔진에서 렌더링 준비를 마치면 호출.
///
/// 렌더링 준비가 완료된 상태에 호출되므로, 이 함수를 구현하여 여기에서 필요한 view를 추가한다.
- (void)addViews;

@optional
/// addView 성공시 호출.
- (void)addViewSucceeded:(NSString * _Nonnull)viewName viewInfoName:(NSString * _Nonnull)viewInfoName;

/// addView 실패시 호출.
- (void)addViewFailed:(NSString * _Nonnull)viewName viewInfoName:(NSString * _Nonnull)viewInfoName;

/// MapContainer 크기 변경시 호출.
- (void)containerDidResized:(CGSize)size;

/// 뷰 삭제 직전에 호출.
- (void)viewWillDestroyed:(ViewBase * _Nonnull)view;

/// 인증 성공시 호출.
- (void)authenticationSucceeded;

/// 인증 실패시 호출.
- (void)authenticationFailed:(NSInteger)errorCode
                        desc:(NSString * _Nonnull)desc;

@end

/// KMController
/// MapContainer 안에 뷰를 추가하고 관리하기 위한 controller 역할을 하는 interface.
@interface KMController : NSObject {

}

#pragma mark - Initializer

/// unavailable
- (instancetype _Nonnull)init __attribute__((unavailable("Use initWithMapConfig: instead.")));

/// Designated initializer.
/// - parameter viewContainer: KMViewContainer
/// - returns: KMController
- (instancetype _Nonnull)initWithViewContainer:(KMViewContainer *  _Nonnull)viewContainer;

#pragma mark - Engine Controls

/// Engine 준비
/// 엔진이 렌더링 준비를 마치는 경우, MapControllerDelegate의 addViews를 호출한다.
- (BOOL)prepareEngine;

/// Engine 리셋
/// 생성한 Resource는 모두 릴리즈되므로, stop이후 기존에 사용했던 모든 resource는 사용할 수 없다.
- (void)resetEngine;

/// 엔진 활성화
///
/// 엔진은 앱이 active 상태일 때에만 활성화 상태에 있어야 한다.
/// 이 시점부터 뷰에 렌더링을 하기 시작한다.
- (void)activateEngine;

/// 엔진 일시정지
///
/// 이 시점부터는 뷰에 렌더링을 하지 않는다.
- (void)pauseEngine;

/// 엔진 이슈 확인용 디버그 메세지.
- (NSString * _Nonnull)getStateDescMessage;

#pragma mark - View Controls

/// SubView(ViewBase)를 추가한다.
/// - parameter viewInfo: 추가할 subView에 대한 config
- (void)addView:(ViewInfo * _Nonnull)viewInfo;

/// SubView(ViewBase)를 추가한다.
/// - parameter viewInfo: 추가할 subView에 대한 config
/// - parameter timeoutInMillis: 네트웍을 통한 viewInfo 수신 타임아웃 시간. 단위 millisecond. 기본값 5000.
- (void)addView:(ViewInfo * _Nonnull)viewInfo
        timeout:(NSUInteger)timeoutInMillis;

/// SubView(ViewBase)를 추가한다.
/// - parameter viewInfo : 추가할 subView에 대한 config
/// - parameter viewSize : 추가할 subView에 대한 size
/// - parameter timeoutInMillis: 네트웍을 통한 viewInfo 수신 타임아웃 시간. 단위 millisecond. 기본값 5000.
- (void)addView:(ViewInfo * _Nonnull)viewInfo
       viewSize:(CGSize)viewSize
        timeout:(NSUInteger)timeoutInMillis;

/// SubView(ViewBase)를 특정 사이즈로 추가한다.
/// - parameter config :  추가할 subView에 대한 config
/// - parameter viewSize : 추가할 subView에 대한 size
- (void)addView:(ViewInfo * _Nonnull)viewInfo
       viewSize:(CGSize)viewSize;

/// SubView를 제거한다.
/// - paramter: 삭제할 subView의 이름
- (void)removeView:(NSString * _Nonnull)viewName;

/// viewName에 해당하는 SubView를 가져온다.
/// - parameter viewName: viewName
/// - returns: viewName에 해당하는 subView. 없을경우 nil.
- (ViewBase * _Nullable)getView:(NSString *  _Nonnull)viewName;

#pragma mark - Cache Controls

/// Disk cache를 모두 삭제한다.
- (void)clearDiskCache;

/// Memory cache를 모두 삭제한다.
- (void)clearMemoryCache:(NSString * _Nonnull)viewName;

/// ViewInfo Cache를 모두 삭제한다.
- (void)clearViewInfoCaches;

#pragma mark - Fonts

/// Label, GUI 등에 사용할 외부 폰트를 추가한다.
///
/// OTF, TTF 포맷을 지원한다.
///
/// - parameters
///       - fontName: 추가할 폰트 이름. 추가된 폰트를 사용할 때 지정하는 이름으로 사용된다.
///       - fontData: 폰트 파일의 binary data.
/// - returns: 폰트 추가 결과. 성공시 True.
- (BOOL)addFontWithName:(NSString * _Nonnull)fontName
               fontData:(NSData * _Nonnull)fontData NS_SWIFT_NAME( addFont(fontName:fontData:) );

#pragma mark - Properties

/// KMController event delegate
@property (nonatomic, weak, nullable) id<MapControllerDelegate> delegate;

/// 엔진 활성화 여부
@property (nonatomic, readonly, getter=isEnginePrepared) BOOL enginePrepared;
/// ProMotion display support 활성화 여부
@property (nonatomic, setter=enableProMotionSupport:) BOOL proMotionSupport;
/// 렌더링 하고 있는지 여부
@property (nonatomic, readonly, getter=isEngineActive) BOOL engineActive;

@end

#endif /* MapController_h */
