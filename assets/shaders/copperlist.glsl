/*
MIT License

Copyright (c) 2022 Marco Lizza

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

uniform sampler2D u_copperlist;

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_position) {
    vec4 attributes = texture2D(u_copperlist, vec2(0.5, texture_coords.y));

    // Since we can't store *negative* values in the color components, we need to
    // separate the offset in two parts: the positive value in the `r` component,
    // and the negative value in the `g` component.
    //
    // Also note that since the offset is applied to the texture coordinates in
    // "reverse" mode, we need to flip the sign of the offset (i.e. the positive
    // offset is added, and the negative offset is subtracted).
    float dx = - attributes.r + attributes.g;
    float dy = - attributes.b + attributes.a;
    vec2 uv = texture_coords + vec2(dx, dy);

    return texture2D(texture, uv);
}
