float _WhiteClipThreshold;

void applyWhiteClipping(inout SurfaceOutput o)
{
    // Apply white clipping effect
    fixed3 whiteClip = saturate((o.Albedo - _WhiteClipThreshold) / (1.0 - _WhiteClipThreshold));
    o.Albedo = lerp(o.Albedo, fixed3(1, 1, 1), whiteClip);
}