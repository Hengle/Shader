Shader "RadialBlur"
{
	Properties
	{
		_MainTex("Input", 2D) = "white" {}
		_BlurCenterX("Blur Center X", Range(0,1)) = 0.5
		_BlurCenterY("Blur Center Y", Range(0,1)) = 0.5
		_BlurStrength ("Blur Strength", Float) = 4.0
		_BlurWidth("Blur Width", Float) = 1.0
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
			fixed _BlurStrength;
			fixed _BlurWidth;
			fixed _BlurCenterX;
			fixed _BlurCenterY;

			fixed4 frag(v2f_img i) : Color
			{
				fixed4 color = tex2D(_MainTex, i.uv);

				fixed2 dir = half2(_BlurCenterX, _BlurCenterY) - i.uv;

				fixed dist = length(dir);

				dir = dir / dist;

				fixed4 sum = color;
				for (int n = 1; n <= 3; n+=2)
				{
					sum += tex2D(_MainTex, i.uv + dir * _BlurWidth * n * 0.01);
					sum += tex2D(_MainTex, i.uv + dir * _BlurWidth * n * -0.01);
				}

				sum *= 1.0 / 5.0;

				fixed t = dist * _BlurStrength;
				t = clamp(t, 0, 1);

				return lerp(color, sum, t);
			}
			ENDCG
		}
	}
}