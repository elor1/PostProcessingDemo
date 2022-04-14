#include "Common.hlsli"

Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0);

float4 main(PostProcessingInput input) : SV_Target
{
	/*float2 texelSize = float2(1.0f / 1920.0f, 1.0f / 1080.0f);
	float2 direction = texelSize * (gHorizontalBlur ? float2(1.0f, 0.0f) : float2(0.0f, 1.0f));
	float blurSize = 10.0f;

	float kernel = 0.12f * blurSize;
	float4 colour = SceneTexture.Sample(PointSample, input.sceneUV) * kernel;
	float total = kernel;
	for (int i = 0; i < 2; i++)
	{
		for (int j = 1; j < blurSize; j++)
		{
			kernel = smoothstep(0.0033f, 0.0033f + blurSize, 0.0033f + blurSize - j);
			float2 offset = direction * j;
			colour += SceneTexture.Sample(PointSample, input.sceneUV + offset) * kernel;
			total += kernel;
		}

		direction = -direction;
	}*/

	float2 texelSize = float2(1.0f / 1920.0f, 1.0f / 1080.0f);
	float2 direction = float2(0.0f, 1.0f);
	if (gHorizontalBlur)
	{
		direction = float2(1.0f, 0.0f);
	}

	const int stepCount = 9;

	float weights[stepCount];
	weights[0] = 0.10855;
	weights[1] = 0.13135;
	weights[2] = 0.10406;
	weights[3] = 0.07216;
	weights[4] = 0.04380;
	weights[5] = 0.02328;
	weights[6] = 0.01083;
	weights[7] = 0.00441;
	weights[8] = 0.00157;

	float offsets[stepCount];
	offsets[0] = 0.66293;
	offsets[1] = 2.47904;
	offsets[2] = 4.46232;
	offsets[3] = 6.44568;
	offsets[4] = 8.42917;
	offsets[5] = 10.41281;
	offsets[6] = 12.39664;
	offsets[7] = 14.38070;
	offsets[8] = 16.36501;

	float4 colour;
	for (int i = 0; i < stepCount; i++)
	{
		float2 uvOffset = offsets[i] * texelSize;
		float4 col = SceneTexture.Sample(PointSample, input.sceneUV + uvOffset) + SceneTexture.Sample(PointSample, input.sceneUV - uvOffset);
		col *= weights[i];

		colour += col;
	}

	// Calculate alpha to display the effect in a softened circle, could use a texture rather than calculations for the same task.
	// Uses the second set of area texture coordinates, which range from (0,0) to (1,1) over the area being processed
	float softEdge = 0.10f; // Softness of the edge of the circle - range 0.001 (hard edge) to 0.25 (very soft)
	float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
	float centreLengthSq = dot(centreVector, centreVector);
	float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge); // Soft circle calculation based on fact that this circle has a radius of 0.5 (as area UVs go from 0->1)

	colour.a = alpha;
	return colour;
}