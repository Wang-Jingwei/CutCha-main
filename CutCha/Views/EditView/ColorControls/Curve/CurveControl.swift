//
//  CurveControl.swift
//  SegmentAnywhere
//
//  Created by hansoong choong on 9/5/24.
//

import SwiftUI

struct CurveControl: View {
    @EnvironmentObject var polynomialTransformer: PolynomialTransformer
    
    @State var channelName = "RGB"
    var body: some View {
        // Red
        PolynomialEditor(
            title: $channelName,
            color: getColor,
            values: getHandleValues,
            coefficients: getCoefficients)
        .padding()
        
    }
    
    var getColor : Color {
        if channelName == "Red" {
            return .red
        } else if channelName == "Green" {
            return .green
        } else if channelName == "Blue" {
            return .blue
        }
        
        return .white
    }
    
    var getHandleValues : Binding<[Double]> {
        if channelName == "Red" {
            return $polynomialTransformer.redHandleValues
        } else if channelName == "Green" {
            return $polynomialTransformer.greenHandleValues
        } else if channelName == "Blue" {
            return $polynomialTransformer.blueHandleValues
        }
        return $polynomialTransformer.rgbHandleValues
    }
    
    var getCoefficients : Binding<[Float]> {
        if channelName == "Red" {
            return $polynomialTransformer.redCoefficients
        } else if channelName == "Green" {
            return $polynomialTransformer.greenCoefficients
        } else if channelName == "Blue" {
            return $polynomialTransformer.blueCoefficients
        }
        return $polynomialTransformer.rgbCoefficients
    }
}
