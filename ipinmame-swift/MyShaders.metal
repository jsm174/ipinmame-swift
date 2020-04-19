
#include <metal_stdlib>
using namespace metal;

//This vertex should be the exact same as the one in the swift file.
struct VertexIn{
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
};

//We will use this rasterizer data model to send information to the rasterizer
struct RasterizerData{
    //Add the position attribute so it does not get interpolated by the rasterizer
    float4 position [[ position ]];
    //The color value will get interpolated since does not have an attribute tag
    float4 color;
    float2 textureCoordinate;
};

struct Material {
    float4 color;
    bool useMaterialColor;
    bool useTexture;
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]]) {
    RasterizerData rd;
    
    rd.position = float4(vIn.position, 1);
    rd.color = vIn.color;
    rd.textureCoordinate = vIn.textureCoordinate;
    
    return rd;
}

//Tbe fragment shaders purpose is to color in each fragment (pixel) to the color returned from the rasterizer.
fragment half4 basic_fragment_shader1(RasterizerData rd [[ stage_in ]],
                                      constant Material &material [[ buffer(1) ]],
                                      sampler sampler2d [[ sampler(0) ]],
                                      texture2d<float> texture [[ texture(0) ]]){
    float2 texCoord = rd.textureCoordinate;
    float4 color;
    if(material.useTexture){
        color = texture.sample(sampler2d, texCoord);
    }else if(material.useMaterialColor) {
        color = material.color;
    }else{
        color = rd.color;
    }
    
    return half4(color.r, color.g, color.b, color.a);
}


fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                    constant Material &material [[ buffer(1) ]],
                                    sampler sampler2d [[ sampler(0) ]],
                                    texture2d<float> texture [[ texture(0) ]]){
    float aspectRatio = 128 / 32;
    float2 dimensions = float2(128, 32);
    float2 dimensionsPerDot = 1.0f / dimensions;
    float2 uv = rd.textureCoordinate;
    
    // Calculate dot center
    float2 dotPos = floor(uv * dimensions);
    float2 dotCenter = dotPos * dimensionsPerDot + dimensionsPerDot * 0.5;

    // Scale coordinates back to original ratio for rounding
    float2 uvScaled = float2(uv.x * aspectRatio, uv.y);
    float2 dotCenterScaled = float2(dotCenter.x * aspectRatio, dotCenter.y);
 
    // Round the dot by testing the distance of the pixel coordinate to the center
    float dist = length(uvScaled - dotCenterScaled) * dimensions[0];
    
    float4 insideColor = texture.sample(sampler2d, dotCenter);

    float4 outsideColor = insideColor;
    outsideColor.r = 0;
    outsideColor.g = 0;
    outsideColor.b = 0;
    outsideColor.a = 1;

    float distFromEdge = 1.25 - dist;  // positive when inside the circle
    float thresholdWidth = .22;  // a constant you'd tune to get the right level of softness
    float antialiasedCircle = saturate((distFromEdge / thresholdWidth) + 0.5);

    //return lerp(outsideColor, insideColor, antialiasedCircle);
    //https://shadowmint.gitbooks.io/unity-material-shaders/support/syntax/lerp.html
    float4 color = outsideColor + antialiasedCircle * (insideColor - outsideColor);
    
    return half4(color.r, color.g, color.b, color.a);
}
