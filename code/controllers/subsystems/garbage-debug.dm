#ifdef TESTING

/datum/var/running_find_references
/datum/var/last_find_references = 0

/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	find_references(FALSE)

/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = 1
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert)
			if(alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
				running_find_references = null
				return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = 0

	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	last_find_references = world.time
	find_references_in_globals()
	for(var/datum/thing in world)
		DoSearchVar(thing, "WorldRef: [thing]")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = 1
	SSgarbage.next_fire = world.time + world.tick_lag

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(SSgarbage)
		while(SSgarbage.queue.len)
			var/datum/o = locate(SSgarbage.queue[1])
			if(istype(o) && o.gcDestroyed)
				del(o)
				SSgarbage.totaldels++
			SSgarbage.queue.Cut(1, 2)

/datum/verb/qdel_then_find_references(datum/thing in world)
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1

	qdel(thing)
	if(!thing.running_find_references)
		thing.find_references(TRUE)

/client/verb/show_qdeleted()
	set category = "Debug"
	set name = "Show qdel() Log"
	set desc = "Render the qdel() log and display it"

	var/dat = "<B>List of things that have been qdel()eted this round</B><BR><BR>"

	var/tmplist = list()
	for(var/elem in SSgarbage.qdel_list)
		if(!(elem in tmplist))
			tmplist[elem] = 0
		tmplist[elem]++

	for(var/path in tmplist)
		dat += "[path] - [tmplist[path]] times<BR>"

	usr << browse(dat, "window=qdeletedlog")

#define SearchVar(X) DoSearchVar(X, "Global: " + #X)

/datum/proc/DoSearchVar(X, Xname)
	if(usr && usr.client && !usr.client.running_find_references) return
	if(istype(X, /datum))
		var/datum/D = X
		if(D.last_find_references == last_find_references)
			return
		D.last_find_references = last_find_references
		for(var/V in D.vars)
			for(var/varname in D.vars)
				var/variable = D.vars[varname]
				if(variable == src)
					testing("Found [src.type] \ref[src] in [D.type]'s [varname] var. [Xname]")
				else if(islist(variable))
					if(src in variable)
						testing("Found [src.type] \ref[src] in [D.type]'s [varname] list var. Global: [Xname]")
#ifdef GC_FAILURE_HARD_LOOKUP
					for(var/I in variable)
						DoSearchVar(I, TRUE)
				else
					DoSearchVar(variable, "[Xname]: [varname]")
#endif
	else if(islist(X))
		if(src in X)
			testing("Found [src.type] \ref[src] in list [Xname].")
#ifdef GC_FAILURE_HARD_LOOKUP
		for(var/I in X)
			DoSearchVar(I, Xname + ": list")
#else
	CHECK_TICK
#endif


/datum/proc/find_references_in_globals()
	SearchVar(all_areas)
	SearchVar(processing_power_items)
	SearchVar(med_hud_users)
	SearchVar(sec_hud_users)
	SearchVar(hud_icon_reference)
	SearchVar(janitorial_supplies)
	SearchVar(world_phylactery)
	SearchVar(listening_objects)
	SearchVar(global_mutations)
	SearchVar(universe)
	SearchVar(global_map)
	SearchVar(hit_appends)
	SearchVar(map_levels)
	SearchVar(diary)
	SearchVar(diary_runtime)
	SearchVar(diary_date_string)
	SearchVar(href_logfile)
	SearchVar(station_name)
	SearchVar(station_short)
	SearchVar(dock_name)
	SearchVar(boss_name)
	SearchVar(boss_short)
	SearchVar(company_name)
	SearchVar(company_short)
	SearchVar(game_version)
	SearchVar(changelog_hash)
	SearchVar(game_year)
	SearchVar(round_progressing)
	SearchVar(master_mode)
	SearchVar(secret_force_mode)
	SearchVar(host)
	SearchVar(jobMax)
	SearchVar(bombers)
	SearchVar(admin_log)
	SearchVar(lastsignalers)
	SearchVar(lawchanges)
	SearchVar(reg_dna)
	SearchVar(monkeystart)
	SearchVar(wizardstart)
	SearchVar(newplayer_start)
	SearchVar(latejoin)
	SearchVar(latejoin_gateway)
	SearchVar(latejoin_cryo)
	SearchVar(latejoin_cyborg)
	SearchVar(latejoin_merchant)
	SearchVar(kickoffsloc)
	SearchVar(prisonwarp)
	SearchVar(holdingfacility)
	SearchVar(xeno_spawn)
	SearchVar(tdome1)
	SearchVar(tdome2)
	SearchVar(tdomeobserve)
	SearchVar(tdomeadmin)
	SearchVar(prisonsecuritywarp)
	SearchVar(prisonwarped)
	SearchVar(ninjastart)
	SearchVar(cardinal)
	SearchVar(cornerdirs)
	SearchVar(alldirs)
	SearchVar(reverse_dir)
	SearchVar(config)
	SearchVar(combatlog)
	SearchVar(IClog)
	SearchVar(OOClog)
	SearchVar(adminlog)
	SearchVar(Debug2)
	SearchVar(debugobj)
	SearchVar(mods)
	SearchVar(gravity_is_on)
	SearchVar(server_greeting)
	SearchVar(awaydestinations)
	SearchVar(fileaccess_timer)
	SearchVar(custom_event_msg)
	SearchVar(dbcon)
	SearchVar(alphabet_uppercase)
	SearchVar(robot_module_types)
	SearchVar(scarySounds)
	SearchVar(max_explosion_range)
	SearchVar(global_announcer)
	SearchVar(station_departments)
	SearchVar(TICKS_IN_DAY)
	SearchVar(TICKS_IN_HOUR)
	SearchVar(TICKS_IN_SECOND)
	SearchVar(exo_beacons)
	SearchVar(ai_names)
	SearchVar(wizard_first)
	SearchVar(wizard_second)
	SearchVar(ninja_titles)
	SearchVar(ninja_names)
	SearchVar(commando_names)
	SearchVar(first_names_male)
	SearchVar(first_names_female)
	SearchVar(last_names)
	SearchVar(clown_names)
	SearchVar(verbs)
	SearchVar(adjectives)
	SearchVar(init)
	SearchVar(world_api_rate_limit)
	SearchVar(tachycardics)
	SearchVar(bradycardics)
	SearchVar(heartstopper)
	SearchVar(cheartstopper)
	SearchVar(BLINDBLOCK)
	SearchVar(DEAFBLOCK)
	SearchVar(HULKBLOCK)
	SearchVar(TELEBLOCK)
	SearchVar(FIREBLOCK)
	SearchVar(XRAYBLOCK)
	SearchVar(CLUMSYBLOCK)
	SearchVar(FAKEBLOCK)
	SearchVar(COUGHBLOCK)
	SearchVar(GLASSESBLOCK)
	SearchVar(EPILEPSYBLOCK)
	SearchVar(TWITCHBLOCK)
	SearchVar(NERVOUSBLOCK)
	SearchVar(MONKEYBLOCK)
	SearchVar(BLOCKADD)
	SearchVar(DIFFMUT)
	SearchVar(HEADACHEBLOCK)
	SearchVar(NOBREATHBLOCK)
	SearchVar(REMOTEVIEWBLOCK)
	SearchVar(REGENERATEBLOCK)
	SearchVar(INCREASERUNBLOCK)
	SearchVar(REMOTETALKBLOCK)
	SearchVar(MORPHBLOCK)
	SearchVar(BLENDBLOCK)
	SearchVar(HALLUCINATIONBLOCK)
	SearchVar(NOPRINTSBLOCK)
	SearchVar(SHOCKIMMUNITYBLOCK)
	SearchVar(SMALLSIZEBLOCK)
	SearchVar(restricted_camera_networks)
	SearchVar(PUB_FREQ)
	SearchVar(SEC_FREQ)
	SearchVar(ENG_FREQ)
	SearchVar(MED_FREQ)
	SearchVar(SCI_FREQ)
	SearchVar(SRV_FREQ)
	SearchVar(SUP_FREQ)
	SearchVar(radiochannels)
	SearchVar(CENT_FREQS)
	SearchVar(CENT_FREQS_ASSOC)
	SearchVar(ANTAG_FREQS)
	SearchVar(ANTAG_FREQS_ASSOC)
	SearchVar(DEPT_FREQS)
	SearchVar(DEPT_FREQS_ASSOC)
	SearchVar(url_find_lazy)
	SearchVar(markup_bold)
	SearchVar(markup_italics)
	SearchVar(markup_strike)
	SearchVar(markup_underline)
	SearchVar(markup_regex)
	SearchVar(markup_tags)
	SearchVar(csrfz_check)
	SearchVar(gzn_check)
	SearchVar(clients)
	SearchVar(admins)
	SearchVar(directory)
	SearchVar(player_list)
	SearchVar(mob_list)
	SearchVar(human_mob_list)
	SearchVar(silicon_mob_list)
	SearchVar(living_mob_list)
	SearchVar(dead_mob_list)
	SearchVar(topic_commands)
	SearchVar(topic_commands_names)
	SearchVar(landmarks_list)
	SearchVar(surgery_steps)
	SearchVar(side_effects)
	SearchVar(mechas_list)
	SearchVar(joblist)
	SearchVar(brig_closets)
	SearchVar(teleportlocs)
	SearchVar(ghostteleportlocs)
	SearchVar(centcom_areas)
	SearchVar(the_station_areas)
	SearchVar(implants)
	SearchVar(turfs)
	SearchVar(all_species)
	SearchVar(all_languages)
	SearchVar(language_keys)
	SearchVar(whitelisted_species)
	SearchVar(playable_species)
	SearchVar(poster_designs)
	SearchVar(world_uplinks)
	SearchVar(hair_styles_list)
	SearchVar(hair_styles_male_list)
	SearchVar(hair_styles_female_list)
	SearchVar(facial_hair_styles_list)
	SearchVar(facial_hair_styles_male_list)
	SearchVar(facial_hair_styles_female_list)
	SearchVar(skin_styles_female_list)
	SearchVar(body_marking_styles_list)
	SearchVar(underwear_m)
	SearchVar(underwear_f)
	SearchVar(undershirt_t)
	SearchVar(socks_f)
	SearchVar(socks_m)
	SearchVar(backbaglist)
	SearchVar(exclude_jobs)
	SearchVar(visual_nets)
	SearchVar(cameranet)
	SearchVar(rune_list)
	SearchVar(escape_list)
	SearchVar(endgame_exits)
	SearchVar(endgame_safespawns)
	SearchVar(syndicate_access)
	SearchVar(cloaking_devices)
	SearchVar(church_name)
	SearchVar(command_name)
	SearchVar(religion_name)
	SearchVar(syndicate_name)
	SearchVar(syndicate_code_phrase)
	SearchVar(syndicate_code_response)
	SearchVar(roundstart_hour)
	SearchVar(round_start_time)
	SearchVar(real_round_start_time)
	SearchVar(common_tools)
	SearchVar(wall_items)
	SearchVar(sortInstance)
	SearchVar(cmp_field)
	SearchVar(tk_maxrange)
	SearchVar(global_hud)
	SearchVar(global_huds)
	SearchVar(robot_inventory)
	SearchVar(pipe_colors)
	SearchVar(gamemode_cache)
	SearchVar(panic_targets)
	SearchVar(panic_targets_data_loss)
	SearchVar(Failsafe)
	SearchVar(Master)
	SearchVar(CURRENT_TICKLIMIT)
	SearchVar(SSalarm)
	SearchVar(SSchemistry)
	SearchVar(SScargo)
	SearchVar(SSeconomy)
	SearchVar(SSeffects)
	SearchVar(emergency_shuttle)
	SearchVar(SSevents)
	SearchVar(SSexplosives)
	SearchVar(SSgarbage)
	SearchVar(SSlistener)
	SearchVar(SSicon_smooth)
	SearchVar(SSipintel)
	SearchVar(SSlighting)
	SearchVar(SSnightlight)
	SearchVar(SSorbit)
	SearchVar(SSoverlays)
	SearchVar(SSparallax)
	SearchVar(SSradio)
	SearchVar(SSrecords)
	SearchVar(sun)
	SearchVar(SScargo)
	SearchVar(SSticker)
	SearchVar(SStimer)
	SearchVar(SSvote)
	SearchVar(SSatoms)
	SearchVar(SSxenoarch)
	SearchVar(SScalamity)
	SearchVar(SSdisease)
	SearchVar(SSmodifiers)
	SearchVar(SSnanoui)
	SearchVar(SSpipenet)
	SearchVar(SSprocessing)
	SearchVar(shuttle_controller)
	SearchVar(base_law_type)
	SearchVar(discord_bot)
	SearchVar(diseases)
	SearchVar(modules)
	SearchVar(archive_diseases)
	SearchVar(advance_cures)
	SearchVar(list_symptoms)
	SearchVar(dictionary_symptoms)
	SearchVar(SYMPTOM_ACTIVATION_PROB)
	SearchVar(revdata)
	SearchVar(camera_repository)
	SearchVar(crew_repository)
	SearchVar(uplink)
	SearchVar(AIRLOCK_WIRE_IDSCAN)
	SearchVar(AIRLOCK_WIRE_MAIN_POWER1)
	SearchVar(AIRLOCK_WIRE_MAIN_POWER2)
	SearchVar(AIRLOCK_WIRE_DOOR_BOLTS)
	SearchVar(AIRLOCK_WIRE_BACKUP_POWER1)
	SearchVar(AIRLOCK_WIRE_BACKUP_POWER2)
	SearchVar(AIRLOCK_WIRE_OPEN_DOOR)
	SearchVar(AIRLOCK_WIRE_AI_CONTROL)
	SearchVar(AIRLOCK_WIRE_ELECTRIFY)
	SearchVar(AIRLOCK_WIRE_SAFETY)
	SearchVar(AIRLOCK_WIRE_SPEED)
	SearchVar(AIRLOCK_WIRE_LIGHT)
	SearchVar(AALARM_WIRE_IDSCAN)
	SearchVar(AALARM_WIRE_POWER)
	SearchVar(AALARM_WIRE_SYPHON)
	SearchVar(AALARM_WIRE_AI_CONTROL)
	SearchVar(AALARM_WIRE_AALARM)
	SearchVar(AUTOLATHE_HACK_WIRE)
	SearchVar(AUTOLATHE_SHOCK_WIRE)
	SearchVar(AUTOLATHE_DISABLE_WIRE)
	SearchVar(CAMERA_WIRE_FOCUS)
	SearchVar(CAMERA_WIRE_POWER)
	SearchVar(CAMERA_WIRE_LIGHT)
	SearchVar(CAMERA_WIRE_ALARM)
	SearchVar(CAMERA_WIRE_NOTHING1)
	SearchVar(CAMERA_WIRE_NOTHING2)
	SearchVar(WIRE_EXPLODE)
	SearchVar(WIRE_POWER1)
	SearchVar(WIRE_POWER2)
	SearchVar(WIRE_AVOIDANCE)
	SearchVar(WIRE_LOADCHECK)
	SearchVar(WIRE_MOTOR1)
	SearchVar(WIRE_MOTOR2)
	SearchVar(WIRE_REMOTE_RX)
	SearchVar(WIRE_REMOTE_TX)
	SearchVar(WIRE_BEACON_RX)
	SearchVar(NUCLEARBOMB_WIRE_LIGHT)
	SearchVar(NUCLEARBOMB_WIRE_TIMING)
	SearchVar(NUCLEARBOMB_WIRE_SAFETY)
	SearchVar(PARTICLE_TOGGLE_WIRE)
	SearchVar(PARTICLE_STRENGTH_WIRE)
	SearchVar(PARTICLE_INTERFACE_WIRE)
	SearchVar(PARTICLE_LIMIT_POWER_WIRE)
	SearchVar(WIRE_SIGNAL)
	SearchVar(WIRE_RECEIVE)
	SearchVar(WIRE_TRANSMIT)
	SearchVar(BORG_WIRE_LAWCHECK)
	SearchVar(BORG_WIRE_MAIN_POWER)
	SearchVar(BORG_WIRE_LOCKED_DOWN)
	SearchVar(BORG_WIRE_AI_CONTROL)
	SearchVar(BORG_WIRE_CAMERA)
	SearchVar(SMARTFRIDGE_WIRE_ELECTRIFY)
	SearchVar(SMARTFRIDGE_WIRE_THROW)
	SearchVar(SMARTFRIDGE_WIRE_IDSCAN)
	SearchVar(SMES_WIRE_RCON)
	SearchVar(SMES_WIRE_INPUT)
	SearchVar(SMES_WIRE_OUTPUT)
	SearchVar(SMES_WIRE_GROUNDING)
	SearchVar(SMES_WIRE_FAILSAFES)
	SearchVar(SUIT_STORAGE_WIRE_ELECTRIFY)
	SearchVar(SUIT_STORAGE_WIRE_SAFETY)
	SearchVar(SUIT_STORAGE_WIRE_LOCKED)
	SearchVar(VENDING_WIRE_THROW)
	SearchVar(VENDING_WIRE_CONTRABAND)
	SearchVar(VENDING_WIRE_ELECTRIFY)
	SearchVar(VENDING_WIRE_IDSCAN)
	SearchVar(same_wires)
	SearchVar(wireColours)
	SearchVar(accessible_z_levels)
	SearchVar(base_turf_by_z)
	SearchVar(newscaster_standard_feeds)
	SearchVar(announced_news_types)
	SearchVar(send_emergency_team)
	SearchVar(can_call_ert)
	SearchVar(shatter_sound)
	SearchVar(explosion_sound)
	SearchVar(spark_sound)
	SearchVar(rustle_sound)
	SearchVar(punch_sound)
	SearchVar(clown_sound)
	SearchVar(swing_hit_sound)
	SearchVar(hiss_sound)
	SearchVar(page_sound)
	SearchVar(fracture_sound)
	SearchVar(blank)
	SearchVar(catwalk)
	SearchVar(wood)
	SearchVar(tiles)
	SearchVar(plating)
	SearchVar(carpet)
	SearchVar(asteroid)
	SearchVar(grass)
	SearchVar(water)
	SearchVar(lava)
	SearchVar(snow)
	SearchVar(sand)
	SearchVar(footstepfx)
	SearchVar(FALLOFF_SOUNDS)
	SearchVar(all_antag_types)
	SearchVar(all_antag_spawnpoints)
	SearchVar(antag_names_to_ids)
	SearchVar(bantype_to_antag_age)
	SearchVar(borers)
	SearchVar(xenomorphs)
	SearchVar(actor)
	SearchVar(commandos)
	SearchVar(deathsquad)
	SearchVar(ert)
	SearchVar(mercs)
	SearchVar(ninjas)
	SearchVar(raiders)
	SearchVar(wizards)
	SearchVar(cult)
	SearchVar(highlanders)
	SearchVar(loyalists)
	SearchVar(renegades)
	SearchVar(revs)
	SearchVar(malf)
	SearchVar(thralls)
	SearchVar(traitors)
	SearchVar(vamp)
	SearchVar(forced_ambiance_list)
	SearchVar(dna_activity_bounds)
	SearchVar(assigned_blocks)
	SearchVar(dna_genes)
	SearchVar(eventchance)
	SearchVar(hadevent)
	SearchVar(antag_add_failed)
	SearchVar(additional_antag_types)
	SearchVar(all_objectives)
	SearchVar(process_objectives)
	SearchVar(possible_changeling_IDs)
	SearchVar(hivemind_bank)
	SearchVar(powers)
	SearchVar(powerinstances)
	SearchVar(narsie_behaviour)
	SearchVar(narsie_cometh)
	SearchVar(narsie_list)
	SearchVar(cultwords)
	SearchVar(runedec)
	SearchVar(engwords)
	SearchVar(rnwords)
	SearchVar(sacrificed)
	SearchVar(universe_has_ended)
	SearchVar(Holiday)
	SearchVar(nuke_disks)
	SearchVar(vampirepower_types)
	SearchVar(vampirepowers)
	SearchVar(ghost_all_access)
	SearchVar(ENGSEC)
	SearchVar(CAPTAIN)
	SearchVar(HOS)
	SearchVar(WARDEN)
	SearchVar(DETECTIVE)
	SearchVar(OFFICER)
	SearchVar(CHIEF)
	SearchVar(ENGINEER)
	SearchVar(ATMOSTECH)
	SearchVar(AI)
	SearchVar(CYBORG)
	SearchVar(INTERN_SEC)
	SearchVar(INTERN_ENG)
	SearchVar(FORENSICS)
	SearchVar(MEDSCI)
	SearchVar(RD)
	SearchVar(SCIENTIST)
	SearchVar(CHEMIST)
	SearchVar(CMO)
	SearchVar(DOCTOR)
	SearchVar(GENETICIST)
	SearchVar(VIROLOGIST)
	SearchVar(PSYCHIATRIST)
	SearchVar(ROBOTICIST)
	SearchVar(XENOBIOLOGIST)
	SearchVar(PARAMEDIC)
	SearchVar(INTERN_MED)
	SearchVar(INTERN_SCI)
	SearchVar(CIVILIAN)
	SearchVar(HOP)
	SearchVar(BARTENDER)
	SearchVar(BOTANIST)
	SearchVar(CHEF)
	SearchVar(JANITOR)
	SearchVar(LIBRARIAN)
	SearchVar(QUARTERMASTER)
	SearchVar(CARGOTECH)
	SearchVar(MINER)
	SearchVar(LAWYER)
	SearchVar(CHAPLAIN)
	SearchVar(CLOWN)
	SearchVar(MIME)
	SearchVar(MERCHANT)
	SearchVar(ASSISTANT)
	SearchVar(assistant_occupations)
	SearchVar(command_positions)
	SearchVar(engineering_positions)
	SearchVar(medical_positions)
	SearchVar(science_positions)
	SearchVar(cargo_positions)
	SearchVar(civilian_positions)
	SearchVar(security_positions)
	SearchVar(nonhuman_positions)
	SearchVar(whitelist)
	SearchVar(captain_announcement)
	SearchVar(doppler_arrays)
	SearchVar(floor_light_cache)
	SearchVar(HOLOPAD_MODE)
	SearchVar(navbeacons)
	SearchVar(SSnews)
	SearchVar(allCasters)
	SearchVar(bomb_set)
	SearchVar(req_console_assistance)
	SearchVar(req_console_supplies)
	SearchVar(req_console_information)
	SearchVar(allConsoles)
	SearchVar(ai_status_emotions)
	SearchVar(station_networks)
	SearchVar(engineering_networks)
	SearchVar(priority_air_alarms)
	SearchVar(minor_air_alarms)
	SearchVar(air_alarm_topic)
	SearchVar(specops_shuttle_moving_to_station)
	SearchVar(specops_shuttle_moving_to_centcom)
	SearchVar(specops_shuttle_at_station)
	SearchVar(specops_shuttle_can_send)
	SearchVar(specops_shuttle_time)
	SearchVar(specops_shuttle_timeleft)
	SearchVar(syndicate_elite_shuttle_moving_to_station)
	SearchVar(syndicate_elite_shuttle_moving_to_mothership)
	SearchVar(syndicate_elite_shuttle_at_station)
	SearchVar(syndicate_elite_shuttle_can_send)
	SearchVar(syndicate_elite_shuttle_time)
	SearchVar(syndicate_elite_shuttle_timeleft)
	SearchVar(recentmessages)
	SearchVar(message_delay)
	SearchVar(telecomms_list)
	SearchVar(word_to_uristrune_table)
	SearchVar(slot_flags_enumeration)
	SearchVar(BUMP_TELEPORTERS)
	SearchVar(active_radio_jammers)
	SearchVar(default_uplink_selection)
	SearchVar(chatrooms)
	SearchVar(PDAs)
	SearchVar(teleportbeacons)
	SearchVar(default_internal_channels)
	SearchVar(default_medbay_channels)
	SearchVar(rod_recipes)
	SearchVar(NO_EMAG_ACT)
	SearchVar(last_chew)
	SearchVar(hazard_overlays)
	SearchVar(tape_roll_applications)
	SearchVar(malftransformermade)
	SearchVar(MIN_ACTIVE_TIME)
	SearchVar(MAX_ACTIVE_TIME)
	SearchVar(enterloopsanity)
	SearchVar(flooring_types)
	SearchVar(random_junk)
	SearchVar(js_byjax)
	SearchVar(js_dropdowns)
	SearchVar(BSACooldown)
	SearchVar(floorIsLava)
	SearchVar(admin_ranks)
	SearchVar(admin_secrets)
	SearchVar(admin_verbs_default)
	SearchVar(admin_verbs_admin)
	SearchVar(admin_verbs_ban)
	SearchVar(admin_verbs_sounds)
	SearchVar(admin_verbs_fun)
	SearchVar(admin_verbs_spawn)
	SearchVar(admin_verbs_server)
	SearchVar(admin_verbs_debug)
	SearchVar(admin_verbs_paranoid_debug)
	SearchVar(admin_verbs_possess)
	SearchVar(admin_verbs_permissions)
	SearchVar(admin_verbs_rejuv)
	SearchVar(admin_verbs_hideable)
	SearchVar(admin_verbs_mod)
	SearchVar(admin_verbs_dev)
	SearchVar(admin_verbs_cciaa)
	SearchVar(jobban_keylist)
	SearchVar(admin_datums)
	SearchVar(CMinutes)
	SearchVar(Banlist)
	SearchVar(adminhelp_ignored_words)
	SearchVar(checked_for_inactives)
	SearchVar(inactive_keys)
	SearchVar(camera_range_display_status)
	SearchVar(intercom_range_display_status)
	SearchVar(debug_verbs)
	SearchVar(prevent_airgroup_regroup)
	SearchVar(say_disabled)
	SearchVar(movement_disabled)
	SearchVar(movement_disabled_exception)
	SearchVar(forbidden_varedit_object_types)
	SearchVar(VVlocked)
	SearchVar(VVicon_edit_lock)
	SearchVar(VVckey_edit)
	SearchVar(VVdynamic_lock)
	SearchVar(sounds_cache)
	SearchVar(commandos_possible)
	SearchVar(random_stock_common)
	SearchVar(random_stock_uncommon)
	SearchVar(random_stock_rare)
	SearchVar(random_stock_large)
	SearchVar(asset_datums)
	SearchVar(preferences_datums)
	SearchVar(seen_citizenships)
	SearchVar(seen_systems)
	SearchVar(seen_factions)
	SearchVar(seen_religions)
	SearchVar(citizenship_choices)
	SearchVar(home_system_choices)
	SearchVar(faction_choices)
	SearchVar(religion_choices)
	SearchVar(spawntypes)
	SearchVar(uplink_locations)
	SearchVar(valid_bloodtypes)
	SearchVar(gear_tweak_free_color_choice)
	SearchVar(loadout_categories)
	SearchVar(gear_datums)
	SearchVar(breach_brute_descriptors)
	SearchVar(breach_burn_descriptors)
	SearchVar(FINGERPRINT_COMPLETE)
	SearchVar(weighted_randomevent_locations)
	SearchVar(weighted_mundaneevent_locations)
	SearchVar(severity_to_string)
	SearchVar(event_last_fired)
	SearchVar(dreams)
	SearchVar(non_fakeattack_weapons)
	SearchVar(ghost_traps)
	SearchVar(current_map.holodeck_programs)
	SearchVar(fruit_icon_cache)
	SearchVar(plant_seed_sprites)
	SearchVar(wax_recipes)
	SearchVar(worths)
	SearchVar(admin_verbs_lighting)
	SearchVar(liquid_delay)
	SearchVar(puddles)
	SearchVar(use_preloader)
	SearchVar(_preloader)
	SearchVar(swapmaps_iconcache)
	SearchVar(SWAPMAPS_SAV)
	SearchVar(SWAPMAPS_TEXT)
	SearchVar(swapmaps_mode)
	SearchVar(swapmaps_compiled_maxx)
	SearchVar(swapmaps_compiled_maxy)
	SearchVar(swapmaps_compiled_maxz)
	SearchVar(swapmaps_initialized)
	SearchVar(swapmaps_loaded)
	SearchVar(swapmaps_byname)
	SearchVar(minevendor_list)
	SearchVar(total_extraction_beacons)
	SearchVar(ore_data)
	SearchVar(dview_mob)
	SearchVar(holder_mob_icon_cache)
	SearchVar(slot_equipment_priority)
	SearchVar(base_miss_chance)
	SearchVar(organ_rel_size)
	SearchVar(intents)
	SearchVar(department_radio_keys)
	SearchVar(channel_to_radio_key)
	SearchVar(cleanbot_types)
	SearchVar(diona_banned_languages)
	SearchVar(alcohol_clumsy)
	SearchVar(sparring_attack_cache)
	SearchVar(MAXIMUM_MEME_POINTS)
	SearchVar(host_brain)
	SearchVar(controlling)
	SearchVar(ai_list)
	SearchVar(ai_verbs_default)
	SearchVar(default_ai_icon)
	SearchVar(ai_icons)
	SearchVar(empty_playable_ai_cores)
	SearchVar(pai_emotions)
	SearchVar(robot_custom_icons)
	SearchVar(robot_modules)
	SearchVar(protected_objects)
	SearchVar(SKILL_NONE)
	SearchVar(SKILL_BASIC)
	SearchVar(SKILL_ADEPT)
	SearchVar(SKILL_EXPERT)
	SearchVar(SKILLS)
	SearchVar(SKILL_ENGINEER)
	SearchVar(SKILL_ORGAN_ROBOTICIST)
	SearchVar(SKILL_SECURITY_OFFICER)
	SearchVar(SKILL_CHEMIST)
	SearchVar(SKILL_PRE)
	SearchVar(file_uid)
	SearchVar(comm_message_listeners)
	SearchVar(global_message_listener)
	SearchVar(last_message_id)
	SearchVar(nttransfer_uid)
	SearchVar(warrant_uid)
	SearchVar(ntnet_card_uid)
	SearchVar(ntnet_global)
	SearchVar(ntnrc_uid)
	SearchVar(all_robolimbs)
	SearchVar(chargen_robolimbs)
	SearchVar(basic_robolimb)
	SearchVar(moving_levels)
	SearchVar(cached_space)
	SearchVar(map_sectors)
	SearchVar(ship_engines)
	SearchVar(allfaxes)
	SearchVar(arrived_faxes)
	SearchVar(sent_faxes)
	SearchVar(alldepartments)
	SearchVar(admin_departments)
	SearchVar(photo_count)
	SearchVar(possible_cable_coil_colours)
	SearchVar(rad_collectors)
	SearchVar(blacklisted_tesla_types)
	SearchVar(random_maps)
	SearchVar(map_count)
	SearchVar(supply_drop)
	SearchVar(maze_cell_count)
	SearchVar(lunchables_lunches_)
	SearchVar(lunchables_snacks_)
	SearchVar(lunchables_drinks_)
	SearchVar(lunchables_drink_reagents_)
	SearchVar(lunchables_alcohol_reagents_)
	SearchVar(message_servers)
	SearchVar(blackbox)
	SearchVar(responsive_carriers)
	SearchVar(finds_as_strings)
	SearchVar(ascii_A)
	SearchVar(ascii_Z)
	SearchVar(ascii_a)
	SearchVar(ascii_z)
	SearchVar(ascii_DOLLAR)
	SearchVar(ascii_ZERO)
	SearchVar(ascii_NINE)
	SearchVar(ascii_UNDERSCORE)
	SearchVar(OOP_OR)
	SearchVar(OOP_AND)
	SearchVar(OOP_BIT)
	SearchVar(OOP_EQUAL)
	SearchVar(OOP_COMPARE)
	SearchVar(OOP_ADD)
	SearchVar(OOP_MULTIPLY)
	SearchVar(OOP_POW)
	SearchVar(OOP_UNARY)
	SearchVar(OOP_GROUP)
	SearchVar(KW_FAIL)
	SearchVar(KW_PASS)
	SearchVar(KW_ERR)
	SearchVar(KW_WARN)
	SearchVar(maint_all_access)
	SearchVar(spells)
	SearchVar(artefact_feedback)
	SearchVar(GPS_list)
	SearchVar(gps_by_type)
	SearchVar(ventcrawl_machinery)
	SearchVar(can_enter_vent_with)
	SearchVar(ALL_ANTIGENS)
	SearchVar(all_unit_tests_passed)
	SearchVar(failed_unit_tests)
	SearchVar(total_unit_tests)
	SearchVar(ascii_esc)
	SearchVar(ascii_red)
	SearchVar(ascii_green)
	SearchVar(ascii_reset)
	SearchVar(assigned)
	SearchVar(created)
	SearchVar(merged)
	SearchVar(invalid_zone)
	SearchVar(air_blocked)
	SearchVar(zone_blocked)
	SearchVar(blocked)
	SearchVar(mark)
	SearchVar(contamination_overlay)
	SearchVar(vsc)
	SearchVar(global_player_panel)

#endif
