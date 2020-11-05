//
//  ViewController.swift
//  Animoji
//
//  Created by Ying Chen on 11/4/20.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    var duckAnchor: DuckExperience.Animoji!
    var allowsTalking = true
    var upperMouth: Entity!
    var bottomMouth: Entity!
    var upperMouthModel: ModelEntity!
    var bottomMouthModel: ModelEntity!
    var lEye: Entity!
    var rEye: Entity!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config)
        arView.session.delegate = self
        
        // Load the "Animoji" scene from the "Experience" Reality File
        duckAnchor = try! DuckExperience.loadAnimoji()
        
        // Add the duck anchor to the scene
        arView.scene.anchors.append(duckAnchor)
        
        upperMouth = duckAnchor.findEntity(named: "upmouth")
        bottomMouth = duckAnchor.findEntity(named: "botmouth")
        
        upperMouthModel = upperMouth.children.first as? ModelEntity
        bottomMouthModel = bottomMouth.children.first as? ModelEntity
        
        lEye = duckAnchor.findEntity(named: "lefteye")
        rEye = duckAnchor.findEntity(named: "righteye")
        
        duckAnchor.actions.finishedTalking.onAction = { _ in
            self.allowsTalking = true
        }
        
    }
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        var faceAnchor: ARFaceAnchor?
        
        for i in anchors {
            if let anchors = i as? ARFaceAnchor {
                faceAnchor = anchors
            }
        }
        guard let blendShapes = faceAnchor?.blendShapes,
              let jawV = blendShapes[.jawOpen]?.floatValue,
              let lEyeV = blendShapes[.eyeBlinkLeft]?.floatValue,
              let rEyeV = blendShapes[.eyeBlinkRight]?.floatValue else { return }
        
        
        bottomMouth.position.z = 0.015 + jawV * 0.02
        upperMouth.position.z = 0 - jawV * 0.005
        if (jawV >= 0.5) && allowsTalking {
            allowsTalking = false
            duckAnchor.notifications.talk.post()
        }
        lEye.scale.z = 1.25 - lEyeV
        rEye.scale.z = 1.25 - rEyeV
    }
}
