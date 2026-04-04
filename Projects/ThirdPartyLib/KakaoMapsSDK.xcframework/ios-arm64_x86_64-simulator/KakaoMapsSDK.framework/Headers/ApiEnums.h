//
//  ApiEnums.h
//  KakaoMapAPI
//
//  Copyright © 2016년 Kakao. All rights reserved.
//

#ifndef ApiEnums_h
#define ApiEnums_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ViewInfoStage) {
    ViewInfoStageProd = 0,
    ViewInfoStageCbt,
    ViewInfoStageDev,
    ViewInfoStageAlpha
};

/// RouteLine의 진행 형태
typedef NS_ENUM(NSInteger, RouteProgressType) {
    /// 시작점부터 지정된 지점까지 비워지게 진행됨
    RouteProgressTypeClearFromStart = 0,
    /// 시작점부터 지정된 지점까지 채워지게 진행됨
    RouteProgressTypeFillFromStart
};

/// Progress 진행 방향
typedef NS_ENUM(NSInteger, ProgressDirection) {
    /// 시작점에서 끝점으로 진행
    ProgressDirectionForward = 0,
    /// 끝점에서 시작점으로 진행
    ProgressDirectionBackward
};

/// Developers Phase
typedef NS_ENUM(NSInteger, KAPhase) {
    /// real
    KAPhaseReal = 0,
    /// alpha
    KAPhaseAlpha,
    /// beta
    KAPhaseBeta,
    /// sandbox
    KAPhaseSandBox
};

/// 지도 타입
typedef NS_ENUM(NSInteger, MapType) {
    /// 지도
    MapTypeStandard = 0,
    /// 로드뷰
    MapTypeRoadview
};

/// ViewInfo type enumeration
typedef NS_ENUM(NSInteger, ViewInfoType) {
    /// 지도 뷰
    ViewInfoTypeMapView = 0,
    /// 로드뷰
    ViewInfoTypeRoadview
};

/// 파노라마에 표시되는 마커의 타입
typedef NS_ENUM(NSInteger, PanoramaMarkerType)
{
    /// Direction. 지정된 pan, tilt 방향에 표시되는 마커
    PanoramaMarkerTypeDirection,
    /// Position. 지정된 위치에 표시되는 마커. 일정 거리 이상 멀어질경우 표시되지 않는다.
    PanoramaMarkerTypePosition
};

/// RoadviewLookAt Type
typedef NS_ENUM(NSInteger, RoadviewLookAtType)
{
    /// 정북방향을 바라본다
    RoadviewLookAtTypeNowHere,
    /// 지정한 Position을 바라본다
    RoadviewLookAtTypePosition,
    /// 지정한 Pan, Tilt값으로 바라본다.
    RoadviewLookAtTypePanTilt
};

/// Label의 LayerType
typedef NS_ENUM(NSInteger, LayerType) {
    /// 일반 Layer Type
    LayerTypeNormal,
    /// 레벨에 따라 디테일 처리를 다르게 하는 LodLayer Type.
    LayerTypeLod
};

/// Poi의 경쟁 타입
typedef NS_ENUM(NSInteger, CompetitionType) {
    /// 경쟁하지 않고 겹쳐서 그린다.
    CompetitionTypeNone = 0,
    /// Upper, Same, Lower 모든 속성을 가지고 경쟁한다.
    CompetitionTypeAll,
    /// 자신보다 우선순위가 높은 Layer와 경쟁한다. 우선순위가 높은 Layer에 우선권이 있으므로, 우선순위가 높은 Layer와의 경쟁할 경우 무조건 지게 되므로 표시되지 않는다.
    CompetitionTypeUpper,
    /// Upper속성과 Lower속성을 가지고 경쟁한다.
    CompetitionTypeUpperLower,
    /// Upper속성과 Same속성을 가지고 경쟁한다.
    CompetitionTypeUpperSame,
    /// 같은 우선순위를 가진 Layer에 있는 Poi와 경쟁한다. 경쟁 룰은 OrderingType에 따라 결정된다.
    CompetitionTypeSame,
    /// Same과 Lower속성을 가지고 경쟁한다.
    CompetitionTypeSameLower,
    /// 낮은 우선순위를 가진 Layer와 경쟁한다. 상위 Layer에 우선권이 있으므로, 표출된 위치에 "upper"속성이 들어간 하위 Layer의 Poi는 그려지지 않는다.
    CompetitionTypeLower
};

/// Poi 경챙 처리 단위
typedef NS_ENUM(NSInteger, CompetitionUnit) {
    /// Poi의 icon과 Text모두 경쟁에서 통과해야 그려진다.
    CompetitionUnitPoi = 0,
    /// Poi의 icon만 경쟁 기준이 된다. 단, text가 경쟁에서 진 경우 text는 표출되지 않는다.
    CompetitionUnitSymbolFirst
};

/// 우선순위가 같은 라벨끼리 경쟁하는 경우, 경쟁을 처리하는 방법
typedef NS_ENUM(NSInteger, OrderingType) {
    /// Poi 별로 가지고 있는 rank 속성값이 높을수록 경쟁에서 우선순위를 갖는다.
    OrderingTypeRank = 0,
    /// 화면 좌하단과 거리가 가까울수록 높은 우선순위를 갖는다.
    OrderingTypeCloserFromLeftBottom
};

/// Poi의 TextLayout. Poi에서 text가 경쟁할 위치를 지정한다.
typedef NS_ENUM(NSInteger, PoiTextLayout) {
    /// 중앙
    PoiTextLayoutCenter = 0,
    /// 상단
    PoiTextLayoutTop,
    /// 하단
    PoiTextLayoutBottom,
    /// 왼쪽
    PoiTextLayoutLeft,
    /// 오른쪽
    PoiTextLayoutRight
};

/// GUI animation 상태 변경 이벤트 종류.
typedef NS_ENUM(NSInteger, AnimationState) {
    /// 시작
    AnimationStateStart = 0,
    /// 정지
    AnimationStateStop,
    /// 일시정지
    AnimationStatePause,
    /// 재개
    AnimationStateResume,
    /// unknown
    AnimationStateUnknown
};

/// ShapeLayer의 Pass type. Shape가 그려지는 순서를 지정할 수 있다.
typedef NS_ENUM(NSInteger, ShapeLayerPassType) {
    /// 지도 배경이 그려지는 Default PassType. zOrder 10000이상을 권장하며, 지도와 배경 사이에 들어갈 수 있음.
    ShapeLayerPassTypeDefault = 0,
    /// 지도 Overlay가 그려지는 PassType. zorder 10000이상을 권장하며, 지도 배경보다 무조건 위에 그려지고 zOrder에 따라 특정 overlay 밑으로 내려갈 수 있다.
    ShapeLayerPassTypeOverlay,
    /// Route 라인 및 패턴보다 위에 그려지는 PassType. 지도 배경/Overaly/Route 라인보다 무조건 위에 그려진다.
    ShapeLayerPassTypeRoute
};

/// Shape의 type
typedef NS_ENUM(NSInteger, ShapeType) {
    ///PolygonShape
    ShapeTypePolygon = 0,
    ///PolylineShape
    ShapeTypePolyline
};

/// Polyline의 Cap설정 여부
typedef NS_ENUM(NSInteger, PolylineCapType) {
    /// Polyline 시작/끝 지점에 Round형태의 Cap
    PolylineCapTypeRound = 0,
    /// Polyline 시작/끝 지점에 Square형태의 Cap
    PolylineCapTypeSquare,
    /// Polyline 시작/끝지점에 Butt형태의 Cap
    PolylineCapTypeButt
};

/// Poi의 transformType
typedef NS_ENUM(NSInteger, PoiTransformType) {
    /// 카메라의 roll값이 회전 방향에 적용되지 않아 특정 방향을 가리키고자 할 때 사용한다.
    PoiTransformTypeAbsoluteRotation,
    /// 카메라의 roll값이 회전 방향에 적용되어 항상 정자세를 유지한다.
    PoiTransformTypeDefault,
    /// AbsoulteRotation 속성을 가지면서 글자가 뒤집어지지 않게 한다.
    PoiTransformTypeKeepUpright,
    /// AbsoluteRotation 속성을 가지면서 바닥에 붙는 변환을 준다.
    PoiTransformTypeAbsoluteRotationDecal,
    /// 바닥에 붙는 변환
    PoiTransformTypeDecal
};

/// Poi가 나타나거나 사라질 때 애니메이션 효과
typedef NS_ENUM(NSInteger, TransitionType)
{
    /// None
    TransitionTypeNone = 0,
    /// 알파(투명도)를 이용한 애니메이션
    TransitionTypeAlpha,
    /// 스케일(크기)을 이용한 애니메이션
    TransitionTypeScale
};

/// 애니메이션 interpolation 방법 지정
typedef NS_ENUM(NSInteger, InterpolationMethodType)
{
    /// 선형 보간(변화량이 일정)
    InterpolationMethodTypeLinear = 0,
    /// 삼차원 함수형태 보간(변화량이 점점 증가)
    InterpolationMethodTypeCubicIn,
    /// 삼차원 함수형태 보간(변화량이 점점 감소)
    InterpolationMethodTypeCubicOut,
    /// 삼차원 함수형태 보간(변화량이 초반부에 증가하다 마지막에 다시 감소)
    InterpolationMethodTypeCubicInOut
};

/// CameraUpdate의 타입
typedef NS_ENUM(NSInteger, CameraUpdateType)
{
    /// 위치, 회전 지정
    CameraUpdateTypePosition = 0,
    /// 회전만 지정
    CameraUpdateTypeOrientationOnly,
    /// 범위 지정
    CameraUpdateTypeArea,
    /// 변화량 지정
    CameraUpdateTypeTransform
};

/// 제스쳐 타입
typedef NS_ENUM(NSInteger, GestureType) {
    /// 더블탭 줌인 
    GestureTypeDoubleTapZoomIn = 1,
    /// 투핑거 싱글탭 줌 아웃
    GestureTypeTwoFingerTapZoomOut = 2,
    /// 패닝
    GestureTypePan = 5,
    /// 회전
    GestureTypeRotate,
    /// 줌
    GestureTypeZoom,
    /// 틸트
    GestureTypeTilt,
    /// 롱탭 후 드래그
    GestureTypeLongTapAndDrag,
    /// 동시 회전 및 줌
    GestureTypeRotateZoom,
    /// 한손가락 줌
    GestureTypeOneFingerZoom,
    /// Unknown
    GestureTypeUnknown
};

/// 지도 이동을 발생시킨 이벤트 종류
typedef NS_ENUM(NSInteger, MoveBy) {
    /// 한 손가락 더블탭 줌인
    MoveByDoubleTapZoomIn = 0,
    /// 두 손가락 싱글탭 줌 아웃
    MoveByTwoFingerTapZoomOut,
    /// 패닝
    MoveByPan,
    /// 회전
    MoveByRotate,
    /// 줌
    MoveByZoom,
    /// 틸트
    MoveByTilt,
    /// 롱탭 후 드래그
    MoveByLongTapAndDrag,
    /// 회전 및 줌 동시
    MoveByRotateZoom,
    /// 한 손가락 줌
    MoveByOneFingerZoom,
    /// 그외 기타
    MoveByNotUserAction
};

/// 클릭 종류 enumeration
typedef NS_ENUM(NSInteger, ClickType) {
    /// 싱글탭
    ClickTypeSingle = 0,
    /// 더블탭
    ClickTypeDouble,
    /// 롱탭
    ClickTypeLong,
    /// Unknown
    ClickTypeUnknown
};

/// GuiLayout의 child 배치 방향
typedef NS_ENUM(NSInteger, LayoutArrangement) {
    /// 세로 배치
    LayoutArrangementVertical = 0,
    /// 가로 배치
    LayoutArrangementHorizontal
};

/// Component의 세로방향 align
typedef NS_ENUM(NSInteger, VerticalAlign) {
    /// 위
    VerticalAlignTop = 0,
    /// 가운데
    VerticalAlignMiddle,
    /// 아래
    VerticalAlignBottom
};

/// Component의 가로방향 align
typedef NS_ENUM(NSInteger, HorizontalAlign) {
    /// 왼쪽
    HorizontalAlignLeft = 0,
    /// 가운데
    HorizontalAlignCenter,
    /// 오른쪽
    HorizontalAlignRight
};

/// Gui 이벤트 종류
typedef NS_ENUM(NSInteger, GuiEventType)
{
    /// 애니메이션 시작
    GuiEventTypeAnimationStart,
    /// 애니메이션 정지
    GuiEventTypeAnimationStop,
    /// 애니메이션 일시정지
    GuiEventTypeAnimationPause,
    /// 애니메이션 재개
    GuiEventTypeAnimationResume,
    
    GuiEventTypeUnknown
};

/// Gui Component type
typedef NS_ENUM(NSInteger, GuiComponentType) {
    /// Bitmap Image
    GuiComponentTypeBitMapImage,
    /// NinePatch
    GuiComponentTypeNinePatch,
    /// Vertical Layout
    GuiComponentTypeVerticalLayout,
    /// Horizontal Layout
    GuiComponentTypeHorizontalLayout,
    /// Button
    GuiComponentTypeButton,
    /// TextLabel
    GuiComponentTypeTextLabel,
    /// TextBox
    GuiComponentTypeTextBox,
    /// AnimationBitmap
    GuiComponentTypeAnimatedImage
};

/// Gui 타입
typedef NS_ENUM(NSInteger, GuiType) {
    /// SpriteGui
    GuiTypeSpriteGui,
    /// InfoWindow
    GuiTypeInfoWindow
};

/// PoiScale 타입
typedef NS_ENUM(NSInteger, PoiScaleType) {
    /// 작게
    PoiScaleTypeSmall,
    /// 보통(기본값)
    PoiScaleTypeRegular,
    /// 크게
    PoiScaleTypeLarge,
    /// 가장 크게
    PoiScaleTypeXLarge
};

/// DimScreen Cover 타입
typedef NS_ENUM(NSInteger, DimScreenCover) {
    /// 지도만
    DimScreenCoverMap,
    /// 지도와 라벨까지
    DimScreenCoverMapAndLabels,
    /// 지도 전부
    DimScreenCoverAll
};

/// LabelCategory 타입
typedef NS_ENUM(NSInteger, LabelCategory) {
    /// label policy 단위로 생성되는 카테고리
    LabelCategoryPolicy_Category = 0,
    /// 주요시군구
    LabelCategoryAddress,
    /// 행정구역
    LabelCategoryDistrict,
    /// 버스정류장
    LabelCategoryBus_Stop,
    /// 철도(지하철포함) 역사
    LabelCategoryRailroad_Platform,
    /// 철도(지하철포함) 입출입구
    LabelCategoryRailroad_Entrance,
    /// 철도(지하철포함) 호선
    LabelCategoryRailroad_Line,
    /// 제휴 브랜드(스타벅스)
    LabelCategoryBrand,
    /// 장소명
    LabelCategoryPlace,
    /// 등산로
    LabelCategoryClimb,
    /// 등산로 흐르는 글씨
    LabelCategoryClimb_Wave,
    /// 도로
    LabelCategoryRoad,
    /// 도로번호
    LabelCategoryRoad_Number,
    /// 도로상세정보( 횡단보도, 방면, 유턴 등 )
    LabelCategoryRoad_Info,
    /// 일반시설
    LabelCategoryFacilities,
    /// 공공시설
    LabelCategoryPublic_Facilities,
    /// 아파트동번호
    LabelCategoryApart_Number,
    /// 아파트 상세
    LabelCategoryApart_Detail,
    /// 주택동번호
    LabelCategoryHouse_Number,
    /// 지형지물
    LabelCategoryLand,
    /// 실내지도 존정보 및 시설물
    LabelCategoryIndoor,
    /// 실내지도 장소
    LabelCategoryIndoor_Place,
    /// 장소 카테고리
    LabelCategoryDetail_Category = 1000
};

#endif /* ApiEnums_h */
