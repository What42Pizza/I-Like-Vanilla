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

if (materialId < 10025u) {
	if (materialId < 10024u) {
		if (materialId < 10015u) {
			if (materialId < 10007u) {
				if (materialId < 10003u) {
					if (materialId < 10001u) {
						SET_REFLECTIVENESS(1.0);
						TWEAK_GLCOLOR_BRIGHTNESS(1.25);
						SET_VOXEL_ID(57u);
					} else {
						if (materialId < 10002u) {
							SET_REFLECTIVENESS(0.6);
							SET_SPECULARNESS(0.5);
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
						} else {
							SET_REFLECTIVENESS(0.6);
							SET_SPECULARNESS(0.5);
							TWEAK_GLCOLOR_BRIGHTNESS(0.8);
						}
					}
				} else {
					if (materialId < 10005u) {
						if (materialId < 10004u) {
							SET_VOXEL_ID(75u);
						} else {
							SET_VOXEL_ID(61u);
						}
					} else {
						if (materialId < 10006u) {
							SET_VOXEL_ID(60u);
						} else {
							SET_VOXEL_ID(63u);
						}
					}
				}
			} else {
				if (materialId < 10011u) {
					if (materialId < 10009u) {
						if (materialId < 10008u) {
							TWEAK_GLCOLOR_BRIGHTNESS(1.25);
						} else {
							TWEAK_GLCOLOR_BRIGHTNESS(0.9);
							SET_VOXEL_ID(62u);
						}
					} else {
						if (materialId < 10010u) {
							SET_REFLECTIVENESS(0.5);
							SET_SPECULARNESS(0.3);
						} else {
							SET_SPECULARNESS(0.5);
						}
					}
				} else {
					if (materialId < 10013u) {
						if (materialId < 10012u) {
							SET_VOXEL_ID(69u);
						} else {
							SET_VOXEL_ID(68u);
						}
					} else {
						if (materialId < 10014u) {
							SET_GLOWING_COLOR(vec3(21.0,  31.3, 69.4), vec3(60.0, 100.0, 97.6), 1.0);
							SET_VOXEL_ID(71u);
						} else {
							SET_VOXEL_ID(70u);
						}
					}
				}
			}
		} else {
			if (materialId < 10023u) {
				if (materialId < 10019u) {
					if (materialId < 10017u) {
						if (materialId < 10016u) {
							SET_VOXEL_ID(65u);
						} else {
							SET_VOXEL_ID(64u);
						}
					} else {
						if (materialId < 10018u) {
							SET_VOXEL_ID(67u);
						} else {
							SET_VOXEL_ID(66u);
						}
					}
				} else {
					if (materialId < 10021u) {
						if (materialId < 10020u) {
							SET_VOXEL_ID(74u);
						} else {
							SET_VOXEL_ID(73u);
						}
					} else {
						if (materialId < 10022u) {
							SET_VOXEL_ID(59u);
						} else {
							SET_VOXEL_ID(58u);
						}
					}
				}
			} else {
				SET_REFLECTIVENESS(1.0);
				SET_SPECULARNESS(1.0);
				SET_VOXEL_ID(72u);
			}
		}
	} else {
		SET_SPECULARNESS(0.8);
	}
} else {
	if (materialId < 10037u) {
		if (materialId < 10036u) {
			if (materialId < 10034u) {
				if (materialId < 10033u) {
					if (materialId < 10029u) {
						if (materialId < 10026u) {
							SET_VOXEL_ID(56u);
						} else {
							if (materialId < 10028u) {
								if (materialId < 10027u) {
									SET_SPECULARNESS(0.5);
									SET_VOXEL_ID(9u);
								} else {
									TWEAK_GLCOLOR_BRIGHTNESS(0.9);
								}
							} else {
								SET_REFLECTIVENESS(1.0);
								SET_SPECULARNESS(0.5);
							}
						}
					} else {
						if (materialId < 10031u) {
							if (materialId < 10030u) {
								SET_REFLECTIVENESS(1.0);
								SET_SPECULARNESS(0.5);
							} else {
								SET_GLOWING_COLOR(vec3(28.0, 56.7, 64.3), vec3(51.0, 79.3, 96.9), 0.7);
								SET_VOXEL_ID(4u);
							}
						} else {
							if (materialId < 10032u) {
								SET_GLOWING_COLOR(vec3(60.0, 19.0, 67.6), vec3(63.0, 21.0, 69.6), 0.5);
								SET_VOXEL_ID(3u);
							} else {
								SET_VOXEL_ID(77u);
							}
						}
					}
				} else {
					SET_SPECULARNESS(0.2);
					TWEAK_GLCOLOR_BRIGHTNESS(0.8);
				}
			} else {
				if (materialId < 10035u) {
					SET_REFLECTIVENESS(0.4);
					SET_SPECULARNESS(1.0);
				} else {
					SET_VOXEL_ID(78u);
				}
			}
		} else {
			SET_REFLECTIVENESS(0.25);
		}
	} else {
		if (materialId < 10038u) {
			SET_SPECULARNESS(2.0);
#if defined SHADER_GBUFFERS_WATER || defined SHADER_VOXY_TRANSLUCENT
SET_REFLECTIVENESS(mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y));
#endif
			SET_VOXEL_ID(79u);
		} else {
			if (materialId < 10067u) {
				if (materialId < 10050u) {
					if (materialId < 10049u) {
						if (materialId < 10042u) {
							if (materialId < 10040u) {
								if (materialId < 10039u) {
									SET_REFLECTIVENESS(0.9);
									SET_SPECULARNESS(0.4);
								} else {
									SET_SPECULARNESS(0.25);
									TWEAK_GLCOLOR_BRIGHTNESS(0.95);
								}
							} else {
								if (materialId < 10041u) {
									SET_SPECULARNESS(0.75);
								} else {
									SET_SPECULARNESS(0.75);
									TWEAK_GLCOLOR_BRIGHTNESS(1.25);
								}
							}
						} else {
							if (materialId < 10045u) {
								if (materialId < 10043u) {
									SET_VOXEL_ID(5u);
								} else {
									if (materialId < 10044u) {
									} else {
									}
								}
							} else {
								if (materialId < 10047u) {
									if (materialId < 10046u) {
										SET_VOXEL_ID(8u);
									} else {
										SET_VOXEL_ID(11u);
									}
								} else {
									if (materialId < 10048u) {
										SET_VOXEL_ID(10u);
									} else {
										SET_VOXEL_ID(53u);
									}
								}
							}
						}
					} else {
						TWEAK_GLCOLOR_BRIGHTNESS(0.92);
					}
				} else {
					if (materialId < 10051u) {
						SET_SPECULARNESS(0.5);
					} else {
						if (materialId < 10059u) {
							if (materialId < 10055u) {
								if (materialId < 10053u) {
									if (materialId < 10052u) {
										SET_REFLECTIVENESS(0.5);
										SET_SPECULARNESS(0.3);
										SET_VOXEL_ID(52u);
									} else {
										SET_REFLECTIVENESS(0.4);
										SET_SPECULARNESS(0.3);
									}
								} else {
									if (materialId < 10054u) {
										SET_SPECULARNESS(0.75);
									} else {
										SET_REFLECTIVENESS(0.75);
										SET_SPECULARNESS(0.3);
										SET_VOXEL_ID(55u);
									}
								}
							} else {
								if (materialId < 10057u) {
									if (materialId < 10056u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
									} else {
										SET_SPECULARNESS(0.5);
										TWEAK_GLCOLOR_BRIGHTNESS(0.8);
									}
								} else {
									if (materialId < 10058u) {
										SET_REFLECTIVENESS(0.4);
										SET_SPECULARNESS(0.3);
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
									} else {
										SET_SPECULARNESS(0.5);
									}
								}
							}
						} else {
							if (materialId < 10063u) {
								if (materialId < 10061u) {
									if (materialId < 10060u) {
										SET_VOXEL_ID(54u);
									} else {
										SET_VOXEL_ID(25u);
									}
								} else {
									if (materialId < 10062u) {
										SET_VOXEL_ID(24u);
									} else {
										SET_VOXEL_ID(27u);
									}
								}
							} else {
								if (materialId < 10065u) {
									if (materialId < 10064u) {
										SET_VOXEL_ID(26u);
									} else {
										SET_VOXEL_ID(21u);
									}
								} else {
									if (materialId < 10066u) {
										SET_VOXEL_ID(20u);
									} else {
										SET_VOXEL_ID(23u);
									}
								}
							}
						}
					}
				}
			} else {
				if (materialId < 10099u) {
					if (materialId < 10083u) {
						if (materialId < 10075u) {
							if (materialId < 10071u) {
								if (materialId < 10069u) {
									if (materialId < 10068u) {
										SET_VOXEL_ID(22u);
									} else {
										SET_VOXEL_ID(33u);
									}
								} else {
									if (materialId < 10070u) {
										SET_VOXEL_ID(32u);
									} else {
										SET_VOXEL_ID(35u);
									}
								}
							} else {
								if (materialId < 10073u) {
									if (materialId < 10072u) {
										SET_REFLECTIVENESS(0.4);
										SET_VOXEL_ID(34u);
									} else {
										SET_VOXEL_ID(29u);
									}
								} else {
									if (materialId < 10074u) {
										SET_VOXEL_ID(28u);
									} else {
										SET_VOXEL_ID(31u);
									}
								}
							}
						} else {
							if (materialId < 10079u) {
								if (materialId < 10077u) {
									if (materialId < 10076u) {
										SET_VOXEL_ID(30u);
									} else {
										SET_VOXEL_ID(41u);
									}
								} else {
									if (materialId < 10078u) {
										SET_GLOWING_COLOR(vec3(  0.0, 31.8, 46.3), vec3(162.0, 65.6, 87.8), GLOWING_ORES_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(18.0, 24.8, 53.3), vec3(56.0, 37.5, 88.6), GLOWING_ORES_STRENGTH);
									}
								}
							} else {
								if (materialId < 10081u) {
									if (materialId < 10080u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(40u);
									} else {
										SET_VOXEL_ID(43u);
									}
								} else {
									if (materialId < 10082u) {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(42u);
									} else {
										TWEAK_GLCOLOR_BRIGHTNESS(0.85);
										SET_VOXEL_ID(37u);
									}
								}
							}
						}
					} else {
						if (materialId < 10091u) {
							if (materialId < 10087u) {
								if (materialId < 10085u) {
									if (materialId < 10084u) {
										SET_VOXEL_ID(36u);
									} else {
										SET_VOXEL_ID(39u);
									}
								} else {
									if (materialId < 10086u) {
										SET_VOXEL_ID(38u);
									} else {
										SET_VOXEL_ID(49u);
									}
								}
							} else {
								if (materialId < 10089u) {
									if (materialId < 10088u) {
										SET_VOXEL_ID(48u);
									} else {
										SET_VOXEL_ID(51u);
									}
								} else {
									if (materialId < 10090u) {
										SET_VOXEL_ID(50u);
									} else {
										SET_VOXEL_ID(45u);
									}
								}
							}
						} else {
							if (materialId < 10095u) {
								if (materialId < 10093u) {
									if (materialId < 10092u) {
										SET_VOXEL_ID(44u);
									} else {
										SET_VOXEL_ID(47u);
									}
								} else {
									if (materialId < 10094u) {
										SET_VOXEL_ID(46u);
									} else {
										SET_VOXEL_ID(17u);
									}
								}
							} else {
								if (materialId < 10097u) {
									if (materialId < 10096u) {
										SET_VOXEL_ID(16u);
									} else {
										SET_VOXEL_ID(19u);
									}
								} else {
									if (materialId < 10098u) {
										SET_VOXEL_ID(18u);
									} else {
										SET_VOXEL_ID(13u);
									}
								}
							}
						}
					}
				} else {
					if (materialId < 10108u) {
						if (materialId < 10107u) {
							if (materialId < 10103u) {
								if (materialId < 10101u) {
									if (materialId < 10100u) {
										SET_GLOWING_COLOR(vec3(162.0, 16.5,  57.3), vec3(184.0, 86.3, 100.0), GLOWING_ORES_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(198.0, 57.0, 54.5), vec3(234.0, 91.5, 95.7), GLOWING_ORES_STRENGTH);
									}
								} else {
									if (materialId < 10102u) {
										SET_GLOWING_COLOR(vec3(  0.0,  6.5, 72.5), vec3(360.0, 30.3, 90.6), GLOWING_ORES_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(25.0, 29.0,  78.0), vec3(72.0, 85.4, 100.0), GLOWING_ORES_STRENGTH);
									}
								}
							} else {
								if (materialId < 10105u) {
									if (materialId < 10104u) {
										SET_GLOWING_COLOR(vec3( 0.0, 62.8, 59.2), vec3(18.0, 98.0, 99.2), GLOWING_ORES_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3(36.0, 29.0,  92.2), vec3(72.0, 94.0, 100.0), GLOWING_ORES_STRENGTH);
									}
								} else {
									if (materialId < 10106u) {
										SET_GLOWING_COLOR(vec3(126.0,  14.9,  48.2), vec3(162.0, 100.0, 100.0), GLOWING_ORES_STRENGTH);
									} else {
										SET_GLOWING_COLOR(vec3( 0.0, 62.8, 59.2), vec3(18.0, 98.0, 99.2), GLOWING_ORES_STRENGTH);
										SET_VOXEL_ID(12u);
									}
								}
							}
						} else {
							SET_GLOWING_COLOR(vec3(  0.0, 64.5, 79.2), vec3(360.0, 97.0, 98.4), 1.0);
							TWEAK_GLCOLOR_BRIGHTNESS(0.75);
						}
					} else {
						if (materialId < 10114u) {
							if (materialId < 10112u) {
								if (materialId < 10110u) {
									if (materialId < 10109u) {
										SET_VOXEL_ID(15u);
									} else {
										SET_VOXEL_ID(14u);
									}
								} else {
									if (materialId < 10111u) {
										SET_VOXEL_ID(7u);
									} else {
										SET_VOXEL_ID(6u);
									}
								}
							} else {
								if (materialId < 10113u) {
									SET_GLOWING_COLOR(vec3(  0.0,  78.0, 48.2), vec3(360.0, 100.0, 69.4), GLOWING_STEMS_STRENGTH);
								} else {
									SET_GLOWING_COLOR(vec3(  0.0, 77.3, 38.0), vec3(360.0, 86.6, 58.4), GLOWING_STEMS_STRENGTH);
								}
							}
						} else {
							if (materialId < 10116u) {
								if (materialId < 10115u) {
									SET_REFLECTIVENESS(0.9);
									SET_SPECULARNESS(0.35);
								} else {
									SET_VOXEL_ID(76u);
								}
							} else {
								SET_SPECULARNESS(0.25);
								TWEAK_GLCOLOR_BRIGHTNESS(0.85);
							}
						}
					}
				}
			}
		}
	}
}
