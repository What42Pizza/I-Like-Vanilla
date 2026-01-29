use crate::*;
use std::cell::UnsafeCell;



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
	#define TWEAK_GLCOLOR_BRIGHTNESS(v) glcolor.rgb *= (v - 1.0) * BRIGHT_BLOCK_DECREASE + 1.0;
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
	voxelId = uint(abs(gl_Normal.x + gl_Normal.y + gl_Normal.z) == 1.0); // assume solid if normal is non-diagonal
	#define SET_VOXEL_ID(v) voxelId = v;
#else
	#define SET_VOXEL_ID(v)
#endif

"#;



const VOXEL_DATAS_START: &str = r#"
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
// To edit the voxel datas, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

#ifdef GET_EMISSION
	emission = 0.0;
	#define SET_EMISSION(v) emission = v;
#else
	#define SET_EMISSION(v)
#endif
#ifdef GET_TRANSLUCENCY
	translucency = 0.0;
	#define SET_TRANSLUCENCY(v) translucency = v;
#else
	#define SET_TRANSLUCENCY(v)
#endif

"#;



const BLOCK_PROPERTIES_START: &str = r#"
# THIS FILE IS AUTO-GENERATED, DO NOT EDIT DIRECTLY!!!
# To edit the block-related datas, edit the 'block datas input.txt' file then (in the 'rust-utils' folder) run `cargo run -- rebuild_ids`

# How the block ids work:
# 
# 1: There is a basic int value automatically given to each block group using the rust-utils rebuild_ids command which is used to traverse the tree structure in blockDatas.glsl
# 2: Bits 14-15 are set according to the block group's shadow casting value and no bottom waving value (0 is always, 1 is never, 2 is foliage, 3 is foliage + no bottom waving)
# 4: Bit 13 is always set to ensure that no auto-generated ids can be mistaken for custom ids
# 3: Bits 11-12 are set depending on the block group's waviness value (which is 0-3)
# 5: The other 11 bits are used for the generated int value

"#;



pub fn function(args: &[String]) -> Result<()> {
	if !args.is_empty() {
		println!("Note: 'rebuild_ids' does not currently take arguments");
	}
	
	println!("Rebuilding ids...");
	let shaders_path = get_shaders_path()?;
	let input = fs::read_to_string(shaders_path.join("common/block datas input.txt"))?;
	
	// step 1: sanitize input
	let lines =
		input
		.lines()
		.enumerate()
		.filter_map(|(i, mut line)| {
			line = line.trim_start();
			if line.starts_with("//") {return None;}
			line = line.trim_end();
			if line.is_empty() {return None;}
			Some((i, line))
		})
		.collect::<Vec<_>>();
	
	// step 2: collect raw data into a `Vec<BlockData>`
	let mut block_datas = vec!();
	if !lines[0].1.starts_with("block ") {return Err(Error::msg("Input file 'block datas input.txt' is invalid: first non-removed line must start with \"block \""));}
	let block_ids = get_block_ids_from_header(lines[0].1);
	let mut curr_block_data = BlockData::new(block_ids);
	
	let mut i = 1;
	loop {
		let line_num = lines[i].0 + 1;
		let line = lines[i].1;
		if line.starts_with("block "){
			if curr_block_data.weight.is_none() {return Err(Error::msg(format!("Input file 'block datas input.txt' is invalid: block datas for {:?} does not contain a weight field", curr_block_data.block_ids)));}
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
				curr_block_data.weight = Some(value.parse()?);
			}
			
			"custom code" => {
				let pattern = value;
				let mut code = String::new();
				'inner: loop {
					i += 1;
					if lines[i].1 == pattern {break 'inner;}
					code += lines[i].1;
					code.push('\n');
				}
				curr_block_data.custom_code = Some(code);
			}
			
			"shadow casting" => {
				curr_block_data.shadow_casting = match value {
					"always" => 0,
					"foliage" => 2,
					"never" => 1,
					_ => return Err(Error::msg(format!("Invalid value for 'shadow casting': '{value}'"))),
				};
			}
			
			"waviness" => {
				curr_block_data.waviness = value.parse()?;
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
				curr_block_data.voxelize = value.parse()?;
			}
			
			"translucency" => {
				curr_block_data.translucency = Some(value);
			}
			
			"emission" => {
				curr_block_data.emission = Some(value);
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
		if i == lines.len() {break;}
	}
	if curr_block_data.weight.is_none() {return Err(Error::msg(format!("Input file 'block datas input.txt' is invalid: block datas for {:?} does not contain a weight field", curr_block_data.block_ids)));}
	block_datas.push(curr_block_data);
	
	//// step 3: extract voxel datas for later
	//let mut voxel_datas =
	//	block_datas
	//	.iter()
	//	.filter_map(|data| {
	//		if !data.voxelize {return None;}
	//		Some(VoxelData {
	//			weight: data.weight.unwrap(),
	//			emission: data.emission,
	//			translucency: data.translucency,
	//		})
	//	})
	//	.collect::<Vec<_>>();
	
	// step 3: turn big list of block datas into tree
	block_datas.sort_by(|a, b| {
		b.weight.unwrap().total_cmp(&a.weight.unwrap()) // note: sorts largest the smallest
	});
	let mut tree_nodes =
		block_datas
		.into_iter()
		.map(|data| TreeNode {
			weight: data.weight.unwrap().powf(0.7), // somewhat flattens the tree so that extremely low weights don't cause extremely high tree depths
			branches: None,
			branch_split: 0,
			leaf: Some(data),
		})
		.collect::<Vec<_>>();
	loop {
		if tree_nodes.len() == 1 {break;}
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
	
	// step 4: give block datas int ids and extract voxel datas
	// (but first, add another leaf for default blocks)
	let mut curr_leaf = &tree_nodes[0];
	loop {
		if let Some(branches) = &curr_leaf.branches {
			curr_leaf = &branches.0;
			continue;
		}
		#[allow(invalid_reference_casting)]
		let curr_leaf = unsafe {&mut *(curr_leaf as *const _ as *mut TreeNode)};
		let leaf = curr_leaf.leaf.take();
		curr_leaf.branches = Some(Box::new((TreeNode {
			weight: 0.0,
			branches: None,
			branch_split: 0,
			leaf: Some(BlockData::new(vec!("none"))),
		}, TreeNode {
			weight: curr_leaf.weight,
			branches: None,
			branch_split: 0,
			leaf,
		})));
		break;
	}
	fn postprocess_tree_data<'a>(node: &mut TreeNode<'a>, curr_id: &mut u16, voxel_datas: &mut Vec<VoxelData<'a>>) -> Result<()> {
		if let Some(branches) = &mut node.branches {
			postprocess_tree_data(&mut branches.0, curr_id, voxel_datas)?;
			node.branch_split = *curr_id;
			postprocess_tree_data(&mut branches.1, curr_id, voxel_datas)?;
		}
		if let Some(leaf) = &mut node.leaf {
			let casting_plus_bottom_value = match (leaf.shadow_casting, leaf.do_bottom_waving) {
				(0, true) => 0,
				(1, true) => 1,
				(2, true) => 2,
				(2, false) => 3,
				_ => return Err(Error::msg(format!("Group id {:?} in input file 'block datas input.txt' is invalid: combination of 'shadow casting' value {} + 'do bottom waving' value {} is not allowed", leaf.block_ids, leaf.shadow_casting, leaf.do_bottom_waving))),
			};
			leaf.int_id =
				*curr_id
				| ((leaf.waviness as u16) << 11)
				| 1 << 13
				| ((casting_plus_bottom_value) << 14);
			*curr_id += 1;
			if leaf.voxelize {
				voxel_datas.push(VoxelData {
					weight: leaf.weight.unwrap(),
					voxel_id: 0,
					emission: leaf.emission,
					translucency: leaf.translucency,
					block_data: unsafe { &*(node.leaf.as_ref().unwrap() as *const _ as *const BlockData<'a>) }, // not using unsafe here causes bad lifetime issues
				});
			}
		}
		Ok(())
	}
	let mut curr_id = 0;
	let mut voxel_datas = vec!();
	postprocess_tree_data(&mut tree_nodes[0], &mut curr_id, &mut voxel_datas)?;
	
	//static mut HIGHEST_DEPTH: usize = 0;
	//fn print_tree<'a>(node: &TreeNode<'a>, depth: usize) {
	//	unsafe {
	//		if depth > HIGHEST_DEPTH {HIGHEST_DEPTH = depth;}
	//	}
	//	let indent = "  ".repeat(depth);
	//	println!("{indent}weight: {}", node.weight);
	//	if let Some(branches) = &node.branches {
	//		print_tree(&branches.0, depth + 1);
	//		print_tree(&branches.1, depth + 1);
	//	}
	//	if let Some(leaf) = &node.leaf {
	//		println!("{indent}block ids: {:?}", leaf.block_ids);
	//	}
	//}
	//print_tree(&tree_nodes[0], 0);
	//unsafe {
	//	println!("{}", HIGHEST_DEPTH + 0);
	//}
	
	// step 5: turn big list of voxel datas into tree
	voxel_datas.sort_by(|a, b| {
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
		if voxel_tree_nodes.len() == 1 {break;}
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
	
	//static mut HIGHEST_DEPTH: usize = 0;
	//fn print_voxel_tree<'a>(node: &VoxelTreeNode<'a>, depth: usize) {
	//	unsafe {
	//		if depth > HIGHEST_DEPTH {HIGHEST_DEPTH = depth;}
	//	}
	//	let indent = "  ".repeat(depth);
	//	println!("{indent}weight: {}", node.weight);
	//	if let Some(branches) = &node.branches {
	//		print_voxel_tree(&branches.0, depth + 1);
	//		print_voxel_tree(&branches.1, depth + 1);
	//	}
	//	if let Some(leaf) = &node.leaf {
	//		println!("{indent}block ids: {:?}", leaf.voxel_id);
	//	}
	//}
	//print_voxel_tree(&tree_nodes[0], 0);
	//unsafe {
	//	println!("{}", HIGHEST_DEPTH + 0);
	//}
	
	// step 6: give voxel datas (and block datas) voxel ids
	fn postprocess_voxel_tree_data(node: &mut VoxelTreeNode, curr_voxel_id: &mut u8) {
		if let Some(branches) = &mut node.branches {
			postprocess_voxel_tree_data(&mut branches.0, curr_voxel_id);
			node.branch_split = *curr_voxel_id;
			postprocess_voxel_tree_data(&mut branches.1, curr_voxel_id);
		}
		if let Some(leaf) = &mut node.leaf {
			leaf.voxel_id = *curr_voxel_id;
			*curr_voxel_id += 1;
			unsafe {
				// Safety: idk as long as the output is good I'm happy
				*leaf.block_data.voxel_id.get() = *curr_voxel_id;
			}
		}
	}
	let mut curr_voxel_id = 2;
	postprocess_voxel_tree_data(&mut voxel_tree_nodes[0], &mut curr_voxel_id);
	
	// step 7: generate 'blockDatas.glsl' file
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
			//*block_datas_file += &format!("{indent}// id: {}\n", leaf.int_id);
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
			if leaf.voxelize {
				*block_datas_file += &format!("{indent}SET_VOXEL_ID({}u);\n", unsafe {*leaf.voxel_id.get()});
			}
		}
	}
	gen_block_datas_code(&mut block_datas_file, &tree_nodes[0], 0);
	fs::write(shaders_path.join("generated/blockDatas.glsl"), block_datas_file)?;
	
	// step 8: generate 'voxelDatas.glsl' file
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
			//*voxel_datas_file += &format!("{indent}// blocks: {:?}\n", leaf.block_data.block_ids);
			if let Some(emission) = &leaf.emission {
				*voxel_datas_file += &format!("{indent}SET_EMISSION({emission});\n");
			}
			if let Some(translucency) = &leaf.translucency {
				*voxel_datas_file += &format!("{indent}SET_TRANSLUCENCY({translucency});\n");
			}
		}
	}
	gen_voxel_datas_code(&mut voxel_datas_file, &voxel_tree_nodes[0], 0);
	fs::write(shaders_path.join("generated/voxelDatas.glsl"), voxel_datas_file)?;
	
	// step 9: generate 'block.properties' file
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
	weight: Option<f32>,
	alias: Option<&'a str>,
	custom_code: Option<String>,
	shadow_casting: u8,
	waviness: u8,
	do_bottom_waving: bool,
	reflectiveness: Option<&'a str>,
	specularness: Option<&'a str>,
	glow_detect_min: Option<&'a str>,
	glow_detect_max: Option<&'a str>,
	glow_amount: Option<&'a str>,
	brightness: Option<&'a str>,
	voxelize: bool,
	voxel_id: UnsafeCell<u8>,
	emission: Option<&'a str>,
	translucency: Option<&'a str>,
}

impl<'a> BlockData<'a> {
	fn new(block_ids: Vec<&'a str>) -> Self {
		Self {
			block_ids,
			int_id: 0,
			weight: None,
			alias: None,
			custom_code: None,
			shadow_casting: 0,
			waviness: 0,
			do_bottom_waving: true,
			reflectiveness: None,
			specularness: None,
			glow_detect_min: None,
			glow_detect_max: None,
			glow_amount: None,
			brightness: None,
			voxelize: false,
			voxel_id: UnsafeCell::new(0),
			emission: None,
			translucency: None,
		}
	}
}

#[derive(Debug)]
struct TreeNode<'a> {
	weight: f32,
	branches: Option<Box<(TreeNode<'a>, TreeNode<'a>)>>,
	branch_split: u16,
	leaf: Option<BlockData<'a>>,
}

#[derive(Debug)]
struct VoxelData<'a> {
	weight: f32,
	block_data: &'a BlockData<'a>,
	voxel_id: u8,
	emission: Option<&'a str>,
	translucency: Option<&'a str>,
}

#[derive(Debug)]
struct VoxelTreeNode<'a> {
	weight: f32,
	branches: Option<Box<(VoxelTreeNode<'a>, VoxelTreeNode<'a>)>>,
	branch_split: u8,
	leaf: Option<VoxelData<'a>>,
}
