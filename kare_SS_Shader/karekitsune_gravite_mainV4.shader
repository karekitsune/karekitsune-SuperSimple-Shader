
 /*
    __                   __   _ __                      
   / /______ _________  / /__(_) /________  ______  ___ 
  / //_/ __ `/ ___/ _ \/ //_/ / __/ ___/ / / / __ \/ _ \
 / ,< / /_/ / /  /  __/ ,< / / /_(__  ) /_/ / / / /  __/
/_/|_|\__,_/_/   \___/_/|_/_/\__/____/\__,_/_/ /_/\___/ 
         __              __                             
   _____/ /_  ____ _____/ /__  __________               
  / ___/ __ \/ __ `/ __  / _ \/ ___/ ___/               
 (__  ) / / / /_/ / /_/ /  __/ /  (__  )                
/____/_/ /_/\__,_/\__,_/\___/_/  /____/                 
                                                        

kare_SuperSimple_Shader
ver1.0.0

Copyright (c) 2021 karekitsune
*/

Shader "karekitsune/kare_SuperSimple_Shader"
{

	Properties
	{

		[Header(Texture)] 
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]_OutlineTex("OutlineMaskTex", 2D) = "white" {} //R = Strength
		[NoScaleOffset]_EffectTex("EffectTex", 2D) = "white" {}



		[ToggleUI]_Unlit("Unlit", Float) = 0
		[ToggleUI]_ReceiveShadow("Unlit", Float) = 0
		_Color("Color", Color) = (1,1,1,0)

		
		[Header(Outline)] 
		[Space]
		_OutlineColor("OutlineColor", Color) = (0,0,0,0)
		_OutlineColorTress("OutlineColorTress", Range( 0 , 1)) = 0.1
		_OutlineWidth("OutlineWidth", Float) = 1

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" } 
	    LOD 0

		CGINCLUDE
		#pragma target 4.0 

		ENDCG

						
//=================================================================================
//		Outline
//=================================================================================
		
		Pass
		{   
			Tags { "LightMode"="ForwardBase" }
			
			Cull Front


			Name "Outline"
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "cginc/karekitsune_gravite_HelperFunc.cginc"
			#include "cginc/karekitsune_gravite_Lighting.cginc"

			uniform sampler2D _MainTex;
			uniform float _OutlineWidth;
			uniform sampler2D _OutlineTex;
			uniform float4 _OutlineColor;
			uniform float _OutlineColorTress;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				half3 ambient : TEXCOORD2;
            	UNITY_LIGHTING_COORDS(3, 4)
				UNITY_FOG_COORDS(5)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			v2f vert ( appdata v )
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				
				o.texcoord0 = v.texcoord0;

				float OutlineTex = tex2Dlod( _OutlineTex, float4( v.texcoord0, 0, 0) ).r;
				float3 vOffset = v.normal * _OutlineWidth  *  OutlineTex * 0.002;
				v.vertex += float4(vOffset,0);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				o.ambient = ToonAmbient();

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				UNITY_TRANSFER_FOG(o,o.pos);

				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
			    UNITY_SETUP_INSTANCE_ID(i);
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
				
				float3 MainTex = tex2D( _MainTex, i.texcoord0 );
				float3 ColorTress = lerp( _OutlineColor , MainTex , _OutlineColorTress);
				float3 LightingResult = kktuneLighting(attenuation,i.ambient);
				float3 OutlineColor= ColorTress * LightingResult;
				
				UNITY_APPLY_FOG(i.fogCoord, OutlineColor);
				return float4(OutlineColor,1);
			}
			ENDCG
		}


		

//=================================================================================
//		MainBody
//=================================================================================

		Pass //main
		{   
		    
			Tags { "LightMode"="ForwardBase" }

			Cull Back

			Name "MainBody"
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma multi_compile_fog


			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "cginc/karekitsune_gravite_HelperFunc.cginc"
			#include "cginc/karekitsune_gravite_Lighting.cginc"

			
			uniform sampler2D _MainTex;
			uniform sampler2D _EffectTex;

			uniform float _Unlit;
			uniform float4 _Color;


			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 packUV01 : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				fixed3 ambient : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
                UNITY_LIGHTING_COORDS(3, 4)
				UNITY_FOG_COORDS(5)
			};

			
			v2f vert ( appdata v )
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

				o.packUV01 = float4(v.texcoord0.xy,v.texcoord1.xy);

				o.ambient = ToonAmbient();

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
			
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);

				float2 UV0 = i.packUV01.xy;
				float3 MainColor = tex2D( _MainTex, UV0 )*_Color;
				
				//===================//
				//	   Lighting
				//===================//

				float3 LightingResult = kktuneLighting(attenuation,i.ambient);

				//===================//
				//		 Comp!!
				//===================//

				MainColor *= LightingResult;//Lighting
				float4 FinalColor = float4(MainColor.rgb,1);

				UNITY_APPLY_FOG(i.fogCoord, FinalColor);
				return FinalColor;
			}
			ENDCG
		}




//=================================================================================
//		LightAdd(Outline)
//=================================================================================

		Pass
		{   

			Tags { "LightMode"="ForwardAdd" }

			Cull Front
			
			Blend One One 
			ZWrite Off

			Name "OutlineAdd"
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			//need to recieve shadow
			#pragma multi_compile_fwdadd nolightmap nodirlightmap nodynlightmap novertexlight fog
			

			#define MULTILIGHTPASS


			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "cginc/karekitsune_gravite_HelperFunc.cginc"
			#include "cginc/karekitsune_gravite_Lighting.cginc"

			uniform sampler2D _MainTex;
			uniform float _OutlineWidth;
			uniform sampler2D _OutlineTex;
			uniform float4 _OutlineColor;
			uniform float _OutlineColorTress;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				half3 ambient : TEXCOORD2;
            	UNITY_LIGHTING_COORDS(3, 4)
				UNITY_FOG_COORDS(5)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			v2f vert ( appdata v )
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				
				o.texcoord0 = v.texcoord0;

				float OutlineTex = tex2Dlod( _OutlineTex, float4( v.texcoord0, 0, 0) ).r;
				float3 vOffset = v.normal * _OutlineWidth  *  OutlineTex * 0.002;
				v.vertex += float4(vOffset,0);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				o.ambient = ToonAmbient();

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				UNITY_TRANSFER_FOG(o,o.pos);

				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
			    UNITY_SETUP_INSTANCE_ID(i);
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
				
				float3 MainTex = tex2D( _MainTex, i.texcoord0 );
				float3 ColorTress = lerp( _OutlineColor , MainTex , _OutlineColorTress);
				float3 LightingResult = kktuneLighting(attenuation,i.ambient);
				float3 OutlineColor= ColorTress * LightingResult;
				UNITY_APPLY_FOG(i.fogCoord, OutlineColor);
				return float4(OutlineColor,1);
			}
			ENDCG
		}




//=================================================================================//
//		LightAdd(MainBody)														   //
//=================================================================================//

		Pass 
		{   
		    
			Tags { "LightMode"="ForwardAdd" }

			Cull Back

			
			Blend One One 
			ZWrite Off

			Name "MainAdd"
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			//need to recieve shadow
			#pragma multi_compile_fwdadd nolightmap nodirlightmap nodynlightmap novertexlight fog
			

			#define MULTILIGHTPASS

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "cginc/karekitsune_gravite_HelperFunc.cginc"
			#include "cginc/karekitsune_gravite_Lighting.cginc"


			uniform sampler2D _MainTex;

			uniform float _Unlit;
			uniform float4 _Color;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 packUV01 : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				fixed3 ambient : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
                UNITY_LIGHTING_COORDS(3, 4)
				UNITY_FOG_COORDS(5)
			};
			
			
			
			v2f vert ( appdata v )
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

				o.packUV01 = float4(v.texcoord0.xy,v.texcoord1.xy);

				o.ambient = ToonAmbient();

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
			
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);

				float2 UV0 = i.packUV01.xy;
				float3 MainColor = tex2D( _MainTex, UV0 )*_Color;
				float3 LightingResult = kktuneLighting(attenuation,0);
				MainColor *= LightingResult;
				UNITY_APPLY_FOG(i.fogCoord, MainColor);
				return float4(MainColor.rgb,1);
			}
			ENDCG
		}

//=================================================================================//
//		ShadowCaster															   //
//=================================================================================//

		Pass 
		{
			Name "ShadowCast"
			Tags { "LightMode" = "ShadowCaster" }
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
	
			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
			};
	
			v2f vert( appdata_base v )
			{
				v2f o;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}
	
			float4 frag( v2f i ) : COLOR
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}

	}

}
