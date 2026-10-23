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

if (voxelId < 28u) {
	if (voxelId < 16u) {
		if (voxelId < 9u) {
			if (voxelId < 5u) {
				if (voxelId < 4u) {
					if (voxelId < 3u) {
						if (voxelId < 2u) {
						} else {
							SET_EMISSION(vec3(0.0, 0.25, 1.0));
						}
					} else {
						SET_EMISSION(vec3(1.0, 0.97, 0.92));
					}
				} else {
					SET_EMISSION(vec3(1.0, 0.9, 0.3));
				}
			} else {
				if (voxelId < 7u) {
					if (voxelId < 6u) {
						SET_EMISSION(vec3(1.0, 0.9, 0.5));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				} else {
					if (voxelId < 8u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				}
			}
		} else {
			if (voxelId < 12u) {
				if (voxelId < 11u) {
					if (voxelId < 10u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				} else {
					if (voxelId < 12u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
					}
				}
			} else {
				if (voxelId < 14u) {
					if (voxelId < 13u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				} else {
					if (voxelId < 15u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				}
			}
		}
	} else {
		if (voxelId < 17u) {
			SET_TRANSLUCENCY(vec3(0.5, 0.75, 1.0));
		} else {
			if (voxelId < 21u) {
				if (voxelId < 19u) {
					if (voxelId < 18u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				} else {
					if (voxelId < 20u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				}
			} else {
				if (voxelId < 23u) {
					if (voxelId < 22u) {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					} else {
						SET_TRANSLUCENCY(vec3(0.9, 0.9, 0.9));
					}
				} else {
					if (voxelId < 26u) {
						if (voxelId < 25u) {
							if (voxelId < 24u) {
								SET_EMISSION(vec3(0.25, 0.25, 0.25));
							} else {
								SET_EMISSION(vec3(1.0, 1.0, 0.9));
							}
						} else {
							SET_EMISSION(vec3(0.7, 0.5, 0.3));
						}
					} else {
						if (voxelId < 27u) {
							SET_EMISSION(vec3(0.0, 0.7, 0.9));
						} else {
							SET_EMISSION(vec3(0.3, 0.5, 0.4));
						}
					}
				}
			}
		}
	}
} else {
	if (voxelId < 83u) {
		if (voxelId < 29u) {
			if (voxelId < 29u) {
				SET_EMISSION(vec3(1.0, 0.5, 0.0));
				SET_TRANSLUCENCY(vec3(0.0, 0.0, 0.0));
			} else {
			}
		} else {
			if (voxelId < 51u) {
				if (voxelId < 37u) {
					if (voxelId < 31u) {
						if (voxelId < 30u) {
							SET_EMISSION(vec3(0.0, 0.5, 0.0));
						} else {
							SET_EMISSION(vec3(1.0, 1.0, 0.9));
						}
					} else {
						if (voxelId < 33u) {
							if (voxelId < 31u) {
							} else {
								if (voxelId < 32u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 35u) {
								if (voxelId < 34u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_TRANSLUCENCY(vec3(0.0, 0.0, 0.0));
								}
							} else {
								if (voxelId < 36u) {
									SET_TRANSLUCENCY(vec3(0.5, 1.0, 0.6));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						}
					}
				} else {
					if (voxelId < 45u) {
						if (voxelId < 41u) {
							if (voxelId < 39u) {
								if (voxelId < 38u) {
									SET_EMISSION(vec3(9.0 / 15.0));
								} else {
									SET_EMISSION(vec3(10.0 / 15.0));
								}
							} else {
								if (voxelId < 40u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 43u) {
								if (voxelId < 42u) {
									SET_EMISSION(vec3(13.0 / 15.0));
								} else {
									SET_EMISSION(vec3(14.0 / 15.0));
								}
							} else {
								if (voxelId < 44u) {
									SET_EMISSION(vec3(7.0 / 15.0));
								} else {
									SET_EMISSION(vec3(8.0 / 15.0));
								}
							}
						}
					} else {
						if (voxelId < 49u) {
							if (voxelId < 47u) {
								if (voxelId < 46u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 48u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						} else {
							if (voxelId < 50u) {
								if (voxelId < 49u) {
								} else {
									SET_TRANSLUCENCY(vec3(0.7, 0.8, 0.5));
								}
							} else {
								if (voxelId < 51u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
								}
							}
						}
					}
				}
			} else {
				if (voxelId < 67u) {
					if (voxelId < 59u) {
						if (voxelId < 55u) {
							if (voxelId < 53u) {
								if (voxelId < 52u) {
									SET_EMISSION(vec3(0.4, 0.4, 0.4));
								} else {
									SET_EMISSION(vec3(0.2, 0.4, 0.3));
								}
							} else {
								if (voxelId < 54u) {
									SET_EMISSION(vec3(3.0 / 15.0));
								} else {
									SET_EMISSION(vec3(4.0 / 15.0));
								}
							}
						} else {
							if (voxelId < 57u) {
								if (voxelId < 56u) {
									SET_EMISSION(vec3(1.0, 1.0, 1.0));
								} else {
									SET_EMISSION(vec3(0.4, 0.5, 0.5));
								}
							} else {
								if (voxelId < 58u) {
									SET_EMISSION(vec3(0.2, 0.2, 0.2));
								} else {
									SET_EMISSION(vec3(0.3, 0.3, 0.3));
								}
							}
						}
					} else {
						if (voxelId < 63u) {
							if (voxelId < 61u) {
								if (voxelId < 60u) {
									SET_EMISSION(vec3(1.0 / 15.0));
								} else {
									SET_EMISSION(vec3(2.0 / 15.0));
								}
							} else {
								if (voxelId < 62u) {
									SET_EMISSION(vec3(11.0 / 15.0));
								} else {
									SET_EMISSION(vec3(12.0 / 15.0));
								}
							}
						} else {
							if (voxelId < 65u) {
								if (voxelId < 64u) {
									SET_EMISSION(vec3(5.0 / 15.0));
								} else {
									SET_EMISSION(vec3(6.0 / 15.0));
								}
							} else {
								if (voxelId < 66u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.0 / 15.0));
								}
							}
						}
					}
				} else {
					if (voxelId < 75u) {
						if (voxelId < 71u) {
							if (voxelId < 69u) {
								if (voxelId < 68u) {
									SET_EMISSION(vec3(0.3, 0.3, 0.3));
								} else {
									SET_EMISSION(vec3(0.9, 0.95, 1.0));
								}
							} else {
								if (voxelId < 70u) {
									SET_EMISSION(vec3(1.0, 1.0, 1.0));
								} else {
									SET_EMISSION(vec3(1.0, 1.0, 0.9));
								}
							}
						} else {
							if (voxelId < 73u) {
								if (voxelId < 72u) {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							} else {
								if (voxelId < 74u) {
									SET_EMISSION(vec3(0.1, 0.0, 0.0));
								} else {
									SET_EMISSION(vec3(0.25, 0.25, 0.25));
								}
							}
						}
					} else {
						if (voxelId < 79u) {
							if (voxelId < 77u) {
								if (voxelId < 76u) {
									SET_EMISSION(vec3(1.0, 1.0, 0.9));
								} else {
									SET_EMISSION(vec3(0.9, 1.0, 1.0));
								}
							} else {
								if (voxelId < 78u) {
									SET_EMISSION(vec3(1.0, 1.0, 1.0));
								} else {
									SET_EMISSION(vec3(1.0, 1.0, 1.0));
								}
							}
						} else {
							if (voxelId < 81u) {
								if (voxelId < 80u) {
									SET_EMISSION(vec3(1.0, 0.9, 0.8));
								} else {
									SET_EMISSION(vec3(0.1, 0.1, 0.1));
								}
							} else {
								if (voxelId < 82u) {
									SET_EMISSION(vec3(15.0 / 15.0));
								} else {
									SET_EMISSION(vec3(1.0, 1.0, 0.9));
								}
							}
						}
					}
				}
			}
		}
	} else {
		SET_TRANSLUCENCY(vec3(0.5, 0.5, 1.0));
	}
}
