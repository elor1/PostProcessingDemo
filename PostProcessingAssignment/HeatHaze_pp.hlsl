//--------------------------------------------------------------------------------------
// Colour Tint Post-Processing Pixel Shader
//--------------------------------------------------------------------------------------
// Just samples a pixel from the scene texture and multiplies it by a fixed colour to tint the scene

#include "Common.hlsli"


//--------------------------------------------------------------------------------------
// Textures (texture maps)
//--------------------------------------------------------------------------------------

// The scene has been rendered to a texture, these variables allow access to that texture
Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0); // We don't usually want to filter (bilinear, trilinear etc.) the scene texture when
                                          // post-processing so this sampler will use "point sampling" - no filtering


//--------------------------------------------------------------------------------------
// Shader code
//--------------------------------------------------------------------------------------

// Post-processing shader that tints the scene texture to a given colour
float4 main(PostProcessingInput input) : SV_Target
{
	const float effectStrength = 0.01f;
	
	// Calculate alpha to display the effect in a softened circle, could use a texture rather than calculations for the same task.
	// Uses the second set of area texture coordinates, which range from (0,0) to (1,1) over the area being processed
	const float softEdge = 0.15f; // Softness of the edge of the circle - range 0.001 (hard edge) to 0.25 (very soft)
	float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
	float centreLengthSq = dot(centreVector, centreVector);
	float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge); // Soft circle calculation based on fact that this circle has a radius of 0.5 (as area UVs go from 0->1)

	// Haze is a combination of sine waves in x and y dimensions
	float SinX = sin(input.areaUV.x * radians(1440.0f) + gHeatHazeTimer * 3.0f);
	float SinY = sin(input.areaUV.y * radians(3600.0f) + gHeatHazeTimer * 3.7f);
	
	// Offset for scene texture UV based on haze effect
	// Adjust size of UV offset based on the constant EffectStrength, the overall size of area being processed, and the alpha value calculated above
	float2 hazeOffset = float2(SinY, SinX) * effectStrength * alpha * gArea2DSize;

	// Get pixel from scene texture, offset using haze
    float3 colour = SceneTexture.Sample(PointSample, input.sceneUV + hazeOffset).rgb;

	// Adjust alpha on a sine wave - because it's better to have it nearer to 1.0 (but don't allow it to exceed 1.0)
    alpha *= saturate(SinX * SinY * 0.33f + 0.66f);

	return float4(colour, alpha);
}