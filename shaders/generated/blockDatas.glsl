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

if (materialId < 24u) {
	if (materialId < 23u) {
		if (materialId < 10u) {
			if (materialId < 9u) {
				if (materialId < 5u) {
					if (materialId < 3u) {
						if (materialId < 2u) {
							if (materialId < 1u) {
							} else {
								SET_REFLECTIVENESS(0.4);
								SET_SPECULARNESS(1.0);
								SET_VOXEL_ID(73u);
							}
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(59u);
						}
					} else {
						if (materialId < 4u) {
							SET_GLOWING_COLOR(vec3(21.0,  31.3, 69.4), vec3(60.0, 100.0, 100.0), 0.5);
							SET_VOXEL_ID(58u);
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(69u);
						}
					}
				} else {
					if (materialId < 7u) {
						if (materialId < 6u) {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(68u);
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(71u);
						}
					} else {
						if (materialId < 8u) {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(70u);
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(65u);
						}
					}
				}
			} else {
				SET_REFLECTIVENESS(1.0);
				SET_SPECULARNESS(0.8);
				SET_VOXEL_ID(72u);
			}
		} else {
			if (materialId < 21u) {
				if (materialId < 14u) {
					if (materialId < 12u) {
						if (materialId < 11u) {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(64u);
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(67u);
						}
					} else {
						if (materialId < 13u) {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(66u);
						} else {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(61u);
						}
					}
				} else {
					if (materialId < 17u) {
						if (materialId < 15u) {
							SET_REFLECTIVENESS(0.4);
							SET_SPECULARNESS(1.0);
							SET_VOXEL_ID(60u);
						} else {
							if (materialId < 16u) {
								TWEAK_GLCOLOR_BRIGHTNESS(1.25);
								SET_VOXEL_ID(53u);
							} else {
								SET_REFLECTIVENESS(1.0);
								SET_SPECULARNESS(0.5);
							}
						}
					} else {
						if (materialId < 19u) {
							if (materialId < 18u) {
							} else {
								SET_SPECULARNESS(0.5);
							}
						} else {
							if (materialId < 20u) {
								SET_VOXEL_ID(80u);
							} else {
								SET_VOXEL_ID(79u);
							}
						}
					}
				}
			} else {
				if (materialId < 22u) {
					SET_SPECULARNESS(0.2);
					TWEAK_GLCOLOR_BRIGHTNESS(0.8);
				} else {
					SET_REFLECTIVENESS(0.4);
					SET_SPECULARNESS(1.0);
				}
			}
		}
	} else {
		SET_SPECULARNESS(0.8);
	}
} else {
	if (materialId < 71u) {
		if (materialId < 70u) {
			if (materialId < 37u) {
				if (materialId < 25u) {
					SET_VOXEL_ID(81u);
				} else {
					if (materialId < 29u) {
						if (materialId < 27u) {
							if (materialId < 26u) {
								SET_GLOWING_COLOR(vec3(60.0, 19.0, 67.6), vec3(63.0, 21.0, 69.6), 0.5);
								SET_VOXEL_ID(78u);
							} else {
								SET_VOXEL_ID(77u);
							}
						} else {
							if (materialId < 28u) {
								SET_REFLECTIVENESS(1.0);
								SET_SPECULARNESS(0.5);
							} else {
								SET_GLOWING_COLOR(vec3(28.0, 56.7, 64.3), vec3(51.0, 79.3, 96.9), 1.1);
								SET_VOXEL_ID(76u);
							}
						}
					} else {
						if (materialId < 33u) {
							if (materialId < 31u) {
								if (materialId < 30u) {
									TWEAK_GLCOLOR_BRIGHTNESS(0.85);
								} else {
									TWEAK_GLCOLOR_BRIGHTNESS(0.9);
								}
							} else {
								if (materialId < 32u) {
									SET_SPECULARNESS(0.75);
								} else {
									SET_SPECULARNESS(0.75);
									TWEAK_GLCOLOR_BRIGHTNESS(1.2);
								}
							}
						} else {
							if (materialId < 35u) {
								if (materialId < 34u) {
									TWEAK_GLCOLOR_BRIGHTNESS(0.8);
								} else {
								}
							} else {
								if (materialId < 36u) {
									SET_REFLECTIVENESS(0.9);
									SET_SPECULARNESS(0.4);
								} else {
									SET_SPECULARNESS(0.25);
									TWEAK_GLCOLOR_BRIGHTNESS(0.95);
								}
							}
						}
					}
				}
			} else {
				if (materialId < 39u) {
					if (materialId < 38u) {
						TWEAK_GLCOLOR_BRIGHTNESS(0.92);
					} else {
						SET_SPECULARNESS(0.2);
					}
				} else {
					if (materialId < 54u) {
						if (materialId < 46u) {
							if (materialId < 42u) {
								if (materialId < 40u) {
									SET_VOXEL_ID(75u);
								} else {
									if (materialId < 41u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.9);
									} else {
									}
								}
							} else {
								if (materialId < 44u) {
									if (materialId < 43u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(74u);
									} else {
										SET_REFLECTIVENESS(0.4);
										SET_SPECULARNESS(0.5);
										SET_VOXEL_ID(6u);
									}
								} else {
									if (materialId < 45u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(5u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(16u);
									}
								}
							}
						} else {
							if (materialId < 50u) {
								if (materialId < 48u) {
									if (materialId < 47u) {
										SET_REFLECTIVENESS(0.75);
										SET_SPECULARNESS(0.3);
										SET_VOXEL_ID(15u);
									} else {
										SET_REFLECTIVENESS(0.5);
										SET_SPECULARNESS(0.3);
										SET_VOXEL_ID(18u);
									}
								} else {
									if (materialId < 49u) {
									} else {
										SET_SPECULARNESS(0.75);
									}
								}
							} else {
								if (materialId < 52u) {
									if (materialId < 51u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.95);
									} else {
										TWEAK_GLCOLOR_BRIGHTNESS(0.9);
									}
								} else {
									if (materialId < 53u) {
										SET_REFLECTIVENESS(0.4);
										SET_SPECULARNESS(0.3);
									} else {
										SET_REFLECTIVENESS(0.4);
										SET_SPECULARNESS(0.3);
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
									}
								}
							}
						}
					} else {
						if (materialId < 62u) {
							if (materialId < 58u) {
								if (materialId < 56u) {
									if (materialId < 55u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(17u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(12u);
									}
								} else {
									if (materialId < 57u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(11u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(14u);
									}
								}
							} else {
								if (materialId < 60u) {
									if (materialId < 59u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(13u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(40u);
									}
								} else {
									if (materialId < 61u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(39u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(42u);
									}
								}
							}
						} else {
							if (materialId < 66u) {
								if (materialId < 64u) {
									if (materialId < 63u) {
										SET_VOXEL_ID(41u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(36u);
									}
								} else {
									if (materialId < 65u) {
										SET_VOXEL_ID(35u);
									} else {
										SET_VOXEL_ID(38u);
									}
								}
							} else {
								if (materialId < 68u) {
									if (materialId < 67u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(37u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(48u);
									}
								} else {
									if (materialId < 69u) {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(47u);
									} else {
										SET_SPECULARNESS(1.0);
										SET_VOXEL_ID(50u);
									}
								}
							}
						}
					}
				}
			}
		} else {
			SET_REFLECTIVENESS(0.2);
		}
	} else {
		if (materialId < 72u) {
			SET_SPECULARNESS(2.0);
#if defined SHADER_GBUFFERS_WATER || defined SHADER_VOXY_TRANSLUCENT
SET_REFLECTIVENESS(mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y));
#endif
			SET_VOXEL_ID(82u);
		} else {
			if (materialId < 122u) {
				if (materialId < 104u) {
					if (materialId < 88u) {
						if (materialId < 80u) {
							if (materialId < 76u) {
								if (materialId < 74u) {
									if (materialId < 73u) {
										SET_GLOWING_COLOR(vec3(25.0, 29.0,  78.0), vec3(72.0, 94.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_NETHER_GOLD_ORE_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(162.0, 16.5,  57.3), vec3(184.0, 86.3, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_DIAMOND_ORE_STRENGTH);
									}
								} else {
									if (materialId < 75u) {
										SET_GLOWING_COLOR(vec3(11.4, 15.4, 39.6), vec3(20.9, 36.6, 58.4), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_ANCIENT_DEBRIS_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(  0.0,  5.0, 65.0), vec3(360.0, 30.3, 92.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_NETHER_QUARTS_ORE_STRENGTH);
									}
								}
							} else {
								if (materialId < 78u) {
									if (materialId < 77u) {
										SET_GLOWING_COLOR(vec3(  0.0,  46.3,  21.0), vec3(360.0, 100.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_REDSTONE_ORE_STRENGTH);
										SET_VOXEL_ID(49u);
									} else {
										SET_GLOWING_COLOR(vec3(  0.0,  46.3,  21.0), vec3(360.0, 100.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_REDSTONE_ORE_STRENGTH);
									}
								} else {
									if (materialId < 79u) {
										SET_GLOWING_COLOR(vec3(198.0, 57.0, 54.5), vec3(234.0, 91.5, 95.7), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_LAPIS_ORE_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(126.0,  14.9,  48.2), vec3(162.0, 100.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_EMERALD_ORE_STRENGTH);
									}
								}
							}
						} else {
							if (materialId < 84u) {
								if (materialId < 82u) {
									if (materialId < 81u) {
										SET_SPECULARNESS(0.5);
									} else {
									}
								} else {
									if (materialId < 83u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.95);
									} else {
										SET_SPECULARNESS(0.5);
									}
								}
							} else {
								if (materialId < 86u) {
									if (materialId < 85u) {
										SET_SPECULARNESS(0.5);
										TWEAK_GLCOLOR_BRIGHTNESS(0.8);
									} else {
										SET_GLOWING_COLOR(vec3(25.0, 29.0,  49.4), vec3(72.0, 94.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_GILDED_BLACKSTONE_STRENGTH);
									}
								} else {
									if (materialId < 87u) {
										SET_SPECULARNESS(0.5);
									} else {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
									}
								}
							}
						}
					} else {
						if (materialId < 96u) {
							if (materialId < 92u) {
								if (materialId < 90u) {
									if (materialId < 89u) {
										SET_REFLECTIVENESS(1.0);
										SET_SPECULARNESS(0.5);
										SET_VOXEL_ID(44u);
									} else {
										SET_REFLECTIVENESS(1.0);
										SET_SPECULARNESS(0.5);
										SET_VOXEL_ID(43u);
									}
								} else {
									if (materialId < 91u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(46u);
									} else {
										SET_VOXEL_ID(45u);
									}
								}
							} else {
								if (materialId < 94u) {
									if (materialId < 93u) {
										SET_VOXEL_ID(24u);
									} else {
										SET_VOXEL_ID(23u);
									}
								} else {
									if (materialId < 95u) {
										SET_REFLECTIVENESS(1.0);
										SET_SPECULARNESS(0.5);
										SET_VOXEL_ID(26u);
									} else {
										SET_REFLECTIVENESS(1.0);
										SET_SPECULARNESS(0.5);
										SET_VOXEL_ID(25u);
									}
								}
							}
						} else {
							if (materialId < 100u) {
								if (materialId < 98u) {
									if (materialId < 97u) {
										SET_GLOWING_COLOR(vec3(18.0, 24.8, 53.3), vec3(56.0, 37.5, 88.6), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_IRON_ORE_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3( 0.0,  0.0, 14.5), vec3(90.0, 16.0, 29.4), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_COAL_ORE_STRENGTH);
									}
								} else {
									if (materialId < 99u) {
										SET_GLOWING_COLOR(vec3(36.0, 29.0,  92.2), vec3(72.0, 94.0, 100.0), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_GOLD_ORE_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(  0.0, 31.8, 46.3), vec3(162.0, 65.6, 87.8), GLOWING_ORES_STRENGTH * 1.5 * GLOWING_COPPER_ORE_STRENGTH);
									}
								}
							} else {
								if (materialId < 102u) {
									if (materialId < 101u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(20u);
									} else {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(19u);
									}
								} else {
									if (materialId < 103u) {
										SET_VOXEL_ID(22u);
									} else {
										SET_VOXEL_ID(21u);
									}
								}
							}
						}
					}
				} else {
					if (materialId < 120u) {
						if (materialId < 112u) {
							if (materialId < 108u) {
								if (materialId < 106u) {
									if (materialId < 105u) {
										SET_VOXEL_ID(32u);
									} else {
										SET_VOXEL_ID(31u);
									}
								} else {
									if (materialId < 107u) {
										SET_VOXEL_ID(34u);
									} else {
										SET_VOXEL_ID(33u);
									}
								}
							} else {
								if (materialId < 110u) {
									if (materialId < 109u) {
										SET_VOXEL_ID(28u);
									} else {
										SET_VOXEL_ID(27u);
									}
								} else {
									if (materialId < 111u) {
										SET_VOXEL_ID(30u);
									} else {
										SET_VOXEL_ID(29u);
									}
								}
							}
						} else {
							if (materialId < 116u) {
								if (materialId < 114u) {
									if (materialId < 113u) {
										SET_VOXEL_ID(8u);
									} else {
										SET_VOXEL_ID(7u);
									}
								} else {
									if (materialId < 115u) {
										SET_REFLECTIVENESS(0.4);
										SET_VOXEL_ID(10u);
									} else {
										SET_VOXEL_ID(9u);
									}
								}
							} else {
								if (materialId < 118u) {
									if (materialId < 117u) {
										SET_VOXEL_ID(52u);
									} else {
										SET_VOXEL_ID(51u);
									}
								} else {
									if (materialId < 119u) {
										SET_VOXEL_ID(4u);
									} else {
										SET_VOXEL_ID(3u);
									}
								}
							}
						}
					} else {
						if (materialId < 121u) {
						} else {
							SET_GLOWING_COLOR(vec3(  0.0, 64.5, 79.2), vec3(360.0, 97.0, 98.4), 1.0);
							TWEAK_GLCOLOR_BRIGHTNESS(0.75);
						}
					}
				}
			} else {
				if (materialId < 132u) {
					if (materialId < 129u) {
						if (materialId < 126u) {
							if (materialId < 124u) {
								if (materialId < 123u) {
									SET_GLOWING_COLOR(vec3(  0.0,  78.0, 48.2), vec3(360.0, 100.0, 69.4), GLOWING_STEMS_STRENGTH);
								} else {
									SET_GLOWING_COLOR(vec3(  0.0, 77.3, 38.0), vec3(360.0, 86.6, 58.4), GLOWING_STEMS_STRENGTH);
								}
							} else {
								if (materialId < 125u) {
									SET_SPECULARNESS(0.2);
									TWEAK_GLCOLOR_BRIGHTNESS(0.95);
								} else {
								}
							}
						} else {
							if (materialId < 128u) {
								if (materialId < 127u) {
									TWEAK_GLCOLOR_BRIGHTNESS(0.9);
								} else {
									SET_REFLECTIVENESS(0.3);
									SET_SPECULARNESS(0.6);
								}
							} else {
								SET_REFLECTIVENESS(0.5);
								SET_SPECULARNESS(0.5);
								TWEAK_GLCOLOR_BRIGHTNESS(0.9);
							}
						}
					} else {
						if (materialId < 130u) {
							SET_REFLECTIVENESS(1.0);
							TWEAK_GLCOLOR_BRIGHTNESS(1.25);
							SET_VOXEL_ID(55u);
						} else {
							if (materialId < 131u) {
								SET_REFLECTIVENESS(0.6);
								SET_SPECULARNESS(0.5);
								TWEAK_GLCOLOR_BRIGHTNESS(0.8);
							} else {
								SET_REFLECTIVENESS(0.5);
								SET_SPECULARNESS(0.5);
								TWEAK_GLCOLOR_BRIGHTNESS(0.8);
							}
						}
					}
				} else {
					if (materialId < 136u) {
						if (materialId < 134u) {
							if (materialId < 133u) {
								SET_REFLECTIVENESS(0.4);
								SET_SPECULARNESS(1.0);
								SET_VOXEL_ID(63u);
							} else {
								SET_REFLECTIVENESS(0.4);
								SET_SPECULARNESS(1.0);
								SET_VOXEL_ID(62u);
							}
						} else {
							if (materialId < 135u) {
								SET_REFLECTIVENESS(0.4);
								SET_SPECULARNESS(1.0);
								SET_VOXEL_ID(57u);
							} else {
								SET_REFLECTIVENESS(0.4);
								SET_SPECULARNESS(1.0);
								SET_VOXEL_ID(56u);
							}
						}
					} else {
						if (materialId < 138u) {
							if (materialId < 137u) {
								TWEAK_GLCOLOR_BRIGHTNESS(1.15);
							} else {
								TWEAK_GLCOLOR_BRIGHTNESS(0.9);
								SET_VOXEL_ID(54u);
							}
						} else {
							if (materialId < 139u) {
								SET_REFLECTIVENESS(0.5);
								SET_SPECULARNESS(0.3);
							} else {
								SET_SPECULARNESS(0.2);
							}
						}
					}
				}
			}
		}
	}
}
