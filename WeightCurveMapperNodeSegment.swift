//
//  WeightCurveMapperNodeSegment.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/6/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public class WeightCurveMapperNodeSegment: MathKit.PrecomputedLineSegment {
    
    public var isIllegal = false
    
    public var x1: Float = 0.0
    public var y1: Float = 0.0
    public var x2: Float = 0.0
    public var y2: Float = 0.0
    
    public var centerX: Float = 0.0
    public var centerY: Float = 0.0
    
    public var directionX = Float(0.0)
    public var directionY = Float(-1.0)
    
    public var normalX = Float(1.0)
    public var normalY = Float(0.0)
    
    public var lengthSquared = Float(1.0)
    public var length = Float(1.0)
    
    public var directionAngle = Float(0.0)
    public var normalAngle = Float(0.0)
    
}
