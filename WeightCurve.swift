//
//  WeightCurve.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/4/24.
//
//  Not Verified, Heavily Changed
//

import Foundation
import MathKit

public protocol WeightCurveControlPointOwning {
     
    var weightCurveControlPoint: WeightCurveControlPoint { get }
}

public class WeightCurve {
    
    public var resetType = WeightCurveResetType.linear2
    
    static let scale = Float(2048.0)
    
    public let spline = ManualSpline()
    public let mapper = WeightCurveMapper()
    
    public var frameWidth = Float(0.0)
    public var frameHeight = Float(0.0)
    
    public var paddingH = Float(16.0)
    public var paddingV = Float(8.0)
    
    public var minX = Float(0.0)
    public var maxX = Float(0.0)
    public var minY = Float(0.0)
    public var maxY = Float(0.0)
    public var rangeX = Float(0.0)
    public var rangeY = Float(0.0)
    
    private let mudgeSpline = ManualSpline()
    
    public init() {
        
    }
    
    public func buildSplineFromCurve(frameWidth: Float,
                                     frameHeight: Float,
                                     paddingH: Float,
                                     paddingV: Float,
                                     tanFactorWeightCurve: Float,
                                     tanFactorWeightCurveAuto: Float,
                                     
                                     weightCurveControlPointStart: WeightCurveControlPoint,
                                     owningList: [some WeightCurveControlPointOwning],
                                     owningListCount: Int,
                                     weightCurveControlPointEnd: WeightCurveControlPoint) {
        self.paddingH = paddingH
        self.paddingV = paddingV
        
        resetWeightCurveControlPoints()
        
        let minX = paddingH
        let maxX = frameWidth - paddingH
        let minY = paddingV
        let maxY = frameHeight - paddingV
        let rangeX = (maxX - minX)
        let rangeY = (maxY - minY)
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        
        self.rangeX = rangeX
        self.rangeY = rangeY
        

        addWeightCurveControlPoint(weightCurveControlPointStart)
        for guideIndex in 0..<owningListCount {
            let owner = owningList[guideIndex]
            let weightCurveControlPoint = owner.weightCurveControlPoint
            addWeightCurveControlPoint(weightCurveControlPoint)
        }
        addWeightCurveControlPoint(weightCurveControlPointEnd)
        
        switch resetType {
        case .standard3:
            _boneOutTempY_Standard(factor: 1.0)
            _interpolateHeights()
        case .standard2:
            _boneOutTempY_Standard(factor: 0.75)
            _interpolateHeights()
        case .standard1:
            _boneOutTempY_Standard(factor: 0.5)
            _interpolateHeights()
        case .inverse3:
            _boneOutTempY_Inverse(factor: 1.0)
            _interpolateHeights()
        case .inverse2:
            _boneOutTempY_Inverse(factor: 0.75)
            _interpolateHeights()
        case .inverse1:
            _boneOutTempY_Inverse(factor: 0.5)
            _interpolateHeights()
        case .linear1:
            _boneOutTempY_Linear(factor: 0.5)
            _interpolateHeights()
        case .linear2:
            _boneOutTempY_Linear(factor: 0.75)
            _interpolateHeights()
        case .linear3:
            _boneOutTempY_Linear(factor: 1.0)
            _interpolateHeights()
        }
        
        _pickleRotationAll(tanFactorWeightCurve: tanFactorWeightCurve, tanFactorWeightCurveAuto: tanFactorWeightCurveAuto)
    }
    
    private func _pickleRotationAll(tanFactorWeightCurve: Float, tanFactorWeightCurveAuto: Float) {
        mudgeSpline.removeAll(keepingCapacity: true)
        
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            mudgeSpline.addControlPoint(Float(weightCurveControlPointIndex),
                                        (1.0 - weightCurveControlPoint.normalizedHeightFactor))
        }
        
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            if weightCurveControlPoint.isManualTanHandleEnabled {
                
                let magnitudeIn = weightCurveControlPoint.normalizedTanMagnitudeIn / tanFactorWeightCurve
                let magnitudeOut = weightCurveControlPoint.normalizedTanMagnitudeOut / tanFactorWeightCurve
                
                let dirX = sinf(weightCurveControlPoint.normalizedTanDirection)
                let dirY = -cosf(weightCurveControlPoint.normalizedTanDirection)
                
                mudgeSpline.enableManualControlTan(at: weightCurveControlPointIndex,
                                                   inTanX: -dirX * magnitudeIn,
                                                   inTanY: -dirY * magnitudeIn,
                                                   outTanX: dirX * magnitudeOut,
                                                   outTanY: dirY * magnitudeOut)
            } else {
                mudgeSpline.disableManualControlTan(at: weightCurveControlPointIndex)
            }
        }
        
        mudgeSpline.solve(closed: false)
        
        let weightCurveControlPointCount1 = (weightCurveControlPointCount - 1)
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            if !weightCurveControlPoint.isManualTanHandleEnabled {
                
                var inTanX = mudgeSpline.inTanX[weightCurveControlPointIndex]
                let inTanY = mudgeSpline.inTanY[weightCurveControlPointIndex]
                var outTanX = mudgeSpline.outTanX[weightCurveControlPointIndex]
                let outTanY = mudgeSpline.outTanY[weightCurveControlPointIndex]
                
                if weightCurveControlPointIndex == 0 {
                    if outTanX < 0.0 {
                        outTanX = 0.0
                    }
                    if inTanX > 0.0 {
                        inTanX = 0.0
                    }
                }
                if weightCurveControlPointIndex == weightCurveControlPointCount1 {
                    if outTanX < 0.0 {
                        outTanX = 0.0
                    }
                    if inTanX > 0.0 {
                        inTanX = 0.0
                    }
                }
                
                var inDist = inTanX * inTanX + inTanY * inTanY
                var outDist = outTanX * outTanX + outTanY * outTanY
                
                let epsilon1 = Float(32.0 * 32.0)
                let epsilon2 = Float( 4.0 *  4.0)
                let epsilon3 = Float(0.1 * 0.1)
                
                var rotation = Float(0.0)
                var isValidReading = true
                
                if inDist > epsilon1 {
                    rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
                } else if outDist > epsilon1 {
                    rotation = Math.face(target: .init(x: outTanX, y: outTanY))
                } else if inDist > epsilon2 {
                    rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
                } else if outDist > epsilon2 {
                    rotation = Math.face(target: .init(x: outTanX, y: outTanY))
                } else if inDist > epsilon3 {
                    rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
                } else if outDist > epsilon3 {
                    rotation = Math.face(target: .init(x: outTanX, y: outTanY))
                } else {
                    isValidReading = false
                }
                
                if inDist > Math.epsilon {
                    inDist = sqrtf(inDist)
                }
                
                if outDist > Math.epsilon {
                    outDist = sqrtf(outDist)
                }
                
                if isValidReading {
                    if weightCurveControlPointIndex == 0 {
                        _pickleRotationDefaultLeftBookEnd(rotation: rotation,
                                                          outDist: outDist,
                                                          tanFactorWeightCurveAuto: tanFactorWeightCurveAuto)
                    } else if weightCurveControlPointIndex == (weightCurveControlPointCount - 1) {
                        _pickleRotationDefaultRightBookEnd(rotation: rotation,
                                                           inDist: inDist,
                                                           tanFactorWeightCurveAuto: tanFactorWeightCurveAuto)
                    } else {
                        _pickleRotationDefaultMiddle(index: weightCurveControlPointIndex,
                                                     rotation: rotation,
                                                     inDist: inDist,
                                                     outDist: outDist,
                                                     tanFactorWeightCurveAuto: tanFactorWeightCurveAuto)
                    }
                }
            }
        }
    }
    
    private func _pickleRotationDefaultLeftBookEnd(rotation: Float,
                                                   outDist: Float,
                                                   tanFactorWeightCurveAuto: Float) {
        if weightCurveControlPointCount > 0 {
            
            let weightCurveControlPoint = weightCurveControlPoints[0]
            
            switch resetType {
            case .standard3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.42420724
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.44
                    return
                }
            case .standard2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.52564806
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.4
                    return
                }
            case .standard1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.72238183
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.36
                    return
                }
            case .linear3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.51950014
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.44
                    return
                }
            case .linear2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.6547546
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.4
                    return
                }
            case .linear1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.86071026
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.36
                    return
                }
            case .inverse3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.48876047
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.36
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.91167784
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.36
                    return
                }
            case .inverse2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.69779015
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.4
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.0656775
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.4
                    return
                }
            case .inverse1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.94985527
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.44
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.2319971
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.44
                    return
                }
            }
            weightCurveControlPoint.normalizedTanDirection = rotation
            weightCurveControlPoint.normalizedTanMagnitudeOut = outDist * tanFactorWeightCurveAuto * 3.0
        }
    }
    
    private func _pickleRotationDefaultRightBookEnd(rotation: Float,
                                                    inDist: Float,
                                                    tanFactorWeightCurveAuto: Float) {
        if weightCurveControlPointCount > 0 {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointCount - 1]
            switch resetType {
            case .standard3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.5707963
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.44
                    return
                }
            case .standard2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.5707963
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.4
                    return
                }
            case .standard1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.5707963
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.36
                    return
                }
            case .linear3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.149663
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.44
                    return
                }
            case .linear2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.244956
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.4
                    return
                }
            case .linear1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.3494707
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.36
                    return
                }
            case .inverse3:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.48876047
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.36
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.91167784
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.36
                    return
                }
            case .inverse2:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.69779015
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.4
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.0656775
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.4
                    return
                }
            case .inverse1:
                if weightCurveControlPointCount == 2 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 0.94985527
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.44
                    return
                }
                if weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.2319971
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.44
                    return
                }
            }
            
            weightCurveControlPoint.normalizedTanDirection = rotation
            weightCurveControlPoint.normalizedTanMagnitudeIn = inDist * tanFactorWeightCurveAuto * 3.0
            
        }
    }
    
    private func _pickleRotationDefaultMiddle(index: Int,
                                              rotation: Float,
                                              inDist: Float,
                                              outDist: Float,
                                              tanFactorWeightCurveAuto: Float) {
        
        if index >= 0 && index < weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[index]
            
            switch resetType {
            case .inverse3:
                if index == 1 && weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.1950371
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.36
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.36
                    return
                }
            case .inverse2:
                if index == 1 && weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.268957
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.4
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.4
                    return
                }
            case .inverse1:
                if index == 1 && weightCurveControlPointCount == 3 {
                    // [DONE] Do Not Modify!!!
                    weightCurveControlPoint.normalizedTanDirection = 1.3675168
                    weightCurveControlPoint.normalizedTanMagnitudeIn = 0.44
                    weightCurveControlPoint.normalizedTanMagnitudeOut = 0.44
                    return
                }
            default:
                break
            }
            weightCurveControlPoint.normalizedTanDirection = rotation
            weightCurveControlPoint.normalizedTanMagnitudeIn = inDist * tanFactorWeightCurveAuto
            weightCurveControlPoint.normalizedTanMagnitudeOut = outDist * tanFactorWeightCurveAuto
        }
    }
    
    private func _interpolateHeights() {
        
        // Now we need to mudge the previous and current point.
        for _ in 0..<6 {
            for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
                let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
                if weightCurveControlPoint.isManualHeightEnabled == false {
                    if weightCurveControlPointIndex > 0 {
                        if weightCurveControlPointIndex < (weightCurveControlPointCount - 1) {
                            let weightCurveControlPointLeft = weightCurveControlPoints[weightCurveControlPointIndex - 1]
                            let weightCurveControlPointRight = weightCurveControlPoints[weightCurveControlPointIndex + 1]
                            let driftFactorLeft = (weightCurveControlPointLeft.normalizedHeightFactor - weightCurveControlPointLeft.tempY)
                            let driftFactorRight = (weightCurveControlPointRight.normalizedHeightFactor - weightCurveControlPointRight.tempY)
                            var tempY = weightCurveControlPoint.tempY
                            tempY += driftFactorLeft * 0.5 * 0.25
                            tempY += driftFactorRight * 0.5 * 0.25
                            if tempY < 0.0 { tempY = 0.0 }
                            if tempY > 1.0 { tempY = 1.0 }
                            weightCurveControlPoint.holdY = tempY
                        }
                    }
                }
            }
            let weightCurveControlPointCount1 = (weightCurveControlPointCount - 1)
            for weightCurveControlPointIndex in 0..<weightCurveControlPointCount1 {
                let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
                if weightCurveControlPoint.isManualHeightEnabled == false {
                    weightCurveControlPoint.normalizedHeightFactor = weightCurveControlPoint.holdY
                }
            }
        }
    }
    
    private func _boneOutTempY_Standard(factor: Float) {
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            weightCurveControlPoint.tempY = _standardMap(index: weightCurveControlPointIndex, count: weightCurveControlPointCount) * factor
            weightCurveControlPoint.defaultY = weightCurveControlPoint.tempY
            if weightCurveControlPoint.isManualHeightEnabled == false {
                weightCurveControlPoint.normalizedHeightFactor = weightCurveControlPoint.defaultY
            }
        }
    }
    
    private func _boneOutTempY_Linear(factor: Float) {
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            weightCurveControlPoint.tempY = _linearMap(index: weightCurveControlPointIndex, count: weightCurveControlPointCount) * factor
            weightCurveControlPoint.defaultY = weightCurveControlPoint.tempY
            if weightCurveControlPoint.isManualHeightEnabled == false {
                weightCurveControlPoint.normalizedHeightFactor = weightCurveControlPoint.defaultY
            }
        }
    }
    
    private func _boneOutTempY_Inverse(factor: Float) {
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            weightCurveControlPoint.tempY = _inverseMap(index: weightCurveControlPointIndex, count: weightCurveControlPointCount) * factor
            weightCurveControlPoint.defaultY = weightCurveControlPoint.tempY
            if weightCurveControlPoint.isManualHeightEnabled == false {
                weightCurveControlPoint.normalizedHeightFactor = weightCurveControlPoint.defaultY
            }
        }
    }
    
    private func _percentLinear(index: Int,
                                count: Int) -> Float {
        if count > 1 {
            var result = Float(index) / Float(count - 1)
            if result < 0.0 { result = 0.0 }
            if result > 1.0 { result = 1.0 }
            return result
        } else {
            return 0.5
        }
    }
    
    private func _percentSkewed(index: Int,
                                count: Int) -> Float {
        var percentSkewed = _percentLinear(index: index,
                                           count: count)
        percentSkewed += (1.0 - percentSkewed) * (0.228) * percentSkewed
        return percentSkewed
    }
    
    public func _linearMap(index: Int,
                                count: Int) -> Float {
        let percentA = _percentLinear(index: index, count: count)
        let percentB = _standardMap(index: index, count: count)
        var amountRemaining = (1.0 - percentA)
        amountRemaining = (1.0 - amountRemaining)
        amountRemaining = amountRemaining * 0.5 + (amountRemaining * amountRemaining) * 0.5
        amountRemaining = (1.0 - amountRemaining)
        let shiftFactor = Float(0.32)
        var result = percentA + (percentB * amountRemaining * shiftFactor)
        if result < 0.0 { result = 0.0 }
        if result > 1.0 { result = 1.0 }
        return result
    }
    
    //π/3
    public func _inverseMap(index: Int,
                             count: Int) -> Float {
        var percentY = _percentLinear(index: index,
                                      count: count)
        let range = Math.pi_2
        let mininum = Math._pi_4
        percentY = tanf(mininum + percentY * range)
        let lowestValue = tanf(mininum)
        let highestValue = tanf(mininum + range)
        percentY = (percentY - lowestValue) / (highestValue - lowestValue)
        if percentY < 0.0 { percentY = 0.0 }
        if percentY > 1.0 { percentY = 1.0 }
        return percentY
    }
    
    public func _standardMap(index: Int,
                              count: Int) -> Float {
        var percentY = _percentSkewed(index: index,
                                      count: count)
        percentY = sinf(percentY * Math.pi_2)
        if percentY < 0.0 { percentY = 0.0 }
        if percentY > 1.0 { percentY = 1.0 }
        return percentY
    }
    
    public func refreshSpline(frameWidth: Float,
                       frameHeight: Float,
                       paddingH: Float,
                       paddingV: Float,
                       tanFactorWeightCurve: Float) {
        
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            weightCurveControlPoint.tempY = (1.0 - weightCurveControlPoint.normalizedHeightFactor)
            weightCurveControlPoint.tempX = weightCurveControlPoint.getPosition(index: weightCurveControlPointIndex,
                                                                                count: weightCurveControlPointCount)
        }
        
        spline.removeAll(keepingCapacity: true)
        
        for weightCurveControlPointIndex in 0..<weightCurveControlPointCount {
            let weightCurveControlPoint = weightCurveControlPoints[weightCurveControlPointIndex]
            
            spline.addControlPoint(weightCurveControlPoint.tempX,
                                   weightCurveControlPoint.tempY)
            
            let magnitudeIn = weightCurveControlPoint.normalizedTanMagnitudeIn / tanFactorWeightCurve
            let magnitudeOut = weightCurveControlPoint.normalizedTanMagnitudeOut / tanFactorWeightCurve
            
            let dirX = sinf(weightCurveControlPoint.normalizedTanDirection)
            let dirY = -cosf(weightCurveControlPoint.normalizedTanDirection)
            
            spline.enableManualControlTan(at: weightCurveControlPointIndex,
                                          inTanX: -dirX * magnitudeIn,
                                          inTanY: -dirY * magnitudeIn,
                                          outTanX: dirX * magnitudeOut,
                                          outTanY: dirY * magnitudeOut)
        }
        spline.solve(closed: false)
        mapper.build(spline: spline)
    }
    
    public var weightCurveControlPoints = [WeightCurveControlPoint]()
    public var weightCurveControlPointCount = 0
    
    public func addWeightCurveControlPoint(_ weightCurveControlPoint: WeightCurveControlPoint) {
        while weightCurveControlPoints.count <= weightCurveControlPointCount {
            weightCurveControlPoints.append(weightCurveControlPoint)
        }
        weightCurveControlPoints[weightCurveControlPointCount] = weightCurveControlPoint
        weightCurveControlPointCount += 1
    }
    
    public func resetWeightCurveControlPoints() {
        weightCurveControlPointCount = 0
    }
    
}
