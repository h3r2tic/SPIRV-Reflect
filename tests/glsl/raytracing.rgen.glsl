#version 460 core
#extension GL_NV_ray_tracing : enable

#define TRACING_EPSILON 1e-3
#define TMAX 1000.0

layout(push_constant) uniform pushConstants
{
    mat4 clipToWorld;
    vec3 sunDirection;
} pc;

layout(binding = 0) uniform accelerationStructureNV accelerationStructure;
layout(r8, binding = 1) uniform image2D outputImage;
layout(binding = 2) uniform sampler2D positionImage;

layout(location = 0) rayPayloadNV float hitDistance;

void main()
{
    vec2 inUV = vec2(
        (float(gl_LaunchIDNV.x) + 0.5f) / float(gl_LaunchSizeNV.x),
        (float(gl_LaunchIDNV.y) + 0.5f) / float(gl_LaunchSizeNV.y)
    );

    vec4 worldPos = texture(positionImage, inUV);
    if (worldPos.a == 0)
    {
        return;
    }

    vec3 rayOrigin = worldPos.xyz;
    vec3 rayDirection = normalize(pc.sunDirection);

    traceNV(accelerationStructure,
            gl_RayFlagsTerminateOnFirstHitNV | gl_RayFlagsOpaqueNV,
            0xff,
            0, 0, 2,
            rayOrigin,
            TRACING_EPSILON,
            rayDirection,
            TMAX,
            0);

    imageStore(outputImage, ivec2(gl_LaunchIDNV.xy), vec4(hitDistance, 0.f, 0.f, 0.f));
}
