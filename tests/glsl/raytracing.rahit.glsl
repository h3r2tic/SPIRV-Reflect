#version 460 core
#extension GL_NV_ray_tracing : require

rayPayloadInNV float hitDistance;

void main()
{
    hitDistance = gl_HitTNV;
    terminateRayNV();
}
