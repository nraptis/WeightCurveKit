//
//  WeightCurveMapping.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/6/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public class WeightCurveMapper {
    
    func build(spline: MathKit.ManualSpline) {
        purgeWeightCurveMapperNodes()
        
        var index = 0
        let splineNormalizedCount1 = spline.count - 1
        while index < splineNormalizedCount1 {
            
            let newWeightCurveMapperNode = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNode()
            newWeightCurveMapperNode.build(spline: spline,
                                           startPosition: Float(index),
                                           endPosition: Float(index + 1))
            addWeightCurveMapperNode(newWeightCurveMapperNode)
            
            index += 1
        }
    }
    
    public var weightCurveMapperNodes = [WeightCurveMapperNode]()
    public var weightCurveMapperNodeCount = 0
    
    func addWeightCurveMapperNode(_ weightCurveMapperNode: WeightCurveMapperNode) {
        while weightCurveMapperNodes.count <= weightCurveMapperNodeCount {
            weightCurveMapperNodes.append(weightCurveMapperNode)
        }
        weightCurveMapperNodes[weightCurveMapperNodeCount] = weightCurveMapperNode
        weightCurveMapperNodeCount += 1
    }
    
    func purgeWeightCurveMapperNodes() {
        for weightCurveMapperNodeIndex in 0..<weightCurveMapperNodeCount {
            let weightCurveMapperNode = weightCurveMapperNodes[weightCurveMapperNodeIndex]
            WeightCurvePartsFactory.shared.depositWeightCurveMapperNode(weightCurveMapperNode)
        }
        weightCurveMapperNodeCount = 0
    }
}
