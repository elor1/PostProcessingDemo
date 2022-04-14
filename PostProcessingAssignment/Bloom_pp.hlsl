#include "Common.hlsli"

Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0);

float4 main(PostProcessingInput input) : SV_Target
{
	float blurSize = 1.0f / 512.0f;
	float intensity = 0.35f;
	float3 sum = float3(0, 0, 0);

	float2 uv = input.sceneUV / float2(1920, 1080);

	sum += SceneTexture.Sample(PointSample, float2(uv.x - 4.0f * blurSize, uv.y)).rgb * 0.05f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x - 3.0f * blurSize, uv.y)).rgb * 0.09f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x - 2.0f * blurSize, uv.y)).rgb * 0.12f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x - blurSize, uv.y)).rgb * 0.15f;
	sum += SceneTexture.Sample(PointSample, uv).rgb * 0.16f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x + blurSize, uv.y)).rgb * 0.15f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x + 2.0f * blurSize, uv.y)).rgb * 0.12f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x + 3.0f * blurSize, uv.y)).rgb * 0.09f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x + 4.0f * blurSize, uv.y)).rgb * 0.05f;

	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y - 4.0f * blurSize)).rgb * 0.05f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y - 3.0f * blurSize)).rgb * 0.09f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y - 2.0f * blurSize)).rgb * 0.12f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y - blurSize)).rgb * 0.15f;
	sum += SceneTexture.Sample(PointSample, uv).rgb * 0.16f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y + blurSize)).rgb * 0.15f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y + 2.0f * blurSize)).rgb * 0.12f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y + 3.0f * blurSize)).rgb * 0.09f;
	sum += SceneTexture.Sample(PointSample, float2(uv.x, uv.y + 4.0f * blurSize)).rgb * 0.05f;

	float3 colour = sum * intensity + SceneTexture.Sample(PointSample, uv).rgb;

	// Calculate alpha to display the effect in a softened circle, could use a texture rather than calculations for the same task.
	// Uses the second set of area texture coordinates, which range from (0,0) to (1,1) over the area being processed
	float softEdge = 0.10f; // Softness of the edge of the circle - range 0.001 (hard edge) to 0.25 (very soft)
	float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
	float centreLengthSq = dot(centreVector, centreVector);
	float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge); // Soft circle calculation based on fact that this circle has a radius of 0.5 (as area UVs go from 0->1)

	// Got the RGB from the scene texture
	return float4(colour, alpha);
}