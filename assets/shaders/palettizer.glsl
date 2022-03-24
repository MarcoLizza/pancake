uniform Image u_palette;

const float COMPONENTS = 0.0 / 2.0;
const float TRANSPARENCY = 1.0 / 2.0;
const float SHIFTING = 2.0 / 2.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    float u = pixel.r;
    vec4 shifting = Texel(u_palette, vec2(u, SHIFTING));
    float v = shifting.r;
    vec4 components = Texel(u_palette, vec2(v, COMPONENTS));
    vec4 transparency = Texel(u_palette, vec2(v, TRANSPARENCY));
    return (components + transparency) * color;
}
