shader_type canvas_item;
render_mode blend_mul;

uniform sampler2D cell_map : filter_nearest;
uniform ivec2 map_size;
uniform float cell = 80.0;

uniform vec2 building_offset = vec2(8);
uniform float building_blur = 3.1;
uniform vec3 building_tint = vec3(0.6);
uniform vec2 path_offset = vec2(8);
uniform float path_blur = 2.1;
uniform vec3 path_tint = vec3(0.57);

varying vec2 p;

void vertex() {
	p = VERTEX;
}

float phi(float z){
	return 0.5*(1.0 + tanh(0.79788*(z + 0.044715*z*z*z)));
}

float blurred_square(vec2 lo, float s){
	vec2 hi = lo + cell;
	float x = phi((hi.x - p.x)/s) - phi((lo.x - p.x)/s);
	float y = phi((hi.y - p.y)/s) - phi((lo.y - p.y)/s);
	return x*y;
}

vec2 kind(ivec2 c){
	if (c.x < 0 || c.y < 0 || c.x >= map_size.x || c.y >= map_size.y){
		return vec2(0.0);
	}
	return texelFetch(cell_map, c, 0).rg;
}

void fragment() {
	ivec2 c = ivec2(floor(p/cell));
	float building_shadow = 0.0;
	float path_shadow = 0.0;
	for (int dy = -1; dy <= 1; dy++){
		for (int dx = -1; dx<= 1; dx++){
			ivec2 n = c + ivec2(dx, dy);
			vec2 k = kind(n);
			vec2 lo = vec2(n)*cell;
			if (k.r > 0.5){
				building_shadow += blurred_square(lo + building_offset, building_blur);
			}
			if (k.r < 0.5){
				path_shadow += blurred_square(lo + path_offset, path_blur);
			}
		}
	}
	path_shadow *= kind(c).g;
	vec3 b = mix(vec3(1.0), building_tint, clamp(building_shadow, 0.0, 1.0));
	vec3 r = mix(vec3(1.0), path_tint, clamp(path_shadow, 0.0, 1.0));
	COLOR = vec4(b*r, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
