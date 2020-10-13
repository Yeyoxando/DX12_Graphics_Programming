//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************

cbuffer SceneConstantBuffer : register(b0)
{
    float radians;
    float padding[63];
};

struct PSInput
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
};

PSInput VSMain(float4 position : POSITION, float4 color : COLOR)
{
    // Rotates in the Z axis
    float4x4 rotateZ = { cos(radians), sin(radians), 0.0f, 0.0f,
                         -sin(radians), cos(radians), 0.0f, 0.0f,
                                    0.0f,           0.0f, 1.0f, 0.0f,
                                    0.0f,           0.0f, 0.0f, 1.0f };
    PSInput result;

    result.position = mul(position, rotateZ);
    result.color = color;

    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    return input.color;
}
