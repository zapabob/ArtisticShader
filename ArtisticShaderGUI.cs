using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using LilToon; // LilToonの名前空間をインポート

public class ArtisticShaderGUI : LilToonBaseGUI
{
    // プロパティの定義
    MaterialProperty toonRampTex;
    MaterialProperty outlineColor;
    MaterialProperty outlineWidth;
    MaterialProperty rimColor;
    MaterialProperty rimPower;
    MaterialProperty emissionMap;
    MaterialProperty emissionColor;
    MaterialProperty sssColor;
    MaterialProperty sssStrength;
    MaterialProperty motionBlurStrength;
    MaterialProperty motionBlurSamples;
    MaterialProperty whiteClipThreshold;using UnityEngine;
    
    public class ArtisticShaderGUI : MonoBehaviour
    {
        
    }

    public override void FindProperties(MaterialProperty[] props)
    {
        base.FindProperties(props);

        toonRampTex = FindProperty("_ToonRamp", props);
        outlineColor = FindProperty("_OutlineColor", props);
        outlineWidth = FindProperty("_OutlineWidth", props);
        rimColor = FindProperty("_RimColor", props);
        rimPower = FindProperty("_RimPower", props);
        emissionMap = FindProperty("_EmissionMap", props);
        emissionColor = FindProperty("_EmissionColor", props);
        sssColor = FindProperty("_SSSColor", props);
        sssStrength = FindProperty("_SSSStrength", props);
        motionBlurStrength = FindProperty("_MotionBlurStrength", props);
        motionBlurSamples = FindProperty("_MotionBlurSamples", props);
        whiteClipThreshold = FindProperty("_WhiteClipThreshold", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // LilToonの基本GUIを描画
        base.OnGUI(materialEditor, properties);

        // カスタムプロパティセクションを追加
        GUILayout.Label("Artistic Shader Properties", EditorStyles.boldLabel);

        // Toon Shading
        EditorGUILayout.LabelField("Toon Shading", EditorStyles.boldLabel);
        materialEditor.TexturePropertySingleLine(new GUIContent("Toon Ramp"), toonRampTex);

        // Outline
        EditorGUILayout.LabelField("Outline", EditorStyles.boldLabel);
        materialEditor.ColorProperty(outlineColor, "Outline Color");
        materialEditor.FloatProperty(outlineWidth, "Outline Width");

        // Rim Light
        EditorGUILayout.LabelField("Rim Light", EditorStyles.boldLabel);
        materialEditor.ColorProperty(rimColor, "Rim Color");
        materialEditor.FloatProperty(rimPower, "Rim Power");

        // Emission Map
        EditorGUILayout.LabelField("Emission Map", EditorStyles.boldLabel);
        materialEditor.TexturePropertySingleLine(new GUIContent("Emission Map"), emissionMap, emissionColor);

        // Subsurface Scattering
        EditorGUILayout.LabelField("Subsurface Scattering (SSS)", EditorStyles.boldLabel);
        materialEditor.ColorProperty(sssColor, "SSS Color");
        materialEditor.FloatProperty(sssStrength, "SSS Strength");

        // Motion Blur
        EditorGUILayout.LabelField("Motion Blur", EditorStyles.boldLabel);
        materialEditor.FloatProperty(motionBlurStrength, "Motion Blur Strength");
        materialEditor.IntProperty(motionBlurSamples, "Motion Blur Samples");

        // White Clipping
        EditorGUILayout.LabelField("White Clipping", EditorStyles.boldLabel);
        materialEditor.FloatProperty(whiteClipThreshold, "White Clip Threshold");
    }
}



















































































































