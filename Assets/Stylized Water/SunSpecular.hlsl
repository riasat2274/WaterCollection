void SunSpecular_float(float3 Normal, float3 ViewDir, float3 LightDir,
    float3 LightColor, float Size, float Strength, float Distortion,
    out float3 Specular)
{
    float3 h = normalize(LightDir + Normal * Distortion);
    float sp = pow(max(0.0, dot(ViewDir, -reflect(LightDir, h))),
                   max(0.001, (1.0 - Size) * 512.0));
    Specular = sp * Strength * LightColor;
}