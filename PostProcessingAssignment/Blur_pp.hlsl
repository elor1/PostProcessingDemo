#include "Common.hlsli"

Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0);

float4 main(PostProcessingInput input) : SV_Target
{
	float4 colour;
	float v;
	const float quality = 16;

	for (float i = 0.0f; i < 1.0f; i += (1 / quality))
	{
		v = 0.9 + i * 0.1f;
		colour += SceneTexture.Sample(PointSample, input.sceneUV * v + 0.5f - 0.5f * v);
	}

	colour /= quality;

	colour.a = 0.1f;
	return colour;
}