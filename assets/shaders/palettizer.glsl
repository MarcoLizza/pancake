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

uniform sampler2D u_palette;

// These are the offset values that are used to sample the palette in order
// to access the color/transparency/extra attributes for the entry.
//
// The palette has as many columns as the number of entries in the palette, and
// as many rows as the number scanlines of the image (multiplied by 3).
const int COLORS = 0;
const int TRANSPARENCY = 1;
const int EXTRA = 2;

float to_texture_space(int scanline, int scanlines) {
    return float(2 * scanline + 1) / float(2 * scanlines);
}

vec4 get_color(float index, int scanline, int scanlines) {
    int base = scanline * 3;

    // First we access the "extra" attributes for that color.
    //
    // Note: the `index` value is already normalized into "texture coordinates"
    // (with values in the range `[0, 1]` relative to the texture width/height)
    // so we can use it as it is.
    vec4 extra = texture2D(u_palette, vec2(to_texture_space(base + EXTRA, scanlines), index));

    // Access the `r` component of the extra attributes, which is the pixel
    // "remapped" index.
    index = extra.r;

    // Once again, use the (normalized) index to access both the pixel colors
    // and transparency.
    //
    // Note: we keep the separate so that changing a palette entry transparency
    // requires just a single "write access" to the texture.
    vec4 colors = texture2D(u_palette, vec2(to_texture_space(base + COLORS, scanlines), index));
    vec4 transparency = texture2D(u_palette, vec2(to_texture_space(base + TRANSPARENCY, scanlines), index));
    return vec4(colors.rgb, transparency.a);
}

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_position) {
    // The `r` component of the picture is the palette color index to be used.
    vec4 pixel = texture2D(texture, texture_coords);
    float index = pixel.r;

    return get_color(index, int(screen_position.y), int(love_ScreenSize.y));
}
