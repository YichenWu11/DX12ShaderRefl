cbuffer GlobalConstants : register(b0)
{
    // float16_t2 v1;
    float2 v1;
    float3 v2;
    float  v3;
    int    v4;
}

float globalVal;

struct PSInput
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
};

PSInput VSMain(float4 position : POSITION, float4 color : COLOR)
{
    PSInput result;

    result.position = position;
    result.color = color;

    return result;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    return input.color * v1.x;
}
