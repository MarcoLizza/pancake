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

uniform Image u_palette;

const float COLORS = 0.0 / 2.0;
const float TRANSPARENCY = 1.0 / 2.0;
const float EXTRA = 2.0 / 2.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = sampler2D(texture, texture_coords);

    // The `r` component of the picture is the palette color index to be used.
    float index = pixel.r;

    // First we access the "extra" attributes for that color.
    //
    // Note: the `index` value is already normalized into "texture coordinates"
    // (with values in the range `[0, 1]` relative to the texture width/height)
    // so we can use it as it is.
    vec4 extra = sampler2D(u_palette, vec2(index, EXTRA));

    // Access the `r` component of the extra attributes, which is the pixel
    // "remapped" index.
    index = extra.r;

    // Once again, use the (normalized) index to access both the pixel colors
    // and transparency.
    //
    // Note: we keep the separate so that changing a palette entry transparency
    // requires just a single "write access" to the texture.
    vec4 colors = sampler2D(u_palette, vec2(index, COLORS));
    vec4 transparency = sampler2D(u_palette, vec2(index, TRANSPARENCY));
    return vec4(colors.rgb, transparency.a);
//    return (colors + transparency) * color;
}
