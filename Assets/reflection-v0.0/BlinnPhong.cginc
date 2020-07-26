inline float4 shade(
    float3 worldNormal, // Assume to be normalzied
    float3 worldLightDir, // Assume to be normalized
    float4 objectColor,
    float3 lightColor
    ) {
    
    float dot_L_N = dot(worldNormal, worldLightDir);
    float3 diffuseReflection = lightColor * saturate(dot_L_N);     // Note that saturate() equals to the effect of  clamp(x, 0.0f, 1.0f)
    return objectColor * float4(diffuseReflection, 1.0f);
}