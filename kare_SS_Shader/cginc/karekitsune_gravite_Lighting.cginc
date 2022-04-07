 
        #if !defined (UNLITPASS)
        uniform fixed4 _LightColor0;
        #endif
        

		
        inline fixed3 kktuneLighting(fixed attenuation,fixed3 ambient)
		{
            fixed3 LightingResult;

            #if defined (UNLITPASS)
                LightingResult = 1;

			#elif defined (MULTILIGHTPASS)
                LightingResult = _LightColor0 * attenuation;
                LightingResult = saturate(LightingResult);

            #else

                LightingResult = lerp(_LightColor0 * attenuation , _LightColor0 , step(_WorldSpaceLightPos0.w ,0.5));//DirectionalLightが何故か無い場合を考慮
                LightingResult = saturate(LightingResult) + ambient;//(何故か)saturate掛けないと真っ黒になる場合がある

                LightingResult = saturate(LightingResult);

            #endif

            return LightingResult;
		}

    


