//
//  WeightCurveMapperNode.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/6/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public class WeightCurveMapperNode {
    
    static let numberOfPoints = 32
    
    public var weightCurveMapperNodePoints = [WeightCurveMapperNodePoint]()
    public var weightCurveMapperNodePointCount = 0
    func addWeightCurveMapperNodePoint(_ weightCurveMapperNodePoint: WeightCurveMapperNodePoint) {
        while weightCurveMapperNodePoints.count <= weightCurveMapperNodePointCount {
            weightCurveMapperNodePoints.append(weightCurveMapperNodePoint)
        }
        weightCurveMapperNodePoints[weightCurveMapperNodePointCount] = weightCurveMapperNodePoint
        weightCurveMapperNodePointCount += 1
    }
    
    func purgeWeightCurveMapperNodePoints() {
        for weightCurveMapperNodePointsIndex in 0..<weightCurveMapperNodePointCount {
            WeightCurvePartsFactory.shared.depositWeightCurveMapperNodePoint(weightCurveMapperNodePoints[weightCurveMapperNodePointsIndex])
        }
        weightCurveMapperNodePointCount = 0
    }
    
    public var weightCurveMapperNodeSegments = [WeightCurveMapperNodeSegment]()
    public var weightCurveMapperNodeSegmentCount = 0
    func addWeightCurveMapperNodeSegment(_ weightCurveMapperNodeSegment: WeightCurveMapperNodeSegment) {
        while weightCurveMapperNodeSegments.count <= weightCurveMapperNodeSegmentCount {
            weightCurveMapperNodeSegments.append(weightCurveMapperNodeSegment)
        }
        weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentCount] = weightCurveMapperNodeSegment
        weightCurveMapperNodeSegmentCount += 1
    }
    
    func purgeWeightCurveMapperNodeSegments() {
        for weightCurveMapperNodeSegmentsIndex in 0..<weightCurveMapperNodeSegmentCount {
            WeightCurvePartsFactory.shared.depositWeightCurveMapperNodeSegment(weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentsIndex])
        }
        weightCurveMapperNodeSegmentCount = 0
    }
    
    var overlappingWeightCurveMapperNodeSegments = [WeightCurveMapperNodeSegment]()
    var overlappingWeightCurveMapperNodeSegmentCount = 0
    func addOverlappingWeightCurveMapperNodeSegment(_ overlappingWeightCurveMapperNodeSegment: WeightCurveMapperNodeSegment) {
        while overlappingWeightCurveMapperNodeSegments.count <= overlappingWeightCurveMapperNodeSegmentCount {
            overlappingWeightCurveMapperNodeSegments.append(overlappingWeightCurveMapperNodeSegment)
        }
        overlappingWeightCurveMapperNodeSegments[overlappingWeightCurveMapperNodeSegmentCount] = overlappingWeightCurveMapperNodeSegment
        overlappingWeightCurveMapperNodeSegmentCount += 1
    }
    
    func resetOverlappingWeightCurveMapperNodeSegments() {
        overlappingWeightCurveMapperNodeSegmentCount = 0
    }
    
    func build(spline: FancySpline, startPosition: Float, endPosition: Float) {
    
        purgeWeightCurveMapperNodeSegments()
        
        let threshold = Float(16.0)
        let thresholdSquared = threshold * threshold
        let shiftX = Float(startPosition)
        
        let firstX = Float(0.0)
        let firstY = spline.getY(startPosition) * WeightCurve.scale
        let lastX = WeightCurve.scale
        
        let lastY = spline.getY(endPosition) * WeightCurve.scale
        var previousX = firstX
        var previousY = firstY
        
        var position = startPosition + 0.05
        while position <= endPosition {
            let x = (spline.getX(position) - shiftX) * WeightCurve.scale
            let y = spline.getY(position) * WeightCurve.scale
            let diffX1 = x - previousX
            let diffY1 = y - previousY
            let distanceSquared1 = diffX1 * diffX1 + diffY1 * diffY1
            let diffX2 = x - lastX
            let diffY2 = y - lastY
            let distanceSquared2 = diffX2 * diffX2 + diffY2 * diffY2
            if distanceSquared1 > thresholdSquared && distanceSquared2 > thresholdSquared {
                let weightCurveMapperNodeSegment = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNodeSegment()
                weightCurveMapperNodeSegment.x1 = previousX
                weightCurveMapperNodeSegment.y1 = previousY
                weightCurveMapperNodeSegment.x2 = x
                weightCurveMapperNodeSegment.y2 = y
                weightCurveMapperNodeSegment.precompute()
                addWeightCurveMapperNodeSegment(weightCurveMapperNodeSegment)
                previousX = x
                previousY = y
            }
            position += 0.025
        }
        
        let weightCurveMapperNodeSegment = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNodeSegment()
        weightCurveMapperNodeSegment.x1 = previousX
        weightCurveMapperNodeSegment.y1 = previousY
        weightCurveMapperNodeSegment.x2 = lastX
        weightCurveMapperNodeSegment.y2 = lastY
        weightCurveMapperNodeSegment.precompute()
        addWeightCurveMapperNodeSegment(weightCurveMapperNodeSegment)
        
        var i = 1
        while i < weightCurveMapperNodeSegmentCount {
            let holdWeightCurveMapperNodeSegment = weightCurveMapperNodeSegments[i]
            var j = i - 1
            while j >= 0, weightCurveMapperNodeSegments[j].x1 > holdWeightCurveMapperNodeSegment.x1 {
                weightCurveMapperNodeSegments[j + 1] = weightCurveMapperNodeSegments[j]
                j -= 1
            }
            weightCurveMapperNodeSegments[j + 1] = holdWeightCurveMapperNodeSegment
            i += 1
        }
        
        purgeWeightCurveMapperNodePoints()
        
        for pointIndex in 0..<Self.numberOfPoints {
            
            if (pointIndex <= 0) {
                
                let newWeightCurveMapperNodePoint = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNodePoint()
                newWeightCurveMapperNodePoint.x = firstX
                newWeightCurveMapperNodePoint.y = firstY
                addWeightCurveMapperNodePoint(newWeightCurveMapperNodePoint)
                
            } else if pointIndex >= (Self.numberOfPoints - 1) {
                
                let newWeightCurveMapperNodePoint = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNodePoint()
                newWeightCurveMapperNodePoint.x = lastX
                newWeightCurveMapperNodePoint.y = lastY
                addWeightCurveMapperNodePoint(newWeightCurveMapperNodePoint)
                
            } else {
            
                let percent = Float(pointIndex) / Float(Self.numberOfPoints - 1)
                
                let newWeightCurveMapperNodePoint = WeightCurvePartsFactory.shared.withdrawWeightCurveMapperNodePoint()
                
                let x = WeightCurve.scale * percent
                newWeightCurveMapperNodePoint.x = x
                newWeightCurveMapperNodePoint.y = firstY + (lastY - firstY) * percent
                addWeightCurveMapperNodePoint(newWeightCurveMapperNodePoint)
                
                resetOverlappingWeightCurveMapperNodeSegments()
                
                for weightCurveMapperNodeSegmentIndex in 0..<weightCurveMapperNodeSegmentCount {
                    let weightCurveMapperNodeSegment = weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentIndex]
                    let minX = min(weightCurveMapperNodeSegment.x1, weightCurveMapperNodeSegment.x2)
                    let maxX = max(weightCurveMapperNodeSegment.x1, weightCurveMapperNodeSegment.x2)
                    if x >= minX && x < maxX {
                        addOverlappingWeightCurveMapperNodeSegment(weightCurveMapperNodeSegment)
                    }
                }
                
                let top = Float(-WeightCurve.scale)
                var bestY = Float(100_000_000.0)
                for overlappingWeightCurveMapperNodeSegmentIndex in 0..<overlappingWeightCurveMapperNodeSegmentCount {
                    let overlappingWeightCurveMapperNodeSegment = overlappingWeightCurveMapperNodeSegments[overlappingWeightCurveMapperNodeSegmentIndex]
                    
                    let rayRayResult = Math.rayIntersectionRay(rayOrigin1X: overlappingWeightCurveMapperNodeSegment.x1,
                                                               rayOrigin1Y: overlappingWeightCurveMapperNodeSegment.y1,
                                                               rayNormal1X: overlappingWeightCurveMapperNodeSegment.normalX,
                                                               rayNormal1Y: overlappingWeightCurveMapperNodeSegment.normalY,
                                                               rayOrigin2X: x,
                                                               rayOrigin2Y: top,
                                                               rayDirection2X: 0.0,
                                                               rayDirection2Y: 1.0)
                    switch rayRayResult {
                    case .invalidCoplanar:
                        let chosenY = min(overlappingWeightCurveMapperNodeSegment.y1, overlappingWeightCurveMapperNodeSegment.y2)
                        if chosenY < bestY {
                            bestY = chosenY
                            newWeightCurveMapperNodePoint.y = bestY
                        }
                    case .valid(_ , let chosenY, _):
                        if chosenY < bestY {
                            bestY = chosenY
                            newWeightCurveMapperNodePoint.y = bestY
                        }
                    }
                }
            }
        }
    }
    
    public func getY(x: Float) -> Float {
        if weightCurveMapperNodePointCount > 2 {
            let x = x * WeightCurve.scale
            
            let upperBound = pointUpperBoundX(value: x)
            if upperBound >= Self.numberOfPoints {
                var result = weightCurveMapperNodePoints[Self.numberOfPoints - 1].y / WeightCurve.scale
                if result < 0.0 { result = 0.0 }
                if result > 1.0 { result = 1.0 }
                return result
            }
            
            if upperBound <= 0 {
                var result = weightCurveMapperNodePoints[0].y / WeightCurve.scale
                if result < 0.0 { result = 0.0 }
                if result > 1.0 { result = 1.0 }
                return result
            }
            
            let weightCurveMapperNodePoint1 = weightCurveMapperNodePoints[upperBound - 1]
            let weightCurveMapperNodePoint2 = weightCurveMapperNodePoints[upperBound]
            
            var percent = (x - weightCurveMapperNodePoint1.x) / (weightCurveMapperNodePoint2.x - weightCurveMapperNodePoint1.x)
            if percent < 0.0 { percent = 0.0 }
            if percent > 1.0 { percent = 1.0 }
            
            var result = (weightCurveMapperNodePoint1.y + (weightCurveMapperNodePoint2.y - weightCurveMapperNodePoint1.y) * percent) / WeightCurve.scale
            if result < 0.0 { result = 0.0 }
            if result > 1.0 { result = 1.0 }
            return result
        } else if weightCurveMapperNodeSegmentCount > 0 {
            let firstSegment = weightCurveMapperNodeSegments[0]
            let lastSegment = weightCurveMapperNodeSegments[weightCurveMapperNodeSegmentCount - 1]
            var result = (firstSegment.y1 + (lastSegment.y2 - firstSegment.y1) * x) / WeightCurve.scale
            if result < 0.0 { result = 0.0 }
            if result > 1.0 { result = 1.0 }
            return result
        } else {
            return 0.0
        }
    }
    
    func pointUpperBoundX(value: Float) -> Int {
        var start = 0
        var end = weightCurveMapperNodePointCount
        while start != end {
            let mid = (start + end) >> 1
            if value >= weightCurveMapperNodePoints[mid].x {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
    
}
