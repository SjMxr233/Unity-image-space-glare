using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpaceGlare : MonoBehaviour
{
    public Material material;
    [Range(0, 2)]
    public float threshold = 1;
    [Range(0, 10)]
    public float strength = 1;
    [Range(1, 5)]
    public int iteration = 5;
    [Range(0, 0.95f)]
    public float attenuation = 1;
    [Range(0, 3)]
    public int downsample = 0;
    [Range(0, 360)]
    public float angle = 0;
    public Color col = Color.white;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material!=null)
        {
            int w = source.width >> downsample;
            int h = source.height >> downsample;
            RenderTexture brightness = RenderTexture.GetTemporary(w,h,0);
            RenderTexture blur1 = RenderTexture.GetTemporary(w, h, 0);
            RenderTexture blur2 = RenderTexture.GetTemporary(w, h, 0);
            RenderTexture star = RenderTexture.GetTemporary(w, h, 0);
            material.SetFloat("_Threhold", threshold);
            material.SetFloat("_Strength", strength);
            Graphics.Blit(source, brightness, material,0);
            
            for (int i=0;i<4;i++)
            {
                float ang = angle + 90 * i;
                ang = ang * Mathf.Deg2Rad;
                Vector2 offset = new Vector2(Mathf.Cos(ang), Mathf.Sin(ang));
                material.SetVector("_Direction", offset);
                int iter = 1;
                material.SetFloat("_iteration", iter);
                material.SetFloat("_Attenuation", attenuation);
                Graphics.Blit(brightness, blur1, material,1);
                for(iter=2;iter<=iteration;iter++)
                {
                    material.SetFloat("_iteration", iter);
                    Graphics.Blit(blur1, blur2, material, 1);
                    RenderTexture tempbuffer = blur1;
                    blur1 = blur2;
                    blur2 = tempbuffer;
                }
                Graphics.Blit(blur1, star, material, 2);
            }
            material.SetColor("_StarColor", col);
            material.SetTexture("_StarTex", star);
            Graphics.Blit(source, destination, material, 3);

            RenderTexture.ReleaseTemporary(brightness);
            RenderTexture.ReleaseTemporary(blur1);
            RenderTexture.ReleaseTemporary(blur2);
            RenderTexture.ReleaseTemporary(star);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
