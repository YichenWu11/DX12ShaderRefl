//Texture2D     texture_2d : register(t0, space0); // D3D_SIT_TEXTURE2D
Buffer<float2> buffer_float2 : register(t0, space0);
SamplerState  sampler_ : register(s1, space1); // D3D_SIT_SAMPLER
RWByteAddressBuffer rw_ba_buffer: register(u0);
#define TEX_COUNT 4
Texture2D     texture_2d_a[TEX_COUNT];
Texture2D     texture_2d_b[TEX_COUNT];
Buffer<float4> buffer_array[TEX_COUNT];

struct PSInput
{
	float4 color : COLOR;
	float   Alpha     : OPACITY;
	float2  TexCoord0 : TEXCOORD0;
};

float4 PSMain(PSInput input) : SV_TARGET
{
	float4 v = 0;
	
	[unroll]
	for(int i=0;i<TEX_COUNT;++i)
	{
		v += float4(texture_2d_a[i].Sample(sampler_, input.TexCoord0).xyz, input.Alpha);
		v += float4(texture_2d_b[i].Sample(sampler_, input.TexCoord0).xyz, input.Alpha);
		v += buffer_array[i][0];
	}
	
	return input.color * v;
}