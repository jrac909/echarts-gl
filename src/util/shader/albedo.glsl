@export ecgl.albedo.vertex

uniform mat4 worldViewProjection : WORLDVIEWPROJECTION;
uniform vec2 uvRepeat: [1, 1];

attribute vec2 texcoord : TEXCOORD_0;
attribute vec3 position: POSITION;

#ifdef VERTEX_COLOR
attribute vec4 a_Color : COLOR;
varying vec4 v_Color;
#endif

varying vec2 v_Texcoord;

void main()
{
    gl_Position = worldViewProjection * vec4(position, 1.0);
    v_Texcoord = texcoord * uvRepeat;

#ifdef VERTEX_COLOR
    v_Color = a_Color;
#endif
}

@end

@export ecgl.albedo.fragment

#define LAYER_DIFFUSEMAP_COUNT 0
#define LAYER_EMISSIVEMAP_COUNT 0

uniform sampler2D diffuseMap;
uniform vec3 color : [1.0, 1.0, 1.0];
uniform float alpha : 1.0;

uniform float emissionIntensity: 1.0;

#ifdef VERTEX_COLOR
varying vec4 v_Color;
#endif

#if (LAYER_DIFFUSEMAP_COUNT > 0)
uniform sampler2D layerDiffuseMap[LAYER_DIFFUSEMAP_COUNT];
#endif

#if (LAYER_EMISSIVEMAP_COUNT > 0)
uniform sampler2D layerEmissiveMap[LAYER_EMISSIVEMAP_COUNT];
#endif

varying vec2 v_Texcoord;

void main()
{
    gl_FragColor = vec4(color, alpha);

#ifdef VERTEX_COLOR
    gl_FragColor *= v_Color;
#endif

    vec4 albedoTexel = vec4(1.0);
#ifdef DIFFUSEMAP_ENABLED
    albedoTexel = texture2D(diffuseMap, v_Texcoord);
#endif

#if (LAYER_DIFFUSEMAP_COUNT > 0)
    for (int _idx_ = 0; _idx_ < LAYER_DIFFUSEMAP_COUNT; _idx_++) {{
        vec4 texel2 = texture2D(layerDiffuseMap[_idx_], v_Texcoord);
        // source-over blend
        albedoTexel.rgb = texel2.rgb * texel2.a + albedoTexel.rgb * (1.0 - texel2.a);
        albedoTexel.a = texel2.a + (1.0 - texel2.a) * albedoTexel.a;
    }}
#endif
    gl_FragColor *= albedoTexel;

#if (LAYER_EMISSIVEMAP_COUNT > 0)
    for (int _idx_ = 0; _idx_ < LAYER_EMISSIVEMAP_COUNT; _idx_++) {{
        // PENDING BLEND?
        vec4 texel2 = texture2D(layerEmissiveMap[_idx_], v_Texcoord);
        gl_FragColor.rgb += texel2.rgb * texel2.a * emissionIntensity;
    }}
#endif
}
@end