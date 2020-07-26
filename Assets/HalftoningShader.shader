// Drawing Diagonal Line on the surface of the model based on shading?.
// Based on : https://www.codebot.org/articles/?doc=9525
// Further Improvement
// - Can we change the angle of direction as parameter changes?
// - Add Specular Component

Shader "paganinist/HalftoningShader" { // defines the name of the shader 
    Properties
    {
        
        _Color("Main Color", Color) = (1.0, 0.0, 0.0, 1.0) // Light Components
        _Thickness("Thickness", Float) = 0.5
    }
   SubShader { // Unity chooses the subshader that fits the GPU best
        Pass { // some shaders require multiple passes

            CGPROGRAM // here begins the part in Unity's Cg
            #pragma vertex vert // this specifies the vert function as the vertex shader 
            #pragma fragment frag // this specifies the frag function as the fragment shader            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Assets/reflection-v0.0/BlinnPhong.cginc"

            float4 _Color;
            float _Thickness;

            struct appdata 
            {
                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
            };

            // [Region] Data structures for internal data trasfer
            struct v2f // // Struct for data transfer from vertex shader to fragment shader
            {
                float4 vertexPos : SV_POSITION;
                float4 worldVertexPos : TEXCOORD0;

                float3 worldNormal : TEXCOORD1;
                float3 worldLightDir : TEXCOORD2;
            };

            float balance(float _sample, float weight) 
            {
                // What is the purpose of this function anyway?
                if(weight < 1.0) weight = _sample + weight;
                return saturate(pow(weight, 5.0));
            }

            v2f vert(appdata v) // vertex shader 
            {
                v2f o;
                // UnityObjectToClipPos() : same as mul(UNITY_MATRIX_MVP, float4(pos, 1.0))
                o.vertexPos = UnityObjectToClipPos(v.vertexPos); 
                o.worldVertexPos = mul(unity_ObjectToWorld, float4(v.vertexPos.xyz, 1.0));
                // UnityObjectToWorldNormal() : transform normal from object to world space (UnityCG.cginc)
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldLightDir = normalize(_WorldSpaceLightPos0);
                return o;
            }

            float4 frag(v2f i) : SV_Target // fragment shader
            {
                // Shade
                float4 color = shade(
                    normalize(i.worldNormal), 
                    normalize(i.worldLightDir), // Should be normlized?
                    _Color,
                    _LightColor0.rgb
                    );

                // Calculate Diagonal/Wave Line
                float2 pixel = floor(float2(i.vertexPos.xy));

                float b = _Thickness / 2.0;
                if(fmod(pixel.y, _Thickness * 2.0) > _Thickness) pixel.x += b;
                pixel = fmod(pixel, float2(_Thickness, _Thickness));
                float a = distance(pixel, float2(b, b)) / (_Thickness * 0.65);

                float diagonal = balance(color.r, a);
                if(diagonal > 0.25) color.rgb = float3(1.0, 1.0, 1.0); // Whitening Un-Diagonalized Area, [Improve : Could it be adaptive?]

                return float4(color.rgb * diagonal, 1.0); 
                // this fragment shader returns a nameless fragment
                // output parameter (with semantic COLOR) that is set to
                // opaque red (red = 1, green = 0, blue = 0, alpha = 1)
            }

            ENDCG // here ends the part in Cg 
      }
   }
}