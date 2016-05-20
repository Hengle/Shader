Shader "Sylar/SobelFilter"
{
	Properties 
	{
		_MainTex("Input", 2D) = "white" {}
	}

	SubShader
	{
	 	Pass
	 	{
	 		CGPROGRAM

	 		#pragma vertex vert_img
	 		#pragma fragment frag
	 		#include "UnityCG.cginc"

	 		sampler2D _MainTex;
	 		float4 _MainTex_TexelSize;

	 		const float sobel_filter_x[9] = {
 				-1, 0, 1,
 				-2, 0, 2,
 				-1, 0, 1
 			};

 			const float sobel_filter_y[9] = {
 				-1, -2, -1,
 				0, 0, 0,
 				1, 2, 1
 			};

 			half TexOffset(float2 uv, half _x, half _y)
 			{
 				half4 color = tex2D(_MainTex, uv + float2(_x * _MainTex_TexelSize.x, _y * _MainTex_TexelSize.y));
 				half value = (color.r + color.g + color.b) / 3;
 				return value;
 			}

	 		half4 frag(v2f_img i) : Color
	 		{
 				half valuex = -TexOffset(i.uv, -1, 1) + TexOffset(i.uv, 1, 1) - 2 * TexOffset(i.uv, -1, 0) + 2 * TexOffset(i.uv, 1, 0) - TexOffset(i.uv, -1, -1) + TexOffset(i.uv, 1, -1);
				half valuey = -TexOffset(i.uv, -1, 1) - 2 * TexOffset(i.uv, 0, 1) - TexOffset(i.uv, 1, 1) + TexOffset(i.uv, -1, -1) + 2 * TexOffset(i.uv, 0, -1) + TexOffset(i.uv, 1, -1);
				// 梯度值
				half value = sqrt(valuex * valuex + valuey * valuey);
				// 梯度角(本来应该为0/45/90/135，这里分别输出为000/001/010/011)
				half3 anglec = (0, 1, 0);
				if (valuex != 0)
				{
					half angle = degrees(atan2(valuey, valuex)) + 90;
					if (angle < 22.5)
					{
						anglec.xyz = (0, 0, 0);
					}
					else if (angle < 67.5)
					{
						anglec.xyz = (0, 0, 1);
					}
					else if (angle < 112.5)
					{
						anglec.xyz = (0, 1, 0);
					}
					else if (angle < 157.5)
					{
						anglec.xyz = (0, 1, 1);
					}
					else
					{
						anglec.xyz = (0, 0, 0);
					}
				}
				half4 result;
				result.rgb = anglec;
				result.a = value;
				return result;
	 		}

	 		ENDCG
	 	}
	}
}