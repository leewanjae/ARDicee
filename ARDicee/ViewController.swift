//
//  ViewController.swift
//  ARDicee
//
//  Created by LeeWanJae on 3/16/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] // 해당 debugOption 설정 시 탐지 포인트들이 보임
        
        // Set the view's delegate
        sceneView.delegate = self
       
        sceneView.automaticallyUpdatesLighting = true
        
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//        // 재순환적으로 노드에 있는 모든 서브트리를 포함시켜 트리를 검색할 수 있게 해준다.
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 수평면 탐지를 가능하게 함
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // 새로운 수평면을 감지하면 먼저 이 메서드를 호출하고 안에있는 코드를 트리거
    // ARAnchor -> 타일이라고 이해하면 됨
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor { // 해당 코드는 위의 planeDetection으로 수평면을 탐지 후 그 값 여부에 따라 실행이 갈림
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)) // y넣으면 작동안함 z로 넣자
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
