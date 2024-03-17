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
        // 해당 debugOption 설정 시 탐지 포인트들이 보임, 장치가 환경을 어떻게 인식하는지 시각화
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.automaticallyUpdatesLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration() // 3D공간에서 위치와 방향 추적
        configuration.planeDetection = .horizontal // 수평면 탐지를 가능하게 함
        sceneView.session.run(configuration) // Run the view's session
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // 뷰나 윈도우에서 사용자로부터 오는 터치가 감지되면 호출된다
    // 가장 먼저 정말로 터치 여부를 확인해야함.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            // 터치한 실제 위치와 동일하게 해줌
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal) else { return print("query error")}
            let results = sceneView.session.raycast(query)
            
            if let hitResult = results.first {
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                // 재순환적으로 노드에 있는 모든 서브트리를 포함시켜 트리를 검색할 수 있게 해준다.
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, // 단순 3.y만 설정시 그리드와 겹치게 주사위가 생김 따라서 너비의 반경을 더해줌
                        z: hitResult.worldTransform.columns.3.z
                    )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    diceNode.runAction(
                        SCNAction.rotateBy(
                            x: CGFloat(randomX * 5),
                            y: 0, z: CGFloat(randomZ * 5),
                            duration: 0.5
                        )
                    )
                }
            }
        }
    }
    
    // 새로운 수평면을 감지하면 먼저 이 메서드를 호출하고 안에있는 코드를 트리거
    // ARAnchor -> 타일이라고 이해하면 됨
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor { // 해당 코드는 위의 planeDetection으로 수평면을 탐지 후 그 값 여부에 따라 실행이 갈림
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)) // height아니고 length
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else { return print("render error") }
    }
}
