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
    // Translation values and matrix
    float trans_x = 0.0f;
    float trans_y = 0.0f;
    float trans_z = 0.5f;
    float4x4 translate_mat = { 1.0f,    0.0f,    0.0f, 0.0f,
                                  0.0f,    1.0f,    0.0f, 0.0f,
                                  0.0f,    0.0f,    1.0f, 0.0f,
                               trans_x, trans_y, trans_z, 1.0f };

    // Rotates in the X axis
    float4x4 rotateX = { 1.0f,            0.0f,           0.0f, 0.0f,
                         0.0f,  cos(radians), sin(radians), 0.0f,
                         0.0f, -sin(radians), cos(radians), 0.0f,
                         0.0f,            0.0f,           0.0f, 1.0f };

    // Rotates in the Y axis
    float4x4 rotateY = { cos(radians), 0.0f, -sin(radians), 0.0f,
                                   0.0f, 1.0f,            0.0f, 0.0f,
                         sin(radians), 0.0f,  cos(radians), 0.0f,
                                   0.0f, 0.0f,            0.0f, 1.0f };

    // Rotates in the Z axis
    float4x4 rotateZ = { cos(radians), sin(radians), 0.0f, 0.0f,
                         -sin(radians), cos(radians), 0.0f, 0.0f,
                                    0.0f,           0.0f, 1.0f, 0.0f,
                                    0.0f,           0.0f, 0.0f, 1.0f };

    // Final rotation matrix (RX * RY * RZ) -> muls has to be done in inverse order
    float4x4 rotate_mat = mul(rotateZ, rotateY);
    rotate_mat = mul(rotate_mat, rotateX);

    // Final transform matrix (T * R * S) -> muls has to be done in inverse order
    float4x4 transform_mat = mul(rotate_mat, translate_mat);

    PSInput result;

    result.position = mul(position, transform_mat);
    result.color = color;

    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    return input.color;
}
