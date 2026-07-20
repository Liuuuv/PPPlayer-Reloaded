shader_type canvas_item;
// from https://godotshaders.com/shader/bouncing-reflective-logo/
// by Gerardo LCDF

// =============================
// original: https://www.shadertoy.com/view/wtcSzN
// adaptation: GerardoLCDF
// =============================

uniform bool u_debug_mode = false;
uniform sampler2D noise_texture : filter_nearest;
uniform sampler2D logo_texture : filter_linear;
uniform vec2 logo_aspect_ratio = vec2(2.0, 0.85); 



#define PI 3.14159265359
float vmin(vec2 v) { return min(v.x, v.y); }
float vmax(vec2 v) { return max(v.x, v.y); }
float ellip(vec2 p, vec2 s) { float m = vmin(s); return (length(p / s) * m) - m; }
float halfEllip(vec2 p, vec2 s) { p.x = max(0.0, p.x); float m = vmin(s); return (length(p / s) * m) - m; }
float fBox(vec2 p, vec2 b) { return vmax(abs(p) - b); }
float dvd_d(vec2 p) { float d = halfEllip(p, vec2(.8, .5)); d = max(d, -p.x - .5); float d2 = halfEllip(p, vec2(.45, .3)); d2 = max(d2, min(-p.y + .2, -p.x - .15)); d = max(d, -d2); return d; }
float dvd_v(vec2 p) { vec2 pp = p; p.y += .7; p.x = abs(p.x); vec2 a = normalize(vec2(1.0, -.55)); float d = dot(p, a); float d2 = d + .3; p = pp; d = min(d, -p.y + .3); d2 = min(d2, -p.y + .5); d = max(d, -d2); d = max(d, abs(p.x + .3) - 1.1); return d; }
float dvd_c(vec2 p) { p.y += .95; float d = ellip(p, vec2(1.8, .25)); float d2 = ellip(p, vec2(.45, .09)); d = max(d, -d2); return d; }
float dvd(vec2 p) { p.y -= .345; p.x -= .035; p *= mat2(vec2(1.0, 0.0), vec2(-0.2, 1.0)); float d = dvd_v(p); d = min(d, dvd_c(p)); p.x += 1.3; d = min(d, dvd_d(p)); p.x -= 2.4; d = min(d, dvd_d(p)); return d; }
float range(float vmin, float vmax, float value) { return (value - vmin) / (vmax - vmin); }
float rangec(float a, float b, float t) { return clamp(range(a, b, t), 0.0, 1.0); }
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) { return a + b*cos( 6.28318*(c*t+d) ); }
vec3 spectrum(float n) { return pal( n, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.0, 0.33, 0.67) ); }
void drawHit(inout vec4 col, vec2 p, vec2 hitPos, float hitDist) { float d = length(p - hitPos); if (u_debug_mode) { col = mix(col, vec4(0.0, 1.0, 1.0, 0.0), step(d, .1)); return; } float wavefront = d - hitDist * 1.5; float freq = 2.0; vec3 spec = (1.0 - spectrum(-wavefront * freq + hitDist * freq)); float ripple = sin((wavefront * freq) * PI*2.0 - PI/2.0); float blend = smoothstep(3.0, 0.0, hitDist); blend *= smoothstep(.2, -.5, wavefront); blend *= rangec(-4.0, .0, wavefront); col.rgb *= mix(vec3(1.0), spec, pow(blend, 4.0)); float height = (ripple * blend); col.a -= height * 1.9 / freq; }
vec2 ref(vec2 p, vec2 planeNormal, float offset) { float t = dot(p, planeNormal) + offset; p -= (2.0 * t) * planeNormal; return p; }
void drawReflectedHit(inout vec4 col, vec2 p, vec2 hitPos, float hitDist, vec2 screenSize) { col.a += length(p) * .0001; drawHit(col, p, hitPos, hitDist); }
void flip(inout vec2 pos) { vec2 flip_val = mod(floor(pos), 2.0); pos = abs(flip_val - mod(pos, 1.0)); }
float stepSign(float a) { return step(0.0, a) * 2.0 - 1.0; }
vec2 compassDir(vec2 p) { vec2 a = vec2(stepSign(p.x), 0.0); vec2 b = vec2(0.0, stepSign(p.y)); float s = stepSign(p.x - p.y) * stepSign(-p.x - p.y); return mix(a, b, s * .5 + .5); }
vec2 calcHitPos(vec2 move, vec2 dir, vec2 size) { vec2 hitPos = mod(move, 1.0); vec2 xCross = hitPos - hitPos.x / (size / size.x) * (dir / dir.x); vec2 yCross = hitPos - hitPos.y / (size / size.y) * (dir / dir.y); hitPos = max(xCross, yCross); hitPos += floor(move); return hitPos; }


void fragment()
{
    vec2 screenSize = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 p = (-screenSize + 2.0 * FRAGCOORD.xy) / screenSize.y;
    
    if (u_debug_mode) { p *= 2.0; }
    
    vec2 screen_aspect = vec2(screenSize.x/screenSize.y, 1.0) * 2.0;

    float t = TIME;
    vec2 dir = normalize(vec2(9.0, 16.0) * screen_aspect);
    vec2 move = dir * t / 1.5;

    float logoScale = .1;
    vec2 logoSize = logo_aspect_ratio * logoScale;

    vec2 size = screen_aspect - logoSize * 2.0;
    
    move = move / size + .5;

    vec2 lastHitPos = calcHitPos(move, dir, size);
    vec4 col = vec4(1.0, 1.0, 1.0, 0.0);
    vec4 colFx = vec4(1.0, 1.0, 1.0, 0.0);
    vec4 colFy = vec4(1.0, 1.0, 1.0, 0.0);
    vec2 e = vec2(.8, 0.0) / screenSize.y;

    if (u_debug_mode) { col.rgb = vec3(0.0); }
    const int limit = 5;
    
    for (int i = 0; i < limit; i++) {
        vec2 hitPos = lastHitPos;
        if (i > 0) { hitPos = calcHitPos(hitPos - .00001/size, dir, size); }
        lastHitPos = hitPos;
        float hitDist = distance(hitPos, move);
        flip(hitPos);
        hitPos = (hitPos - .5) * size;
        hitPos += logoSize * compassDir(hitPos / size);
        drawReflectedHit(col, p, hitPos, hitDist, screen_aspect);
        drawReflectedHit(colFx, p + e, hitPos, hitDist, screen_aspect);
        drawReflectedHit(colFy, p + e.yx, hitPos, hitDist, screen_aspect);
    }
        
    flip(move);
    move = (move - .5) * size;
    
    float bf = .1;
    float fx = (col.a - colFx.a) * 2.0;
    float fy = (col.a - colFy.a) * 2.0;
    vec3 nor = normalize(vec3(fx, fy, e.x/bf));
    
    float ff = length(vec2(fx, fy));
    float ee = rangec(0.0, 10.0/screenSize.y, ff);
    nor = normalize(vec3(vec2(fx, fy)*ee, ff));

    col.rgb = clamp(1.0 - col.rgb, vec3(0.0), vec3(1.0));
    col.rgb /= 3.0;
    
    if (!u_debug_mode) {
        vec3 lig = normalize(vec3(1.0, 2.0, 2.0));
        vec3 rd = normalize(vec3(p, -10.0));
        vec3 hal = normalize( lig - rd );

        float dif = clamp(dot(lig, nor), 0.0, 1.0);
        float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ), 16.0) * dif * (0.04 + 0.96 * pow( clamp(1.0 + dot(hal, rd), 0.0, 1.0), 5.0 ));

        vec3 lin = vec3(0.0);
        lin += 5.0 * dif;
        lin += .2;
        col.rgb = col.rgb * lin;
        col.rgb += 5.0 * spe;
    }
    
    if (u_debug_mode) {
        float b = vmin(abs(fract(p / screen_aspect) - .5) * 2.0);
        b /= fwidth(b) * 2.0;
        b = clamp(b, 0.0, 1.0);
        b = 1.0 - b;
        col.rgb = mix(col.rgb, vec3(0.0), b);
    }

    vec2 logo_size = logo_aspect_ratio * logoScale;

    vec2 local_pos = p - move;

    vec2 logo_uv = (local_pos / logo_size) + 0.5;

    vec4 logo_sample = texture(logo_texture, logo_uv);

    float uv_valid = step(0.0, logo_uv.x) * step(logo_uv.x, 1.0) * step(0.0, logo_uv.y) * step(logo_uv.y, 1.0);
    float logo_mask = logo_sample.a * uv_valid;

    col.rgb = mix(col.rgb, logo_sample.rgb, logo_mask);

    vec4 noise_sample = texture(noise_texture, FRAGCOORD.xy / screenSize);
    col.rgb += (noise_sample.rgb * 2.0 - 1.0) * .005;

    col.rgb = pow(col.rgb, vec3(1.0/1.5));

    col.a = col.a * .5 + .5;
    col.a *= .3;
    COLOR = col;
}