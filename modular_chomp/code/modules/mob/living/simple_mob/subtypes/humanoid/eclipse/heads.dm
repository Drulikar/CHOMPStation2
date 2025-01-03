/mob/living/simple_mob/humanoid/eclipse/head
	name = "Eclipse Head"
	desc = "You shouldn't be seeing this. This is going to be rough"
	health = 315
	maxHealth = 315 //A 20 damae shot will need to land 35 times
	projectile_dispersion = 8
	projectile_accuracy = 0
	ranged_cooldown = 5
	grab_resist = 100

	damage_fatigue_mult = 0

	armor = list(melee = 20, bullet = 20, laser = 20, energy = 20, bomb = 100, bio = 100, rad = 100)
	armor_soak = list(melee = 7, bullet = 7, laser = 7, energy = 7, bomb = 0, bio = 0, rad = 0)

/mob/living/simple_mob/humanoid/eclipse/head/security
	name = "Eclipse Head Of Security"
	icon_state = "fleetsec"
	projectiletype = /obj/item/projectile/energy/flamecrystal
	special_attack_cooldown = 10 SECONDS
	special_attack_min_range = 1
	special_attack_max_range = 8
	loot_list = list(/obj/item/gun/energy/flamegun = 100,
		/obj/item/bone/skull = 100
			)


/mob/living/simple_mob/humanoid/eclipse/head/security/updatehealth()
	. = ..()

	if(vore_fullness == 1)
		ranged_cooldown = 8
		projectiletype = /obj/item/projectile/energy/flamecrystal
	else if(vore_fullness == 2)
		ranged_cooldown = 12
		projectiletype = /obj/item/projectile/energy/fireball
	else if (vore_fullness > 2)
		ranged_cooldown = 16
		projectiletype = /obj/item/projectile/energy/fireball
	else
		ranged_cooldown = 5

/mob/living/simple_mob/humanoid/eclipse/head/security/do_special_attack(atom/A)
	if(vore_fullness < 2)
		if(prob(50))
			rapidfire(A)
		else
			tornado_maw(A)
	else if(vore_fullness == 2)
		tornado_maw(A)
	else if(vore_fullness > 2)
		if(prob(50))
			deathtoll(A)
		else
			tornado_maw(A)

/mob/living/simple_mob/humanoid/eclipse/head/security/proc/rapidfire(atom/A)
	var/obj/item/projectile/P = new /obj/item/projectile/energy/flamecrystal(get_turf(src))
	P.launch_projectile(A, BP_TORSO, src)
	sleep(1)
	P.launch_projectile(A, BP_TORSO, src)
	sleep(1)
	P.launch_projectile(A, BP_TORSO, src)
	sleep(1)
	P.launch_projectile(A, BP_TORSO, src)
	sleep(1)
	P.launch_projectile(A, BP_TORSO, src)

/mob/living/simple_mob/humanoid/eclipse/head/security/proc/tornado_maw(atom/A)
	var/turf/T = get_turf(src)

	var/datum/effect/effect/system/grav_pull/s1 = new /datum/effect/effect/system/grav_pull
	s1.set_up(5, 1, T)
	s1.start()

/mob/living/simple_mob/humanoid/eclipse/head/security/proc/deathtoll(atom/A)
	var/list/potential_targets = ai_holder.list_targets()
	for(var/atom/entry in potential_targets)
		if(istype(entry, /mob/living/simple_mob/humanoid/eclipse))
			potential_targets -= entry
	if(potential_targets.len)
		var/iteration = clamp(potential_targets.len, 1, 3)
		for(var/i = 0, i < iteration, i++)
			if(!(potential_targets.len))
				break
			var/mob/target = pick(potential_targets)
			potential_targets -= target
			deathtollfollow(target)

/mob/living/simple_mob/humanoid/eclipse/head/security/proc/deathtollfollow(atom/target)
	var/list/bomb_range = block(locate(target.x-6, target.y-6, target.z), locate(target.x+6, target.y+6, target.z))
	var/obj/item/projectile/P = new /obj/item/projectile/bullet/flamegun(get_turf(src))
	bomb_range -= get_turf(target)
	for(var/i = 0, i < 4, i++)
		var/turf/T = pick(bomb_range)
		P.launch_projectile(target, BP_TORSO, src)
		bomb_range -= T

/obj/item/projectile/energy/flamecrystal
	name = "Flame Crystal"
	icon = 'modular_chomp/icons/mob/eclipse.dmi' //commiting sin
	icon_state = "firecrystal"
	damage = 15
	armor_penetration = 40 //Large pointy crystal
	damage_type = BRUTE
	check_armour = "bullet"
	modifier_type_to_apply = /datum/modifier/fire/weak
	modifier_duration = 0.05 MINUTE
	range = 12
	hud_state = "laser_sniper"

/obj/item/projectile/bullet/flamegun
	use_submunitions = 1
	only_submunitions = 1
	range = 0
	embed_chance = 0
	submunition_spread_max = 800
	submunition_spread_min = 200
	submunitions = list(/obj/item/projectile/energy/flamecrystal = 3)
	hud_state = "laser_heat"

/obj/item/projectile/bullet/flamegun/on_range()
	qdel(src)

/mob/living/simple_mob/humanoid/eclipse/head/scientist
	name = "Eclipse Lead Researcher"
	icon_state = "fleetsci"
	maxHealth = 60
	health = 60
	special_attack_cooldown = 5 SECONDS
	special_attack_min_range = 1
	special_attack_max_range = 10
	projectiletype = /obj/item/projectile/bullet/pistol/ap

	loot_list = list(/obj/item/circuitboard/mecha/hades/targeting = 100,
		/obj/item/circuitboard/mecha/hades/peripherals = 100,
		/obj/item/circuitboard/mecha/hades/main = 100,
		/obj/item/bone/skull = 100
			)

	var/obj/item/shield_projector/shield1 = null
	var/obj/item/shield_projector/shield2 = null
	var/obj/item/shield_projector/shield3 = null

/mob/living/simple_mob/humanoid/eclipse/head/scientist/Initialize(mapload)
	shield1 = new /obj/item/shield_projector/rectangle/automatic/eclipse(src)
	shield2 = new /obj/item/shield_projector/rectangle/automatic/eclipse/medium(src)
	shield3 = new /obj/item/shield_projector/rectangle/automatic/eclipse/big(src)
	return ..()

/obj/item/shield_projector/rectangle/automatic/eclipse
	name = "cult shield stone"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_melted"
	shield_health = 100
	max_shield_health = 100
	shield_regen_delay = 120 SECONDS
	shield_regen_amount = 100
	size_x = 1
	size_y = 1
	color = "#FF6600"
	high_color = "#0099CC"
	low_color = "#660066"

/obj/item/shield_projector/rectangle/automatic/eclipse/medium
	size_x = 2
	size_y = 2

/obj/item/shield_projector/rectangle/automatic/eclipse/big
	size_x = 3
	size_y = 3

/mob/living/simple_mob/mechanical/hivebot/swarm/eclipse
	faction = FACTION_ECLIPSE


/mob/living/simple_mob/humanoid/eclipse/head/captain
	name = "Eclipse Expedition Leader"
	icon_state = "captain"

	loot_list = list(/obj/item/slime_extract/dark = 20,
			/obj/item/prop/alien/junk = 60,
			/obj/random/tool/alien = 60,
			/obj/random/tool/alien = 60,
			/obj/item/cell/device/weapon/recharge/alien = 60,
			/obj/random/tool/alien = 60,
			/obj/item/cell/device/weapon/recharge/alien = 60,
			/obj/item/bluespace_harpoon = 60,
			/obj/item/flame/lighter/supermatter/syndismzippo = 60,
			/obj/item/gun/energy/medigun = 60,
			/obj/item/bone/skull = 100
			)

	var/obj/item/shield_projector/shield1 = null

/mob/living/simple_mob/humanoid/eclipse/head/captain/Initialize(mapload)
	shield1 = new /obj/item/shield_projector/rectangle/automatic/eclipse/big(src)

/mob/living/simple_mob/humanoid/eclipse/head/captain/updatehealth() //This is a mistake
	. = ..()

	if(vore_fullness == 1)
		ranged_cooldown = 4
		projectiletype = /obj/item/projectile/energy/frostsphere
		movement_cooldown = 1
		melee_attack_delay = 1.3
		melee_damage_lower = 20
		melee_damage_upper = 35
		armor = list(melee = 35, bullet = 35, laser = 35, energy = 35, bomb = 100, bio = 100, rad = 100)
		armor_soak = list(melee = 7, bullet = 7, laser = 7, energy = 7, bomb = 0, bio = 0, rad = 0)
		special_attack_cooldown = 15
	else if(vore_fullness == 2)
		ranged_cooldown = 0.5
		projectiletype = /obj/item/projectile/energy/muckblob
		movement_cooldown = 2
		melee_attack_delay = 1.8
		melee_damage_lower = 20
		melee_damage_upper = 40
		armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
		armor_soak = list(melee = 6, bullet = 6, laser = 6, energy = 6, bomb = 0, bio = 0, rad = 0)
		special_attack_cooldown = 20
	else if (vore_fullness > 2)
		ranged_cooldown = 16
		projectiletype = /obj/item/projectile/energy/mob/ionbeam
		movement_cooldown = 3
		melee_attack_delay = 2
		melee_damage_lower = 30
		melee_damage_upper = 40
		armor = list(melee = 60, bullet = 60, laser = 60, energy = 60, bomb = 100, bio = 100, rad = 100)
		armor_soak = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)
		special_attack_cooldown = 30
	else
		ranged_cooldown = 8
		projectiletype = /obj/item/projectile/bullet/flamegun
		movement_cooldown = 0
		melee_attack_delay = 1.1
		melee_damage_lower = 20
		melee_damage_upper = 25
		armor = list(melee = 20, bullet = 20, laser = 20, energy = 20, bomb = 100, bio = 100, rad = 100)
		armor_soak = list(melee = 7, bullet = 7, laser = 7, energy = 7, bomb = 0, bio = 0, rad = 0)
		special_attack_cooldown = 10


/mob/living/simple_mob/humanoid/eclipse/head/captain/do_special_attack(atom/A) //note to self, try to make fullness alts for this attacks
	if(prob(20))
		invokesec(A)
	else if(prob(20))
		invokesci(A)
	else if(prob(20))
		invokeengi(A)
	else if(prob(20))
		invokemedical(A)
	else
		invokecargo(A)


/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/invokesec(atom/A)
	var/list/potential_targets = ai_holder.list_targets()
	for(var/atom/entry in potential_targets)
		if(istype(entry, /mob/living/simple_mob/humanoid/eclipse))
			potential_targets -= entry
	if(potential_targets.len)
		var/iteration = clamp(potential_targets.len, 1, 3)
		for(var/i = 0, i < iteration, i++)
			if(!(potential_targets.len))
				break
			var/mob/target = pick(potential_targets)
			potential_targets -= target
			secattack(target)

/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/secattack(atom/target)
	var/list/bomb_range = block(locate(target.x-4, target.y-4, target.z), locate(target.x+4, target.y+4, target.z))
	var/obj/item/projectile/P = new /obj/item/projectile/energy/flamecrystal(get_turf(src))
	bomb_range -= get_turf(target)
	for(var/i = 0, i < 4, i++)
		var/turf/T = pick(bomb_range)
		P.launch_projectile(target, BP_TORSO, src)
		bomb_range -= T

/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/invokecargo(atom/A)
	visible_message(span_warning("\The [src] calls for their help on radio!"))

/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/invokeengi(atom/A) //place holdery
	var/obj/item/projectile/P = new /obj/item/projectile/temp(get_turf(src))
	P.launch_projectile(A, BP_TORSO, src)
	var/obj/item/projectile/P2 = new /obj/item/projectile/temp/hot(get_turf(src))
	P2.launch_projectile(A, BP_TORSO, src)

/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/invokesci(atom/A)
	visible_message(span_warning("\The [src] begins to fabricate drones!"))
	sleep(3)
	new /mob/living/simple_mob/mechanical/hivebot/swarm/eclipse (src.loc)
	new /mob/living/simple_mob/mechanical/hivebot/swarm/eclipse (src.loc)
	new /mob/living/simple_mob/mechanical/hivebot/swarm/eclipse (src.loc)

/mob/living/simple_mob/humanoid/eclipse/head/captain/proc/invokemedical(atom/A)
	visible_message(span_warning("\The [src] begins to tend to their wounds!"))
	sleep(3)
	adjustBruteLoss(-12)
	adjustFireLoss(-12)
	adjustToxLoss(-12)
	adjustOxyLoss(-12)
	adjustCloneLoss(-12)


/mob/living/simple_mob/humanoid/eclipse/head/shade
	name = "???"
	icon_state = "shade"
	health = 300
	maxHealth = 300 //18 20 damage shots

	armor = list(melee = 20, bullet = 20, laser = 20, energy = 20, bomb = 100, bio = 100, rad = 100)

	projectiletype = /obj/item/projectile/bullet/lightingburst

	special_attack_cooldown = 10 SECONDS
	special_attack_min_range = 0
	special_attack_max_range = 7

	loot_list = list(/obj/item/gun/energy/pulseglove = 100
			)


/mob/living/simple_mob/humanoid/eclipse/head/shade/do_special_attack(atom/A)
	var/list/potential_targets = ai_holder.list_targets()
	for(var/atom/entry in potential_targets)
		if(istype(entry, /mob/living/simple_mob/humanoid/eclipse))
			potential_targets -= entry
	if(potential_targets.len)
		var/iteration = clamp(potential_targets.len, 1, 5)
		for(var/i = 0, i < iteration, i++)
			if(!(potential_targets.len))
				break
			var/mob/target = pick(potential_targets)
			potential_targets -= target
			bullethell(target)

/mob/living/simple_mob/humanoid/eclipse/head/shade/proc/bullethell(atom/target)
	var/list/bomb_range = block(locate(target.x-6, target.y-6, target.z), locate(target.x+6, target.y+6, target.z))
	var/obj/item/projectile/P = new /obj/item/projectile/bullet/meteorstorm(get_turf(src))
	bomb_range -= get_turf(target)
	for(var/i = 0, i < 4, i++)
		var/turf/T = pick(bomb_range)
		P.launch_projectile(target, BP_TORSO, src)
		bomb_range -= T

/mob/living/simple_mob/mechanical/combat_drone/artillery
	faction = FACTION_ECLIPSE
	projectiletype = /obj/item/projectile/arc/blue_energy

/mob/living/simple_mob/humanoid/eclipse/head/tyrlead
	name = "Eclipse Precursor Overseer"
	icon_state = "overseer_shield"
	special_attack_cooldown = 4 SECONDS
	special_attack_min_range = 1
	special_attack_max_range = 8
	projectiletype = /obj/item/projectile/energy/homing_bolt
	ai_holder_type = /datum/ai_holder/simple_mob/intentional/adv_dark_gygax
	var/fullshield = 4
	var/shieldrage = 4

/mob/living/simple_mob/humanoid/eclipse/head/tyrlead/bullet_act(obj/item/projectile/P) //Projectiles will be absorbed by the shield. Note to self do funky sprite. 4 hits to remove
	if(fullshield > 0)
		fullshield--
		if(P == /obj/item/projectile/ion)
			fullshield = 0
			visible_message(span_boldwarning(span_orange("[P] breaks the shield!!.")))
			icon_state = "overseer"
		if(fullshield > 0)
			visible_message(span_boldwarning(span_orange("[P] is absorbed by the shield!.")))
		else
			visible_message(span_boldwarning(span_orange("[P] breaks the shield!!.")))
			icon_state = "overseer"
	else
		..()
		shieldrage--
		if(shieldrage == 0)
			shieldrage = 4
			fullshield = 4
			visible_message(span_boldwarning(span_orange("The shield reactivates!!.")))
			icon_state = "overseer_shield"

/mob/living/simple_mob/humanoid/eclipse/head/tyrlead/do_special_attack(atom/A)
	var/deathdir = rand(1,3)
	switch(deathdir)
		if(1)
			teleport(A)
		if(2)
			bomb_chaos(A)
		if(3)
			bomb_lines(A)

/mob/living/simple_mob/humanoid/eclipse/head/engineer //teshari
	name = "Eclipse Chief Engineer"
	health = 50
	maxHealth = 50
	melee_damage_lower = 60 //Durasteel fireaxe
	melee_damage_upper = 60
	projectiletype = null

/mob/living/simple_mob/humanoid/eclipse/head/engineer/Initialize()
	add_modifier(/datum/modifier/technomancer/haste, null, src) // tesh goes nyooooom
	return ..()

/mob/living/simple_mob/humanoid/eclipse/head/medical //noodl
	name = "Eclipse Chief Medical Officer"
	health = 150
	maxHealth = 150
	special_attack_cooldown = 5 SECONDS
	special_attack_min_range = 0
	special_attack_max_range = 7
	melee_damage_lower = 15 //Durasteel fireaxe
	melee_damage_upper = 15
	attack_armor_pen = 60
	projectiletype = null
	var/cloaked_alpha = 45			// Lower = Harder to see.
	var/cloak_cooldown = 5 SECONDS	// Amount of time needed to re-cloak after losing it.
	var/last_uncloak = 0			// world.time
	var/poison_type = REAGENT_ID_STOXIN
	var/poison_per_bite = 8
	var/poison_chance = 80

/mob/living/simple_mob/humanoid/eclipse/head/medical/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.reagents)
			var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
			if(L.can_inject(src, null, target_zone))
				inject_poison(L, target_zone)

/mob/living/simple_mob/humanoid/eclipse/head/medical/proc/inject_poison(mob/living/L, target_zone)
	if(prob(poison_chance))
		to_chat(L, span_warning("You feel a tiny prick."))
		L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_mob/humanoid/eclipse/head/medical/cloak()
	if(cloaked)
		return
	animate(src, alpha = cloaked_alpha, time = 1 SECOND)
	cloaked = TRUE


/mob/living/simple_mob/humanoid/eclipse/head/medical/uncloak()
	last_uncloak = world.time // This is assigned even if it isn't cloaked already, to 'reset' the timer if the spider is continously getting attacked.
	if(!cloaked)
		return
	animate(src, alpha = initial(alpha), time = 1 SECOND)
	cloaked = FALSE

// Check if cloaking if possible.
/mob/living/simple_mob/humanoid/eclipse/head/medical/proc/can_cloak()
	if(stat)
		return FALSE
	if(last_uncloak + cloak_cooldown > world.time)
		return FALSE

	return TRUE

// Called by things that break cloaks, like Technomancer wards.
/mob/living/simple_mob/humanoid/eclipse/head/medical/break_cloak()
	uncloak()


/mob/living/simple_mob/humanoid/eclipse/head/medical/is_cloaked()
	return cloaked


// Cloaks the spider automatically, if possible.
/mob/living/simple_mob/humanoid/eclipse/head/medical/handle_special()
	if(!cloaked && can_cloak())
		cloak()


//special attack things
/mob/living/simple_mob/humanoid/eclipse/head/scientist/do_special_attack(atom/A)
	addtimer(CALLBACK(src, PROC_REF(summon_drones), A, 3, 0.5 SECONDS), 0.5 SECONDS, TIMER_DELETE_ME)

/mob/living/simple_mob/humanoid/eclipse/proc/summon_drones(atom/target, var/amount, var/fire_delay)
	if(!target)
		return
	var/deathdir = rand(1,3)
	switch(deathdir)
		if(1)
			new /mob/living/simple_mob/mechanical/mining_drone/scavenger/eclipse (src.loc)
		if(2)
			new /mob/living/simple_mob/mechanical/hivebot/swarm/eclipse (src.loc)
		if(3)
			new /mob/living/simple_mob/mechanical/combat_drone/artillery
	amount--
	if(amount > 0)
		addtimer(CALLBACK(src, PROC_REF(summon_drones), target, amount, fire_delay), fire_delay, TIMER_DELETE_ME)


/mob/living/simple_mob/humanoid/eclipse/head/medical/do_special_attack(atom/A)
	if(!cloaked)
		teleport(A)

/mob/living/simple_mob/humanoid/eclipse/proc/teleport(atom/A)
	// Teleport attack.
	if(!A)
		to_chat(src, span_warning("There's nothing to teleport to."))
		return FALSE

	var/list/nearby_things = range(4, A)
	var/list/valid_turfs = list()

	// All this work to just go to a non-dense tile.
	for(var/turf/potential_turf in nearby_things)
		var/valid_turf = TRUE
		if(potential_turf.density)
			continue
		for(var/atom/movable/AM in potential_turf)
			if(AM.density)
				valid_turf = FALSE
		if(valid_turf)
			valid_turfs.Add(potential_turf)

	if(!(valid_turfs.len))
		to_chat(src, span_warning("There wasn't an unoccupied spot to teleport to."))
		return FALSE

	var/turf/target_turf = pick(valid_turfs)
	var/turf/T = get_turf(src)

	var/datum/effect/effect/system/spark_spread/s1 = new /datum/effect/effect/system/spark_spread
	s1.set_up(5, 1, T)
	var/datum/effect/effect/system/spark_spread/s2 = new /datum/effect/effect/system/spark_spread
	s2.set_up(5, 1, target_turf)


	T.visible_message(span_warning("\The [src] vanishes!"))
	s1.start()

	forceMove(target_turf)
	playsound(target_turf, 'sound/effects/phasein.ogg', 50, 1)
	to_chat(src, span_notice("You teleport to \the [target_turf]."))

	target_turf.visible_message(span_warning("\The [src] appears!"))
	s2.start()

/mob/living/simple_mob/humanoid/eclipse/head/cargomaster //Naga
	name = "Eclipse Cargo Master"


/mob/living/simple_mob/humanoid/eclipse/proc/bomb_lines(atom/A)
	if(!A)
		return
	var/list/potential_targets = ai_holder.list_targets()
	for(var/atom/entry in potential_targets)
		if(istype(entry, /mob/living/simple_mob/humanoid/eclipse))
			potential_targets -= entry
	if(potential_targets.len)
		var/iteration = clamp(potential_targets.len, 1, 3)
		for(var/i = 0, i < iteration, i++)
			if(!(potential_targets.len))
				break
			var/mob/target = pick(potential_targets)
			potential_targets -= target
			spawn_lines(target)


/mob/living/simple_mob/humanoid/eclipse/proc/spawn_lines(atom/target)
	var/alignment = rand(1,2)	// 1 for vertical, 2 for horizontal
	var/list/line_range = list()
	var/turf/T = get_turf(target)
	line_range += T
	for(var/i = 1, i <= 7, i++)
		switch(alignment)
			if(1)
				if(T.x-i > 0)
					line_range += locate(T.x-i, T.y-i, T.z)
				if(T.x+i <= world.maxx)
					line_range += locate(T.x+i, T.y+i, T.z)
				if(T.y-i > 0)
					line_range += locate(T.x+i, T.y-i, T.z)
				if(T.y+i <= world.maxy)
					line_range += locate(T.x-i, T.y+i, T.z)
			if(2)
				if(T.x-i > 0)
					line_range += locate(T.x-i, T.y, T.z)
				if(T.x+i <= world.maxx)
					line_range += locate(T.x+i, T.y, T.z)
				if(T.y-i > 0)
					line_range += locate(T.x, T.y-i, T.z)
				if(T.y+i <= world.maxy)
					line_range += locate(T.x, T.y+i, T.z)
	for(var/turf/dropspot in line_range)
		new /obj/effect/artillery_attack(dropspot)


/mob/living/simple_mob/humanoid/eclipse/proc/bomb_chaos(atom/A)
	if(!A)
		return
	var/list/potential_targets = ai_holder.list_targets()
	for(var/atom/entry in potential_targets)
		if(istype(entry, /mob/living/simple_mob/humanoid/eclipse))
			potential_targets -= entry
	if(potential_targets.len)
		var/iteration = clamp(potential_targets.len, 1, 3)
		for(var/i = 0, i < iteration, i++)
			if(!(potential_targets.len))
				break
			var/mob/target = pick(potential_targets)
			potential_targets -= target
			chaos_lines(target)


/mob/living/simple_mob/humanoid/eclipse/proc/chaos_lines(atom/target)
	var/alignment = rand(1,2)
	var/list/line_range = list()
	var/turf/T = get_turf(target)
	line_range += T
	for(var/i = 1, i <= 7, i++)
		switch(alignment)
			if(1)
				if(T.x-i > 0)
					var/zed = rand(1,3)
					line_range += locate(T.x+zed, T.y-i, T.z)
				if(T.x+i <= world.maxx)
					var/zed = rand(1,3)
					line_range += locate(T.x+zed, T.y+i, T.z)
				if(T.y-i > 0)
					var/zed = rand(1,3)
					line_range += locate(T.x+i, T.y+zed, T.z)
				if(T.y+i <= world.maxy)
					var/zed = rand(1,3)
					line_range += locate(T.x-i, T.y+zed, T.z)
			if(2)
				if(T.x-i > 0)
					var/zed = rand(1,3)
					line_range += locate(T.x-i, T.y-zed, T.z)
				if(T.x+i <= world.maxx)
					var/zed = rand(1,3)
					line_range += locate(T.x+i, T.y-zed, T.z)
				if(T.y-i > 0)
					var/zed = rand(1,3)
					line_range += locate(T.x-zed, T.y-i, T.z)
				if(T.y+i <= world.maxy)
					var/zed = rand(1,3)
					line_range += locate(T.x-zed, T.y+i, T.z)
	for(var/turf/dropspot in line_range)
		new /obj/effect/artillery_attack(dropspot)


/obj/effect/artillery_attack
	anchored = TRUE
	density = FALSE
	unacidable = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "drop_marker"

/obj/effect/artillery_attack/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/artillery_attack/LateInitialize()
	var/delay = rand(25, 30)
	addtimer(CALLBACK(src, PROC_REF(spawner)), delay, TIMER_DELETE_ME)

/obj/effect/artillery_attack/proc/spawner()
	new /obj/effect/falling_effect/callstrike_bomb(src.loc)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 0.7 SECONDS, TIMER_DELETE_ME)

/obj/effect/falling_effect/callstrike_bomb
	falling_type = /obj/effect/callstrike
	crushing = FALSE

/obj/effect/callstrike
	anchored = TRUE
	density = FALSE
	mouse_opacity = 0
	icon ='modular_chomp/icons/obj/guns/precursor/tyr.dmi'

/obj/effect/callstrike/Initialize(mapload)
	.=..()
	icon_state = "arti"

/obj/effect/callstrike/end_fall(var/crushing = FALSE)
	for(var/mob/living/L in loc)
		var/target_zone = ran_zone()
		var/blocked = L.run_armor_check(target_zone, "laser")
		var/soaked = L.get_armor_soak(target_zone, "laser")

		if(!L.apply_damage(70, BURN, target_zone, blocked, soaked))
			break
	playsound(src, 'sound/effects/clang2.ogg', 50, 1)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 0.25 SECONDS, TIMER_DELETE_ME)
