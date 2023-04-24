shader_type spatial;

uniform sampler2D terrain_grass;
uniform sampler2D terrain_rock;
uniform sampler2D terrain_beach;
uniform float min_grass_height = 1.0;
uniform float max_rock_height = 20.0;
varying float vertex_y;
uniform vec2 uvscale = vec2(5);
void fragment() {
	float vert_weight = vertex_y;
	
	vec3 grass = texture(terrain_grass,UV*uvscale).rgb;
	vec3 rock = texture(terrain_rock,UV*uvscale).rgb;
	vec3 beach = texture(terrain_beach,UV*uvscale).rgb;
	
	if (vert_weight >= 0.5) {
		float weight = smoothstep(min_grass_height,max_rock_height,vert_weight);
		vec3 final_color = mix(grass,rock,weight);
		ALBEDO = final_color.rgb;
	}
	if (vert_weight < 0.5) {
		float weight = smoothstep(-7.0,1.0,vert_weight);
		vec3 final_color = mix(grass,beach,weight);
		ALBEDO = final_color.rgb;
	}
}
void vertex(){
	vertex_y = VERTEX.y;
}

