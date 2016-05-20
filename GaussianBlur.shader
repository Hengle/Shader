Shader "Sylar/GaussianBlur" 
{
	Properties 
	{
		_MainTex("Input", 2D) = "white" {}
		_BlurSize("Blur", float) = 1
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

 			#pragma vertex vert
 			#pragma fragment frag
 			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _BlurSize;

	 		struct appdata
	 		{
	 			float4 vertex : POSITION;
	 			float2 texcoord : TEXCOORD0;
	 		};

	 		struct v2f
	 		{
	 			float4 pos : POSITION;
	 			float2 uv : TEXCOORD0;
	 			float2 offset1 : TEXCOORD1;
	 			float2 offset2 : TEXCOORD2;
	 		};

	 		static const float offsets[3] = { 0, 1.3846153846, 3.2307692308 };
	 		static const float weights[3] = { 0.2270270270, 0.1581081081, 0.03513513515 };

	 		v2f vert(appdata i)
	 		{
	 			v2f o;
	 			o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
	 			o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
	 			o.offset1 = (offsets[1] * _BlurSize * _MainTex_TexelSize.x, offsets[1] * _BlurSize * _MainTex_TexelSize.y);
	 			o.offset2 = (offsets[2] * _BlurSize * _MainTex_TexelSize.x, offsets[2] * _BlurSize * _MainTex_TexelSize.y);
	 			return o;
	 		}

	 		#define TexOffset(x, y) (tex2D(_MainTex, i.uv + float2(x, y)))

	 		half4 frag(v2f i) : Color
	 		{
	 			half4 sum = TexOffset(0, 0) * weights[0];

	 			half4 sum1 = (0, 0, 0, 0);
	 			sum1 += TexOffset(i.offset1.x, 0);
				sum1 += TexOffset(-i.offset1.x, 0);
				sum1 += TexOffset(0, i.offset1.y);
				sum1 += TexOffset(0, -i.offset1.y);
				sum1 *= weights[1];

				half4 sum2 = (0, 0, 0, 0);
				sum2 += TexOffset(i.offset2.x, 0);
				sum2 += TexOffset(-i.offset2.x, 0);
				sum2 += TexOffset(0, i.offset2.y);
				sum2 += TexOffset(0, -i.offset2.y);
				sum2 *= weights[2]; 

	 			return sum + sum1 + sum2;
	 		}

	 		ENDCG
		}
	}

	Fallback "Diffuse"
}