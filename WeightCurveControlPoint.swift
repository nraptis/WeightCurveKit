//
//  WeightCurveControlPoint.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/4/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public class WeightCurveControlPoint {
    
    public init() {
        
    }
    
    public static func getDefaultTanMagnitude(count: Int,
                                       index: Int,
                                       resetType: WeightCurveResetType) -> Float {
        
        switch resetType {
        case .standard3, .standard2, .standard1:
            if count <= 2 {
                if index == 0 {
                    return 0.65
                } else {
                    return 0.30
                }
            }
        default:
            break
        }
        
        if count <= 3 {
            return 0.375
        } else if count == 4 {
            return 0.375 + 0.01
        } else if count == 5 {
            return 0.375 + 0.02
        } else if count == 6 {
            return 0.375 + 0.03
        } else {
            return 0.375 + 0.04
        }
    }
    
    typealias Point = MathKit.Math.Point
    
    public var normalizedTanDirection = Float(0.0)
    public var normalizedTanMagnitudeIn = Float(0.0)
    public var normalizedTanMagnitudeOut = Float(0.0)
    
    public var isManualHeightEnabled = false
    public var normalizedHeightFactor = Float(0.0)
    public var isManualTanHandleEnabled = false
    
    var tempX = Float(0.0)
    var tempY = Float(0.0)
    var defaultY = Float(0.0)
    var holdY = Float(0.0)
    
    func disableManualTanHandle() {
        isManualTanHandleEnabled = false
    }
    
    public func getPercentLinear(index: Int,
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
    
    public func getPosition(index: Int,
                            count: Int) -> Float {
        return Float(index)
    }
    
    
    public func getX(index: Int,
                     count: Int,
                     frameWidth: Float,
                     paddingH: Float) -> Float {
        let percentX = getPercentLinear(index: index,
                                        count: count)
        return (paddingH) + (frameWidth - paddingH - paddingH) * percentX
    }
    
    private func getY(index: Int,
                      count: Int,
                      isManual: Bool,
                      frameHeight: Float,
                      paddingV: Float) -> Float {
        paddingV + ((1.0 - normalizedHeightFactor) * (frameHeight - paddingV - paddingV))
    }
    
    public func getY(index: Int,
                     count: Int,
                     frameHeight: Float,
                     paddingV: Float) -> Float {
        getY(index: index,
             count: count,
             isManual: isManualHeightEnabled,
             frameHeight: frameHeight,
             paddingV: paddingV)
    }
    
    public func getTanHandles(index: Int,
                              count: Int,
                              frameWidth: Float,
                              frameHeight: Float,
                              paddingH: Float,
                              paddingV: Float) -> TanHandles {
        let x = getX(index: index,
                     count: count,
                     frameWidth: frameWidth,
                     paddingH: paddingH)
        let y = getY(index: index,
                     count: count,
                     isManual: isManualHeightEnabled,
                     frameHeight: frameHeight,
                     paddingV: paddingV)
        let dirX = sinf(normalizedTanDirection)
        let dirY = -cosf(normalizedTanDirection)
        
        let width = (frameWidth - paddingH - paddingH)
        let height = (frameHeight - paddingV - paddingV)
        
        var splineFactorX = Float(1.0)
        if count > 1 {
            splineFactorX = 1.0 / Float(count - 1)
        }
        
        return TanHandles(inX: x - dirX * normalizedTanMagnitudeIn * width * splineFactorX,
                          inY: y - dirY * normalizedTanMagnitudeIn * height,
                          outX: x + dirX * normalizedTanMagnitudeOut * width * splineFactorX,
                          outY: y + dirY * normalizedTanMagnitudeOut * height)
    }
    
    public func getTanHandlesRelativeOnlyY(index: Int,
                                           count: Int,
                                           frameHeight: Float,
                                           paddingV: Float) -> TanHandles {
        
        
        let dirY = -cosf(normalizedTanDirection)
        
        let height = (frameHeight - paddingV - paddingV)
        
        return MathKit.TanHandles(inX: 0.0,
                                  inY: -(dirY * normalizedTanMagnitudeIn * height),
                                  outX: 0.0,
                                  outY: dirY * normalizedTanMagnitudeOut * height)
    }
    
}
