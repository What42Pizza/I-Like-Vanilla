use crate::*;



pub fn create_file_contents(world_name: &str, shader_name: &str, shader_type: &str) -> String {
	let shader_name_uppercase = shader_name.to_uppercase();
	format!(r##"
#version 140

#define SHADER_{shader_name_uppercase}
#define {world_name}
#define {shader_type}

#include "/settings.glsl"
#include "/uniforms.glsl"
#include "/common.glsl"

#include "/program/{shader_name}.glsl"
"##)[1..].to_string()
}





pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'build_world_files' does not take any arguments");
	}
	println!("Building world files...");
	
	let shaders_path = get_shaders_path()?;
	for (world_folder_name, world_name) in WORLDS_LIST {
		let world_path = shaders_path.join(world_folder_name);
		if world_path.exists() {
			fs::remove_dir_all(&world_path)?;
		}
		fs::create_dir(&world_path)?;
		for shader_name in SHADERS_LIST {
			build_shader_files(world_name, shader_name, &world_path)?;
		}
		build_final_shader_files(&world_path)?;
	}
	
	println!("Done");
	Ok(())
}



pub fn build_shader_files(world_name: &str, shader_name: &str, world_path: &Path) -> Result<()> {
	let fsh_contents = create_file_contents(world_name, shader_name, "FSH");
	fs::write(world_path.join(format!("{shader_name}.fsh")), fsh_contents)?;
	let vsh_contents = create_file_contents(world_name, shader_name, "VSH");
	fs::write(world_path.join(format!("{shader_name}.vsh")), vsh_contents)?;
	Ok(())
}



pub fn build_final_shader_files(world_path: &Path) -> Result<()> {
	
	// fsh
	let fsh_contents = &r##"
#version 140

uniform sampler2D colortex7;
uniform sampler2D shadowtex0;

void main() {
	vec3 color = texelFetch(colortex7, ivec2(gl_FragCoord.xy), 0).rgb;
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}
"##[1..];
	fs::write(world_path.join("composite99.fsh"), fsh_contents)?;
	
	// vsh
	let vsh_contents = &r##"
#version 140

void main() {
	gl_Position = ftransform();
}
"##[1..];
	fs::write(world_path.join("composite99.vsh"), vsh_contents)?;
	
	Ok(())
}
