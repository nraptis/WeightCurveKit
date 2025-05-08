//
//  WeightCurvePartsFactory.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/4/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation

public class WeightCurvePartsFactory {
    
    public nonisolated(unsafe) static let shared = WeightCurvePartsFactory()
    
    public func dispose() {
        weightCurveMapperNodes.removeAll(keepingCapacity: false)
           weightCurveMapperNodeCount = 0


        weightCurveMapperNodeSegments.removeAll(keepingCapacity: false)
           weightCurveMapperNodeSegmentCount = 0


        weightCurveMapperNodePoints.removeAll(keepingCapacity: false)
           weightCurveMapperNodePointCount = 0
        
    }
    
    private init() {
        
    }
    
    ////////////////
    ///
    ///
    private var weightCurveMapperNodes = [WeightCurveMapperNode]()
    var weightCurveMapperNodeCount = 0
    func depositWeightCurveMapperNode(_ weightCurveMapperNode: WeightCurveMapperNode) {
        while weightCurveMapperNodes.count <= weightCurveMapperNodeCount {
            weightCurveMapperNodes.append(weightCurveMapperNode)
        }
        weightCurveMapperNodes[weightCurveMapperNodeCount] = weightCurveMapperNode
        weightCurveMapperNodeCount += 1
    }
    func withdrawWeightCurveMapperNode() -> WeightCurveMapperNode {
        if weightCurveMapperNodeCount > 0 {
            weightCurveMapperNodeCount -= 1
            return weightCurveMapperNodes[weightCurveMapperNodeCount]
        }
        return WeightCurveMapperNode()
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var weightCurveMapperNodeSegments = [WeightCurveMapperNodeSegment]()
    var weightCurveMapperNodeSegmentCount = 0
    func depositWeightCurveMapperNodeSegment(_ weightCurveMapperNodeSegment: WeightCurveMapperNodeSegment) {
        while weightCurveMapperNodeSegments.count <= weightCurveMapperNodeSegmentCount {
            weightCurveMapperNodeSegments.append(weightCurveMapperNodeSegment)
        }
        weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentCount] = weightCurveMapperNodeSegment
        weightCurveMapperNodeSegmentCount += 1
    }
    func withdrawWeightCurveMapperNodeSegment() -> WeightCurveMapperNodeSegment {
        if weightCurveMapperNodeSegmentCount > 0 {
            weightCurveMapperNodeSegmentCount -= 1
            return weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentCount]
        }
        return WeightCurveMapperNodeSegment()
    }
    ///
    ///
    ////////////////
    
    
    ////////////////
    ///
    ///
    private var weightCurveMapperNodePoints = [WeightCurveMapperNodePoint]()
    var weightCurveMapperNodePointCount = 0
    
    func depositWeightCurveMapperNodePoint(_ weightCurveMapperNodePoint: WeightCurveMapperNodePoint) {
        while weightCurveMapperNodePoints.count <= weightCurveMapperNodePointCount {
            weightCurveMapperNodePoints.append(weightCurveMapperNodePoint)
        }
        weightCurveMapperNodePoints[weightCurveMapperNodePointCount] = weightCurveMapperNodePoint
        weightCurveMapperNodePointCount += 1
    }
    func withdrawWeightCurveMapperNodePoint() -> WeightCurveMapperNodePoint {
        if weightCurveMapperNodePointCount > 0 {
            weightCurveMapperNodePointCount -= 1
            return weightCurveMapperNodePoints[weightCurveMapperNodePointCount]
        }
        return WeightCurveMapperNodePoint()
    }
    ///
    ///
    ////////////////
    
}
