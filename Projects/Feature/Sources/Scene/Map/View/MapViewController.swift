//  MapViewController.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import KakaoMapsSDK
import Service
import Moya

public final class MapViewController: UIViewController, MapControllerDelegate, KakaoMapEventDelegate {
    
    // MARK: - Properties
    private let placeProvider = MoyaProvider<PlaceServices>()
    
    private var accessToken: String {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else { return "" }
        return "Bearer \(token)"
    }
    
    private var mapContainer: KMViewContainer?
    private var mapController: KMController?
    private let mapWrapperView = UIView()
    
    private var allPlaces: [MapPlaceData] = []
    private var dummyRecentSearches: [MapPlaceData] = [] {
        didSet { self.recentSearchView.tableView.reloadData() }
    }
    
    private var dummyReviews: [MapReview] = [] {
        didSet {
            if let currentDetail = self.currentPlaceDetail {
                self.placeDetailView.updateReviewCount(dummyReviews.count, recommendCount: currentDetail.recommendCount)
            }
            self.placeDetailView.tableView.reloadData()
        }
    }
    
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    private let recentSearchView = MapRecentSearchView().then {
        $0.isHidden = true
        $0.backgroundColor = .color.background.color
        $0.tableView.backgroundColor = .color.background.color
    }
    private let bottomSheetView = MapBottomSheetView()
    private let placeDetailView = MapPlaceDetailView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    
    private var bottomSheetHeight: Constraint?
    private var detailSheetHeight: Constraint?
    private let defaultHeight: CGFloat = 240
    private let detailMinHeight: CGFloat = 225
    private var selectedPlaceId: Int = -1
    private var currentPlaceDetail: MapPlaceDetailModel?

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
        setupReviewWriteAction()
        fetchRecommendedCount()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mapController == nil {
            setupMap()
        } else {
            mapController?.activateEngine()
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapController?.pauseEngine()
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .color.background.color
        view.addSubview(mapWrapperView)
        [bottomSheetView, recentSearchView, routeSelectionView, placeDetailView, searchBar].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        mapWrapperView.snp.makeConstraints { $0.edges.equalToSuperview() }
        routeSelectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
        }
        placeDetailView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.detailSheetHeight = $0.height.equalTo(0).priority(.high).constraint
        }
        recentSearchView.snp.makeConstraints { $0.edges.equalToSuperview() }
        recentSearchView.titleStack.snp.remakeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
        }
        recentSearchView.tableView.snp.remakeConstraints {
            $0.top.equalTo(recentSearchView.titleStack.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func setupDelegate() {
        [recentSearchView.tableView, placeDetailView.tableView].forEach { $0.delegate = self; $0.dataSource = self }
    }
    
    private func setupActions() {
        placeDetailView.closeButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)
        placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
        placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
        routeSelectionView.backButton.addTarget(self, action: #selector(backFromRouteSelection), for: .touchUpInside)
        bottomSheetView.onCardTapped = { [weak self] in self?.showDetailView() }
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
        searchBar.textField.addTarget(self, action: #selector(performSearch), for: .editingDidEndOnExit)
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        placeDetailView.onHeartToggled = { [weak self] isSelected in
            guard let self = self, self.selectedPlaceId != -1 else { return }
            let service: PlaceServices = isSelected ? .recommendPlace(placeId: self.selectedPlaceId, authorization: self.accessToken) : .cancelRecommendPlace(placeId: self.selectedPlaceId, authorization: self.accessToken)
            self.placeProvider.request(service) { [weak self] _ in self?.fetchRecommendedCount() }
        }
        routeSelectionView.onCardTapped = { [weak self] routeTitle in
            let detailVC = MapRouteDetailViewController(); detailVC.routeTypeTitle = routeTitle; detailVC.modalPresentationStyle = .overFullScreen
            detailVC.onDismiss = { [weak self] in self?.routeSelectionView.isHidden = false }
            self?.routeSelectionView.isHidden = true; self?.present(detailVC, animated: true)
        }
    }
    
    private func setupReviewWriteAction() { placeDetailView.reviewWriteButton.addTarget(self, action: #selector(didTapReviewWrite), for: .touchUpInside) }

    // MARK: - Networking
    private func fetchPlaceList() {
        placeProvider.request(.getAllPlaces(authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                if let decodedData = try? JSONDecoder().decode(MapPlaceResponse.self, from: response.data).places {
                    self?.allPlaces = decodedData
                    self?.renderAllPlaceMarkers()
                }
            case .failure(let error):
                print("[DEBUG] 장소 로드 에러: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchRecommendedCount() { placeProvider.request(.getRecommendedPlacesCount(authorization: accessToken)) { _ in } }
    
    private func fetchReviews(placeId: Int) {
        placeProvider.request(.getPlaceReviews(placeId: placeId, authorization: self.accessToken)) { [weak self] result in
            if case .success(let response) = result { self?.dummyReviews = (try? JSONDecoder().decode([MapReview].self, from: response.data)) ?? [] }
        }
    }

    @objc private func performSearch() {
        guard let keyword = searchBar.textField.text, !keyword.isEmpty else { return }
        placeProvider.request(.searchPlace(keyword: keyword, authorization: accessToken)) { [weak self] result in
            if case .success(let response) = result, let decodedData = try? JSONDecoder().decode([MapPlaceData].self, from: response.data) {
                self?.dummyRecentSearches = decodedData; self?.recentSearchView.titleLabel.text = decodedData.isEmpty ? "검색 결과가 없습니다" : "'\(keyword)' 검색 결과"
            }
        }
    }

    @objc private func didTapReviewWrite() {
        guard let detailData = currentPlaceDetail else { return }
        self.navigationController?.pushViewController(MapReviewWriteViewController(placeData: detailData), animated: true)
    }

    // MARK: - Marker Rendering
    private func renderAllPlaceMarkers() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: "poiLayer") else { return }
        
        layer.removePois(poiIDs: layer.getAllPois()?.map { $0.itemID } ?? [])

        for place in allPlaces {
            let option = PoiOptions(styleID: "dotStyle", poiID: "\(place.placeId)")
            option.clickable = true
            option.rank = 0
            if let poi = layer.addPoi(option: option, at: MapPoint(longitude: place.longitude, latitude: place.latitude)) {
                poi.show()
            }
        }
    }

    // MARK: - Gestures
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let isDetail = gesture.view == placeDetailView
        let translation = gesture.translation(in: view)
        let currentHeight = isDetail ? placeDetailView.frame.height : bottomSheetView.frame.height
        let newHeight = currentHeight - translation.y
        let minH = isDetail ? detailMinHeight : defaultHeight
        let maxH = view.frame.height - (searchBar.frame.maxY + 20)
        
        if gesture.state == .changed {
            let clampedHeight = max(minH, min(newHeight, maxH))
            if isDetail { detailSheetHeight?.update(offset: clampedHeight) }
            else { bottomSheetHeight?.update(offset: clampedHeight) }
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: view).y
            let targetHeight: CGFloat = (velocity < -500 || (velocity <= 500 && newHeight > (minH + maxH) / 2)) ? maxH : minH
            UIView.animate(withDuration: 0.3) {
                if isDetail { self.detailSheetHeight?.update(offset: targetHeight) }
                else { self.bottomSheetHeight?.update(offset: targetHeight) }
                self.view.layoutIfNeeded()
            }
        }
        gesture.setTranslation(.zero, in: view)
    }

    private func setupGesture() {
        bottomSheetView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        placeDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }

    // MARK: - View Transition
    private func showDetailView(with data: MapPlaceData? = nil) {
        self.bottomSheetView.isHidden = true
        if let data = data {
            placeProvider.request(.getPlaceDetail(placeId: data.placeId, authorization: accessToken)) { [weak self] result in
                if case .success(let response) = result, let detailModel = try? JSONDecoder().decode(MapPlaceDetailModel.self, from: response.data) {
                    self?.selectedPlaceId = detailModel.placeId
                    self?.currentPlaceDetail = detailModel
                    self?.placeDetailView.configure(with: detailModel)
                    self?.fetchReviews(placeId: detailModel.placeId)
                    self?.updateViewVisibility()
                }
            }
        } else {
            let detailModel = MapMockData.detailExample
            self.selectedPlaceId = detailModel.placeId
            self.currentPlaceDetail = detailModel
            fetchReviews(placeId: self.selectedPlaceId)
            placeDetailView.configure(with: detailModel)
            updateViewVisibility()
        }
    }

    private func updateViewVisibility() {
        placeDetailView.isHidden = false
        searchBar.isHidden = false
        detailSheetHeight?.update(offset: detailMinHeight)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func hideDetailView() {
        if let view = mapController?.getView("mapview") as? KakaoMap, let activeLayer = view.getLabelManager().getLabelLayer(layerID: "activePoiLayer") {
            activeLayer.removePois(poiIDs: activeLayer.getAllPois()?.map { $0.itemID } ?? [])
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.detailSheetHeight?.update(offset: 0)
            self.view.layoutIfNeeded()
        }) { _ in
            self.placeDetailView.isHidden = true
            self.bottomSheetView.isHidden = false
            self.selectedPlaceId = -1
            self.currentPlaceDetail = nil
        }
    }

    @objc private func backToHome() { hideDetailView(); recentSearchView.isHidden = true; searchBar.updateState(.home); searchBar.isHidden = false; searchBar.textField.text = ""; view.endEditing(true) }
    @objc private func didTapSearchBar() { if !placeDetailView.isHidden { hideDetailView() }; searchBar.updateState(.search); recentSearchView.isHidden = false; recentSearchView.titleLabel.text = "최근 검색" }
    @objc private func didTapArriveRoute() { routeSelectionView.isHidden = false; searchBar.isHidden = true; [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true } }
    @objc private func didTapStartRoute() { didTapArriveRoute() }
    @objc private func backFromRouteSelection() { routeSelectionView.isHidden = true; placeDetailView.isHidden = false; searchBar.isHidden = false; detailSheetHeight?.update(offset: detailMinHeight); UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() } }
    
    // MARK: - Kakao Maps Setup
    private func setupMap() {
        mapWrapperView.layoutIfNeeded()
        let container = KMViewContainer(frame: mapWrapperView.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapWrapperView.addSubview(container)
        self.mapContainer = container
        let controller = KMController(viewContainer: container)
        controller.delegate = self
        self.mapController = controller
        mapController?.prepareEngine()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.mapController?.activateEngine()
        }
    }

    public func addViews() {
        mapController?.addView(MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: MapPoint(longitude: 126.8106, latitude: 35.1461), defaultLevel: 15))
    }

    public func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        view.eventDelegate = self
        createPoiStyle()
        let manager = view.getLabelManager()
        
        // competitionType을 none으로 설정하여 터치 간섭 방지
        let _ = manager.addLabelLayer(option: LabelLayerOptions(layerID: "poiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 20000))
        let _ = manager.addLabelLayer(option: LabelLayerOptions(layerID: "activePoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 20001))
        
        fetchPlaceList()
    }

    private func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        // 정규화된 이미지 로드 방식 (모듈 이슈 방지)
        let pinImage = UIImage(named: "ic_route_location_pin") ?? UIImage(systemName: "mappin.and.ellipse")!
        
        // 비트맵 정규화 (엔진 호환성 확보)
        UIGraphicsBeginImageContextWithOptions(pinImage.size, false, pinImage.scale)
        pinImage.draw(in: CGRect(origin: .zero, size: pinImage.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let actualPin = normalizedImage {
            let dotIconStyle = PoiIconStyle(symbol: actualPin, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let poiStyle = PoiStyle(styleID: "dotStyle", styles: [PerLevelPoiStyle(iconStyle: dotIconStyle, level: 0)])
            manager.addPoiStyle(poiStyle)
            
            // active 스타일 추가 (누락 방지)
            let activeIconStyle = PoiIconStyle(symbol: actualPin, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let activeStyle = PoiStyle(styleID: "activePinStyle", styles: [PerLevelPoiStyle(iconStyle: activeIconStyle, level: 0)])
            manager.addPoiStyle(activeStyle)
        }
    }

    public func kakaoMapDidTap(kakaoMap: KakaoMap, point: CGPoint) {
        if !placeDetailView.isHidden { hideDetailView() }
    }

    public func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String) {
        let cleanID = poiID.replacingOccurrences(of: "active_", with: "")
        guard let id = Int(cleanID), let selectedData = allPlaces.first(where: { $0.placeId == id }) else { return }
        
        showDetailView(with: selectedData)
        
        if let activeLayer = kakaoMap.getLabelManager().getLabelLayer(layerID: "activePoiLayer") {
            activeLayer.removePois(poiIDs: activeLayer.getAllPois()?.map { $0.itemID } ?? [])
            let option = PoiOptions(styleID: "activePinStyle", poiID: "active_\(cleanID)")
            option.clickable = true
            if let activePoi = activeLayer.addPoi(option: option, at: MapPoint(longitude: selectedData.longitude, latitude: selectedData.latitude)) {
                activePoi.show()
            }
        }
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        mapController = nil
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableView == recentSearchView.tableView ? dummyRecentSearches.count : dummyReviews.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            cell.configure(model: dummyRecentSearches[indexPath.row], date: "26.04.11"); cell.backgroundColor = .clear
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView, let currentIndexPath = tableView.indexPath(for: cell) else { return }
                self.dummyRecentSearches.remove(at: currentIndexPath.row); tableView.deleteRows(at: [currentIndexPath], with: .fade)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            cell.configure(with: dummyReviews[indexPath.row])
            cell.onDeleteTap = { [weak self] in
                guard let self = self, let currentIndexPath = tableView.indexPath(for: cell) else { return }
                ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") {
                    let reviewToDelete = self.dummyReviews[currentIndexPath.row]
                    self.placeProvider.request(.deleteReview(reviewId: reviewToDelete.reviewId, authorization: self.accessToken)) { _ in self.dummyReviews.remove(at: currentIndexPath.row) }
                }
            }
            cell.onReportTap = { [weak self] in guard let self = self else { return }; ReviewAlert.show(in: self, title: "후기 신고", message: "이 후기를 신고하시겠습니까?") { } }
            return cell
        }
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchView.tableView {
            let selectedData = dummyRecentSearches[indexPath.row]; recentSearchView.isHidden = true; searchBar.updateState(.home); view.endEditing(true); showDetailView(with: selectedData)
        }
    }
}
