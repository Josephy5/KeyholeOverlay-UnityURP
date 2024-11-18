using System.Collections;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("KeyholeOverlay")]
public class KeyholeOverlayVolume : VolumeComponent, IPostProcessComponent
{
    //the customizable parameters for the shader
    public Texture2DParameter _OverlayTexture = new Texture2DParameter(null, true);
    public ColorParameter _Color = new ColorParameter(Color.black, true);
    public FloatParameter _Cutoff = new ClampedFloatParameter(0.78f, 0f, 1f, true);
    public FloatParameter _Fade = new ClampedFloatParameter(1f, 0f, 1f, true);
    public FloatParameter _Scale = new ClampedFloatParameter(1.7f, 0f, 3f, true);
    public FloatParameter _BlurAmount = new ClampedFloatParameter(10f,0f,10f, true);
    public FloatParameter _BlurEdgeThreshold = new ClampedFloatParameter(0.6f,0f,2f, true);
    public FloatParameter _BlurEdgeRefine = new ClampedFloatParameter(0.38f, 0f, 1f, true);

    //set the parameters for the render pass's material
    public void load(Material material, ref RenderingData renderingData)
    {
        material.SetTexture("_KeyholeTex", _OverlayTexture.value);
        material.SetColor("_Color", _Color.value);
        material.SetFloat("_Cutoff", _Cutoff.value);
        material.SetFloat("_Fade", _Fade.value);
        material.SetFloat("_Scale", _Scale.value);
        material.SetFloat("_BlurAmount", _BlurAmount.value);
        material.SetFloat("_BlurEdgeThreshold", _BlurEdgeThreshold.value);
        material.SetFloat("_BlurEdgeRefine", _BlurEdgeRefine.value);
    }

    public bool IsActive() => true;
    public bool IsTileCompatible() => false;
}