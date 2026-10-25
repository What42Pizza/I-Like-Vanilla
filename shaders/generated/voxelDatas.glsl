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

if (voxelId < 55u) {
	if (voxelId < 54u) {
		if (voxelId < 7u) {
			if (voxelId < 6u) {
				if (voxelId < 4u) {
					if (voxelId < 3u) {
						SET_TRANSLUCENCY(vec3(1.0, 0.7, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(1.0, 0.8, 1.0));
					}
				} else {
					if (voxelId < 5u) {
						SET_TRANSLUCENCY(vec3(0.95, 0.95, 0.95));
					} else {
						SET_TRANSLUCENCY(vec3(0.85, 0.85, 0.85));
					}
				}
			} else {
				SET_EMISSION(vec3(1.25, 0.85, 0.6));
				SET_TRANSLUCENCY(vec3(0.0, 0.0, 0.0));
			}
		} else {
			if (voxelId < 22u) {
				if (voxelId < 11u) {
					if (voxelId < 9u) {
						if (voxelId < 8u) {
							SET_EMISSION(vec3(1.25, 1.0, 0.9));
						} else {
							SET_EMISSION(vec3(0.5, 0.85, 1.5));
						}
					} else {
						if (voxelId < 10u) {
							SET_EMISSION(vec3(0.6, 0.6, 0.65));
						} else {
							SET_EMISSION(vec3(0.9, 0.3, 0.0));
						}
					}
				} else {
					if (voxelId < 14u) {
						if (voxelId < 12u) {
							SET_EMISSION(vec3(1.1, 1.0, 0.85));
						} else {
							if (voxelId < 13u) {
								SET_EMISSION(vec3(1.0, 1.0, 1.0));
							} else {
								SET_EMISSION(vec3(0.1, 0.2, 0.35));
							}
						}
					} else {
						if (voxelId < 18u) {
							if (voxelId < 16u) {
								if (voxelId < 15u) {
									SET_EMISSION(vec3(1.2, 0.65, 1.15));
								} else {
									SET_EMISSION(vec3(6.0 / 15.0));
								}
							} else {
								if (voxelId < 17u) {
									SET_TRANSLUCENCY(vec3(0.0, 0.0, 0.0));
								} else {
									SET_EMISSION(vec3(0.4, 0.35, 0.3));
								}
							}
						} else {
							if (voxelId < 20u) {
								if (voxelId < 19u) {
									SET_EMISSION(vec3(11.0 / 15.0));
								} else {
									SET_EMISSION(vec3(8.0 / 15.0));
								}
							} else {
								if (voxelId < 21u) {
									SET_EMISSION(vec3(5.0 / 15.0));
								} else {
									SET_EMISSION(vec3(10.0 / 15.0));
								}
							}
						}
					}
				}
			} else {
				if (voxelId < 38u) {
					if (voxelId < 30u) {
						if (voxelId < 26u) {
							if (voxelId < 24u) {
								if (voxelId < 23u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.85, 0.8, 0.75));
								}
							} else {
								if (voxelId < 25u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 28u) {
								if (voxelId < 27u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 29u) {
									SET_EMISSION(vec3(0.55, 0.5, 0.45));
								} else {
									SET_EMISSION(vec3(0.7, 0.65, 0.6));
								}
							}
						}
					} else {
						if (voxelId < 34u) {
							if (voxelId < 32u) {
								if (voxelId < 31u) {
									SET_EMISSION(vec3(1.15, 1.0, 1.05));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 33u) {
									SET_EMISSION(vec3(0.3, 0.3, 0.3));
								} else {
									SET_EMISSION(vec3(0.85, 1.0, 0.9));
								}
							}
						} else {
							if (voxelId < 36u) {
								if (voxelId < 35u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 37u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						}
					}
				} else {
					if (voxelId < 46u) {
						if (voxelId < 42u) {
							if (voxelId < 40u) {
								if (voxelId < 39u) {
									SET_EMISSION(vec3(0.85, 0.65, 0.4));
								} else {
									SET_EMISSION(vec3(0.9, 1.1, 1.2));
								}
							} else {
								if (voxelId < 41u) {
									SET_EMISSION(vec3(1.0 / 15.0));
								} else {
									SET_EMISSION(vec3(1.05, 0.85, 0.7));
								}
							}
						} else {
							if (voxelId < 44u) {
								if (voxelId < 43u) {
									SET_EMISSION(vec3(0.2, 0.2, 0.2));
								} else {
									SET_EMISSION(vec3(0.65, 0.45, 0.3));
								}
							} else {
								if (voxelId < 45u) {
									SET_EMISSION(vec3(1.25, 1.05, 0.9));
								} else {
									SET_EMISSION(vec3(0.1, 0.1, 0.1));
								}
							}
						}
					} else {
						if (voxelId < 50u) {
							if (voxelId < 48u) {
								if (voxelId < 47u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 49u) {
									SET_EMISSION(vec3(9.0 / 15.0));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 52u) {
								if (voxelId < 51u) {
									SET_EMISSION(vec3(3.0 / 15.0));
								} else {
									SET_EMISSION(vec3(0.0 / 15.0));
								}
							} else {
								if (voxelId < 53u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(2.0 / 15.0));
								}
							}
						}
					}
				}
			}
		}
	} else {
		SET_TRANSLUCENCY(vec3(0.35, 0.5, 1.0));
	}
} else {
	if (voxelId < 95u) {
		if (voxelId < 86u) {
			if (voxelId < 79u) {
				if (voxelId < 71u) {
					if (voxelId < 63u) {
						if (voxelId < 59u) {
							if (voxelId < 57u) {
								if (voxelId < 56u) {
									SET_EMISSION(vec3(0.75, 0.35, 0.1));
								} else {
									SET_EMISSION(vec3(0.4, 0.6, 0.5));
								}
							} else {
								if (voxelId < 58u) {
									SET_EMISSION(vec3(1.0, 0.95, 0.85));
								} else {
									SET_EMISSION(vec3(0.85, 0.75, 0.95));
								}
							}
						} else {
							if (voxelId < 61u) {
								if (voxelId < 60u) {
									SET_EMISSION(vec3(0.4, 0.4, 0.4));
								} else {
									SET_EMISSION(vec3(0.7, 0.8, 1.0));
								}
							} else {
								if (voxelId < 62u) {
									SET_EMISSION(vec3(1.1, 1.0, 0.95));
								} else {
									SET_EMISSION(vec3(0.3, 0.3, 0.3));
								}
							}
						}
					} else {
						if (voxelId < 67u) {
							if (voxelId < 65u) {
								if (voxelId < 64u) {
									SET_EMISSION(vec3(15.0 / 15.0));
								} else {
									SET_EMISSION(vec3(12.0 / 15.0));
								}
							} else {
								if (voxelId < 66u) {
									SET_EMISSION(vec3(1.0, 0.9, 0.8));
								} else {
									SET_EMISSION(vec3(14.0 / 15.0));
								}
							}
						} else {
							if (voxelId < 69u) {
								if (voxelId < 68u) {
									SET_EMISSION(vec3(0.8, 1.0, 0.9));
								} else {
									SET_EMISSION(vec3(1.2, 1.0, 0.8));
								}
							} else {
								if (voxelId < 70u) {
									SET_EMISSION(vec3(13.0 / 15.0));
								} else {
									SET_EMISSION(vec3(0.65, 0.9, 0.55));
								}
							}
						}
					}
				} else {
					if (voxelId < 72u) {
						SET_EMISSION(vec3(0.5, 0.3, 0.0));
					} else {
						if (voxelId < 76u) {
							if (voxelId < 74u) {
								if (voxelId < 73u) {
									SET_TRANSLUCENCY(vec3(0.5, 1.0, 0.6));
								} else {
									SET_TRANSLUCENCY(vec3(0.7, 0.8, 0.5));
								}
							} else {
								if (voxelId < 75u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 78u) {
								if (voxelId < 77u) {
									SET_EMISSION(vec3(7.0 / 15.0));
								} else {
									SET_EMISSION(vec3(4.0 / 15.0));
								}
							} else {
								SET_EMISSION(vec3(0.45, 0.75, 1.2));
							}
						}
					}
				}
			} else {
				if (voxelId < 82u) {
					if (voxelId < 80u) {
						SET_EMISSION(vec3(1.0, 0.9, 0.5));
					} else {
						if (voxelId < 81u) {
							SET_TRANSLUCENCY(vec3(1.0, 0.75, 0.55));
						} else {
							SET_TRANSLUCENCY(vec3(1.0, 1.0, 0.75));
						}
					}
				} else {
					if (voxelId < 84u) {
						if (voxelId < 83u) {
							SET_EMISSION(vec3(1.0, 1.0, 1.0));
						} else {
							SET_EMISSION(vec3(1.0, 0.7, 0.4));
						}
					} else {
						if (voxelId < 85u) {
							SET_TRANSLUCENCY(vec3(0.6, 0.65, 1.0));
						} else {
							SET_TRANSLUCENCY(vec3(0.9, 0.7, 1.0));
						}
					}
				}
			}
		} else {
			if (voxelId < 94u) {
				if (voxelId < 90u) {
					if (voxelId < 88u) {
						if (voxelId < 87u) {
							SET_TRANSLUCENCY(vec3(0.6, 0.7, 0.8));
						} else {
							SET_TRANSLUCENCY(vec3(0.8, 0.9, 1.0));
						}
					} else {
						if (voxelId < 89u) {
							SET_TRANSLUCENCY(vec3(0.85, 0.6, 0.55));
						} else {
							SET_TRANSLUCENCY(vec3(1.0, 0.7, 0.7));
						}
					}
				} else {
					if (voxelId < 92u) {
						if (voxelId < 91u) {
							SET_TRANSLUCENCY(vec3(0.75, 0.75, 0.75));
						} else {
							SET_TRANSLUCENCY(vec3(0.65, 0.65, 0.65));
						}
					} else {
						if (voxelId < 93u) {
							SET_TRANSLUCENCY(vec3(0.8, 1.0, 0.75));
						} else {
							SET_TRANSLUCENCY(vec3(0.8, 0.9, 0.7));
						}
					}
				}
			} else {
				SET_TRANSLUCENCY(vec3(0.5, 0.75, 1.0));
			}
		}
	} else {
		SET_TRANSLUCENCY(vec3(0.5, 0.6, 0.5));
	}
}
