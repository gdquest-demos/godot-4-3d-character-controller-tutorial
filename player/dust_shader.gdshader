shader_type spatial;
render_mode unshaded, ambient_light_disabled;

uniform sampler2D voronoi_sampler : filter_linear_mipmap, repeat_enable;

varying vec4 custom;

void vertex() {
	
	mat4 mat_world = mat4(normalize(INV_VIEW_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]) ,normalize(INV_VIEW_MATRIX[2]), MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	float voronoi = texture(voronoi_sampler, UV * 0.25 + vec2(0.0, custom.z)).x;
	float dist = distance(UV, vec2(0.5));
	float dist_mask = smoothstep(0.5, 0.0, dist);
	float mask = max(0.0, dist_mask - voronoi);
	ALBEDO = COLOR.rgb;
	ALPHA = mask * COLOR.a;
}