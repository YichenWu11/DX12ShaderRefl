
Texture2DMSArray<float4, 64> ms_texture_array;

float4 main(float4  Position  : SV_POSITION):SV_TARGET0
{
  int w1,h1,e1,n1;
  ms_texture_array.GetDimensions(w1,h1,e1,n1); 
  return w1.xxxx;
}