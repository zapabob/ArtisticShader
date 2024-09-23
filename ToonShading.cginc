sampler2D _ToonRamp;

void applyToonShading(inout SurfaceOutput o)
{
    // Apply toon shading using _ToonRamp texture
    fixed3 ramp = tex2D(_ToonRamp, o.Albedo.rg).rgb;
    o.Albedo *= ramp;
}