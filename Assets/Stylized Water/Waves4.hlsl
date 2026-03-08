void GerstnerWater_float(
float3 Position,
float Time,

float2 Dir1, float Steep1, float Len1, float Speed1,
float2 Dir2, float Steep2, float Len2, float Speed2,
float2 Dir3, float Steep3, float Len3, float Speed3,
float2 Dir4, float Steep4, float Len4, float Speed4,

float FoamCrestStrength,
float FoamCrestThreshold,

float Depth,
float ShoreFoamDistance,

out float3 OutPosition,
out float3 OutNormal,
out float Foam,
out float2 Distortion
)
{
    float pi = 3.14159265;

    float3 pos = Position;

    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);

    float crestAccum = 0;

    float2 dirs[4] = { normalize(Dir1), normalize(Dir2), normalize(Dir3), normalize(Dir4) };
    float steeps[4] = { Steep1, Steep2, Steep3, Steep4 };
    float lens[4] = { Len1, Len2, Len3, Len4 };
    float speeds[4] = { Speed1, Speed2, Speed3, Speed4 };

    for (int i = 0; i < 4; i++)
    {
        float k = 2 * (pi / lens[i]);
        float f = k * (dot(dirs[i], pos.xz) - speeds[i] * Time);
        float a = steeps[i] / k;

        float cosF = cos(f);
        float sinF = sin(f);

        pos.x += dirs[i].x * (a * cosF);
        pos.y += a * sinF;
        pos.z += dirs[i].y * (a * cosF);

        tangent += float3(
        -dirs[i].x * dirs[i].x * steeps[i] * sinF,
        dirs[i].x * steeps[i] * cosF,
        -dirs[i].x * dirs[i].y * steeps[i] * sinF);

        binormal += float3(
        -dirs[i].x * dirs[i].y * steeps[i] * sinF,
        dirs[i].y * steeps[i] * cosF,
        -dirs[i].y * dirs[i].y * steeps[i] * sinF);

        crestAccum += saturate((sinF + 1.0) * 0.5);
    }

    OutPosition = pos;

    float3 normal = normalize(cross(binormal, tangent));
    OutNormal = normal;

    // Crest Foam
    float crest = crestAccum * 0.25;
    crest = pow(crest, FoamCrestStrength);
    crest = step(FoamCrestThreshold, crest);

    // Shoreline Foam (depth fade)
    float shoreFoam = saturate(1 - Depth / ShoreFoamDistance);

    Foam = saturate(crest + shoreFoam);

    // Normal distortion (for normal map scrolling)
    Distortion = normal.xz * 0.1;
}