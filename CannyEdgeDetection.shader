Shader "Sylar/CannyEdgeDetection"
{
	Properties 
	{
		_MainTex("Input", 2D) = "white" {}
		_SobelMap("Sobel Map", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
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
	 		sampler2D _SobelMap;
	 		float4 _SobelMap_TexelSize;
	 		half4 _EdgeColor;

	 		#define TexOffset(_x, _y) tex2D(_SobelMap, i.uv + float2(_x * _SobelMap_TexelSize.x, _y * _SobelMap_TexelSize.y))

	 		half4 frag(v2f_img i) : Color
	 		{
	 			half4 color = (1, 1, 1, 1);//tex2D(_MainTex, i.uv);
				half4 map = TexOffset(0, 0);
				if (map.g == 0 && map.b == 0)
				{
					half4 west = TexOffset(-1, 0);
					half4 east = TexOffset(1, 0);
					if (map.a > west.a && map.a > east.a)
					{
						color = _EdgeColor;
					}
				}
				else if (map.g == 0 && map.b == 1)
				{
					half4 north_east = TexOffset(1, 1);
					half4 south_west = TexOffset(-1, -1);
					if (map.a > north_east.a && map.a > south_west.a)
					{
						color = _EdgeColor;
					}
				}
				else if (map.g == 1 && map.b == 0)
				{
					half4 north = TexOffset(0, 1);
					half4 south = TexOffset(0, -1);
					if (map.a > north.a && map.a > south.a)
					{
						color = _EdgeColor;
					}
				}
				else if (map.g == 1 && map.b == 1)
				{
					half4 north_west = TexOffset(-1, 1);
					half4 south_east = TexOffset(1, -1);
					if (map.a > north_west.a && map.a > south_east.a)
					{
						color = _EdgeColor;
					}
				}
				return color;
	 		}

	 		ENDCG
	 	}
	}
}