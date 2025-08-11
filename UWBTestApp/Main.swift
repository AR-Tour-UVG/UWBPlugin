//
//  Main.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/20/25.
//
import SwiftUI


@main
struct Main: App {
    @StateObject var wrapper: PositionCoordinatorWrapper
    
    init() {
        let viewModel = ViewModel()
        _wrapper = StateObject(wrappedValue: viewModel.posWrapper)
    }
    
    var body: some Scene {
        WindowGroup {
            PositionView(wrapper: wrapper)
        }
    }
}

struct PositionView: View {
    @ObservedObject var wrapper: PositionCoordinatorWrapper
    
    var body: some View {
        VStack {
            if let pos = wrapper.filteredPos {
                Text("X: \(pos.x), Y: \(pos.y)")
            } else {
                Text("No position yet")
            }
        }
        .padding()
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let anchors = wrapper.anchors {
                    ForEach(Array(anchors.values.enumerated()), id: \.element.id) { index, anchor in
                        VStack(alignment: .leading) {
                            Text("ID: \(String(anchor.id.prefix(5)))")
                            Text("Position: (x: \(anchor.position.x), y: \(anchor.position.y), z: \(anchor.position.z))")
                            Text("Distance: \(String(format: "%.2f", anchor.distance))")
                            Text("Timestamp: \(anchor.timestamp != nil ? Date(timeIntervalSince1970: anchor.timestamp!).formatted(date: .omitted, time: .standard) : "N/A")")
                        }
                        .font(.system(.body, design: .monospaced))
                        .padding(.bottom, 8)
                        .background(index % 2 == 0 ? Color(.systemGray6) : Color.clear) // alternate background for readability
                        .cornerRadius(6)
                    }
                } else {
                    Text("No anchors")
                }
            }
            .padding()
        }
    }
}

struct PositionView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a fake wrapper with test data
        let dummyWrapper = PositionCoordinatorWrapper(
            coordinator: PositionCoordinator(
                anchorsPositions: [:],
                connectionLimit: 6,
                connectionTimeout: 10
            )
        )
        
        dummyWrapper.filteredPos = Vector2D(x: 1.23, y: 4.56)
        
        
        // Create some dummy anchors
        let anchor1 = Anchor(id: "A12345", position: Vector3D(x: 1, y: 2, z: 3), distance: 10, timestamp: Date().timeIntervalSince1970)
        let anchor2 = Anchor(id: "B67890", position: Vector3D(x: 4, y: 5, z: 6), distance: 20, timestamp: Date().timeIntervalSince1970)
        let anchor3 = Anchor(id: "C54321", position: Vector3D(x: 7, y: 8, z: 9), distance: 15, timestamp: Date().timeIntervalSince1970)
        
        // Set anchors dictionary with arbitrary keys (keys not important here)
        dummyWrapper.anchors = [
            "key1": anchor1,
            "key2": anchor2,
            "key3": anchor3
        ]
        
        return PositionView(wrapper: dummyWrapper)
    }
}
