//
//  ObjectNode.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/24/24.
//

import ARKit
import RoomPlan

enum ObjectLabelMode {
    case startEditing
    case editing
    case stopEditing
    case normal
}

class ObjectNode {
    private(set) var model: ObjectModel?
    private(set) var uuid: UUID
    private(set) var box: SCNNode
    private(set) var label: SCNNode
    private(set) var labelMode: ObjectLabelMode
    private(set) var modelLabelText: String
    private(set) var editedLabelText: String
    private(set) var currentLabelText: String
    private(set) var currentCategory: CapturedRoom.Object.Category?

    private var frontPlaneNode: SCNNode
    private var textNode: SCNNode
    private var queuedModel: ObjectModel?
    private var trackingNode: SCNNode?

    init(model: ObjectModel, uuid: UUID) {
        // private(set)
        self.model = nil
        self.uuid = uuid
        self.box = SCNNode()
        self.label = SCNNode()
        self.frontPlaneNode = SCNNode()
        self.textNode = SCNNode()
        self.labelMode = .normal
        self.modelLabelText = ""
        self.editedLabelText = ""
        self.currentLabelText = ""
        self.currentCategory = nil

        // private
        self.queuedModel = nil
        self.trackingNode = nil

        setup()
        update(with: model)
    }

    func update(with model: ObjectModel) {
        queuedModel = model
    }


    func updateLabelText(_ text: String) {
        guard labelMode == .editing else {
            print("error: not in editing mode; cannot update edited label text")
            return
        }
        editedLabelText = text
        updateLabelState(with: text)
    }

    private func updateLabelState(with text: String) {
        updateLabelNode(with: text)
        currentLabelText = text
        currentCategory = category(for: text)
    }

    private func updateLabelNode(with text: String) {
        DesignScape.update(textNode, with: text, color: .accent)
        let (planeWidth, planeHeight) = planeDimensionsFor(textNode: textNode)
        DesignScape.update(frontPlaneNode, width: planeWidth, height: planeHeight, color: .white)
    }

    func updateAt(time: TimeInterval) {
        // box and label shape changes
        if queuedModel != nil, model != queuedModel {
            // update model
            self.model = queuedModel!
            queuedModel = nil

            guard let model = model else {
                return
            }

            // box
            DesignScape.update(box, with: model.dimensions, category: currentCategory)
            box.simdTransform = model.transform

            // label
            modelLabelText = DesignScape.text(for: model.category)
            label.simdTransform = labelTransform(with: box)
        }

        // label coloring and poistioning
        switch labelMode {
        case .startEditing:
            labelMode = .editing
            break
        case .editing:
            break
        case .stopEditing:
            labelMode = .normal
            break
        case .normal:
            let correctLabelText = editedLabelText.count > 0 ? editedLabelText : modelLabelText
            if currentLabelText != correctLabelText {
                //print("markkim updateAt: currentLabelText: \(currentLabelText), correctLabelText: \(correctLabelText), editedLabelText: \(editedLabelText), modelLabelText: \(modelLabelText)")
                updateLabelState(with: correctLabelText)
            }
            break
        }
    }

    func cleanup() {
        box.removeFromParentNode()
        label.removeFromParentNode()
    }

    private func setup() {
        // set node names with uuid
        // this helps with hit testing and identifying the right nodes
        box.name = uuid.uuidString
        label.name = uuid.uuidString
        frontPlaneNode.name = uuid.uuidString
        textNode.name = uuid.uuidString

        // add billboarding effect to label
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y]
        label.constraints = [billboardConstraint]

        // position additional node components
        frontPlaneNode.simdPosition = simd_float3(0, 0, 0)
        textNode.simdPosition = simd_float3(0, 0, 0.5)

        // add additional node components to label
        label.addChildNode(frontPlaneNode)
        label.addChildNode(textNode)
    }

    private func labelTransform(with box: SCNNode) -> simd_float4x4 {
        // scale label
        let scaleTransform = simd_float4x4.scaleTransform(simd_float3(0.0035, 0.0035, 0.0035))
        // place label above box
        let (minBox, maxBox) = box.boundingBox
        let boxUpVector = box.simdTransform.unitUpVector()
        let dY = (0.5 * (maxBox.y - minBox.y) + 0.1) * boxUpVector
        let translationTransform = simd_float4x4.translationTransform(dY)
        let labelTransform = translationTransform * box.simdTransform * scaleTransform

        return labelTransform
    }
}

struct ObjectModel: Equatable {
    var dimensions: simd_float3
    var transform: simd_float4x4
    var category: CapturedRoom.Object.Category

    init(dimensions: simd_float3, transform: simd_float4x4, category: CapturedRoom.Object.Category) {
        self.dimensions = dimensions
        self.transform = transform
        self.category = category
    }
}

