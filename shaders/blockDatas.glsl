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
	#if GLOWING_ORES_ENABLED == 1
		#define SET_GLOWING_ORE_COLOR(v1, v2, v3) glowingColorMin = (v1 - 0.5) / 100.0; glowingColorMax = (v2 + 0.5) / 100.0; glowingAmount = v3;
	#else
		#define SET_GLOWING_ORE_COLOR(v1, v2, v3)
	#endif
	#define SET_GLOWING_COLOR(v1, v2, v3) glowingColorMin = (v1 - 0.5) / 100.0; glowingColorMax = (v2 + 0.5) / 100.0; glowingAmount = v3;
#else
	#define SET_GLOWING_ORE_COLOR(v1, v2, v3)
	#define SET_GLOWING_COLOR(v1, v2, v3)
#endif
#ifdef GET_VOXEL_ID
	voxelId = 0u;
	#define SET_VOXEL_ID(v) voxelId = v;
#else
	#define SET_VOXEL_ID(v)
#endif

// Note: these comments use `..` like Rust does, where the range is [min-max)
if (materialId < 1570u) { // 0..1570
	if (materialId < 1500u) { // 0..1500
		// unused
		
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
} else { // 1570..
	if (materialId < 1620u) { // 1570..1620
		if (materialId < 1590u) { // 1570..1590
			if (materialId < 1580u) { // 1570..1580
				if (materialId < 1573u) { // 1570..1573
					if (materialId == 1570u) {
						// water
						SET_REFLECTIVENESS(mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y));
						SET_SPECULARNESS(2.0); // values greater than 1.0 only work here bc this isn't deferred lighting and the specular value is immediately unsed instead of stored
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
							SET_VOXEL_ID(125u);
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
							// cave vines + berries
							
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
							TWEAK_GLCOLOR_BRIGHTNESS(1.25);
						} else if (materialId == 1611u) {
							// shroomlight
							TWEAK_GLCOLOR_BRIGHTNESS(0.9);
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
	} else { // 1620..
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
				if (materialId < 1660u) { // 1640..1660
					if (materialId < 1650u) { // 1640..1650
						if (materialId < 1642u) { // 1640..1642
							if (materialId == 1640u) {
								// iron block, etc
								SET_REFLECTIVENESS(0.2);
								SET_SPECULARNESS(0.3);
								TWEAK_GLCOLOR_BRIGHTNESS(0.85);
							} else {
								// valuable blocks
								SET_REFLECTIVENESS(0.2);
								SET_SPECULARNESS(0.3);
							}
						} else { // 1642..1650
							if (materialId == 1642u) {
								// copper block, etc
								
							} else {
								// oxidized copper, etc
								
							}
						}
					} else { // 1650..1660
						if (materialId < 1652u) { // 1650..1652
							if (materialId == 1650u) {
								// chest
								
							} else {
								// birch door
								
							}
						} else { // 1652..1660
							if (materialId == 1652u) {
								// stripped pale oak log, etc
								
							} else {
								// white wool, etc
								TWEAK_GLCOLOR_BRIGHTNESS(0.9);
							}
						}
					}
				} else { // 1660..1900
					if (materialId < 1700u) { // 1660..1700
						if (materialId < 1670u) { // 1660..1670
							if (materialId < 1662u) { // 1660..1662
								if (materialId == 1660u) {
									// netherrak
								SET_REFLECTIVENESS(0.15);
								} else {
									// bone block
									
								}
							} else { // 1662..1670
								if (materialId == 1662u) {
									// warped stem
									SET_GLOWING_COLOR(
										vec3(  0.0, 77.3, 38.0),
										vec3(100.0, 86.6, 58.4),
										1.0
									);
								} else {
									// crimson stem
									SET_GLOWING_COLOR(
										vec3(  0.0,  78.0, 48.2),
										vec3(100.0, 100.0, 69.4),
										1.0
									);
								}
							}
						} else { // 1670..1700
							if (materialId == 1670u) {
								// end stone, etc
								
							} else {
								// purpur block, etc
							}
						}
					} else { // 1700..1900
						if (materialId < 1704u) { // 1700..1704
							if (materialId < 1702u) { // 1700..1702
								if (materialId == 1700u) {
									// coal ore
									
								} else {
									// iron ore
									SET_GLOWING_ORE_COLOR(
										vec3( 5.0, 24.8, 53.3),
										vec3(15.0, 37.5, 88.6),
										GLOWING_ORES_STRENGTH
									);
								}
							} else { // 1702..1704
								if (materialId == 1702u) {
									// copper ore
									SET_GLOWING_ORE_COLOR(
										vec3( 0.0, 31.8, 46.3),
										vec3(45.0, 65.6, 87.8),
										GLOWING_ORES_STRENGTH
									);
								} else {
									// gold ore
									SET_GLOWING_ORE_COLOR(
										vec3(10.0, 29.0,  92.2),
										vec3(20.0, 94.0, 100.0),
										GLOWING_ORES_STRENGTH
									);
								}
							}
						} else { // 1704..1900
							if (materialId < 1707u) { // 1704..1707
								if (materialId == 1704u) {
									// redstone ore
									SET_GLOWING_ORE_COLOR(
										vec3(0.0, 62.8, 59.2),
										vec3(5.0, 98.0, 99.2),
										GLOWING_ORES_STRENGTH
									);
								} else if (materialId == 1705u) {
									// emerald ore
									SET_GLOWING_ORE_COLOR(
										vec3(35.0,  14.9,  48.2),
										vec3(45.0, 100.0, 100.0),
										GLOWING_ORES_STRENGTH
									);
								} else {
									// lapis ore
									SET_GLOWING_ORE_COLOR(
										vec3(55.0, 57.0, 54.5),
										vec3(65.0, 91.5, 95.7),
										GLOWING_ORES_STRENGTH
									);
								}
							} else { // 1707..1900
								if (materialId == 1707u) {
									// diamond ore
									SET_GLOWING_ORE_COLOR(
										vec3(45.0, 16.5,  57.3),
										vec3(51.0, 86.3, 100.0),
										GLOWING_ORES_STRENGTH
									);
								} else if (materialId == 1708u) {
									// nether gold ore
									SET_REFLECTIVENESS(0.15);
									SET_GLOWING_ORE_COLOR(
										vec3( 7.0, 29.0,  78.0),
										vec3(20.0, 85.4, 100.0),
										GLOWING_ORES_STRENGTH
									);
								} else {
									// nether quartz ore
									SET_REFLECTIVENESS(0.15);
									SET_GLOWING_ORE_COLOR(
										vec3(  0.0,  6.5, 72.5),
										vec3(100.0, 30.3, 90.6),
										GLOWING_ORES_STRENGTH
									);
								}
							}
						}
					}
				}
			}
		} else { // 1900..
			if (materialId < 9500u) { // 1900..9500
				if (materialId < 6500u) { // 1900..6500
					if (materialId < 3500u) { // 1900..3500
						if (materialId < 1910u) { // 1900..1910
							if (materialId == 1900u) {
								// fire
								
							} else {
								// soul fire
								
							}
						} else {
							if (materialId == 1910u) {
								// nether portal
								
							} else if (materialId == 1920u) {
								// end portal
								
							} else if (materialId == 1930u) {
								// end gateway
								
							}
						}
					} else { // 3500..6500
						// sugar cane
						
					}
				} else { // 6500..9500
					if (materialId < 7500u) { // 6500..7500
						if (materialId < 6502u) { // 6500..6502
							if (materialId == 6500u) {
								// oak leaves, etc
								SET_SPECULARNESS(0.8);
							} else {
								// pale oak leaves
								SET_SPECULARNESS(0.8);
							}
						} else { // 6502..7500
							if (materialId == 6502u) {
								// pale hanging moss
								SET_SPECULARNESS(0.5);
							} else {
								// vine
								SET_SPECULARNESS(0.75);
							}
						}
					} else { // 7500..9500
						if (materialId == 7500u) {
							// tall grass: upper, etc
							SET_SPECULARNESS(0.5);
						} else {
							// rose bush: upper, etc
							
						}
					}
				}
			} else { // 9500..
				if (materialId < 13500u) { // 9500..13500
					if (materialId < 11500u) { // 9500..11500
						// pointed dripstone
						
					} else { // 11500..13500
						if (materialId == 11500u) {
							// red mushrooms, etc
							
						} else if (materialId == 11501u) {
							// cobweb
							
						} else {
							// wither rose
							
						}
					}
				} else { // 13500..
					if (materialId < 15500u) { // 13500..15500
						if (materialId < 13502u) { // 13500..13502
							if (materialId == 13500u) {
								// dead bush
								
							} else {
								// oak sapling, etc
								
							}
						} else { // 13502..15500
							if (materialId == 13502u) {
								// dandelion, etc
								
							} else {
								// potatoes, etc
								
							}
						}
					} else { // 15500..
						if (materialId < 15502u) { // 15500..15502
							if (materialId == 15500u) {
								// short grass, etc
								SET_SPECULARNESS(0.5);
							} else {
								// firefly bush
								
							}
						} else { // 15500..
							if (materialId == 15502u) {
								// wheat
								
							} else {
								// rose bush: lower, etc
								
							}
						}
					}
				}
			}
		}
	}
}
