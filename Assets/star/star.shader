Shader "mxr/star"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
		CGINCLUDE

			sampler2D _MainTex,_StarTex;
            float4    _StarColor;
			float4 _MainTex_ST,_MainTex_TexelSize;
			half _Attenuation,_Threhold,_Strength;
			half _iteration;
			float2 _Direction;
			#include "UnityCG.cginc"
		ENDCG
		//pass 0提前亮度
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_bright
            fixed4 frag_bright(v2f_img i) : SV_Target
            {
                fixed4 c=tex2D(_MainTex,i.uv);
				float gray=dot(c.rgb,fixed3(0.2125,0.7154,0.0721));
				float val=clamp(gray-_Threhold,0,1);
				return c*val*_Strength;
            }
            ENDCG
        }
		//pass 1沿偏移方向做模糊
		Pass
        {
            CGPROGRAM
            #pragma vertex vert_blur
            #pragma fragment frag_blur
            struct v2f_blur
            {
                float4 pos    : SV_POSITION;
                half2  uv     : TEXCOORD0;
            };

            v2f_blur vert_blur(appdata_img v)
            {
                v2f_blur o;
                o.pos    = UnityObjectToClipPos (v.vertex);
                o.uv     = v.texcoord;
                return o;
            }

            float4 frag_blur(v2f_blur i) : SV_Target
            {
				float b=pow(4,_iteration-1);
				float4 color=float4(0,0,0,0);
                for (int j = 0; j < 4; j++)
                {
                    color += saturate(tex2D(_MainTex,i.uv) * pow(_Attenuation,b*j));
                    i.uv += _Direction*_MainTex_TexelSize.xy*b;
                }

                return color;
            }

            ENDCG
        }
		//pass 2混合模糊后的图像
		Pass
        {
            Blend One One
            CGPROGRAM
            #pragma  vertex vert_img
            #pragma  fragment frag
            fixed4 frag(v2f_img i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
		//pass 3混合原图像
		 Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            fixed4 frag(v2f_img i) : SV_Target
            {
                float4 mainColor = tex2D(_MainTex, i.uv);
                float4 starColor = tex2D(_StarTex, i.uv);
                starColor= (starColor.r + starColor.g + starColor.b) * 0.3333 * _StarColor;
                return saturate(mainColor + starColor);
            }
            ENDCG
        }
    }
}
