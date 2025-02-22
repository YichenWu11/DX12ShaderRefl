#define DM_GFX_HLSL_SPIRV

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
#define EVA_SAMPLE_COUNT 1
#define EVA_DIRECTION_COUNT 4
#define EVA_STEP_COUNT 3
#define TILE_SIZE 16
#define USE_INTERLEAVED_SAMPLING 1
#define EVA_REGISTER_SPACE_GBUFFER space0
#define EVA_REGISTER_SPACE_AMBIENT_OCCLUSION space1
#line 2 "horizon_based_ambient_occlution_cs.hlsl"

#define PI 3.1415926535897932384626433832795
#define FILTER_INV_SIGMA_SQR 100.0  // (1.0 / 0.1)^2
#define FILTER_LAMBDA 0.4


DM_GFX_VK_BINDING(0, 0)
Texture2D<float3> NormalTexture : register(t1, EVA_REGISTER_SPACE_GBUFFER);

DM_GFX_VK_BINDING(1, 0)
Texture2D<float> AmbientOcclusionDepthTexture : register(t0, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);
DM_GFX_VK_BINDING(2, 0)
Texture2D<float> RandomOffsetTexture : register(t1, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);

DM_GFX_VK_BINDING(0, 1)
Texture2D<float> AmbientOcclusionTexture : register(t2, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);
DM_GFX_VK_BINDING(1, 1)
RWTexture2D<float> AmbientOcclusionTextureOutput : register(u0, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);

struct SSAOConstantsStruct {
    float2 ZProjection;
    float2 pad;

    float3 FarPlaneTopLeftCornerInView;
    float Strength;

    float2 FarPlaneDiagonalInView;
    float RadiusInView;
    float RadiusInViewSquared;

    uint2 TileSize;
    float2 rTextureSize;

    uint4 TextureSize;
};

DM_GFX_VK_BINDING(6, 0)
ConstantBuffer<SSAOConstantsStruct> SSAOConstants : register(b0, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);

DM_GFX_VK_BINDING(5, 0)
SamplerState BilinearSampler : register(s0, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);

float LengthSquared(float3 x)
{
    return dot(x, x);
}

float DistanceSquared(float3 a, float3 b)
{
    return LengthSquared(b - a);
}

float Sqr(float x)
{
    return x * x;
}

float4 Sqr(float4 x)
{
    return x * x;
}

float DepthInView(float depthInClip)
{
    return SSAOConstants.ZProjection.y / (depthInClip + SSAOConstants.ZProjection.x);
}

float4 DepthInView(float4 depthInClip)
{
    return SSAOConstants.ZProjection.yyyy / (depthInClip + SSAOConstants.ZProjection.xxxx);
}

// With Vulkan this is in hbao_halvedepth_vs_ps.hlsl
#ifndef DM_GFX_HLSL_SPIRV
Texture2D<float> DepthTexture : register(t0, EVA_REGISTER_SPACE_GBUFFER);
SamplerState PointSampler : register(s1, EVA_REGISTER_SPACE_AMBIENT_OCCLUSION);

void HalveDepthVS(
    uint vertexIndex : SV_VertexID,
    out float4 position : SV_Position,
    out float2 texCoord : TexCoord)
{
    position = float4(
        4.0 * (vertexIndex & 1) - 1.0,
        1.0 - 2.0 * (vertexIndex & 2), 0.0, 1.0);

    texCoord = float2(2.0 * (vertexIndex & 1), vertexIndex & 2);
}

void HalveDepthPS(
    float4 position : SV_Position,
    float2 texCoord : TexCoord,
    out float normalizedDepthInView : SV_Target,
    out float maxDepth : SV_Depth)
{
    float4 depths = DepthTexture.GatherRed(PointSampler, texCoord, int2(0, 0));
    float depthInView = dot(DepthInView(depths), float4(.25f,.25f,.25f,.25f));

    normalizedDepthInView = depthInView / SSAOConstants.FarPlaneTopLeftCornerInView.z;

    depths.xy = max(depths.xy, depths.zw);
    maxDepth = max(depths.x, depths.y);
}

#endif


float3 PositionInView(float depthInView, float2 texCoord)
{
    float3 viewRayInView = SSAOConstants.FarPlaneTopLeftCornerInView;
    viewRayInView.xy += texCoord * SSAOConstants.FarPlaneDiagonalInView;
    return depthInView * viewRayInView;
}

[numthreads(TILE_SIZE,TILE_SIZE,1)]
void HBAOCS(uint2 globalThread : SV_DispatchThreadID)
{
    [branch] if(any(globalThread >= SSAOConstants.TextureSize.xy))
        return;

    int2 p = (int2)globalThread;
    float output = 0;

    uint2 bin = p / SSAOConstants.TileSize; // TODO:

    p = (p % SSAOConstants.TileSize) * 4 + bin;
    float2 texCoord = (p + float2(0.5, 0.5)) * SSAOConstants.rTextureSize;

    float centerDepth = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, texCoord, 0);
    float3 centerNormal = normalize(NormalTexture[p] * 2 - 1);

    float3 centerPositionInView = PositionInView(centerDepth, texCoord);
    centerPositionInView.z += 0.1;

    const float radiusInViewSquared = SSAOConstants.RadiusInViewSquared;
    float2 radiusInTexture = min(0.1, SSAOConstants.RadiusInView / (centerDepth * SSAOConstants.FarPlaneDiagonalInView));

    float directionOffset = RandomOffsetTexture[p & 3];
    float stepOffset = RandomOffsetTexture[p & 3 ^ 3];

    const float radiusInViewSquaredRcp = 1.0f / radiusInViewSquared;
    output = 0;

    // Assume EVA_DIRECTION_COUNT is always >= 4 and < 8
    {
        float4 angles;
        angles.x = (directionOffset + 0) * ((2 * PI) / EVA_DIRECTION_COUNT);
        angles.y = (directionOffset + 1) * ((2 * PI) / EVA_DIRECTION_COUNT);
        angles.z = (directionOffset + 2) * ((2 * PI) / EVA_DIRECTION_COUNT);
        angles.w = (directionOffset + 3) * ((2 * PI) / EVA_DIRECTION_COUNT);

        float2 deltas[4];
        deltas[0] = float2(cos(angles.x), sin(angles.x)) * radiusInTexture;
        deltas[1] = float2(cos(angles.y), sin(angles.y)) * radiusInTexture;
        deltas[2] = float2(cos(angles.z), sin(angles.z)) * radiusInTexture;
        deltas[3] = float2(cos(angles.w), sin(angles.w)) * radiusInTexture;

        float4 cosHorizonAngles = 0;

        [unroll]
        for(int j = 0; j < EVA_STEP_COUNT; ++j)
        {
            const float t = Sqr((j + stepOffset) / EVA_STEP_COUNT);
            float2 offsets[4];
            offsets[0] = deltas[0] * t;
            offsets[1] = deltas[1] * t;
            offsets[2] = deltas[2] * t;
            offsets[3] = deltas[3] * t;

            float2 samplePositionsInTexture[4];
            samplePositionsInTexture[0] = texCoord + offsets[0];
            samplePositionsInTexture[1] = texCoord + offsets[1];
            samplePositionsInTexture[2] = texCoord + offsets[2];
            samplePositionsInTexture[3] = texCoord + offsets[3];

            float4 sampleDepths;
            sampleDepths.x = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, samplePositionsInTexture[0], 0);
            sampleDepths.y = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, samplePositionsInTexture[1], 0);
            sampleDepths.z = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, samplePositionsInTexture[2], 0);
            sampleDepths.w = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, samplePositionsInTexture[3], 0);

            float4 samplePositionInTextureXs = float4(
                samplePositionsInTexture[0].x, samplePositionsInTexture[1].x,
                samplePositionsInTexture[2].x, samplePositionsInTexture[3].x);

            float4 samplePositionInTextureYs = float4(
                samplePositionsInTexture[0].y, samplePositionsInTexture[1].y,
                samplePositionsInTexture[2].y, samplePositionsInTexture[3].y);

            const float4 samplePositionInViewXs
                = sampleDepths * (SSAOConstants.FarPlaneDiagonalInView.x * samplePositionInTextureXs + SSAOConstants.FarPlaneTopLeftCornerInView.x);

            const float4 samplePositionInViewYs
                = sampleDepths * (SSAOConstants.FarPlaneDiagonalInView.y * samplePositionInTextureYs + SSAOConstants.FarPlaneTopLeftCornerInView.y);

            const float4 samplePositionInViewZs = sampleDepths * SSAOConstants.FarPlaneTopLeftCornerInView.z;

            const float4 deltaInViewXs = samplePositionInViewXs - centerPositionInView.x;
            const float4 deltaInViewYs = samplePositionInViewYs - centerPositionInView.y;
            const float4 deltaInViewZs = samplePositionInViewZs - centerPositionInView.z;

            const float4 lengthsInViewSquared = Sqr(deltaInViewXs) + Sqr(deltaInViewYs) + Sqr(deltaInViewZs);
            float4 flags = lengthsInViewSquared < radiusInViewSquared.xxxx ? 1.0f : 0.0f;

            float4 normalizedDistanceSquared = lengthsInViewSquared * radiusInViewSquaredRcp;
            float4 weights = flags * (1 - normalizedDistanceSquared);

            float4 directionInViewXs = deltaInViewXs * rsqrt(lengthsInViewSquared);
            float4 directionInViewYs = deltaInViewYs * rsqrt(lengthsInViewSquared);
            float4 directionInViewZs = deltaInViewZs * rsqrt(lengthsInViewSquared);
            float4 cosAngles = directionInViewXs * centerNormal.x + directionInViewYs * centerNormal.y + directionInViewZs * centerNormal.z;
            float4 deltaOutputs = saturate(cosAngles - cosHorizonAngles);

            output += dot(deltaOutputs, weights);
            cosHorizonAngles = weights > 0.0f ? max(cosHorizonAngles, cosAngles) : cosHorizonAngles;
        }
    }

    [unroll]
    for(int i = 4; i < EVA_DIRECTION_COUNT; ++i)
    {
        const float angle = (directionOffset + i) * ((2 * PI) / EVA_DIRECTION_COUNT);
        const float2 delta = float2(cos(angle), sin(angle)) * radiusInTexture;

        float cosHorizonAngle = 0;

        [unroll]
        for(int j = 0; j < EVA_STEP_COUNT; ++j)
        {
            const float t = Sqr((j + stepOffset) / EVA_STEP_COUNT);
            const float2 offset = delta * t;

            const float2 samplePositionInTexture = texCoord + offset;
            const float sampleDepth = AmbientOcclusionDepthTexture.SampleLevel(BilinearSampler, samplePositionInTexture, 0);

            const float3 samplePositionInView = PositionInView(sampleDepth, samplePositionInTexture);
            const float3 deltaInView = samplePositionInView - centerPositionInView;
            const float lengthInViewSquared = LengthSquared(deltaInView);

            [flatten] if(lengthInViewSquared < radiusInViewSquared)
            {
                float normalizedDistanceSquared = lengthInViewSquared * radiusInViewSquaredRcp;
                float weight = 1 - normalizedDistanceSquared;
                float3 directionInView = deltaInView * rsqrt(lengthInViewSquared);
                float cosAngle = dot(directionInView, centerNormal);

                float deltaOutput = saturate(cosAngle - cosHorizonAngle);

                output += deltaOutput * weight;
                cosHorizonAngle = max(cosHorizonAngle, cosAngle);
            }
        }
    }

    output = pow(saturate(1 - output / EVA_DIRECTION_COUNT), SSAOConstants.Strength);

    AmbientOcclusionTextureOutput[p] = output;
}

[numthreads(TILE_SIZE,TILE_SIZE,1)]
void PMBlurCS(uint2 globalThread : SV_DispatchThreadID)
{
    [branch] if(any(globalThread >= SSAOConstants.TextureSize.xy))
        return;

    // gather: x=north, y=south, z=east, w=west

    // two gathers instead of four loads. cheaper.
    // /-----------------\
    // | w1  |  z1 |     |
    // |-----+-----+-----|
    // | x1  |w0,y1| z0  |
    // |-----+-----+-----|
    // |     | x0  | y0  |
    // \-----------------/
    // gather with 4 offsets translates into 3 gathers, so not that usefull
    float2 texCoord = SSAOConstants.rTextureSize * ((float2)(globalThread + 1));
    float4 neighbors0 = AmbientOcclusionTexture.GatherRed(BilinearSampler, texCoord, int2(0, 0));
    float4 neighbors1 = AmbientOcclusionTexture.GatherRed(BilinearSampler, texCoord - SSAOConstants.rTextureSize, int2(0, 0));
    float4 neighbors;
    neighbors.xz = neighbors0.xz;
    neighbors.yw = neighbors1.zx;
    float val = neighbors0.w;

    // this is an approximation (of an approximation) to div(exp(-||grad(I)||^2/K^2) * grad(I))
    // this way implementation is straightforward and very close to the actual value
    float4 deriv = neighbors - val;
    AmbientOcclusionTextureOutput[globalThread] = val + dot(exp(-deriv*deriv*FILTER_INV_SIGMA_SQR), deriv)
        * FILTER_LAMBDA;
}

#ifdef GAUSSIAN_FILTER
// requires even FILTER_TILE_SIZE to work correctly. ain't padding for odds.
// furthermore, FILTER_TILE_SIZE can't be smaller than twice FILTER_RADIUS
#define FILTER_SLM_SIZE (FILTER_TILE_SIZE + 2*FILTER_RADIUS)
groupshared float pixels[2][FILTER_SLM_SIZE];

float GaussianWeight(float sigma, float dist)
{
    return exp(-dist*dist / (2*sigma*sigma));
}

[numthreads(FILTER_TILE_SIZE,2,1)]
void GaussianBlurCS_X(uint2 globalThread : SV_DispatchThreadID,
                      uint2 localThread : SV_GroupThreadID,
                      uint2 groupId : SV_GroupID)
{
    int threadId = (int)(FILTER_TILE_SIZE * localThread.y + localThread.x);
    [branch] if(threadId < FILTER_SLM_SIZE / 2)
    {
        int2 sampleCell = (int2)groupId * int2(FILTER_TILE_SIZE, 2);
        sampleCell.x -= FILTER_RADIUS;
        sampleCell.x += threadId * 2;
        float2 texCoord = SSAOConstants.rTextureSize * ((float2)(sampleCell + 1));
        float4 samples = AmbientOcclusionTexture.GatherRed(BilinearSampler, texCoord, int2(0, 0));
        pixels[1][threadId * 2] = samples.x;
        pixels[1][threadId * 2 + 1] = samples.y;
        pixels[0][threadId * 2] = samples.w;
        pixels[0][threadId * 2 + 1] = samples.z;
    }

    GroupMemoryBarrierWithGroupSync();

    // some precomputed stuff
    float sigma = (FILTER_RADIUS + 1) / 3.0;
    float totalWeight = 0;
    int i;
    [unroll] for(i=-FILTER_RADIUS;i<=FILTER_RADIUS;i++)
        totalWeight += GaussianWeight(sigma, (float)i);

    float newPixel = 0;
    [unroll] for(i=-FILTER_RADIUS;i<=FILTER_RADIUS;i++)
        newPixel += pixels[localThread.y][localThread.x + FILTER_RADIUS + i] * GaussianWeight(sigma, (float)i);

    AmbientOcclusionTextureOutput[globalThread] = newPixel / totalWeight;
}

[numthreads(2,FILTER_TILE_SIZE,1)]
void GaussianBlurCS_Y(uint2 globalThread : SV_DispatchThreadID,
                      uint2 localThread : SV_GroupThreadID,
                      uint2 groupId : SV_GroupID)
{
    int threadId = (int)(2 * localThread.y + localThread.x);
    [branch] if(threadId < FILTER_SLM_SIZE / 2)
    {
        int2 sampleCell = (int2)groupId * int2(2, FILTER_TILE_SIZE);
        sampleCell.y -= FILTER_RADIUS;
        sampleCell.y += threadId * 2;
        float2 texCoord = SSAOConstants.rTextureSize * ((float2)(sampleCell + 1));
        float4 samples = AmbientOcclusionTexture.GatherRed(BilinearSampler, texCoord, int2(0, 0));
        pixels[1][threadId * 2] = samples.z;
        pixels[1][threadId * 2 + 1] = samples.y;
        pixels[0][threadId * 2] = samples.w;
        pixels[0][threadId * 2 + 1] = samples.x;
    }

    GroupMemoryBarrierWithGroupSync();

    // some precomputed stuff
    float sigma = (FILTER_RADIUS + 1) / 3.0;
    float totalWeight = 0;
    int i;
    [unroll] for(i=-FILTER_RADIUS;i<=FILTER_RADIUS;i++)
        totalWeight += GaussianWeight(sigma, (float)i);

    float newPixel = 0;
    [unroll] for(i=-FILTER_RADIUS;i<=FILTER_RADIUS;i++)
        newPixel += pixels[localThread.x][localThread.y + FILTER_RADIUS + i] * GaussianWeight(sigma, (float)i);

    AmbientOcclusionTextureOutput[globalThread] = newPixel / totalWeight;
}

#endif
