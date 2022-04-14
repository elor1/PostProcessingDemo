#include "Common.hlsli"

Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0);

float4 main(PostProcessingInput input) : SV_Target
{
	float2 pixelSize = float2(144.0f, 81.0f);
	float3 colourDepth = float3(32.0f, 64.0f, 32.0f);

	float2 uv = floor(input.sceneUV * pixelSize) / pixelSize;
	float3 colour = SceneTexture.Sample(PointSample, uv).rgb;
	colour = floor(colour * colourDepth) / colourDepth;

	// Got the RGB from the scene texture
	return float4(colour, 1.0f);
}