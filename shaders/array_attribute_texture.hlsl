#define DM_GFX_ENTRY_FUNCTION_PS

#ifdef DM_GFX_HLSL_SPIRV
    #define DM_GFX_VK_LOCATION(location_var) [[vk::location(location_var)]]
    #define DM_GFX_VK_BINDING(binding_var, set) [[vk::binding(binding_var, set)]]
    #define DM_GFX_VK_COUNTER_BINDING(location) [[vk::counter_binding(location)]]
#else
    #define DM_GFX_VK_LOCATION(location)
    #define DM_GFX_VK_BINDING(binding, set)
    #define DM_GFX_VK_COUNTER_BINDING(location)
#endif
#define DM_GFX_SHADER_PROFILE 5_1
#define EVA_ABUFFER_MAX_FRAGMENT_COUNT 8294400
#define EVA_REGISTER_SRV_MATERIAL_DIFFUSE t0
#define EVA_REGISTER_SRV_MATERIAL_SURFACE_ATTRIBUTES t1
#define EVA_REGISTER_SRV_MATERIAL_AMBIENT_OCCLUSION t2
#define EVA_REGISTER_SRV_MATERIAL_NORMAL t3
#define EVA_REGISTER_SRV_MATERIAL_LUMINANCE t4
#define EVA_REGISTER_SRV_MATERIAL_ALPHA t5
#define EVA_REGISTER_SRV_MATERIAL_NORMAL_AND_DIFFUSE_DETAIL t7
#define EVA_REGISTER_SRV_MATERIAL_DIFFUSE1 t8
#define EVA_REGISTER_SRV_MATERIAL_SPECULAR1 t9
#define EVA_REGISTER_SRV_MATERIAL_NORMAL1 t10
#define EVA_REGISTER_SRV_MATERIAL_LUMINANCE1 t11
#define EVA_REGISTER_SRV_MATERIAL_NORMAL_AND_DIFFUSE_DETAIL1 t12
#define EVA_REGISTER_SRV_MATERIAL_RGBA_BLEND_MAP t13
#define EVA_REGISTER_SRV_MATERIAL_RGBA_DIFFUSE_TEXTURES t14
#define EVA_REGISTER_SRV_MATERIAL_RGBA_ATTRIBUTE_TEXTURES t18
#define EVA_REGISTER_SRV_MATERIAL_RGBA_NORMAL_TEXTURES t22
#define EVA_REGISTER_SAMPLER_SURFACE s0
#define EVA_REGISTER_CBV_VIEW b1
#define EVA_REGISTER_CBV_GLOBAL b0
#define EVA_REGISTER_CBV_MEDIUM b5
#define EVA_REGISTER_CBV_MATERIAL b2
#define EVA_REGISTER_CBV_TESSELLATION b4
#define EVA_REGISTER_CBV_TRANSFORMER b3
#define EVA_REGISTER_SPACE_ILLUMINATION space1
#define EVA_PER_TILE_CULLING_LIGHT_COUNTERS 3
#define EVA_PER_TILE_CULLING_CONSTANTS_ELEMENTS 2
#define EVA_MAX_FRUSTUM_LIGHT_COUNT 292
#define EVA_MAX_TILE_FRUSTUM_LIGHTS 200
#define EVA_MAX_TILE_OMNI_LIGHTS 200
#define EVA_MAX_TILE_REFLECTION_CAPTURERS 256
#define EVA_OMNI_PER_TILE_ELEMENTS 305
#define EVA_FRUSTUM_PER_TILE_ELEMENTS 303
#define EVA_REFLECTION_PER_TILE_ELEMENTS 259
#define EVA_RGBA_BLEND
#define EVA_RGBA_BLEND_CHANNEL_COUNT 3

#define EVA_RGBA_BLEND_MAX_CHANNEL_COUNT 4

#define EVA_RGBA_BLEND_LERP_NORMALS_COUNT 0

#define EVA_SAMPLE_COUNT 1

struct PixelInput
{
    DM_GFX_VK_LOCATION(0) float4 Position : SV_Position0;
    DM_GFX_VK_LOCATION(1) float2 TexCoord : TexCoord0;
    DM_GFX_VK_LOCATION(2) float3 EyeDirectionInView : EyeDirectionInView0;
    DM_GFX_VK_LOCATION(3) float3 TangentInView : TangentInView0;
    DM_GFX_VK_LOCATION(4) float3 BitangentInView : BitangentInView0;
    DM_GFX_VK_LOCATION(5) float3 NormalInView : NormalInView0;
    DM_GFX_VK_LOCATION(6) float3 EyeDirectionInWorld : EyeDirectionInWorld0;
};

struct PixelOutput
{
    DM_GFX_VK_LOCATION(0) float4 Normal : SV_Target0;
    DM_GFX_VK_LOCATION(1) float4 Albedo : SV_Target1;
    DM_GFX_VK_LOCATION(2) float4 Attribute : SV_Target2;
    DM_GFX_VK_LOCATION(3) float3 SurfaceIllumination : SV_Target3;
};

DM_GFX_VK_BINDING(0, 3) cbuffer MaterialConstants : register(EVA_REGISTER_CBV_MATERIAL)
{
    float2 UVScale;
    float2 UVOffset;
    float3 DiffuseColor;
    float AlphaTestTolerance;
    float3 LuminanceNormalColor;
    float LuminanceInterpolationExponent;
    float3 LuminanceGrazingColor;
    float Transparency;
    float4 DiffuseAndNormalWeightsAndTiling;
    float4 FadeOutStartAndLength;
    float3 GlassColor;
    float GlassReflectionIntensity;
    float4 RgbaBlendDiffuseColor_UVTileMultiplier[4];
    float4 RgbaBlendUVOffset[4];
};

#define EVA_NO_UV_ANIMATION
#line 2 "material_uv_animation.hlsl"
#ifndef EVA_GEOMETRY_MATERIAL_UV_ANIMATION_HLSL
#define EVA_GEOMETRY_MATERIAL_UV_ANIMATION_HLSL

// UV Animation

#if defined(EVA_UV_ANIMATION)

// Inputs:
// float2 TexCoord : TexCoord;
//
// Constants:
// float3 UVScale;
// float3 UVOffset;
//
void EvaluateUVAnimation(
    inout PixelInput input)
{
    input.TexCoord.xy = input.TexCoord.xy * UVScale + UVOffset;
}

#endif // EVA_UV_ANIMATION

#if defined(EVA_NO_UV_ANIMATION)
// Inputs: None
// Outputs: None
// Constants: None
//
void EvaluateUVAnimation(
    inout PixelInput input)
{
}
#endif // defined(EVA_NO_UV_ANIMATION)

#endif
#define EVA_NO_ALPHA_TEST
#line 2 "material_alpha_test.hlsl"
#ifndef EVA_GEOMETRY_MATERIAL_ALPHA_TEST_HLSL
#define EVA_GEOMETRY_MATERIAL_ALPHA_TEST_HLSL

// Alpha testing

#if defined(EVA_ALPHA_TEST) && !defined(EVA_MULTISAMPLE_ENABLED) 

// Inputs:
// float2 TexCoord : TexCoord;
//
DM_GFX_VK_BINDING(6, 3)
Texture2D<float> AlphaTexture : register(EVA_REGISTER_SRV_MATERIAL_ALPHA);

void ApplyAlphaTestClipping(
    PixelInput input,
    inout PixelOutput output,
    out uint coverage)
{
    // TODO Juha: Apply dithering to alpha.
    
    float alphaTexel = AlphaTexture.Sample(SurfaceSampler, input.TexCoord.xy) - 0.5f;
    // Using clip() instead of outputting SV_Coverage is potentially faster.
    // clip() not supported in SPIR-V CodeGen currently
    clip(alphaTexel);

    uint bit;
    // SPIR-V CodeGen bug: (alphaTexel > 0.0) ? 1 : 0 doesn't work
    if (alphaTexel > 0.0)
        bit = 1;
    else
        bit = 0;

    coverage = bit;
}

#endif // EVA_ALPHA_TEST && !EVA_MULTISAMPLE_ENABLED

#if defined(EVA_ALPHA_TEST) && defined(EVA_MULTISAMPLE_ENABLED)

// Inputs:
// float2 TexCoord : TexCoord;
// uint coverage : SV_Coverage;
//
// Outputs:
// uint coverage : SV_Coverage;
//
DM_GFX_VK_BINDING(6, 3)
Texture2D<float> AlphaTexture : register(EVA_REGISTER_SRV_MATERIAL_ALPHA);

void ApplyAlphaTestClipping(
    PixelInput input,
    PixelOutput outputPixel,
    out uint coverage)
{
    uint inputCoverage = input.coverage;
    uint output = 0;

    [unroll]
    for (uint i = 0; i < EVA_SAMPLE_COUNT; ++i)
    {
        float2 texcoordAtSample = EvaluateAttributeAtSample(input.TexCoord.xy, i);
        float texel = AlphaTexture.Sample(SurfaceSampler, texcoordAtSample);
        uint bit = (texel > 0.5f); 
        output |= bit << i;
    }
    
    coverage = inputCoverage & output;
    outputPixel.coverage = coverage;;
}

#endif // defined(EVA_ALPHA_TEST) && defined(EVA_MULTISAMPLE_ENABLED)

#if defined(EVA_NO_ALPHA_TEST) && !defined(EVA_MULTISAMPLE_ENABLED) 
// Inputs: None
// Outputs: None
// Constants: None
//
void ApplyAlphaTestClipping(PixelInput input, PixelOutput output, out uint coverage)
{
    coverage = 1;
}
#endif // defined(EVA_NO_ALPHA_TEST) && !defined(EVA_MULTISAMPLE_ENABLED)

#if defined(EVA_NO_ALPHA_TEST) && defined(EVA_MULTISAMPLE_ENABLED)
// Inputs:
// uint coverage : SV_Coverage;
//
// Outputs: None
// Constants: None
//
void ApplyAlphaTestClipping(PixelInput input, PixelOutput output, out uint coverage)
{
    coverage = input.coverage;
}
#endif // defined(EVA_NO_ALPHA_TEST) && defined(EVA_MULTISAMPLE_ENABLED)

#endif
#define EVA_NO_LUMINANCE
#line 2 "material_luminance.hlsl"
#ifndef EVA_GEOMETRY_MATERIAL_LUMINANCE_HLSL
#define EVA_GEOMETRY_MATERIAL_LUMINANCE_HLSL

// Luminance

#ifdef EVA_LUMINANCE
// Inputs:
// float2 TexCoord : TexCoord;
// float3 EyeDirectionInView : EyeDirectionInView;
// float3 PositionInWorld : PositionInWorld;
//
// Outputs:
// float3 SurfaceIllumination : SV_Target3;
//
// Constants:
// float3 LuminanceNormalColor;
// float LuminanceInterpolationExponent;
// float3 LuminanceGrazingColor;
//
// Notes:
// normalInView is provided from ApplySurfaceShading function.
//

DM_GFX_VK_BINDING(5, 3)
Texture2D<float3> LuminanceTexture : register(EVA_REGISTER_SRV_MATERIAL_LUMINANCE);
DM_GFX_VK_BINDING(10, 3)
Texture2D<float3> LuminanceTexture1 : register(EVA_REGISTER_SRV_MATERIAL_LUMINANCE1);
//Texture2D<float3> MagmaManLuminanceTexture;

void ApplyLuminance(
    PixelInput input,
    float3 normalInView,
    inout PixelOutput output)
{
/*#ifndef EVA_DOUBLE_SIDED_SURFACE_SHADING
    if (!input.IsFrontFace)
    {
        output.SurfaceIllumination = 0.0;
        return;
    }
#endif*/

    float3 V = normalize(input.EyeDirectionInView);
    float lerpFactor = pow(1 - saturate(dot(normalInView, V)), LuminanceInterpolationExponent);
    float3 luminanceColor = lerp(LuminanceNormalColor, LuminanceGrazingColor, lerpFactor);
    
#ifdef EVA_TEXTURE_BLENDING
    float3 luminanceTexel0 = LuminanceTexture.Sample(SurfaceSampler, input.TexCoords.xy);
    float3 luminanceTexel1 = LuminanceTexture1.Sample(SurfaceSampler, input.TexCoords.zw);
    float3 luminanceTexel = lerp(luminanceTexel0, luminanceTexel1, input.Color_BlendFactor.w);
    float3 luminance = luminanceTexel * luminanceColor;
#else
    #ifdef EVA_PORTAL_LUMINANCE
    // Portal texture is the same size as the main texture, so can load directly from the
    // same position. Effectively this texturing happens in the screen space coordinates.
    float3 luminanceTexel = LuminanceTexture[input.Position.xy];
    #else
    float3 luminanceTexel = LuminanceTexture.Sample(SurfaceSampler, input.TexCoord.xy);
    #endif

    float3 luminance = luminanceTexel * luminanceColor;
#endif
        
    output.SurfaceIllumination.xyz += luminance;
    //output.SurfaceIllumination.w = 0;
    output.SurfaceIllumination = max(output.SurfaceIllumination, 0);
}

#endif

#ifdef EVA_NO_LUMINANCE
// Inputs: None
// Outputs: None
//
// Constants: None
void ApplyLuminance(
    PixelInput input,
    float3 normalInView,
    inout PixelOutput output)
{
}
#endif

#endif
#define EVA_SURFACE_SHADING
#line 2 "surface_sampler.hlsl"

#ifndef EVA_GEOMETRY_SURFACE_SAMPLER_HLSL
#define EVA_GEOMETRY_SURFACE_SAMPLER_HLSL

// This can be bilinear, trilinear or anisotropic
DM_GFX_VK_BINDING(0, 0)
SamplerState SurfaceSampler : register(EVA_REGISTER_SAMPLER_SURFACE);

#endif
#line 2 "global_constants.hlsl"
#ifndef EVA_GEOMETRY_GLOBAL_CONSTANTS_HLSL
#define EVA_GEOMETRY_GLOBAL_CONSTANTS_HLSL

#if 0 // not used
cbuffer GlobalConstants : register(EVA_REGISTER_CBV_GLOBAL)
{
    uint FullCoverage;
    float3 FogColor;
    float OneOverFogDistance;
    int OmniLightCount;
}
#endif

#endif
#line 2 "view_gbuffer.hlsl"
#ifndef EVA_VIEW_HLSL
#define EVA_VIEW_HLSL

// Data definitions

struct ViewConstantsStruct
{
    float4x4 WorldToViewClipMatrix;
    float4x4 PreviousWorldToViewClipMatrix;
    float4x4 WorldToViewMatrix;
    float4x4 ViewToWorldMatrix;
    float4x4 ViewToViewClipMatrix;
    float4x4 ViewClipToViewMatrix;
    float4x4 ViewportToViewMatrix;
    float4x4 ViewToTargetMatrix;
    float4x4 EnvironmentReflectionViewToWorldMatrix;

    float4 LeftViewClipPlane;
    float4 RightViewClipPlane;    
    float4 BottomViewClipPlane;
    float4 TopViewClipPlane;

    float2 TargetSize;
    float2 OneOverTargetSize;
    float2 ViewZNormalizationScaleBias;
    float3 EyePositionInWorld;
    float ViewHeightToTexelsScale;
    float2 ViewDistanceToWScaleBias;
    float2 ZProjection;
};

#ifdef DM_GFX_HLSL_SPIRV
DM_GFX_VK_BINDING(0, 1)
ConstantBuffer<ViewConstantsStruct> ViewConstants;
#endif

// Functions

// SPIRV CodeGen workarounds
#ifdef DM_GFX_HLSL_SPIRV

#define GetTargetToViewMatrix(view) \
    ((view).ViewportToViewMatrix)

#define GetPositionInTexture(view, positionInTarget) \
    ((positionInTarget) * (view).OneOverTargetSize)

#define ZInView(view, depth) \
    (-1.0f / ((depth) *  (view).ViewportToViewMatrix._43 +  (view).ViewportToViewMatrix._44))

#else

float4x4 GetTargetToViewMatrix(ViewConstantsStruct view)
{
    return view.ViewportToViewMatrix;
}

float2 GetPositionInTexture(ViewConstantsStruct view, float2 positionInTarget)
{
    return positionInTarget * view.OneOverTargetSize;
}

float ZInView(ViewConstantsStruct view, float depth)
{
    return -1.0f / (depth *  view.ViewportToViewMatrix._43 +  view.ViewportToViewMatrix._44);
}

#endif


#endif
//! include "view.hlsl"

// Adds global ViewConstants constant buffer

#ifndef EVA_GEOMETRY_VIEW_CONSTANTS_HLSL
#define EVA_GEOMETRY_VIEW_CONSTANTS_HLSL

#ifndef EVA_REGISTER_SPACE_VIEW
#define EVA_REGISTER_SPACE_VIEW space0
#endif

// Resources

// With Vulkan the constants are defined directly in view.hlsl or view_gbuffer.hlsl
#ifndef DM_GFX_HLSL_SPIRV
ConstantBuffer<ViewConstantsStruct> ViewConstants : register(EVA_REGISTER_CBV_VIEW, EVA_REGISTER_SPACE_VIEW);
#endif

#endif // EVA_GEOMETRY_VIEW_CONSTANTS_HLSL
#line 2 "material_surface_shading.hlsl"
#ifndef EVA_GEOMETRY_MATERIAL_SURFACE_SHADING_HLSL
#define EVA_GEOMETRY_MATERIAL_SURFACE_SHADING_HLSL

// TODO: move these to common shader library
// These are here so that they can be accessed by both
// surface shading and transparent surface shading.
float2 UnpackUNorm8ToSNorm8(float2 unorm8)
{
    float2 unsignedUnnormalized = unorm8 * 255;
    float2 signedUnormalized = unsignedUnnormalized - 128;
    float2 signedNormalized = signedUnormalized / 127;
    return max(-1, signedNormalized);
}

float3 UnpackNormal(Texture2D<float2> normalTexture, SamplerState sam, float2 texCoord)
{
    float2 xy = UnpackUNorm8ToSNorm8(normalTexture.Sample(sam, texCoord));
    return float3(xy, sqrt(1.0 - clamp(dot(xy, xy), 0.0, 1.0)));
}

#if defined(EVA_SURFACE_SHADING)

// Inputs:
// float2 TexCoord : TexCoord;
// float3 EyeDirectionInView : EyeDirectionInView;
// float3 TangentInView : TangentInView;
// float3 BitangentInView : BitangentInView;
// float3 NormalInView : NormalInView;
// float3 EyeDirectionInWorld : EyeDirectionInWorld
//
// Outputs:
// float3 Normal : SV_Target0;
// float4 Albedo : SV_Target1;
// float3 Attribute : SV_Target2;
//
// Constants:
// See MaterialConstants in materials.xml 
//
// Notes:
// input coverage is provided from ApplyAlphaTestClipping function.
//

DM_GFX_VK_BINDING(1, 3)
Texture2D<float4> DiffuseTexture : register(EVA_REGISTER_SRV_MATERIAL_DIFFUSE);
DM_GFX_VK_BINDING(2, 3)
Texture2D<float2> AttributeTexture : register(EVA_REGISTER_SRV_MATERIAL_SURFACE_ATTRIBUTES);
DM_GFX_VK_BINDING(3, 3)
Texture2D<float2> NormalTexture : register(EVA_REGISTER_SRV_MATERIAL_NORMAL);
DM_GFX_VK_BINDING(4, 3)
Texture2D<float> AmbientOcclusionTexture : register(EVA_REGISTER_SRV_MATERIAL_AMBIENT_OCCLUSION);

#ifdef EVA_TEXTURE_DETAIL
DM_GFX_VK_BINDING(7, 3)
Texture2D<float3> NormalAndDiffuseDetailTexture : register(EVA_REGISTER_SRV_MATERIAL_NORMAL_AND_DIFFUSE_DETAIL);
#endif

#ifdef EVA_TEXTURE_BLENDING
DM_GFX_VK_BINDING(8, 3)
Texture2D<float4> DiffuseTexture1 : register(EVA_REGISTER_SRV_MATERIAL_DIFFUSE1);
DM_GFX_VK_BINDING(9, 3)
Texture2D<float2> NormalTexture1 : register(EVA_REGISTER_SRV_MATERIAL_NORMAL1);
DM_GFX_VK_BINDING(11, 3)
Texture2D<float3> NormalAndDiffuseDetailTexture1 : register(EVA_REGISTER_SRV_MATERIAL_NORMAL_AND_DIFFUSE_DETAIL1);
#endif

#ifdef EVA_RGBA_BLEND
DM_GFX_VK_BINDING(13, 3)
Texture2D<float4> BlendMap : register(EVA_REGISTER_SRV_MATERIAL_RGBA_BLEND_MAP);
DM_GFX_VK_BINDING(14, 3)
Texture2D<float4> DiffuseTextures[EVA_RGBA_BLEND_MAX_CHANNEL_COUNT] : register(EVA_REGISTER_SRV_MATERIAL_RGBA_DIFFUSE_TEXTURES);
DM_GFX_VK_BINDING(15, 3)
Texture2D<float2> AttributeTextures[EVA_RGBA_BLEND_MAX_CHANNEL_COUNT] : register(EVA_REGISTER_SRV_MATERIAL_RGBA_ATTRIBUTE_TEXTURES);
DM_GFX_VK_BINDING(16, 3)
Texture2D<float2> NormalTextures[EVA_RGBA_BLEND_MAX_CHANNEL_COUNT] : register(EVA_REGISTER_SRV_MATERIAL_RGBA_NORMAL_TEXTURES);
#endif // EVA_RGBA_BLEND


float4 Material_Diffuse_and_Metalness(PixelInput input, float2 texCoord, float detailFade, float4 blendWeights, float4x2 blendChannelTextureCoordinates)
{
    float4 sampleVar = DiffuseTexture.Sample(SurfaceSampler, texCoord);
    
#ifdef EVA_TEXTURE_BLENDING
    float3 diffuse0 = sampleVar.xyz;
    float3 diffuse1 = DiffuseTexture1.Sample(SurfaceSampler, input.TexCoords.zw).xyz;
    sampleVar.xyz = input.Color_BlendFactor.xyz * lerp(diffuse0, diffuse1, input.Color_BlendFactor.w);
#endif

    // Multiply base material sample with diffuse color before RGBA blend and 
    // other additional material properties, which should not be affected.
    sampleVar.xyz *= DiffuseColor;

#ifdef EVA_RGBA_BLEND
    // Color overwrites always the material color below it
    [unroll] for (int i = 0; i < EVA_RGBA_BLEND_CHANNEL_COUNT; ++i)
        sampleVar = lerp(sampleVar, DiffuseTextures[i].Sample(SurfaceSampler, blendChannelTextureCoordinates[i]) * float4(RgbaBlendDiffuseColor_UVTileMultiplier[i].xyz, 1.f), blendWeights[i]);
#endif

#ifdef EVA_TEXTURE_DETAIL
#ifdef EVA_TEXTURE_BLENDING
    float3 normalAndDiffuse0 = NormalAndDiffuseDetailTexture.Sample(SurfaceSampler, texCoord * DiffuseAndNormalWeightsAndTiling.z);
    float3 normalAndDiffuse1 = NormalAndDiffuseDetailTexture1.Sample(SurfaceSampler, input.TexCoords.zw * DiffuseAndNormalWeightsAndTiling.z);
    float3 normalAndDiffuse = lerp(normalAndDiffuse0, normalAndDiffuse1, input.Color_BlendFactor.w);
#else
    float3 normalAndDiffuse = NormalAndDiffuseDetailTexture.Sample(SurfaceSampler, texCoord * DiffuseAndNormalWeightsAndTiling.z);
#endif
    sampleVar = lerp(sampleVar, sampleVar * normalAndDiffuse.z, DiffuseAndNormalWeightsAndTiling.x * detailFade);
#endif

    return sampleVar;
}

float2 Material_Attributes(float2 texCoord, float4 blendWeights, float4x2 blendChannelTextureCoordinates)
{
    float2 sampleVar = AttributeTexture.Sample(SurfaceSampler, texCoord);

#ifdef EVA_RGBA_BLEND
    int i = 0;
    // Overwrite mode; combine attributes based on weight
    [unroll] for (; i < EVA_RGBA_BLEND_LERP_NORMALS_COUNT; ++i) {
        sampleVar = lerp(sampleVar, AttributeTextures[i].Sample(SurfaceSampler, blendChannelTextureCoordinates[i]), blendWeights[i]);
    }

#if EVA_RGBA_BLEND_LERP_NORMALS_COUNT != EVA_RGBA_BLEND_CHANNEL_COUNT
    // Overpaint mode: base cavity multiplied by total paint cavity, roughess lerped
    // TODO: can this be optimized without detoriorating blend quality?
    float total_cavity = 0.f;
    float total_blendweights = 0.f;
	 [unroll]
     for (; i < EVA_RGBA_BLEND_CHANNEL_COUNT; ++i) {
        float2 attributes = AttributeTextures[i].Sample(SurfaceSampler, blendChannelTextureCoordinates[i]);
        total_blendweights += blendWeights[i];
        total_cavity += attributes.g * blendWeights[i];
        sampleVar.x = lerp(sampleVar.x, attributes.x, blendWeights[i]);
    }

    // If sum(blendWeights) = 1, total cavity is "base cavity * (weighted sum of layered cavities)".
    // However, many times blendweights don't sum to 1 (eg. if layers have "holes", which means
    // that base material should show trough). Mixing 1.f (no cavity) with the total cavity
    // produces the correct visual result.
    sampleVar.y *= lerp(1.f, total_cavity, min(1.f, total_blendweights));
#endif
#endif

    return sampleVar;
}

float3 Material_NormalInWorld(float3 normalInView)
{
    // No scaling allowed in camera matrix
    return mul((float3x3)ViewConstants.ViewToWorldMatrix, normalInView);
}

// "Unity normal blending"; from http://blog.selfshadow.com/publications/blending-in-detail/
// Transforms detail normal (n2) into tangent space of n1
float3 BlendNormals(float3 n1, float3 n2, float weight)
{
    n2 = normalize(float3(n2.xy*weight, n2.z));

    float3 r;
    r.x = dot(n1.zxx, n2.xyz);
    r.y = dot(n1.yzy, n2.xyz);
    r.z = dot(float3(-n1.xy, n1.z), n2.xyz);
    return normalize(r);
}

//#define EVA_PS_TANGENTS

// Returns surface normal in view space.
float3 Material_NormalInView(PixelInput input, float2 texCoord, float detailFade, float4 blendWeights, float4x2 blendChannelTextureCoordinates)
{
#ifdef EVA_TEXTURE_BLENDING
    float3 normalInTangent0 = UnpackNormal(NormalTexture, SurfaceSampler, input.TexCoords.xy);
    float3 normalInTangent1 = UnpackNormal(NormalTexture1, SurfaceSampler, input.TexCoords.zw);
    float3 normalInTangent = lerp(normalInTangent0, normalInTangent1, input.Color_BlendFactor.w);
#else
    float3 normalInTangent = UnpackNormal(NormalTexture, SurfaceSampler, texCoord);
#endif
        
#ifdef EVA_RGBA_BLEND
    int i = 0;
    [unroll] for (; i < EVA_RGBA_BLEND_LERP_NORMALS_COUNT; ++i) {
        normalInTangent = lerp(normalInTangent, UnpackNormal(NormalTextures[i], SurfaceSampler, blendChannelTextureCoordinates[i]), blendWeights[i]);
    }

    // rest of the normals are blended in detail mode
	 [unroll]
   for (; i < EVA_RGBA_BLEND_CHANNEL_COUNT; ++i) {
        normalInTangent = BlendNormals(normalInTangent, UnpackNormal(NormalTextures[i], SurfaceSampler, blendChannelTextureCoordinates[i]), blendWeights[i]);
    }
#endif

#ifdef EVA_TEXTURE_DETAIL
#ifdef EVA_TEXTURE_BLENDING
    float2 dxy0 = UnpackUNorm8ToSNorm8(
        NormalAndDiffuseDetailTexture.Sample(SurfaceSampler, input.TexCoords.xy * DiffuseAndNormalWeightsAndTiling.w).xy);
    float2 dxy1 = UnpackUNorm8ToSNorm8(
        NormalAndDiffuseDetailTexture1.Sample(SurfaceSampler, input.TexCoords.zw * DiffuseAndNormalWeightsAndTiling.w).xy);
    float3 detailNormal0 = float3(dxy0, sqrt(1 - clamp(dot(dxy0, dxy0), 0.0, 1.0)));
    float3 detailNormal1 = float3(dxy1, sqrt(1 - clamp(dot(dxy1, dxy1), 0.0, 1.0)));
    float3 detailNormal = normalize(lerp(detailNormal0, detailNormal1, input.Color_BlendFactor.w));
#else
    float2 dxy = UnpackUNorm8ToSNorm8(
        NormalAndDiffuseDetailTexture.Sample(SurfaceSampler, texCoord * DiffuseAndNormalWeightsAndTiling.w).xy);
        
    float3 detailNormal = float3(dxy, sqrt(1 - clamp(dot(dxy, dxy), 0.0, 1.0)));
#endif
    normalInTangent = BlendNormals(normalInTangent, detailNormal, DiffuseAndNormalWeightsAndTiling.y * detailFade);
#endif

#ifndef EVA_PS_TANGENTS
    float3x3 tangentToViewMatrix = float3x3(
        normalize(input.TangentInView),
        normalize(input.BitangentInView),
        normalize(input.NormalInView));
        
    float3 normalInView = mul(normalInTangent, tangentToViewMatrix);
#else
    // texture coordinates are (s,t)
    // screen coordinates are (x,y)
    float2 dst_dx = ddx(texCoord.xy);
    float2 dst_dy = ddy(texCoord.xy);
    float3 dS_dx = ddx(input.Position.xyz);
    float3 dS_dy = ddy(input.Position.xyz);
    
    float det = dst_dx.x*dst_dy.y - dst_dx.y*dst_dy.x;
    float invDet = 1.f/det;
    // we don't really need to divide by det, vectors are normalized anyway
    float2 dxy_ds = float2(dst_dy.y, -dst_dy.x) * invDet;
    float2 dxy_dt = float2(-dst_dx.y, dst_dx.x) * invDet;
    
    float3 dS_ds = dS_dx * dxy_ds.x + dS_dy * dxy_ds.y;
    float3 dS_dt = dS_dx * dxy_dt.x + dS_dy * dxy_dt.y;
    float3 n = normalize(input.NormalInView);
    dS_ds -= n * dot(dS_ds, n);
    dS_dt -= n * dot(dS_dt, n);
    if(dot(cross(dS_ds, dS_dt), n) < 0)
    {
        //dS_dt = cross(n, dS_ds);
        //dS_dt = -dS_dt;
        //dS_dt = reflect(-dS_dt, normalize(dS_ds));
        //dS_ds = -dS_ds;
        //dS_ds = reflect(-dS_ds, normalize(dS_dt));
        float3 tmp = dS_ds;
        dS_ds = -dS_dt;
        dS_dt = -tmp;
    }
#if 1
    float3 normalInView = det == 0.f ? n : (n * normalInTangent.z
                        + normalize(cross(n, dS_ds)) * normalInTangent.y
                        + normalize(cross(dS_dt, n)) * normalInTangent.x);
#else
    normalInTangent /= max(normalInTangent.z, 1e-6f);
    float3 normalInView = det == 0.f ? n : (cross(dS_ds, dS_dt)
                        + cross(n, dS_ds) * normalInTangent.y
                        + cross(dS_dt, n) * normalInTangent.x);
#endif
#endif

#ifdef EVA_DOUBLE_SIDED_SURFACE_SHADING
    normalInView = input.IsFrontFace ? normalInView : -normalInView;
#endif
    return normalize(normalInView);
}

float Luminance__(float3 rgb)
{
    float3 luminance_weights = float3(0.2126, 0.7152, 0.0722);
    return dot(luminance_weights, rgb);
}

void ApplySurfaceShading(
    PixelInput input,
    uint coverage,
    inout PixelOutput output,
    out float3 normalInView)
{
#ifdef EVA_TEXTURE_DETAIL
    float detailFade = saturate(1.0 - (length(input.EyeDirectionInView) - FadeOutStartAndLength.x) / FadeOutStartAndLength.y);
#else
    float detailFade = 1;
#endif

    float2 texCoord;

#if defined(EVA_RGBA_BLEND_EXTRA_UVS) || defined(EVA_TEXTURE_BLENDING)
    texCoord = input.TexCoords.xy;
#else
    texCoord = input.TexCoord;
#endif

#ifdef EVA_RGBA_BLEND
    float2 blendTextureCoordinateInput;

    #ifdef EVA_RGBA_BLEND_EXTRA_UVS 
        blendTextureCoordinateInput = input.TexCoords.zw; 
    #else
        blendTextureCoordinateInput = input.TexCoord.xy;
    #endif

    float4 blendWeights = BlendMap.Sample(SurfaceSampler, blendTextureCoordinateInput);
    float4x2 blendChannelTextureCoordinates;

    [unroll] for (int i = 0; i < EVA_RGBA_BLEND_CHANNEL_COUNT; ++i)
        blendChannelTextureCoordinates[i] = blendTextureCoordinateInput * RgbaBlendDiffuseColor_UVTileMultiplier[i].w + RgbaBlendUVOffset[i].xy;
#else
    float4 blendWeights = (float4)0.;
    float4x2 blendChannelTextureCoordinates = (float4x2)0.;
#endif

    normalInView = Material_NormalInView(input, texCoord, detailFade, blendWeights, blendChannelTextureCoordinates);
 
    float4 albedo = Material_Diffuse_and_Metalness(input, texCoord, detailFade, blendWeights, blendChannelTextureCoordinates);
    float2 materialAttributes = Material_Attributes(texCoord, blendWeights, blendChannelTextureCoordinates);

    output.Normal.xyz = normalInView * 0.5 + 0.5;
        
    output.Albedo.xyz = albedo.xyz;
    output.Albedo.w = 1 - materialAttributes.x;
    
    float3 normalInWorld = Material_NormalInWorld(normalInView);

    output.Attribute.x = materialAttributes.y;
    output.Attribute.y = AmbientOcclusionTexture.Sample(SurfaceSampler, texCoord);
    output.Attribute.z = albedo.w;
}

#endif // EVA_SURFACE_SHADING

#if defined(EVA_NO_SURFACE_SHADING) && !defined(EVA_DEPTH_ONLY)
// Inputs:
// float3 NormalInView : NormalInView;
//
// Outputs:
// float3 Normal : SV_Target0;
// float3 Diffuse : SV_Target1;
// float4 Specular : SV_Target2;
//
// Constants:
// uint FullCoverage;
//
// Notes:
// input coverage is provided from ApplyAlphaTestClipping function.
//
void ApplySurfaceShading(
    PixelInput input,
    uint coverage,
    inout PixelOutput output,
    out float3 normalInView)
{
    normalInView = input.NormalInView;
    output.Normal.xyz = normalInView * 0.5 + 0.5;
    // Is this used?
    //output.Normal.w = (coverage != FullCoverage);
}
#endif // EVA_NO_SURFACE_SHADING && !EVA_DEPTH_ONLY

#if defined(EVA_NO_SURFACE_SHADING) && defined(EVA_DEPTH_ONLY)
// Depth only, propably with alpha testing, so empty function.
void ApplySurfaceShading(
    PixelInput input,
    uint coverage,
    inout PixelOutput output,
    out float3 normalInView)
{
    normalInView = 0;
}
#endif // EVA_NO_SURFACE_SHADING && EVA_DEPTH_ONLY


#ifdef EVA_GLASS_SURFACE_SHADING
DM_GFX_VK_BINDING(1, 3)
Texture2D<float4> DiffuseTexture : register(EVA_REGISTER_SRV_MATERIAL_DIFFUSE);
DM_GFX_VK_BINDING(2, 3)
Texture2D<float2> AttributeTexture : register(EVA_REGISTER_SRV_MATERIAL_SURFACE_ATTRIBUTES);
DM_GFX_VK_BINDING(3, 3)
Texture2D<float2> NormalTexture : register(EVA_REGISTER_SRV_MATERIAL_NORMAL);

#ifndef EVA_ALPHA_TEST
DM_GFX_VK_BINDING(6, 3)
Texture2D<float> AlphaTexture : register(EVA_REGISTER_SRV_MATERIAL_ALPHA);
#endif

// Culling data
DM_GFX_VK_BINDING(1, 1)
Buffer<uint> TiledCullingConstantsAndOmniBuffer : register(t0, EVA_REGISTER_SPACE_ILLUMINATION);
// Buffer<uint> TiledCullingUnshadowedFrustumBuffer: register(t1, EVA_REGISTER_SPACE_ILLUMINATION);
// Buffer<uint> TiledCullingShadowedFrustumBuffer: register(t2, EVA_REGISTER_SPACE_ILLUMINATION);
DM_GFX_VK_BINDING(4, 1)
Buffer<uint> TiledCullingReflectionCapturerBuffer : register(t3, EVA_REGISTER_SPACE_ILLUMINATION);

// Reflection capturer data
DM_GFX_VK_BINDING(5, 1)
StructuredBuffer<PackedReflectionCapturerData> ReflectionCapturerBuffer : register(t4, EVA_REGISTER_SPACE_ILLUMINATION);
DM_GFX_VK_BINDING(6, 1)
TextureCube<float4> ReflectionCapturerCubes[64] : register(t5, EVA_REGISTER_SPACE_ILLUMINATION);

// Head for link
DM_GFX_VK_BINDING(17, 1)
RWByteAddressBuffer ABufferFragmentBufferCounter : register(u0);
DM_GFX_VK_BINDING(18, 1)
RWStructuredBuffer<ABufferFragment> ABufferFragmentBuffer : register(u1);
DM_GFX_VK_BINDING(19, 1)
RWByteAddressBuffer ABufferHeadPointerBuffer : register(u2);

void LoadSurfaceAttributes(out SurfaceAttributes surface, PixelInput input, float3 position, float2 texCoord, float depth)
{
    surface.Depth = depth;
    
    float4 PositionInViewH = mul(GetTargetToViewMatrix(ViewConstants), float4(position.xy, depth, 1));
    surface.PositionInView = input.PositionInView;//PositionInViewH.xyz / PositionInViewH.w;

    float3x3 tangentToViewMatrix = transpose(float3x3(
        normalize(input.TangentInView), 
        normalize(input.BitangentInView),
        normalize(input.NormalInView)));
        
    float3 normalInView = mul(tangentToViewMatrix, UnpackNormal(NormalTexture, SurfaceSampler, texCoord));

    surface.Normal = normalize(normalInView);
    float2 attributes = AttributeTexture.Sample(SurfaceSampler, texCoord);
    surface.Roughness = 1. - attributes.r;
}

void ApplySurfaceShading(
    PixelInput input,
    uint coverage,
    inout PixelOutput output,
    out float3 normalInView)
{
    float alpha = AlphaTexture.Sample(SurfaceSampler, input.TexCoord.xy) * Transparency;

    if (alpha >= (1.0 / 255.f))
    {
        uint2 positionInTarget = input.Position.xy;
        // TODO: don't use hardcoded values
        uint2 tileIndex = uint2(positionInTarget.x / 16, positionInTarget.y / 16);
        uint flattenedTileIndex = tileIndex.x + (uint)ceil(ViewConstants.TargetSize.x / 16)  * tileIndex.y;

        SurfaceAttributes surface;
        LoadSurfaceAttributes(surface, input, input.Position.xyz, input.TexCoord.xy, input.Position.z / input.Position.w);

        float3 AccumulatedReflection = AccumulateReflections(flattenedTileIndex, ViewConstants.ViewToWorldMatrix, 
            surface, SurfaceSampler,
            TiledCullingConstantsAndOmniBuffer, TiledCullingReflectionCapturerBuffer,
            ReflectionCapturerCubes, ReflectionCapturerBuffer
        );

        float3 eyeDirectionInView = normalize(surface.PositionInView);
        // Glass should reflect about 4% of light when viewed directly
        float3 Rf0_0 = float3(0.041869f, 0.042680f, 0.042998f);
        // combined reflectance (without interference)
        float3 Rf0 = 2.0f * Rf0_0 / (1.0f + Rf0_0);
        float n_dot_v = abs(dot(surface.Normal.xyz, eyeDirectionInView));
        // Fresnel for reflection intensity
        float3 reflectionIntensity = Rf0 + (1.0 - Rf0) * pow(1.0 - n_dot_v, 5.0);
    
        // Depending on the surface angle reduce transmitting light
        float3 multi_alpha = min(1, alpha + reflectionIntensity);

        // Rough surfaces scatter more light even when viewed directly
        float3 diffuseColor = AccumulatedReflection * GlassReflectionIntensity * min(1, reflectionIntensity + surface.Roughness); 

        // NOTE: A-buffer uses premultiplied alpha, so multiply color with alpha to get the correct blending
        ABufferFragment fragment = PackABufferFragment(diffuseColor * multi_alpha, dot(multi_alpha, float3(0.2126f, 0.7152f, 0.0722f)), input.Position.z);
        StoreABufferFragment(positionInTarget, ViewConstants.TargetSize.x, fragment, ABufferFragmentBufferCounter, ABufferFragmentBuffer, ABufferHeadPointerBuffer);

        normalInView = input.NormalInView * 0.5 + 0.5;
    }
}
#endif // EVA_GLASS_SURFACE_SHADING

#ifdef EVA_TRANPARENCY_SURFACE_SHADING

Texture2D<float4> DiffuseTexture : register(EVA_REGISTER_SRV_MATERIAL_DIFFUSE);
Texture2D<float2> AttributeTexture : register(EVA_REGISTER_SRV_MATERIAL_SURFACE_ATTRIBUTES);
Texture2D<float2> NormalTexture : register(EVA_REGISTER_SRV_MATERIAL_NORMAL);
Texture2D<float> AlphaTexture : register(EVA_REGISTER_SRV_MATERIAL_ALPHA);

// Head for link
DM_GFX_VK_BINDING(17, 1)
RWByteAddressBuffer ABufferFragmentBufferCounter : register(u0);
DM_GFX_VK_BINDING(18, 1)
RWStructuredBuffer<ABufferFragment> ABufferFragmentBuffer : register(u1);
DM_GFX_VK_BINDING(19, 1)
RWByteAddressBuffer ABufferHeadPointerBuffer : register(u2);

void ApplySurfaceShading(
    PixelInput input,
    uint coverage,
    inout PixelOutput output,
    out float3 normalInView)
{
    float alpha = AlphaTexture.Sample(SurfaceSampler, input.TexCoord.xy) * Transparency;
    uint2 positionInTarget = input.Position.xy; 
    float3 diffuseColor = DiffuseTexture.Sample(SurfaceSampler, input.TexCoord.xy).xyz * DiffuseColor;
    
    // NOTE: A-buffer uses premultiplied alpha, so multiply color with alpha to get the correct blending
    ABufferFragment fragment = PackABufferFragment(diffuseColor * alpha, alpha, input.Position.z);
    StoreABufferFragment(positionInTarget, ViewConstants.TargetSize.x, fragment, ABufferFragmentBuffer, ABufferHeadPointerBuffer);
    
    normalInView =  input.NormalInView * 0.5 + 0.5;
}

#endif // EVA_TRANPARENCY_SURFACE_SHADING

#endif // EVA_GEOMETRY_MATERIAL_SURFACE_SHADING_HLSL

void PS(PixelInput input, out PixelOutput output)
{

#line 12 "materials.xml"

output = (PixelOutput)0;

// UV Animation
EvaluateUVAnimation(input);

// Alpha test
uint coverage;
ApplyAlphaTestClipping(input, output, coverage);

// Surface Shading
float3 normalInView;
ApplySurfaceShading(input, coverage, output, normalInView);

// Velocity
//ApplyVelocity(input, output);

// Luminance
ApplyLuminance(input, normalInView, output);

}

