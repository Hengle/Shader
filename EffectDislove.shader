// 溶解效果
Shader "Custom/EffectDislove" 
{
	Properties
	 {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DisloveTex("Base (Red)", 2D) = "white" {}
		_TintColor("Tint Color", Color) = (1, 1, 1, 1)
		_Threshold("Disolve Threshold", Range(0, 1.2)) = 0
		_EdgeSize("Disolve Edge Size", Range(0, 0.199)) = 0
		_EdgeColor("Dislove Edge Color", Color) = (1, 1, 1, 1)
	}
	SubShader 
	{
		Tags { "Quene"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
		Blend SrcAlpha One
		Fog {Mode Off}
		Cull Off
		Lighting Off
		ZWrite Off

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _DisloveTex;
			float4 _MainTex_ST;
			float4 _DisloveTex_ST;
			fixed4 _TintColor;
			float _Threshold;
			fixed4 _EdgeColor;
			float _EdgeSize;

			struct appdata_t
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord1 : TEXCOORD0;
				half2 texcoord2 : TEXCOORD1;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord2 = TRANSFORM_TEX(v.texcoord, _DisloveTex);
				return o;
			}

			fixed4 frag(v2f i) : Color
			{
				fixed4 color = tex2D(_MainTex, i.texcoord1) * _TintColor * 2;
				fixed4 dislove = tex2D(_DisloveTex, i.texcoord2);
				fixed alpha1 = dislove.r > max(_Threshold - _EdgeSize, 0);
				fixed alpha2 = dislove.r < _Threshold;
				color.a = color.a * alpha1;
				color = lerp(color, _EdgeColor, alpha1 * alpha2);
				return color;
			}
			
			ENDCG
		}
	} 
	FallBack "Particles/Additive"
}
