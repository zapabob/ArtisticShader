sampler2D _ICLightTex;
fixed4 _ICLightColor;
float _ICLightIntensity;

void applyICLight(inout SurfaceOutput o)
{
    // Apply ICLight effect
    fixed4 icLight = tex2D(_ICLightTex, o.Albedo.rg) * _ICLightColor;
    o.Emission += icLight.rgb * _ICLightIntensity;
}