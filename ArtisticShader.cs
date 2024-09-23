using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.PostProcessing;
using LilToon;

[ExecuteInEditMode]
[RequireComponent(typeof(LilToonMaterial))]
public class ArtisticShader : MonoBehaviour
{
    public Shader artisticShader;
    public Material artisticMaterial;
    private LilToonMaterial lilToonMaterial;

    private void OnEnable()
    {
        lilToonMaterial = GetComponent<LilToonMaterial>();

        if (artisticMaterial == null && artisticShader != null)
        {
            artisticMaterial = new Material(artisticShader);
            lilToonMaterial.SetCustomMaterial(artisticMaterial);
        }

        if (modularAvatar != null)
        {
            ApplyArtisticShaderToAvatar(modularAvatar);
        }
    }

    private void ApplyArtisticShaderToAvatar(GameObject avatar)
    {
        Renderer[] renderers = avatar.GetComponentsInChildren<Renderer>();
        foreach (Renderer renderer in renderers)
        {
            foreach (var mat in renderer.materials)
            {
                mat.shader = artisticShader;
            }
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (artisticMaterial != null)
        {
            Graphics.Blit(src, dest, artisticMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private void OnDisable()
    {
        if (artisticMaterial != null)
        {
            DestroyImmediate(artisticMaterial);
        }
    }
}