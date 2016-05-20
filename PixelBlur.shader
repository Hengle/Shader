Shader "Sylar/PixelBlur" 
{
	Properties 
	{
		_MainTex("Input", 2D) = "white" {}
		_RectWidth("Rect Width", Range(0, 1)) = 0.1
		_RectHeight("Rect Height", Range(0, 1)) = 0.1
	}

	SubShader
	{
	 	Pass
	 	{
	 		ZTest Off
	 		Cull Off
	 		ZWrite Off
	 		Blend Off
	 		Fog {Mode Off}

	 		CGPROGRAM
	 		#pragma vertex vert_img
	 		#pragma fragment frag
	 		#pragma fragmentoption ARB_precision_hint_fastest
	 		#include "UnityCG.cginc"

	 		sampler2D _MainTex;
	 		fixed _RectWidth;
	 		fixed _RectHeight;

	 		fixed4 frag(v2f_img i) : Color
	 		{
	 			half2 uv = half2(floor(i.uv.x / _RectWidth) * _RectWidth, floor(i.uv.y / _RectHeight) * _RectHeight);
	 			return tex2D(_MainTex, uv);
	 		}
	 		ENDCG
	 	}
	}
}