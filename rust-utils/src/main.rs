// ======== SETTINGS ======== //



pub const WORLDS_LIST: &[(&str, &str)] = &[
	("world-1", "NETHER"),
	("world0", "OVERWORLD"),
	("world1", "END"),
];



pub const EXPORT_FOLDERS: &[&str] = &[
	"shaders",
];

pub const EXPORT_FILES: &[FileCopyData] = &[
	FileCopyData::new("LICENSE", None),
	FileCopyData::new("changelog.md", None),
	FileCopyData::new("shader readme.txt", Some("readme.txt")),
];



pub const STYLES: &[&str] = &["Vanilla", "Fantasy", "Realistic"];//, "cartoon"



// ======== END SETTINGS ======== //





const COMMANDS: &[data::Command] = &[
	data::Command::new("help", "help", "Shows the help screen", commands::help::function),
	data::Command::new("count_sloc", "count_sloc", "Counts the significant lines of code", commands::count_sloc::function),
	data::Command::new("check_settings", "check_settings", "Detects all shader settings and ensures they are consistent across all files", commands::check_settings::function),
	data::Command::new("export", "export", "Exports the shader with only shader files included", commands::export::function),
];





pub use crate::{data::*, utils::*, custom_impls::*};
pub use std::{fs, path::{PathBuf, Path}, result::Result as StdResult, process::Output as ProcessOutput, collections::{HashMap, HashSet}, ffi::OsStr, io::{self, Write}};
pub use zip::{write::{FileOptionExtension, FileOptions}, ZipWriter};
pub use walkdir::WalkDir;
pub use anyhow::*;



pub mod commands;
pub mod data;
pub mod utils;
pub mod custom_impls;



fn main() -> Result<()> {
	print!("\n\n\n");
	let mut args = std::env::args();
	
	args.next().expect("could not get program");
	
	let Some(first_arg) = args.next() else {
		println!("Error: no arguments given.");
		commands::help::print_help();
		return Ok(());
	};
	let command_args = args.collect::<Vec<String>>();
	
	for command in COMMANDS {
		if command.name == first_arg {
			command.run(&command_args)?;
			print!("\n\n\n");
			return Ok(())
		}
	}
	
	eprintln!("Unknown command: '{first_arg}'");
	println!();
	commands::help::print_help();
	print!("\n\n\n");
	Err(Error::msg("Unknown command"))
}
