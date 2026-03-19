float r_dither(vec2 frag) {
    return fract(dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float shifted_r_dither(vec2 frag) {
    return fract(dither_shift + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}
