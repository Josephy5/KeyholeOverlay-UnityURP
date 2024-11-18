using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

//render pass code for the transition effect
public class KeyholeOverlayPass : ScriptableRenderPass
{
    static readonly string renderPassTag = "Keyhole Overlay";

    private KeyholeOverlayVolume KeyholeOverlayVolume;
    //material containing the shader
    private Material KeyholeOverlayMaterial;

    //initializes our variables
    public KeyholeOverlayPass(RenderPassEvent evt, Shader KeyholeOverlayshader)
    {
        renderPassEvent = evt;
        if (KeyholeOverlayshader == null)
        {
            Debug.LogError("No Shader");
            return;
        }
        //to make profiling easier
        profilingSampler = new ProfilingSampler(renderPassTag);
        KeyholeOverlayMaterial = CoreUtils.CreateEngineMaterial(KeyholeOverlayshader);
    }
    //where our rendering of the effect starts
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (KeyholeOverlayMaterial == null)
        {
            Debug.LogError("No KeyholeOverlay Material");
            return;
        }
        //in case if the camera doesn't have the post process option enabled and if the camera is not the game's camera
        if (!renderingData.cameraData.postProcessEnabled || (renderingData.cameraData.cameraType != CameraType.Game))
        {
            return;
        }

        VolumeStack stack = VolumeManager.instance.stack;
        KeyholeOverlayVolume = stack.GetComponent<KeyholeOverlayVolume>();

        var cmd = CommandBufferPool.Get(renderPassTag);
        Render(cmd, ref renderingData);

        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();

        CommandBufferPool.Release(cmd);
    }

    //helper method to contain all of our rendering code for the Execute() method
    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        //we handle the setting the shader's material's parameters/variables in the transition volume script instead of here
        if (KeyholeOverlayVolume.IsActive() == false) return;
        KeyholeOverlayVolume.load(KeyholeOverlayMaterial, ref renderingData);

        //for profiling
        using (new ProfilingScope(cmd, profilingSampler))
        {
            var src = renderingData.cameraData.renderer.cameraColorTargetHandle;

            int width = renderingData.cameraData.cameraTargetDescriptor.width;
            int height = renderingData.cameraData.cameraTargetDescriptor.height;

            var tempColorTexture = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            var tempColorTexture2 = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

            //actual rendering code
            cmd.Blit(src, tempColorTexture, KeyholeOverlayMaterial, 0);
            cmd.Blit(tempColorTexture, tempColorTexture2, KeyholeOverlayMaterial, 1);
            cmd.Blit(tempColorTexture2, src, KeyholeOverlayMaterial, 2);
            //cmd.Blit(tempColorTexture, src, KeyholeOverlayMaterial, 1);

            RenderTexture.ReleaseTemporary(tempColorTexture);
            RenderTexture.ReleaseTemporary(tempColorTexture2);
        }
    }
}