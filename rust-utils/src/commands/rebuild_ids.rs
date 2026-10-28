use crate::*;



const BLOCK_DATAS_START: &str = r#"
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
// To edit the block datas, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

#ifdef GET_REFLECTIVENESS
	reflectiveness = 0.0;
	#define SET_REFLECTIVENESS(v) reflectiveness = v;
#else
	#define SET_REFLECTIVENESS(v)
#endif
#ifdef GET_SPECULARNESS
	specularness = 0.0;
	#define SET_SPECULARNESS(v) specularness = v;
#else
	#define SET_SPECULARNESS(v)
#endif
#ifdef DO_BRIGHTNESS_TWEAKS
	#define TWEAK_GLCOLOR_BRIGHTNESS(v) glcolor.rgb *= (v - 1.0) * BRIGHTNESS_TWEAKS_STRENGTH + 1.0;
#else
	#define TWEAK_GLCOLOR_BRIGHTNESS(v)
#endif
#ifdef GET_GLOWING_COLOR
	glowingColorMin = vec3(-1.0);
	glowingColorMax = vec3(-1.0);
	#define SET_GLOWING_COLOR(v1, v2, v3) glowingColorMin = (v1 - 0.5) / vec3(360.0, 100.0, 100.0); glowingColorMax = (v2 + 0.5) / vec3(360.0, 100.0, 100.0); glowingAmount = v3;
#else
	#define SET_GLOWING_COLOR(v1, v2, v3)
#endif
#ifdef GET_VOXEL_ID
	#define SET_VOXEL_ID(v) voxelId = v;
#else
	#define SET_VOXEL_ID(v)
#endif

"#;



const VOXEL_DATAS_START: &str = r#"
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
// To edit the voxel datas, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

#ifdef GET_EMISSION
	emission = vec3(0.0);
	#define SET_EMISSION(v) emission = v;
#else
	#define SET_EMISSION(v)
#endif
#ifdef GET_TRANSLUCENCY
	translucency = vec3(1.0);
	#define SET_TRANSLUCENCY(v) translucency = v;
#else
	#define SET_TRANSLUCENCY(v)
#endif

"#;



const GENERATED_COMMON_START: &str = r#"
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
// To edit auto-generated data, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

"#;



const BLOCK_PROPERTIES_START: &str = r#"
# THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
# To edit the block-related datas, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

# How the block ids work:
# 
# 1: There is a basic int value automatically given to each block group using the rust-utils rebuild_ids command which is used to traverse the tree structure in blockDatas.glsl
# 2: Bit 14 is always set to ensure that no auto-generated ids can be mistaken for custom ids
# 3: Bits 12-13 are set according to the block group's shadow casting value and no bottom waving value (0 is always, 1 is never, 2 is foliage, 3 is foliage + no bottom waving)
# 4: Bits 10-11 are set depending on the block group's waviness value (which is 0-3)
# 5: The other 10 bits are used for the generated int value

"#;



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'rebuild_ids' does not currently take arguments");
	}
	
	println!("Rebuilding ids...");
	let shaders_path = get_shaders_path()?;
	let input = fs::read_to_string(shaders_path.join("block datas input.txt"))?;
	
	// step 1: sanitize input
	let lines =
		input
		.lines()
		.enumerate()
		.filter_map(|(i, mut line)| {
			line = line.trim_start();
			if line.starts_with("//") { return None; }
			line = line.trim_end();
			if line.is_empty() { return None; }
			Some((i, line))
		})
		.collect::<Vec<_>>();
	
	// step 2: collect all raw block datas into a `Vec<BlockData>`
	let mut block_datas = vec![];
	if !lines[0].1.starts_with("block ") { return Err(Error::msg("Input file 'block datas input.txt' is invalid: first non-removed line must start with \"block \"")); }
	let block_ids = get_block_ids_from_header(lines[0].1);
	let mut curr_block_data = BlockData::new(block_ids);
	
	let mut i = 1;
	loop {
		let line_num = lines[i].0 + 1;
		let line = lines[i].1;
		if line.starts_with("block "){
			if curr_block_data.weight == 0.0 { return Err(Error::msg(format!("Input file 'block datas input.txt' is invalid: block datas for {:?} does not contain a weight field, or the weight was set to 0.0", curr_block_data.block_ids))); }
			block_datas.push(curr_block_data);
			let block_ids = get_block_ids_from_header(line);
			curr_block_data = BlockData::new(block_ids);
			i += 1;
			continue;
		}
		let colon_index = line.find(':').ok_or_else(|| Error::msg(format!("Input file 'block datas input.txt' is invalid: line {line_num} has no colon")))?;
		let key = &line[..colon_index];
		let value = &line[colon_index + 2 ..];
		match key {
			
			"alias" => {
				curr_block_data.alias = Some(value);
			}
			
			"weight" => {
				curr_block_data.weight = value.parse()?;
			}
			
			"custom code" => {
				let pattern = value;
				let mut code = String::new();
				'inner: loop {
					i += 1;
					if lines[i].1 == pattern { break 'inner; }
					code += lines[i].1;
					code.push('\n');
				}
				curr_block_data.custom_code = Some(code);
			}
			
			"custom voxel code" => {
				let pattern = value;
				let mut code = String::new();
				'inner: loop {
					i += 1;
					if lines[i].1 == pattern { break 'inner; }
					code += lines[i].1;
					code.push('\n');
				}
				curr_block_data.custom_voxel_code = Some(code);
			}
			
			"shadow casting" => {
				curr_block_data.shadow_casting = match value {
					"always" => ShadowCastingValue::Always,
					"foliage" => ShadowCastingValue::Foliage,
					"never" => ShadowCastingValue::Never,
					_ => return Err(Error::msg(format!("Invalid value for 'shadow casting': '{value}'"))),
				};
			}
			
			"waviness" => {
				curr_block_data.waviness = match value.parse::<u8>()? {
					0 => WavinessValue::None,
					1 => WavinessValue::Low,
					2 => WavinessValue::Medium,
					3 => WavinessValue::High,
					_ => return Err(Error::msg(format!("Invalid value for 'waviness': '{value}'"))),
				};
			}
			
			"do bottom waving" => {
				curr_block_data.do_bottom_waving = value.parse()?;
			}
			
			"reflectiveness" => {
				curr_block_data.reflectiveness = Some(value);
			}
			
			"specularness" => {
				curr_block_data.specularness = Some(value);
			}
			
			"voxelize" => {
				curr_block_data.voxelize = match &*value.to_lowercase() {
					"true" => VoxelizeValue::True,
					"false" => VoxelizeValue::False,
					"empty" => VoxelizeValue::Empty,
					_ => bail!("Invalid value for 'voxelize': '{value}', must be 'true', 'false', or 'empty'"),
				};
			}
			
			"emission" => {
				curr_block_data.voxel_emission = Some(value);
			}
			
			"translucency" => {
				curr_block_data.voxel_translucency = Some(value);
			}
			
			"glow detect min" => {
				curr_block_data.glow_detect_min = Some(value);
			}
			
			"glow detect max" => {
				curr_block_data.glow_detect_max = Some(value);
			}
			
			"glow amount" => {
				curr_block_data.glow_amount = Some(value);
			}
			
			"brightness" => {
				curr_block_data.brightness = Some(value);
			}
			
			_ => return Err(Error::msg(format!("Input file 'block datas input.txt' is invalid: line {} cannot start with \"{}\"", line_num, key))),
			
		}
		i += 1;
		if i == lines.len() { break; }
	}
	if curr_block_data.weight == 0.0 { return Err(Error::msg(format!("Input file 'block datas input.txt' is invalid: block datas for {:?} does not contain a weight field, or the weight was set to 0.0", curr_block_data.block_ids))); }
	block_datas.push(curr_block_data);
	
	// step 3: turn big list of block datas into a tree
	block_datas.sort_by(|a, b| {
		b.weight.total_cmp(&a.weight) // note: sorts largest the smallest
	});
	let mut tree_nodes =
		block_datas
		.iter_mut()
		.map(|data| TreeNode {
			weight: data.weight.powf(0.7), // somewhat flattens the tree so that extremely low weights don't cause extremely high tree depths
			branches: None,
			branch_split: 0,
			leaf: Some(data),
		})
		.collect::<Vec<_>>();
	loop {
		if tree_nodes.len() == 1 { break; }
		let node_a = tree_nodes.pop().unwrap();
		let node_b = tree_nodes.pop().unwrap();
		let new_weight = node_a.weight + node_b.weight;
		let new_node = TreeNode {
			weight: new_weight,
			branches: Some(Box::new((node_a, node_b))),
			branch_split: 0,
			leaf: None,
		};
		let new_index = tree_nodes.binary_search_by(|v| new_weight.total_cmp(&v.weight));
		let new_index = new_index.unwrap_or_else(|new_index| new_index);
		tree_nodes.insert(new_index, new_node);
	}
	
	// step 4: add another leaf that represents the default for when no block id is given
	// this leaf is positioned so that it will always receive the int id 0
	let mut curr_leaf = &tree_nodes[0];
	loop {
		if let Some(branches) = &curr_leaf.branches {
			curr_leaf = &branches.0;
			continue;
		} else {
			break;
		}
	}
	#[allow(invalid_reference_casting)]
	let curr_leaf = unsafe { &mut *(curr_leaf as *const _ as *mut TreeNode) };
	let mut empty_block_id = BlockData::new(vec!("none"));
	curr_leaf.branches = Some(Box::new((TreeNode {
		weight: 0.0,
		branches: None,
		branch_split: 0,
		leaf: Some(&mut empty_block_id),
	}, TreeNode {
		weight: curr_leaf.weight,
		branches: None,
		branch_split: 0,
		leaf: curr_leaf.leaf.take(),
	})));
	
	// step 5: give block datas int ids and extract voxel and alias datas
	fn postprocess_tree_data<'a>(node: &mut TreeNode<'a>, curr_id: &mut u16, aliases: &mut Vec<(&'a str, u16)>) -> Result<()> {
		if let Some(branches) = &mut node.branches {
			postprocess_tree_data(&mut branches.0, curr_id, aliases)?;
			node.branch_split = *curr_id;
			postprocess_tree_data(&mut branches.1, curr_id, aliases)?;
		}
		if let Some(leaf) = &mut node.leaf {
			let casting_plus_bottom_value = match (leaf.shadow_casting, leaf.do_bottom_waving) {
				(ShadowCastingValue::Always, true) => 0,
				(ShadowCastingValue::Never, true) => 1,
				(ShadowCastingValue::Foliage, true) => 2,
				(ShadowCastingValue::Foliage, false) => 3,
				_ => return Err(Error::msg(format!("Group id {:?} in input file 'block datas input.txt' is invalid: combination of 'shadow casting' value {:?} + 'do bottom waving' value {} is not allowed", leaf.block_ids, leaf.shadow_casting, leaf.do_bottom_waving))),
			};
			leaf.int_id =
				*curr_id
				| 1 << 14
				| ((casting_plus_bottom_value) << 12)
				| ((leaf.waviness as u16) << 10);
			*curr_id += 1;
			if let Some(alias) = leaf.alias {
				aliases.push((alias, leaf.int_id));
			}
		}
		Ok(())
	}
	let mut curr_id = 0;
	let mut aliases = vec![];
	postprocess_tree_data(&mut tree_nodes[0], &mut curr_id, &mut aliases)?;
	
	// step 6: gather all block datas that will be voxelized
	fn gather_voxel_datas<'a>(node: &'a mut TreeNode<'a>, voxel_datas: &mut Vec<&'a mut &'a mut BlockData<'a>>) {
		if let Some(branches) = &mut node.branches {
			gather_voxel_datas(&mut branches.0, voxel_datas);
			gather_voxel_datas(&mut branches.1, voxel_datas);
		}
		if let Some(leaf) = &mut node.leaf && leaf.voxelize == VoxelizeValue::True {
			voxel_datas.push(leaf);
		}
	}
	let mut voxel_datas = vec![];
	#[allow(invalid_reference_casting)]
	let tree_nodes_2 = unsafe { &mut *(&tree_nodes as *const _ as *mut Vec<TreeNode>) };
	gather_voxel_datas(&mut tree_nodes_2[0], &mut voxel_datas);
	
	// step 7: turn big list of voxel datas into tree
	voxel_datas.sort_by(|a: &&mut &mut BlockData, b: &&mut &mut BlockData| {
		b.weight.total_cmp(&a.weight) // note: sorts largest the smallest
	});
	let mut voxel_tree_nodes =
		voxel_datas
		.into_iter()
		.map(|data| VoxelTreeNode {
			weight: data.weight.powf(0.7), // somewhat flattens the tree so that extremely low weights don't cause extremely high tree depths
			branches: None,
			branch_split: 0,
			leaf: Some(data),
		})
		.collect::<Vec<_>>();
	loop {
		if voxel_tree_nodes.len() == 1 { break; }
		let node_a = voxel_tree_nodes.pop().unwrap();
		let node_b = voxel_tree_nodes.pop().unwrap();
		let new_weight = node_a.weight + node_b.weight;
		let new_node = VoxelTreeNode {
			weight: new_weight,
			branches: Some(Box::new((node_a, node_b))),
			branch_split: 0,
			leaf: None,
		};
		let new_index = voxel_tree_nodes.binary_search_by(|v| new_weight.total_cmp(&v.weight));
		let new_index = new_index.unwrap_or_else(|new_index| new_index);
		voxel_tree_nodes.insert(new_index, new_node);
	}
	
	// step 8: give block datas voxel ids
	fn postprocess_voxel_tree_data(node: &mut VoxelTreeNode, curr_voxel_id: &mut u8) {
		if let Some(branches) = &mut node.branches {
			postprocess_voxel_tree_data(&mut branches.0, curr_voxel_id);
			node.branch_split = *curr_voxel_id;
			postprocess_voxel_tree_data(&mut branches.1, curr_voxel_id);
		}
		if let Some(leaf) = &mut node.leaf && leaf.voxelize != VoxelizeValue::Empty {
			leaf.voxel_id = *curr_voxel_id;
			*curr_voxel_id += 1;
		}
	}
	let mut curr_voxel_id = 2;
	postprocess_voxel_tree_data(&mut voxel_tree_nodes[0], &mut curr_voxel_id);
	
	// step 9: generate 'blockDatas.glsl' file
	let mut block_datas_file = BLOCK_DATAS_START[1..].to_string();
	fn gen_block_datas_code(block_datas_file: &mut String, node: &TreeNode, depth: usize) {
		let indent = "\t".repeat(depth);
		if let Some(branches) = &node.branches {
			*block_datas_file += &format!("{indent}if (materialId < {}u) {{\n", node.branch_split);
			gen_block_datas_code(block_datas_file, &branches.0, depth + 1);
			*block_datas_file += &format!("{indent}}} else {{\n");
			gen_block_datas_code(block_datas_file, &branches.1, depth + 1);
			*block_datas_file += &format!("{indent}}}\n");
		}
		if let Some(leaf) = &node.leaf {
			//*block_datas_file += &format!("{indent}// block id: {}, material id: {}\n", leaf.int_id, leaf.int_id & 0x3FF);
			//*block_datas_file += &format!("{indent}// blocks: {:?}\n", leaf.block_ids);
			if let Some(reflectiveness) = &leaf.reflectiveness {
				*block_datas_file += &format!("{indent}SET_REFLECTIVENESS({reflectiveness});\n");
			}
			if let Some(specularness) = &leaf.specularness {
				*block_datas_file += &format!("{indent}SET_SPECULARNESS({specularness});\n");
			}
			if let Some(glow_detect_min) = &leaf.glow_detect_min {
				*block_datas_file += &format!("{indent}SET_GLOWING_COLOR({glow_detect_min}, ");
			}
			if let Some(glow_detect_max) = &leaf.glow_detect_max {
				*block_datas_file += &format!("{glow_detect_max}, ");
			}
			if let Some(glow_amount) = &leaf.glow_amount {
				*block_datas_file += &format!("{glow_amount});\n");
			}
			if let Some(brightness) = &leaf.brightness {
				*block_datas_file += &format!("{indent}TWEAK_GLCOLOR_BRIGHTNESS({brightness});\n");
			}
			if let Some(custom_code) = &leaf.custom_code {
				*block_datas_file += custom_code;
			}
			if matches!(leaf.voxelize, VoxelizeValue::True | VoxelizeValue::Empty) {
				*block_datas_file += &format!("{indent}SET_VOXEL_ID({}u);\n", leaf.voxel_id);
			}
		}
	}
	gen_block_datas_code(&mut block_datas_file, &tree_nodes[0], 0);
	fs::write(shaders_path.join("generated/blockDatas.glsl"), block_datas_file)?;
	
	// step 10: generate 'voxelDatas.glsl' file
	let mut voxel_datas_file = VOXEL_DATAS_START[1..].to_string();
	fn gen_voxel_datas_code(voxel_datas_file: &mut String, node: &VoxelTreeNode, depth: usize) {
		let indent = "\t".repeat(depth);
		if let Some(branches) = &node.branches {
			*voxel_datas_file += &format!("{indent}if (voxelId < {}u) {{\n", node.branch_split);
			gen_voxel_datas_code(voxel_datas_file, &branches.0, depth + 1);
			*voxel_datas_file += &format!("{indent}}} else {{\n");
			gen_voxel_datas_code(voxel_datas_file, &branches.1, depth + 1);
			*voxel_datas_file += &format!("{indent}}}\n");
		}
		if let Some(leaf) = &node.leaf {
			//*voxel_datas_file += &format!("{indent}// blocks: {:?}\n", leaf.block_ids);
			if let Some(emission) = &leaf.voxel_emission {
				*voxel_datas_file += &format!("{indent}SET_EMISSION({emission});\n");
			}
			if let Some(translucency) = &leaf.voxel_translucency {
				*voxel_datas_file += &format!("{indent}SET_TRANSLUCENCY({translucency});\n");
			}
			if let Some(custom_voxel_code) = &leaf.custom_voxel_code {
				*voxel_datas_file += custom_voxel_code;
			}
		}
	}
	gen_voxel_datas_code(&mut voxel_datas_file, &voxel_tree_nodes[0], 0);
	fs::write(shaders_path.join("generated/voxelDatas.glsl"), voxel_datas_file)?;
	
	// step 11: generate 'block.properties' file
	let mut block_properties_file = BLOCK_PROPERTIES_START[1..].to_string();
	fn gen_block_properties_code(block_properties_file: &mut String, node: &TreeNode) {
		if let Some(branches) = &node.branches {
			gen_block_properties_code(block_properties_file, &branches.0);
			gen_block_properties_code(block_properties_file, &branches.1);
		}
		if let Some(leaf) = &node.leaf {
			*block_properties_file += &format!("block.{} =", leaf.int_id);
			for id in &leaf.block_ids {
				block_properties_file.push(' ');
				*block_properties_file += id;
			}
			block_properties_file.push('\n');
		}
	}
	gen_block_properties_code(&mut block_properties_file, &tree_nodes[0]);
	fs::write(shaders_path.join("block.properties"), block_properties_file)?;
	
	// step 12: generate 'item.properties' file
	let mut item_properties_file = BLOCK_PROPERTIES_START[1..].to_string();
	fn gen_item_properties_code(item_properties_file: &mut String, node: &TreeNode) {
		if let Some(branches) = &node.branches {
			gen_item_properties_code(item_properties_file, &branches.0);
			gen_item_properties_code(item_properties_file, &branches.1);
		}
		if let Some(leaf) = &node.leaf {
			*item_properties_file += &format!("item.{} =", leaf.int_id);
			for id in &leaf.block_ids {
				item_properties_file.push(' ');
				*item_properties_file += id;
			}
			item_properties_file.push('\n');
		}
	}
	gen_item_properties_code(&mut item_properties_file, &tree_nodes[0]);
	fs::write(shaders_path.join("item.properties"), &item_properties_file)?;
	
	// step 13: generate 'generated/common.glsl'
	let mut generated_common_file = GENERATED_COMMON_START[1..].to_string();
	for (alias, int_id) in aliases {
		generated_common_file += &format!("const uint {alias} = {}u;\n", int_id & ((1 << 10) - 1));
	}
	fs::write(shaders_path.join("generated/common.glsl"), generated_common_file)?;
	
	println!("Done");
	
	Ok(())
}



fn get_block_ids_from_header(header_line: &str) -> Vec<&str> {
	header_line
		.split(' ')
		.skip(1)
		.map(|part| &part[..part.len() - 1])
		.collect::<Vec<_>>()
}



#[derive(Debug)]
struct BlockData<'a> {
	block_ids: Vec<&'a str>,
	int_id: u16,
	weight: f32,
	alias: Option<&'a str>,
	custom_code: Option<String>,
	custom_voxel_code: Option<String>,
	shadow_casting: ShadowCastingValue,
	waviness: WavinessValue,
	do_bottom_waving: bool,
	reflectiveness: Option<&'a str>,
	specularness: Option<&'a str>,
	glow_detect_min: Option<&'a str>,
	glow_detect_max: Option<&'a str>,
	glow_amount: Option<&'a str>,
	brightness: Option<&'a str>,
	voxelize: VoxelizeValue,
	voxel_id: u8,
	voxel_emission: Option<&'a str>,
	voxel_translucency: Option<&'a str>,
}

impl<'a> BlockData<'a> {
	fn new(block_ids: Vec<&'a str>) -> Self {
		Self {
			block_ids,
			int_id: 0,
			weight: 0.0,
			alias: None,
			custom_code: None,
			custom_voxel_code: None,
			shadow_casting: ShadowCastingValue::Always,
			waviness: WavinessValue::None,
			do_bottom_waving: true,
			reflectiveness: None,
			specularness: None,
			glow_detect_min: None,
			glow_detect_max: None,
			glow_amount: None,
			brightness: None,
			voxelize: VoxelizeValue::False,
			voxel_id: 0u8,
			voxel_emission: None,
			voxel_translucency: None,
		}
	}
}

#[derive(Debug, Copy, Clone, PartialEq)]
enum ShadowCastingValue {
	Always = 0,
	Foliage = 2,
	Never = 1,
}

#[derive(Debug, Copy, Clone, PartialEq)]
enum WavinessValue {
	None = 0,
	Low = 1,
	Medium = 2,
	High = 3,
}

#[derive(Debug, Copy, Clone, PartialEq)]
enum VoxelizeValue {
	True,
	False,
	Empty,
}

#[derive(Debug)]
struct TreeNode<'a> {
	weight: f32,
	branches: Option<Box<(TreeNode<'a>, TreeNode<'a>)>>,
	branch_split: u16,
	leaf: Option<&'a mut BlockData<'a>>,
}

#[derive(Debug)]
struct VoxelTreeNode<'a> {
	weight: f32,
	branches: Option<Box<(VoxelTreeNode<'a>, VoxelTreeNode<'a>)>>,
	branch_split: u8,
	leaf: Option<&'a mut BlockData<'a>>,
}
