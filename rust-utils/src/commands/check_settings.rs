use crate::prelude::*;
use std::{collections::HashSet, fs};



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'help' does not currently take arguments");
	}
	
	check_settings()?;
	println!("finished searching shaders for setting errors");
	
	Ok(())
}



/*
Strategy:
1: Go through shaders.properties and get a list of all settings in the desired order (and check for inconsistencies)
2: Go through setting_defines.glsl and check which settings are supposed to be in style files (and check for inconsistencies)
3: Go through the lang file and check for inconsistencies
4: Go through each style file and check for inconsistencies (ignoring listed settings that aren't supposed to be in style files)
*/
pub fn check_settings() -> Result<bool> {
	let shaders_path = get_shaders_path()?;
	let mut found_problems = false;
	let (prop_settings_set, prop_settings_list) = get_properties_settings(&shaders_path, &mut found_problems)?;
	let style_settings_set = check_defines_file(&shaders_path, &prop_settings_set, &prop_settings_list, &mut found_problems)?;
	check_lang_file(&shaders_path, &prop_settings_set, &prop_settings_list, &mut found_problems)?;
	for style in crate::STYLES {
		check_style_file(&shaders_path, &prop_settings_set, &prop_settings_list, &style_settings_set, style, &mut found_problems)?;
	}
	Ok(found_problems)
}



pub fn get_properties_settings(shaders_path: &Path, found_problems: &mut bool) -> Result<(HashSet<String>, Vec<String>)> {
	let properties = fs::read_to_string(shaders_path.join("shaders.properties"))?;
	let mut settings_set = HashSet::new();
	let mut settings_list = vec!();
	let mut sliders_line = None;
	for (i, mut line) in properties.lines().enumerate() {
		line = line.trim();
		if line.starts_with("sliders") {sliders_line = Some(line);}
		let Some(line) = line.strip_prefix("screen") else {continue;};
		if line.contains(".columns") {continue;}
		let Some(equal_position) = line.find('=') else {
			println!("WARNING: invalid settings screen found in shaders.properties line {}, could not find equals sign", i + 1);
			continue;
		};
		let line = line[equal_position + 1 ..].trim_start();
		for part in line.split_ascii_whitespace() {
			if part.is_empty() {continue;}
			if part.starts_with('[') {continue;}
			if part == "<empty>" {continue;}
			if part == "<profile>" {continue;}
			if settings_set.contains(part) {continue;}
			settings_set.insert(part.to_string());
			settings_list.push(part.to_string());
		}
	}
	if let Some(sliders_line) = sliders_line {
		let mut sliders_iter = sliders_line.split_ascii_whitespace();
		let first_part = sliders_iter.next();
		if first_part != Some("sliders") {println!("WARNING: found unexpected first value (\"{first_part:?}\") for sliders definition in shaders.properties");}
		let second_part = sliders_iter.next();
		if second_part != Some("=") {println!("WARNING: found unexpected second value (\"{first_part:?}\") for sliders definition in shaders.properties");}
		for part in sliders_iter {
			if settings_set.contains(part) {continue;}
			println!("WARNING: found settings in sliders (in shaders.properties) that is not listed in the settings menu: {part}");
		}
	} else {
		println!("WARNING: could not find sliders definition in shaders.properties");
	}
	Ok((settings_set, settings_list))
}



pub fn check_defines_file(shaders_path: &Path, prop_settings_set: &HashSet<String>, prop_settings_list: &[String], found_problems: &mut bool) -> Result<HashSet<String>> {
	let define_strings = fs::read_to_string(shaders_path.join("setting_defines.glsl"))?;
	let mut defines = vec!();
	let mut style_settings_set = HashSet::new();
	for (i, mut line) in define_strings.lines().enumerate() {
		line = line.trim();
		if line.starts_with("//#define ") {line = &line[2..];}
		let setting_name = if let Some(define) = line.strip_prefix("#define ") {
			let mut define_iter = define.split_ascii_whitespace();
			let Some(setting_name) = define_iter.next() else {
				println!("WARNING: invalid settings screen found in setting_defines.glsl line {}, could not get setting name", i + 1);
				continue;
			};
			if define_iter.next() == Some("-1") {
				style_settings_set.insert(setting_name.to_string());
			}
			setting_name
		} else if let Some(define) = line.strip_prefix("const ") {
			let mut parts_iter = define.split_ascii_whitespace();
			parts_iter.next();
			let Some(setting_name) = parts_iter.next() else {
				println!("WARNING: could not find setting name in setting_defines.glsl line {}", i + 1);
				continue;
			};
			setting_name
		} else {
			continue;
		};
		if !prop_settings_set.contains(setting_name) {
			println!("WARNING: found setting in define_settings which is not present in shaders.properties: {setting_name}");
		}
		defines.push(setting_name);
	}
	check_settings_order(&defines, prop_settings_list, None, "setting_defines.glsl");
	Ok(style_settings_set)
}



pub fn check_lang_file(shaders_path: &Path, prop_settings_set: &HashSet<String>, prop_settings_list: &[String], found_problems: &mut bool) -> Result<()> {
	let lang_strings = fs::read_to_string(shaders_path.join("lang/en_US.lang"))?;
	let mut settings = vec!();
	for (i, mut line) in lang_strings.lines().enumerate() {
		line = line.trim();
		let Some(entry) = line.strip_prefix("option.") else {
			continue;
		};
		if entry.contains(".comment=") {continue;}
		let Some(equal_position) = entry.find('=') else {
			println!("WARNING: invalid settings screen found in lang/en_US.lang line {}, could not find equals sign", i + 1);
			continue;
		};
		let setting_name = &entry[..equal_position];
		if !prop_settings_set.contains(setting_name) {
			println!("WARNING: found setting in lang/en_US.lang which is not present in shaders.properties: {setting_name}");
		}
		settings.push(setting_name);
	}
	check_settings_order(&settings, prop_settings_list, None, "lang/en_US.lang");
	Ok(())
}



pub fn check_style_file(
	shaders_path: &Path,
	prop_settings_set: &HashSet<String>,
	prop_settings_list: &[String],
	style_settings_set: &HashSet<String>,
	style_name: &'static str,
	found_problems: &mut bool
) -> Result<()> {
	let setting_strings = fs::read_to_string(shaders_path.join(format!("style_{style_name}.glsl")))?;
	let mut settings = vec!();
	for (i, mut setting) in setting_strings.lines().enumerate() {
		setting = setting.trim();
		let mut setting_parts = setting.split_ascii_whitespace();
		if setting_parts.next() != Some("#define") {continue;}
		let Some(setting_name) = setting_parts.next() else {
			println!("WARNING: found invalid setting with no name in style_{style_name}.glsl line {}", i + 1);
			continue;
		};
		if !prop_settings_set.contains(setting_name) {
			println!("WARNING: found setting in style {style_name} which is not present in shaders.properties: {setting_name}");
		}
		settings.push(setting_name);
	}
	check_settings_order(&settings, prop_settings_list, Some(style_settings_set), style_name);
	Ok(())
}



pub fn check_settings_order(settings_list: &[&str], prop_settings_list: &[String], style_settings_set: Option<&HashSet<String>>, file_name: &'static str) {
	let mut prev_i = 0;
	for (i, setting) in prop_settings_list.iter().enumerate() {
		if let Some(style_settings_set) = style_settings_set && !style_settings_set.contains(setting) {continue;}
		let Some((mut defines_i, _)) = settings_list.iter().enumerate().find(|(_, define)| *define == setting) else {
			println!("WARNING: found setting in shaders.properties that is not present in {file_name}: {setting}");
			continue;
		};
		defines_i += 1;
		if defines_i != prev_i + 1 {
			println!("WARNING: found setting in {file_name} with incorrect ordering: {setting}");
		}
		prev_i = defines_i;
	}
}
