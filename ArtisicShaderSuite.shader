Shader "lilToon/CustomArtisticShaderSuite"
{
    Properties
    {
        // Main
        [Header("Main")]
        _MainTex ("メインテクスチャ", 2D) = "white" {}
        _Color ("カラー", Color) = (1, 1, 1, 1)

        // Toon Shading
        [Header("トゥーンシェーディング")]
        _ShadowColor ("シャドウカラー", Color) = (0.2, 0.2, 0.2, 1)
        _ShadowSmoothness ("シャドウスムーズネス", Range(0, 1)) = 0.5
        _ShadowThreshold ("シャドウしきい値", Range(0, 1)) = 0.5
        _SpecularColor ("スペキュラーカラー", Color) = (1, 1, 1, 1)
        _SpecularSmoothness ("スペキュラスムーズネス", Range(0, 1)) = 0.5
        _SpecularThreshold ("スペキュラしきい値", Range(0, 1)) = 0.5
        _RimColor ("リムカラー", Color) = (1, 1, 1, 1)
        _RimSmoothness ("リムスムーズネス", Range(0, 1)) = 0.5
        _RimThreshold ("リムしきい値", Range(0, 1)) = 0.5

        // Outline
        [Header("アウトライン")]
        _OutlineColor ("アウトラインカラー", Color) = (0, 0, 0, 1)
        _OutlineWidth ("アウトライン幅", Range(0, 1)) = 0.1
        _OutlineTexture ("アウトラインテクスチャ", 2D) = "white" {}

        // Emission
        [Header("エミッション")]
        _EmissionColor ("エミッションカラー", Color) = (0, 0, 0, 1)
        _EmissionMap ("エミッションマップ", 2D) = "white" {}
        _EmissionIntensity ("エミッション強度", Range(0, 10)) = 1

        // Subsurface Scattering
        [Header("サブサーフェススキャタリング")]
        _SSSColor ("SSSカラー", Color) = (1, 0.5, 0.3, 1)
        _SSSIntensity ("SSS強度", Range(0, 1)) = 0.5
        _SSSPower ("SSSパワー", Range(0.1, 10)) = 1
        _SSSDistortion ("SSSディストーション", Range(0, 1)) = 0.5

        // Motion Blur
        [Header("モーションブラー")]
        _MotionBlurIntensity ("モーションブラー強度", Range(0, 1)) = 0.5
        _MotionBlurSamples ("モーションブラーサンプル数", Int) = 8
        _MotionBlurDirection ("モーションブラー方向", Vector) = (0, 0, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        Pass
        {
            Name "ForwardLit"

            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #include "Packages/com.lilToon/lilToon.include.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float4 pos = TransformObjectToHClip(input.positionOS);
                output.positionCS = pos;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                float3 worldPos = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.viewDirWS = GetCameraPositionWS() - worldPos;
                UNITY_TRANSFER_FOG(output,o.fogCoord);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _Color;

                // Toon Shading
                half NdotL = saturate(dot(normalize(input.normalWS), normalize(GetMainLightDir())));
                half shadowSmooth = smoothstep(_ShadowThreshold - _ShadowSmoothness, _ShadowThreshold + _ShadowSmoothness, NdotL);
                half3 shadowColor = lerp(_ShadowColor.rgb, albedo.rgb, shadowSmooth);

                half specularSmooth = smoothstep(_SpecularThreshold - _SpecularSmoothness, _SpecularThreshold + _SpecularSmoothness, NdotL);
                half3 specularColor = _SpecularColor.rgb * specularSmooth;

                half rimSmooth = smoothstep(_RimThreshold - _RimSmoothness, _RimThreshold + _RimSmoothness, 1.0 - saturate(dot(normalize(input.normalWS), normalize(normalize(input.viewDirWS)))));
                half3 rimColor = _RimColor.rgb * rimSmooth;

                half3 toonColor = shadowColor + specularColor + rimColor;

                // Outline
                half outlineFactor = smoothstep(0.0, _OutlineWidth, input.uv.x);
                half3 outlineColor = lerp(albedo.rgb, _OutlineColor.rgb, outlineFactor) * SAMPLE_TEXTURE2D(_OutlineTexture, sampler_OutlineTexture, input.uv).rgb;

                // Emission
                half3 emissionColor = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv).rgb * _EmissionColor.rgb * _EmissionIntensity;

                // Subsurface Scattering
                half3 sssColor = _SSSColor.rgb * _SSSIntensity;
                half sssTransmission = pow(saturate(dot(normalize(input.viewDirWS), -normalize(GetMainLightDir()))), _SSSPower) * _SSSDistortion;
                sssColor *= sssTransmission;

                // Motion Blur
                half3 motionColor = albedo.rgb;
                for (int i = 1; i < _MotionBlurSamples; i++)
                {
                    half2 offset = _MotionBlurDirection.xy * (_MotionBlurIntensity * i / _MotionBlurSamples);
                    motionColor += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + offset).rgb;
                }
                motionColor /= _MotionBlurSamples;

                half3 finalColor = toonColor + outlineColor + emissionColor + sssColor;
                finalColor = lerp(finalColor, motionColor, _MotionBlurIntensity);

                // Fog
                UNITY_APPLY_FOG(input.fogCoord, finalColor);

                return half4(finalColor, albedo.a);
            }
            ENDHLSL
        }

        UsePass "lilToon/ShadowCaster"
    }
}