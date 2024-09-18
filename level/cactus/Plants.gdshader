shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D grass_texture : filter_nearest, source_color;
uniform sampler2D normap: hint_normal;
uniform vec2 sway = vec2(0.025,0.015);
uniform vec2 sway_speed = vec2(1.25,0.45);
uniform float alpha_scissor:hint_range(0.1, 1.0, 0.1);

void vertex(){
	//NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * sway_speed.x + UV.y) * ( 1.0 - UV.y) * sway.x;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * sway_speed.y + UV.y) * ( 1.0 - UV.y) * sway.y;
}

void fragment(){
	ALBEDO = texture(grass_texture, UV).rgb;
	ALPHA = texture(grass_texture, UV).a;
	NORMAL_MAP = texture(normap,UV).rgb;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;

}