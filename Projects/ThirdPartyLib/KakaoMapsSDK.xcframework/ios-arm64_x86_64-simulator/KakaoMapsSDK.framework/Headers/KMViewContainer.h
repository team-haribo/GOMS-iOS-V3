//
//  KMViewContainer.h
//  KakaoMapAPI
//
//  Created by narr on 2019/12/26.
//  Copyright © 2019 Kakao. All rights reserved.
//

#ifndef K3fMapContainer_h
#define K3fMapContainer_h

#import <UIKit/UIKit.h>

/// Rendering mode
typedef NS_ENUM(NSUInteger, RenderMode) {
    /// OpenGL
    RenderModeGL,
    /// Metal
    RenderModeMetal,
    /// Undefined
    RenderModeUndefined
};

/// TouchEvent Delegate
@protocol K3fMapContainerDelegate <NSObject>
@optional
/// Touch 시작시 발생
- (void)touchesBegan:(NSSet * _Nonnull)touches;
/// Touch가 끝났을 때 발생
- (void)touchesEnded:(NSSet * _Nonnull)touches;
/// Touch가 취소되었을 때 발생
- (void)touchesCancelled:(NSSet * _Nonnull)touches;
/// Touch 움직일 때 발생
- (void)touchesMoved:(NSSet * _Nonnull)touches;
@end

/// MapContainer
/// UIView를 상속받아 지도를 표시하는 클래스.
@interface KMViewContainer : UIView{
    
}

#pragma mark - Metal usage
/// if true, render using OpenGL. default NO.
+ (void)setUseGL:(BOOL)useGL;
/// return useGL value.
+ (BOOL)useGL;

#pragma mark - delegate

/// View touchEvent Delegate.
- (void)setDelegate:(id<K3fMapContainerDelegate> _Nullable)delegate;

#pragma mark - Properties
/// RenderMode에 따라 실제 지도가 그려지는 childView.
@property (nonatomic, retain) UIView * _Nullable renderView;
/// RenderMode. setUseGL이 true 일경우 GL. 아닐경우 실행환경에 따라  GL/Metal 이 자동으로 선택됨.
@property (atomic, assign) RenderMode renderMode;
/// 기기의 display가 ProMotion 을 지원하는지 여부
@property (nonatomic, readonly) BOOL proMotionDisplay;
@end

#endif /* K3fMapContainer_h */
