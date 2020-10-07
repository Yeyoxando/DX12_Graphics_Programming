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

struct PSInput
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
};

PSInput VSMain(float4 position : POSITION, float4 color : COLOR)
{
    PSInput result;

    // Translation values and matrix
    float trans_x = 0.0f;
    float trans_y = 0.0f;
    float trans_z = 0.5f;
    float4x4 translate_mat = {    1.0f,    0.0f,    0.0f, 0.0f,
                                  0.0f,    1.0f,    0.0f, 0.0f,
                                  0.0f,    0.0f,    1.0f, 0.0f,
                               trans_x, trans_y, trans_z, 1.0f };
    // Scale values and matrix
    float scale_x = 1.0f;
    float scale_y = 1.0f;
    float scale_z = 1.0f;
    float4x4 scale_mat = { scale_x,    0.0f,    0.0f, 0.0f,
                              0.0f, scale_y,    0.0f, 0.0f,
                              0.0f,    0.0f, scale_z, 0.0f,
                              0.0f,    0.0f,    0.0f, 1.0f };

    // Rotations
    // Pi constant
    float kPi = 3.14159265359f;
    // Tau constant
    float kTau = kPi * 2.0f;

    float x_radians = kTau / 6.0f;

    // Rotates in the X axis
    float4x4 rotateX = { 1.0f,            0.0f,           0.0f, 0.0f,
                         0.0f,  cos(x_radians), sin(x_radians), 0.0f,
                         0.0f, -sin(x_radians), cos(x_radians), 0.0f,
                         0.0f,            0.0f,           0.0f, 1.0f };

    float y_radians = 0.0f;
    // Rotates in the Y axis
    float4x4 rotateY = { cos(y_radians), 0.0f, -sin(y_radians), 0.0f,
                                   0.0f, 1.0f,            0.0f, 0.0f,
                         sin(y_radians), 0.0f,  cos(y_radians), 0.0f,
                                   0.0f, 0.0f,            0.0f, 1.0f };

    float z_radians = kTau / 4.0f;
    // Rotates in the Z axis
    float4x4 rotateZ = {  cos(z_radians), sin(z_radians), 0.0f, 0.0f,
                         -sin(z_radians), cos(z_radians), 0.0f, 0.0f,
                                    0.0f,           0.0f, 1.0f, 0.0f,
                                    0.0f,           0.0f, 0.0f, 1.0f };

    // Final rotation matrix (RX * RY * RZ) -> muls has to be done in inverse order
    float4x4 rotate_mat = mul(rotateZ, rotateY);
    rotate_mat = mul(rotate_mat, rotateX);

    // Final transform matrix (T * R * S) -> muls has to be done in inverse order
    float4x4 transform_mat = mul(scale_mat, rotate_mat);
    transform_mat = mul(transform_mat, translate_mat);

    // Final transformation
    float4 final_position = mul(position, transform_mat);

    result.position = final_position;
    result.color = color;

    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    return input.color;
}
