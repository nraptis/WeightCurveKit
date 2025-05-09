//
//  WeightCurvePoint.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 3/4/24.
//
//  Verified on 11/9/2024 by Nick Raptis
//

import Foundation
import MathKit

public class WeightCurvePoint: PointProtocol {
    public typealias Point = Math.Point
    public typealias Vector = Math.Vector
    public var x = Float(0.0)
    public var y = Float(0.0)
    public var point: Point {
        Point(x: x, y: y)
    }
}

