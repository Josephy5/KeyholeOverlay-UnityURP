//Some shader code is based on Dan Moran's Shader case study of Pokemon Battle Transition YouTube video
//and Acerola's post processing github
//The only change is the removal of the distort calculation and parameters and modifications to the gaussian blur
//code to be more oriented in blurring the edges of the keyhole mask.
Shader "Hidden/KeyholeOverlay"
{
    Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_KeyholeTex("Keyhole Texture", 2D) = "white" {}
		_Color("Screen Color", Color) = (1,1,1,1)
		_Cutoff("Cutoff", Range(0, 1)) = 0
		_Fade("Fade", Range(0, 1)) = 0
		_Scale("Scale", Range(0,3)) = 1
		_BlurAmount("Blur Amount", Float) = 1.0
		_BlurEdgeThreshold("Blur Amount", Float) = 0.01
		_BlurEdgeRefine("Blur Edge Refine", Float) = 0.45
	}

		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			CGINCLUDE

			#include "UnityCG.cginc"

			//all the structs needed for the passes
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			//variables relating to textures
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _KeyholeTex;

			//other variables
			float4 _Color;
			float _Scale;
			float _Fade;
			float _Cutoff;
			float _BlurAmount;
			float _BlurEdgeThreshold;
			float _BlurEdgeRefine;

			//vert function for first pass (index 0)
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;
				o.uv1 = v.uv;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv1.y = 1 - o.uv1.y;
				#endif

				return o;
			}

			//vert function for second and third pass (index 1 & 2)
			v2f vp(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv;
				return o;
			}

			#define PI 3.14159265358979323846f
			
			// Helper function to calculate gaussian needed for the blur effect
			// Normally supposed to use a 3x3 matrix of pre determined weights of each pixel in a 3x3 grid
			// But I am using a line from Acerola's open source code from his post processing github repo to run a equation that does the
			// calculation itself that results a very close aproximation of the values similar to the ones in the pre determined weight matrix
			float gaussian(float sigma, float pos) {
				return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
			}

			// Helper function to determine if we're at the edge
			float isEdge(float maskValue, float cutoff) {
				fixed edgeWidth = _BlurEdgeThreshold;
				fixed distFromCutoff = abs(maskValue - cutoff);
				return 1.0 - saturate(distFromCutoff / edgeWidth);
			}
			ENDCG

			//keyhole hole cutout mask pass (index 0)
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				fixed4 frag(v2f i) : SV_Target
				{
					//Scale the uv to desired center position
					fixed2 uv = i.uv1;
					uv -= 0.5;
					uv /= _Scale;
					uv += 0.5;
					
					fixed4 transit = tex2D(_KeyholeTex, uv);

					fixed2 direction = float2(0,0);

					//getting the screen colour with cutoff values and mask in place
					fixed4 col = tex2D(_MainTex, i.uv + _Cutoff * direction);
					
					//overlay our results onto the screen to mask it off
					if (transit.b < _Cutoff){
						col = lerp(col, _Color, _Fade);
					}

					return col;
				}					
				ENDCG
			}
			
			// Gaussian Blur First Pass (index 1)
            Pass {
				CGPROGRAM
                #pragma vertex vp
                #pragma fragment fp
							
				//where all the rendering work is at
                fixed4 fp(v2f i) : SV_Target {
					//Scale the uv to desired center position
					fixed2 uv = i.uv1;
					uv -= 0.5;
					uv.x /= _Scale; //- 0.06f;
					uv.y /= _Scale; //- 0.02f;
					//uv /= _Scale;
					uv += 0.5;

					fixed4 transit = tex2D(_KeyholeTex, uv);

					fixed maskValue = transit.b;
					//get the edge factor and apply the gaussian blur on it
					fixed edgeFactor = isEdge(maskValue, _Cutoff);
					if (edgeFactor > 0.0) {
						fixed4 output = 0;
						fixed sum = 0;
						//gaussian blur stuff
						for (int x = -9; x <= 9; ++x) {
							fixed2 offset = float2(x, 0) * _MainTex_TexelSize.xy;
							fixed4 c = tex2D(_MainTex, i.uv + offset);
							fixed gauss = gaussian(_BlurAmount, x);
                        
							output += c * gauss;
							sum += gauss;
						}
						//normalize and overlay our results onto the screen
						fixed4 blurred = output / sum;
						return lerp(tex2D(_MainTex, i.uv), blurred, _BlurEdgeRefine);
					}
					//if its not the right place to blur, just return the original screen color
					return tex2D(_MainTex, i.uv);
                 }
                 ENDCG
             }

             // Gaussian Blur Second Pass (index 2)
             Pass {
                 CGPROGRAM
                 #pragma vertex vp
                 #pragma fragment fp

				 //where all the rendering work is at
                 fixed4 fp(v2f i) : SV_Target {
					//Scale the uv to desired center position                    
					fixed2 uv = i.uv1;
					uv -= 0.5;
					uv.x /= _Scale; //- 0.06f;
					uv.y /= _Scale; //- 0.02f;
					//uv /= _Scale;
					uv += 0.5;

					fixed4 transit = tex2D(_KeyholeTex, uv);

					fixed maskValue = transit.b;
					//get the edge factor and apply the gaussian blur on it	
					fixed edgeFactor = isEdge(maskValue, _Cutoff);
					if (edgeFactor > 0.0) {
						fixed4 output = 0;
						fixed sum = 0;
						//gaussian blur stuff
						for (int y = -9; y <= 9; ++y) {
							fixed2 offset = float2(0, y) * _MainTex_TexelSize.xy;
							fixed4 c = tex2D(_MainTex, i.uv + offset);
							fixed gauss = gaussian(_BlurAmount, y);
                        
							output += c * gauss;
							sum += gauss;
						}
						//normalize and overlay our results onto the screen
						fixed4 blurred = output / sum;
						return lerp(tex2D(_MainTex, i.uv), blurred, _BlurEdgeRefine);
					 }
					 //if its not the right place to blur, just return the original screen color
					 return tex2D(_MainTex, i.uv);
                  }
                  ENDCG
              }
		}
}
