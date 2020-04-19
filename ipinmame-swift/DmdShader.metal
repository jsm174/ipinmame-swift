//
//  DmdShader.metal
//  ipinmame-swift
//
//  Created by Jason Millard on 3/22/20.
//  Copyright © 2020 Jason Millard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//
//_MainTex ("Texture", 2D) = "white" {}
//_Width ("Width", Float) = 128
//_Height ("Height", Float) = 32
//_Size ("Dot Size", Float) = 1.25
//

float4 setDmd (float width, float height, float size, float2 uv, sampler samp, texture2d<float> tex2D) {
    float aspectRatio = width / height;
    float2 dimensions = float2(width, height);
    float2 dimensionsPerDot = 1.0f / dimensions;
    
    // Calculate dot center
    float2 dotPos = floor(uv * dimensions);
    float2 dotCenter = dotPos * dimensionsPerDot + dimensionsPerDot * 0.5;

    // Scale coordinates back to original ratio for rounding
    float2 uvScaled = float2(uv.x * aspectRatio, uv.y);
    float2 dotCenterScaled = float2(dotCenter.x * aspectRatio, dotCenter.y);
 
    // Round the dot by testing the distance of the pixel coordinate to the center
    float dist = length(uvScaled - dotCenterScaled) * dimensions[0];
    
    float4 insideColor = tex2D.sample(samp, dotCenter);

    float4 outsideColor = insideColor;
    outsideColor.r = 0;
    outsideColor.g = 0;
    outsideColor.b = 0;
    outsideColor.a = 1;

    float distFromEdge = size - dist;  // positive when inside the circle
    float thresholdWidth = .22;  // a constant you'd tune to get the right level of softness
    float antialiasedCircle = saturate((distFromEdge / thresholdWidth) + 0.5);

    //return lerp(outsideColor, insideColor, antialiasedCircle);
    //https://shadowmint.gitbooks.io/unity-material-shaders/support/syntax/lerp.html
    return outsideColor + antialiasedCircle * (insideColor - outsideColor);
}




/*

            float4 setDmd (float2 uv, sampler2D samp) : COLOR
            {
                // Calculate dot center
                float2 dotPos = floor(uv * Dimensions);
                float2 dotCenter = dotPos * DimensionsPerDot + DimensionsPerDot * 0.5;

                // Scale coordinates back to original ratio for rounding
                float2 uvScaled = float2(uv.x * AspectRatio, uv.y);
                float2 dotCenterScaled = float2(dotCenter.x * AspectRatio, dotCenter.y);

                // Round the dot by testing the distance of the pixel coordinate to the center
                float dist = length(uvScaled - dotCenterScaled) * Dimensions;

                float4 insideColor = tex2D(samp, dotCenter);

                float4 outsideColor = insideColor;
                outsideColor.r = 0;
                outsideColor.g = 0;
                outsideColor.b = 0;
                outsideColor.a = 1;

                float distFromEdge = _Size - dist;  // positive when inside the circle
                float thresholdWidth = .22;  // a constant you'd tune to get the right level of softness
                float antialiasedCircle = saturate((distFromEdge / thresholdWidth) + 0.5);

                return lerp(outsideColor, insideColor, antialiasedCircle);
            }

*/
