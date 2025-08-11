//
//  WraperPositionCordinator.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 8/11/25.
//

import Foundation
import Combine

class PositionCoordinatorWrapper: ObservableObject {
    private let coordinator: PositionCoordinator
    
    @Published var filteredPos: Vector2D? = nil
    @Published var anchors: [String: Anchor]? = nil
    
    init(coordinator: PositionCoordinator) {
        self.coordinator = coordinator
        self.filteredPos = coordinator.getFilteredPosition()
        self.anchors = coordinator.getAnchors()
        
        // Poll every 0.1s
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.filteredPos = coordinator.getFilteredPosition()
            self.anchors = coordinator.getAnchors()
        }
    }
}
