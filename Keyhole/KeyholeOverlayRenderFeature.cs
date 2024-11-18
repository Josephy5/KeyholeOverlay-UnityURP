using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class KeyholeOverlayRenderFeature : ScriptableRendererFeature
{
    //initialzing the render feature settings
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        //the transition shader, will automatically be assigned
        public Shader shader;
    }
    public Settings settings = new Settings();

    KeyholeOverlayPass m_KeyholeOverlayPass;

    //When render feature object is enabled, set the shader
    private void OnEnable()
    {
        settings.shader = Shader.Find("Hidden/KeyholeOverlay");
    }
    //sets the hatching's render pass up
    public override void Create()
    {
        this.name = "KeyholeOverlay Pass";
        if (settings.shader == null)
        {
            Debug.LogWarning("No KeyholeOverlay Shader");
            return;
        }
        m_KeyholeOverlayPass = new KeyholeOverlayPass(settings.renderPassEvent, settings.shader);
    }

    //call and adds the hatching render pass to the scriptable renderer's queue
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_KeyholeOverlayPass);
    }
}