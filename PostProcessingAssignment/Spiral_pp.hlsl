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
	// Get vector from post-processing area centre to pixel UV
	const float2 centreUV = gArea2DTopLeft + gArea2DSize * 0.5f;
	float2 centreOffsetUV = input.sceneUV - centreUV;
	float centreDistance = length(centreOffsetUV); // Distance of pixel from screen centre
	
	// Get sin and cos of spiral amount, increasing with distance from centre
	float s, c;
	sincos( centreDistance * gSpiralLevel * gSpiralLevel, s, c );
	
	// Create a (2D) rotation matrix and apply to the vector - i.e. rotate the
	// vector around the centre by the spiral amount
	matrix<float,2,2> rot2D = { c, s,
	                           -s, c };
	float2 rotatedOffsetUV = mul(centreOffsetUV, rot2D);

	// Sample texture at new position (centre UV + rotated UV offset)
    float3 outputColour = SceneTexture.Sample( PointSample, centreUV + rotatedOffsetUV ).rgb;

	// Calculate alpha to display the effect in a softened circle, could use a texture rather than calculations for the same task.
	// Uses the second set of area texture coordinates, which range from (0,0) to (1,1) over the area being processed
	float softEdge = 0.10f; // Softness of the edge of the circle - range 0.001 (hard edge) to 0.25 (very soft)
	float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
	float centreLengthSq = dot(centreVector, centreVector);
	float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge); // Soft circle calculation based on fact that this circle has a radius of 0.5 (as area UVs go from 0->1)
																					   
	return float4(outputColour, alpha);
}