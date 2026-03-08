void GerstnerWave_float(
    float3 Position,
    float2 Direction,
    float Steepness,
    float Wavelength,
    float Speed,
    float Time,
    float FoamStrength,
    float FoamThreshold,

    out float3 OutPosition,
    out float3 OutNormal,
    out float Foam
)
{
    float pi = 3.14159265;
    float k = 2 * (pi / Wavelength);
    float2 dir = normalize(Direction);

    float f = k * (dot(dir, Position.xz) - Speed * Time);
    float a = Steepness / k;

    float cosF = cos(f);
    float sinF = sin(f);

    float3 displacement;

    displacement.x = dir.x * (a * cosF);
    displacement.y = a * sinF;
    displacement.z = dir.y * (a * cosF);

    OutPosition = Position + displacement;

    float3 tangent = float3(
        1 - dir.x * dir.x * Steepness * sinF,
        dir.x * Steepness * cosF,
        -dir.x * dir.y * Steepness * sinF
    );

    float3 binormal = float3(
        -dir.x * dir.y * Steepness * sinF,
        dir.y * Steepness * cosF,
        1 - dir.y * dir.y * Steepness * sinF
    );

    OutNormal = normalize(cross(binormal, tangent));

    // Crest-only foam
    float crest = saturate((sinF + 1.0) * 0.5);
    crest = pow(crest, FoamStrength);

    Foam = step(FoamThreshold, crest);
}