//***************************************************************************************
// Default.hlsl by Frank Luna (C) 2015 All Rights Reserved.
//
// Default shader, currently supports lighting.
//***************************************************************************************

// Defaults for number of lights.
#ifndef NUM_DIR_LIGHTS
    #define NUM_DIR_LIGHTS 3
#endif

#ifndef NUM_POINT_LIGHTS
    #define NUM_POINT_LIGHTS 0
#endif

#ifndef NUM_SPOT_LIGHTS
    #define NUM_SPOT_LIGHTS 0
#endif

// Include structures and functions for lighting.
#include "LightingUtil.hlsl"

//Texture2D    gDiffuseMap : register(t0);
Texture2D    gTextures[2] : register(t0);

SamplerState gsamPointWrap : register(s0);
SamplerState gsamPointClamp : register(s1);
SamplerState gsamLinearWrap : register(s2);
SamplerState gsamLinearClamp : register(s3);
SamplerState gsamAnisotropicWrap : register(s4);
SamplerState gsamAnisotropicClamp : register(s5);
SamplerState gsamLinearBorderColor : register(s6);
SamplerState gsamLinearMirror : register(s7);



// Constant data that varies per frame.
cbuffer cbPerObject : register(b0)
{
    float4x4 gWorld;
    float4x4 gTexTransform;
};

// Constant data that varies per material.
cbuffer cbPass : register(b1)
{
    float4x4 gView;
    float4x4 gInvView;
    float4x4 gProj;
    float4x4 gInvProj;
    float4x4 gViewProj;
    float4x4 gInvViewProj;
    float3 gEyePosW;
    float cbPerObjectPad1;
    float2 gRenderTargetSize;
    float2 gInvRenderTargetSize;
    float gNearZ;
    float gFarZ;
    float gTotalTime;
    float gDeltaTime;
    float4 gAmbientLight;

    // Indices [0, NUM_DIR_LIGHTS) are directional lights;
    // indices [NUM_DIR_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHTS) are point lights;
    // indices [NUM_DIR_LIGHTS+NUM_POINT_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHT+NUM_SPOT_LIGHTS)
    // are spot lights for a maximum of MaxLights per object.
    Light gLights[MaxLights];
};

cbuffer cbMaterial : register(b2)
{
	float4 gDiffuseAlbedo;
    float3 gFresnelR0;
    float  gRoughness;
    float4x4 gMatTransform;
};

struct VertexIn
{
	float3 PosL    : POSITION;
    float3 NormalL : NORMAL;
	float2 TexC    : TEXCOORD;
};

struct VertexOut
{
	float4 PosH    : SV_POSITION;
    float3 PosW    : POSITION;
    float3 NormalW : NORMAL;
	float2 TexC    : TEXCOORD;
};

VertexOut VS(VertexIn vin)
{
	VertexOut vout = (VertexOut)0.0f;
	
    // Transform to world space.
    float4 posW = mul(float4(vin.PosL, 1.0f), gWorld);
    vout.PosW = posW.xyz;

    // Assumes nonuniform scaling; otherwise, need to use inverse-transpose of world matrix.
    vout.NormalW = mul(vin.NormalL, (float3x3)gWorld);

    // Transform to homogeneous clip space.
    vout.PosH = mul(posW, gViewProj);
	
	// Output vertex attributes for interpolation across triangle.
    float4 texC = mul(float4(vin.TexC, 0.0f, 1.0f), gTexTransform);
    vout.TexC = mul(texC, gMatTransform).xy;

    return vout;
}

float4 PS(VertexOut pin) : SV_Target
{

    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamPointWrap, pin.TexC * 0.1f) * gDiffuseAlbedo; // Figure 9.7 (Upscaled to see correctly working)
    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamAnisotropicWrap, pin.TexC) * gDiffuseAlbedo; // Figure 9.9 (Top face has a better view)
    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamLinearWrap, pin.TexC * 3.0f) * gDiffuseAlbedo; // Figure 9.10 (Repeating texture)
    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamLinearBorderColor, pin.TexC * 3.0f) * gDiffuseAlbedo; // Figure 9.11 (Border color)
    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamLinearClamp, pin.TexC * 3.0f) * gDiffuseAlbedo; // Figure 9.12 (Clamp)
    //float4 diffuseAlbedo = gDiffuseMap.Sample(gsamLinearMirror, pin.TexC * 3.0f) * gDiffuseAlbedo; // Figure 9.13 (Mirror)

    // Exercise 3
    //float4 diffuseAlbedo = gTextures[0].Sample(gsamLinearWrap, pin.TexC) * gDiffuseAlbedo;
    //float4 alpha = gTextures[1].Sample(gsamLinearWrap, pin.TexC);
    //diffuseAlbedo = diffuseAlbedo * alpha;

    // Exercise 4
    //2d rotation matrix
    float2x2 rotMatrix2D = { cos(gTotalTime), -sin(gTotalTime),
                             sin(gTotalTime), cos(gTotalTime)};
    float2x2 rotMatrix2DB = { cos(-gTotalTime * 0.2f), -sin(-gTotalTime * 0.2f),
                             sin(-gTotalTime * 0.2f), cos(-gTotalTime * 0.2f)};

    float2 finalCoord = mul(pin.TexC - 0.5f, rotMatrix2D) + 0.5f;
    float2 finalCoordB = mul(pin.TexC - 0.5f, rotMatrix2DB) + 0.5f;
    float4 diffuseAlbedo = gTextures[0].Sample(gsamLinearWrap, finalCoord) * gDiffuseAlbedo;
    float4 alpha = gTextures[1].Sample(gsamLinearBorderColor, finalCoordB);
    diffuseAlbedo = diffuseAlbedo * alpha;

    // Interpolating normal can unnormalize it, so renormalize it.
    pin.NormalW = normalize(pin.NormalW);

    // Vector from point being lit to eye. 
    float3 toEyeW = normalize(gEyePosW - pin.PosW);

    // Light terms.
    float4 ambient = gAmbientLight*diffuseAlbedo;

    const float shininess = 1.0f - gRoughness;
    Material mat = { diffuseAlbedo, gFresnelR0, shininess };
    float3 shadowFactor = 1.0f;
    float4 directLight = ComputeLighting(gLights, mat, pin.PosW,
        pin.NormalW, toEyeW, shadowFactor);

    float4 litColor = ambient + directLight;

    // Common convention to take alpha from diffuse material.
    litColor.a = diffuseAlbedo.a;

    return litColor;
}

