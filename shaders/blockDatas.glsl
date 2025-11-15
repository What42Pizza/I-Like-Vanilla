/*

if I ever want to switch to a huffman-like tree encoding, I'd probably structure the data like like this and auto-generate the if-tree and block.properties

oak_leaves, spruce_leaves, birch_leaves, jungle_leaves, acacia_leaves, dark_oak_leaves, mangrove_leaves, azalea_leaves, flowering_azalea_leaves:
	mult: 3000
	specular: 1.0
	voxel_mult: vec3(0.5, 0.7, 0.5)

water, flowing_water:
	mult: 1000
	specular: 1.0
	reflective: mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y)
	voxel_mult: vec3(0.6, 0.85, 0.95)

white_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
white_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
light_gray_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
light_gray_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
gray_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
gray_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
black_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
black_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
brown_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
brown_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
red_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
red_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
orange_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
orange_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
yellow_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
yellow_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
lime_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
lime_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
green_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
green_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
cyan_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
cyan_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
light_blue_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
light_blue_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
blue_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
blue_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
purple_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
purple_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
magenta_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
magenta_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
pink_stained_glass:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)
pink_stained_glass_pane:
	mult: 25
	specular: 1.0,
	reflective: 0.3
	voxel_mult: vec3(0.5)

white_candle:
	mult: 1
	specular: 0.8
light_gray_candle:
	mult: 1
	specular: 0.8
gray_candle:
	mult: 1
	specular: 0.8
black_candle:
	mult: 1
	specular: 0.8
brown_candle:
	mult: 1
	specular: 0.8
red_candle:
	mult: 1
	specular: 0.8
orange_candle:
	mult: 1
	specular: 0.8
yellow_candle:
	mult: 1
	specular: 0.8
lime_candle:
	mult: 1
	specular: 0.8
green_candle:
	mult: 1
	specular: 0.8
cyan_candle:
	mult: 1
	specular: 0.8
light_blue_candle:
	mult: 1
	specular: 0.8
blue_candle:
	mult: 1
	specular: 0.8
purple_candle:
	mult: 1
	specular: 0.8
magenta_candle:
	mult: 1
	specular: 0.8
pink_candle:
	mult: 1
	specular: 0.8

white_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
light_gray_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
gray_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
black_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
brown_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
red_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
orange_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
yellow_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
lime_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
green_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
cyan_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
light_blue_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
blue_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
purple_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
magenta_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)
pink_candle:lit=true:
	mult: 1
	specular: 0.8
	voxel_add: vec3(0.5)

light:level=0:
	mult: 1
	voxel_add: vec3(0/15)
light:level=1:
	mult: 1
	voxel_add: vec3(1/15)
light:level=2:
	mult: 1
	voxel_add: vec3(2/15)
light:level=3:
	mult: 1
	voxel_add: vec3(3/15)
light:level=4:
	mult: 1
	voxel_add: vec3(4/15)
light:level=5:
	mult: 1
	voxel_add: vec3(5/15)
light:level=6:
	mult: 1
	voxel_add: vec3(6/15)
light:level=7:
	mult: 1
	voxel_add: vec3(7/15)
light:level=8:
	mult: 1
	voxel_add: vec3(8/15)
light:level=9:
	mult: 1
	voxel_add: vec3(9/15)
light:level=10:
	mult: 1
	voxel_add: vec3(10/15)
light:level=11:
	mult: 1
	voxel_add: vec3(11/15)
light:level=12:
	mult: 1
	voxel_add: vec3(12/15)
light:level=13:
	mult: 1
	voxel_add: vec3(13/15)
light:level=14:
	mult: 1
	voxel_add: vec3(14/15)
light:level=15:
	mult: 1
	voxel_add: vec3(15/15)

*/



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
	#define TWEAK_GLCOLOR_BRIGHTNESS(v) glcolor.rgb *= v;
#else
	#define TWEAK_GLCOLOR_BRIGHTNESS(v)
#endif
#ifdef GET_VOXEL_ID
	voxelId = 0u;
	#define SET_VOXEL_ID(v) voxelId = v;
#else
	#define SET_VOXEL_ID(v)
#endif

// Note: these comments use `..` like Rust does, where the range is [min..max)
if (materialId < 1570u) { // 0..1570
	if (materialId < 1500u) { // 0..1500 (unused)
		
	} else { // 1500..1570
		SET_VOXEL_ID(materialId - 1500u + 2u);
		if (materialId < 1532u) { // 1500..1532
			// glass
			SET_REFLECTIVENESS(0.3);
			SET_SPECULARNESS(1.0);
		} else { // 1532..1570
			// candles
			SET_SPECULARNESS(1.0);
		}
	}
} else { // 1570..15503
	if (materialId < 1620u) { // 1570..1620
		if (materialId < 1590u) { // 1570..1590
			if (materialId < 1580u) { // 1570..1580
				if (materialId < 1573u) { // 1570..1573
					if (materialId == 1570u) {
						// water
						SET_REFLECTIVENESS(mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y));
						SET_SPECULARNESS(4.0); // values greater than 1.0 only work here bc this isn't deferred lighting and the specular value is immediately unsed instead of stored
						SET_VOXEL_ID(100u);
					} else if (materialId == 1571u) {
						// lava
						SET_VOXEL_ID(101u);
					} else {
						// ice
						SET_REFLECTIVENESS(0.4);
						SET_SPECULARNESS(0.5);
						SET_VOXEL_ID(110u);
					}
				} else { // 1573..1580
					if (materialId < 1575u) { // 1573..1575
						if (materialId == 1573u) {
							// tinted glass
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
							SET_VOXEL_ID(111u);
						} else {
							// glass
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						}
					} else { // 1575..1580
						if (materialId == 1575u) {
							// slime block
							SET_REFLECTIVENESS(0.2);
							SET_SPECULARNESS(0.3);
							SET_VOXEL_ID(112u);
						} else {
							SET_REFLECTIVENESS(0.25);
							SET_SPECULARNESS(0.3);
							SET_VOXEL_ID(113u);
						}
					}
				}
			} else { // 1580..1590
				if (materialId < 1584u) { // 1580..1584
					if (materialId < 1582u) { // 1580..1582
						if (materialId == 1580u) {
							// torch, etc
							SET_VOXEL_ID(120u);
						} else {
							// soul torch, etc
							SET_VOXEL_ID(121u);
						}
					} else { // 1582..1584
						if (materialId == 1582u) {
							// redstone torch
							SET_VOXEL_ID(121u);
						} else {
							// sea lantern
							SET_VOXEL_ID(122u);
						}
					}
				} else { // 1584..1590
					if (materialId < 1586u) { // 1584..1586
						if (materialId == 1584u) {
							// beacon
							SET_VOXEL_ID(123u);
						} else {
							// redstone lamp, etc
							SET_VOXEL_ID(124u);
						}
					} else { // 1586..1590
						if (materialId == 1586u) {
							// lava couldron
							SET_SPECULARNESS(0.5);
							SET_VOXEL_ID(101u); // same voxel id as lava
						} else {
							// command blocks
							SET_SPECULARNESS(0.75);
							SET_VOXEL_ID(125u); // same voxel id as lava
						}
					}
				}
			}
		} else { // 1590..1620
			if (materialId < 1600u) { // 1590 .. 1600
				if (materialId < 1594u) { // 1590..1594
					if (materialId < 1592u) { // 1590..1592
						if (materialId == 1590u) {
							// glow lichen
							
						} else {
							// cave_vines + berries
							
						}
					} else { // 1592..1594
						if (materialId == 1592u) {
							// sea pickle
							
						} else {
							// redstone ore
							
						}
					}
				} else { // 1594..1600
					if (materialId < 1597u) { // 1594..1597
						if (materialId == 1594u) {
							// ochre froglight
							TWEAK_GLCOLOR_BRIGHTNESS(0.85);
						} else if (materialId == 1595u) {
							// verdant froglight
							TWEAK_GLCOLOR_BRIGHTNESS(0.85);
						} else {
							// pearlescent froglight
							TWEAK_GLCOLOR_BRIGHTNESS(0.85);
						}
					} else { // 1597..1600
						if (materialId == 1597u) {
							// conduit
							
						} else {
							// sculk sensor, etc
							
						}
					}
				}
			} else { // 1600..1620
				if (materialId < 1610u) { // 1600..1610
					if (materialId < 1602u) { // 1600..1602
						if (materialId == 1600u) {
							// small amethyst bud
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						} else {
							// medium amethyst bud
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						}
					} else { // 1602..1610
						if (materialId == 1602u) {
							// large amethyst bud
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						} else {
							// amethyst cluster
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						}
					}
				} else { // 1610..1620
					if (materialId < 1613u) { // 1600..1613
						if (materialId == 1610u) {
							// glowstone
							SET_REFLECTIVENESS(0.4);
						} else if (materialId == 1611u) {
							// shroomlight
							
						} else {
							// magma_block
							
						}
					} else { // 1613..1610
						if (materialId == 1613u) {
							// end rod
							
						} else {
							// end crystal
							
						}
					}
				}
			}
		}
	} else { // 1620..15503
		if (materialId < 1900u) { // 1620..1900
			if (materialId < 1640u) { // 1620..1640
				if (materialId < 1630u) { // 1620..1630
					if (materialId < 1623u) { // 1620..1623
						if (materialId == 1620u) {
							// amethyst block, etc
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(0.5);
						} else if (materialId == 1621u) {
							// quartz, etc
							SET_REFLECTIVENESS(0.2);
							SET_SPECULARNESS(0.5);
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
						} else {
							// smooth quartz, etc
							SET_REFLECTIVENESS(0.2);
							SET_SPECULARNESS(0.5);
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
						}
					} else { // 1623..1640
						if (materialId == 1623u) {
							// terracotta
							SET_SPECULARNESS(0.25);
							TWEAK_GLCOLOR_BRIGHTNESS(0.85);
						} else if (materialId == 1624u) {
							// packed ice, etc
							SET_REFLECTIVENESS(0.45);
							SET_SPECULARNESS(0.5);
						} else {
							// raw iron block, etc
							SET_SPECULARNESS(0.5);
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
						}
					}
				} else { // 1630..1640
					if (materialId < 1632u) { // 1630..1632
						if (materialId == 1630u) {
							// sand
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
							SET_SPECULARNESS(0.2);
						} else {
							// diorite, etc
							TWEAK_GLCOLOR_BRIGHTNESS(0.95);
							SET_SPECULARNESS(0.25);
						}
					} else { // 1632..1640
						if (materialId == 1632u) {
							// polished granite, etc
							SET_REFLECTIVENESS(0.3);
							SET_SPECULARNESS(0.35);
						} else {
							// prismarine bricks, etc
							SET_REFLECTIVENESS(0.3);
							SET_SPECULARNESS(0.4);
						}
					}
				}
			} else { // 1640..1900
				
			}
		} else { // 1900..15503
			
		}
	}
}
