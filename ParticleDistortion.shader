Shader "ParticleDistortion"
{
	Properties 
	{
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
		strength_x("strength_x", Range(-0.3, 0.3)) = 0.1
		strength_y("strength_y", Range(-0.3, 0.3)) = 0.1
		speed_x ("speed_x", Range(-1, 1)) = 1
		speed_y ("speed_y", Range(-1, 1)) = 1
		transparency("transparency", Range(0.01, 0.3)) = 0.05
	}
 
	Category 
	{
    	Tags { "Queue" = "Transparent+10" }
     	SubShader 
     	{
         	GrabPass {}
			Pass 
			{
				Tags { "LightMode" = "Always" }
				Lighting Off
				Cull Off
				ZWrite On
				ZTest LEqual
				Blend SrcAlpha OneMinusSrcAlpha
				AlphaTest Greater 0

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _GrabTexture : register(s0);
				float4 _NoiseTex_ST;
				sampler2D _NoiseTex;
				float strength_x;
				float strength_y;
				float speed_x;
				float speed_y;
				float transparency;

				struct data
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 position : POSITION;
					float4 screenPos : TEXCOORD0;
					float2 uvmain : TEXCOORD1;
					float2 distortion : TEXCOORD2;
				};

				v2f vert(data i)
				{
					v2f o;
					o.position = mul(UNITY_MATRIX_MVP, i.vertex);      // compute transformed vertex position
					o.uvmain = TRANSFORM_TEX(i.texcoord, _NoiseTex);   // compute the texcoords of the noise
					o.distortion = float2(strength_x, strength_y);
					float viewAngle = dot(normalize(ObjSpaceViewDir(i.vertex)), i.normal);
					o.distortion *= viewAngle * viewAngle;    // square viewAngle to make the effect fall off stronger
					float depth = -mul(UNITY_MATRIX_MV, i.vertex).z;    // compute vertex depth
					o.distortion /= 1+depth;        // scale effect with vertex depth
					o.screenPos = o.position;   // pass the position to the pixel shader
					return o;
				}

				half4 frag( v2f i) : COLOR
				{   
					// compute the texture coordinates
					float2 screenPos = i.screenPos.xy / i.screenPos.w;   // screenpos ranges from -1 to 1
					screenPos.x = (screenPos.x + 1) * 0.5;   // I need 0 to 1
					screenPos.y = (screenPos.y + 1) * 0.5;   // I need 0 to 1
					#if UNITY_UV_START_AT_TOP
					   screenPos.y = 1 - screenPos.y;
					#endif

					// get two offset values by looking up the noise texture shifted in different directions
					half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz * speed_x);
					half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx * speed_y);

					// use the r values from the noise texture lookups and combine them for x offset
					// use the g values from the noise texture lookups and combine them for y offset
					// use minus one to shift the texture back to the center
					// scale with distortion amount
					screenPos.x += ((offsetColor1.r + offsetColor2.r) - 1) * i.distortion.x;
					screenPos.y += ((offsetColor1.g + offsetColor2.g) - 1) * i.distortion.y;

					half4 col = tex2D(_GrabTexture, screenPos);
					col.a = length(i.distortion)/transparency;
					return col;
				}

				ENDCG
			}

			Pass
			{
				Tags {"RenderType"="Transparent" "IgnoreProjector"="True"}
				Blend SrcAlpha One
				AlphaTest Greater .01
				ColorMask RGB
				Fog {Mode Off}
				Cull Off
				Lighting Off
				ZWrite Off

				BindChannels
				{
					Bind "Color", color
					Bind "Vertex", vertex
					Bind "texcoord", texcoord
				}

				SetTexture [_MainTex]
				{
					ConstantColor [_MainColor]
					combine primary * constant
				}

				SetTexture [_MainTex]
				{
					combine previous * texture DOUBLE
				}
			}
		}
	}
}