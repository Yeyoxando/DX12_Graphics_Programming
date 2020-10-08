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

    float x_radians = 0.0f;//kTau / 6.0f;

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

    float z_radians = 0.0f;//kTau / 4.0f;
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
    float4 final_color = input.color;

    //Predefined colors
    float4 red = { 1.0f, 0.0f, 0.0f, 1.0f };
    float4 green = { 0.0f, 1.0f, 0.0f, 1.0f };
    float4 blue = { 0.0f, 0.0f, 1.0f, 1.0f };

    // Stripped triangle
    // Untransformed triangle height goes from 300.0f to 600.0f on world-space, so each side height is 100.0f
    /*
    if (input.position.y < 400.0f) {
        final_color = red;
    }
    if (input.position.y >= 400.0f && input.position.y <= 500.0f) {
        final_color = green;
    }
    if (input.position.y > 500.0f) {
        final_color = blue;
    }
    */
    
    // Top-Bottom smooth gradient
    // Knowing that the untransformed triangle height goes from 300.0f to 600.0f we can calculate the lerp value on this way.
    // Simulate that the triangle start is on 0.0f and divide the obtained value by its height
    /*
    float lerp_value = (input.position.y - 300.0f) / 300.0f;
    final_color = lerp(red, blue, lerp_value);
    */

    // Centre-Edge smooth gradient (Line)
    // Knowing that the untransformed triangle wide goes from 450.0f to 750.0f we can calculate the lerp value on this way.
    // Simulate that the triangle x coordinate starts at 0.0f, then displace by its half-size, finally divide it by its half-size
    // Last step is to obtain it's absolute value to obtain a correct lerp value for the negative side as well.
    /*
    float lerp_value = abs(((input.position.x - 450.0f) - 150.0f) / 150.0f);
    final_color = lerp(red, green, lerp_value);
    */

    // Centre-Edge smooth gradient (Dot)
    // Knowing that the triangle center is at { 600.0f, 450.0f }, we can calculate the distance from the center to the current position
    // We can also displace a bit the center of the dot to adjust it more to the center (+50.0f to y coordinate)
    // Finally, we have to divide the obtained distance by the triangle half-size to normalize the value and use a value from 0.0f to 1.0f in lerp function
    float2 center_position = { 600.0f, (450.0f + 50.0f)};
    float pixel_to_center = distance(center_position, input.position.xy);
    final_color = lerp(blue, green, (pixel_to_center / 150.0f));

    return final_color;
}
