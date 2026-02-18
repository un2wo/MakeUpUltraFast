/* MakeUp - luma.glsl
Luma related functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float luma(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

float color_average(vec3 color) {
    return (color.r + color.g + color.b) * 0.3333333333;
}

// sorry for beinsg a stupid chud vibecoder (adjustable smoothstep based on Peter Stock's algorithm)
vec3 adjustable_smoothstep(vec3 x, float p, float g) {
    float c = (g - 1.0) / (2.0 - g);
    vec3 y;
    for (int i = 0; i < 3; ++i) {
        float xi = clamp(x[i], 0.0, 1.0);
        if (xi < p) {
            float num = xi * xi * (1.0 + c);
            float den = xi + p * c;
            y[i] = num / den;
        } else {
            float xm = 1.0 - xi;
            float num = xm * xm * (1.0 + c);
            float den = xm + (1.0 - p) * c;
            y[i] = 1.0 - (num / den);
        }
    }
    return y;
}
