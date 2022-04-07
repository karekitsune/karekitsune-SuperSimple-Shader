//=================================================================================
//		HelperFunc
//=================================================================================

		float remap(float value, float inMin, float inMax, float outMin, float outMax)
			{
    			return (value - inMin) * ((outMax - outMin) / (inMax - inMin)) + outMin;
			}

		float pseudoPow(float value, float expvalue)
			{
				return value-((value - (value * value))*(1-expvalue));
			}

		float2 adjustUV(float2 UV,float rowvalue,float columnvalue,float2 texturepos) //縦４横4テクスチャの　下から縦２　左から横３　個めのテクスチャを指定したいとき(UV,4,4,float2(2,3))になるよ
			{
			UV = frac(UV);
			rowvalue = 1/rowvalue;
			columnvalue = 1/columnvalue;
			texturepos = float2(rowvalue*(texturepos.x-1) , columnvalue*(texturepos.y-1) );
			UV = float2( texturepos.x + UV.x * rowvalue , texturepos.y + UV.y * columnvalue );
			return UV;
			}
			
		float3 HSV2RGB(float h, float s, float v)
			{
			return ((clamp(abs(frac(h+float3(0,2,1)/3.)*6.-3.)-1.,0.,1.)-1.)*s+1.)*v;
			}

		float3 ToonAmbient()
		{
			return float3(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w);
		}