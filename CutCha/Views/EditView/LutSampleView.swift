//
//  LutSampleView.swift
//  CutCha
//
//  Created by Wang Jingwei on 6/11/24.
//

import SwiftUI
import SceneKit

struct LutSampleView: View {
    @EnvironmentObject var lutViewModel: LUTViewModel
    let length: CGFloat
    let pointSize = 0.5
    
    @State private var scene: SCNScene?
    
    var body: some View {
        Group {
            if let scene = scene {
                SceneView(scene: scene, options: [.allowsCameraControl])
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        setupScene()
                    }
            }
        }
        .onDisappear {
            scene = nil
        }
    }
    
    private func createGeometry() -> SCNNode? {
        let vertexSource = SCNGeometrySource(vertices: lutViewModel.vertices)
        
        let colorData = Data(bytes: lutViewModel.colors, count: lutViewModel.colors.count * MemoryLayout<SCNVector3>.stride)
        let colorSource = SCNGeometrySource(data: colorData,
                                          semantic: .color,
                                          vectorCount: lutViewModel.colors.count,
                                          usesFloatComponents: true,
                                          componentsPerVector: 3,
                                          bytesPerComponent: MemoryLayout<Float>.size,
                                          dataOffset: 0,
                                          dataStride: MemoryLayout<SCNVector3>.stride)
        
        let pointElements = SCNGeometryElement(indices: lutViewModel.indices, primitiveType: .point)
        pointElements.minimumPointScreenSpaceRadius = length / CGFloat(lutViewModel.lutSize) * pointSize
        pointElements.maximumPointScreenSpaceRadius = length / CGFloat(lutViewModel.lutSize) * pointSize
        
        let geometry = SCNGeometry(sources: [vertexSource, colorSource], elements: [pointElements])
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIColor.white
        geometry.materials = [material]
        return SCNNode(geometry: geometry)
    }
    
    private func setupScene() {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        if let pointCloudNode = createGeometry() {
            scene.rootNode.addChildNode(pointCloudNode)
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.zNear = 0.001
        cameraNode.camera?.zFar = 10.0
        cameraNode.position = SCNVector3(0.5, 0.5, 1.5)
        scene.rootNode.addChildNode(cameraNode)
        
        self.scene = scene
    }
}
