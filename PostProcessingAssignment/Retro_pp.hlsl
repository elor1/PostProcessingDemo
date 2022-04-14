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

	// Calculate alpha to display the effect in a softened circle, could use a texture rather than calculations for the same task.
	// Uses the second set of area texture coordinates, which range from (0,0) to (1,1) over the area being processed
	float softEdge = 0.10f; // Softness of the edge of the circle - range 0.001 (hard edge) to 0.25 (very soft)
	float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
	float centreLengthSq = dot(centreVector, centreVector);
	float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge); // Soft circle calculation based on fact that this circle has a radius of 0.5 (as area UVs go from 0->1)

	// Got the RGB from the scene texture
	return float4(colour, alpha);
}