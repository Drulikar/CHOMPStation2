/obj/machinery/vr_sleeper
	name = "virtual reality sleeper"
	desc = "A fancy bed with built-in sensory I/O ports and connectors to interface users' minds with their bodies in virtual reality."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scanner_0"

	var/base_state = "body_scanner_"

	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/vr_sleeper
	var/mob/living/carbon/human/occupant = null
	var/mob/living/carbon/human/avatar = null
	var/datum/mind/vr_mind = null
	var/datum/effect/effect/system/smoke_spread/bad/smoke

	var/eject_dead = TRUE

	var/mirror_first_occupant = TRUE	// Do we force the newly produced body to look like the occupant?

	use_power = USE_POWER_IDLE
	idle_power_usage = 15
	active_power_usage = 200
	light_color = "#FF0000"
	//var/global/list/vr_mob_tf_options // Global var located in global_list_ch.dm

/obj/machinery/vr_sleeper/Initialize(mapload)
	. = ..()
	default_apply_parts()
	smoke = new
	update_icon()

/obj/machinery/vr_sleeper/Destroy()
	. = ..()
	go_out()

/obj/machinery/vr_sleeper/process()
	if(stat & (NOPOWER|BROKEN))
		if(occupant)
			go_out()
			visible_message(span_infoplain(span_bold("\The [src]") + " emits a low droning sound, before the pod door clicks open."))
		return
	else if(eject_dead && occupant && occupant.stat == DEAD) // If someone dies somehow while inside, spit them out.
		visible_message(span_warning("\The [src] sounds an alarm, swinging its hatch open."))
		go_out()

/obj/machinery/vr_sleeper/update_icon()
	icon_state = "[base_state][occupant ? "1" : "0"]"

// CHOMPedit
/obj/machinery/vr_sleeper/examine(mob/user)
	. = ..()
	if(occupant)
		. += span_notice("[occupant] is inside.")

/obj/machinery/vr_sleeper/Topic(href, href_list)
	if(..())
		return 1

	if(usr == occupant)
		to_chat(usr, span_warning("You can't reach the controls from the inside."))
		return

	add_fingerprint(usr)

	if(href_list["eject"])
		go_out()

	return 1

/obj/machinery/vr_sleeper/attackby(var/obj/item/I, var/mob/user)
	add_fingerprint(user)

	if(occupant && (istype(I, /obj/item/healthanalyzer) || istype(I, /obj/item/robotanalyzer)))
		I.attack(occupant, user)
		return

	if(default_deconstruction_screwdriver(user, I))
		return
	else if(default_deconstruction_crowbar(user, I))
		if(occupant && avatar)
			avatar.exit_vr()
			avatar = null
			go_out()
		return


/obj/machinery/vr_sleeper/MouseDrop_T(var/mob/target, var/mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !isliving(target))
		return
	go_in(target, user)



/obj/machinery/vr_sleeper/relaymove(var/mob/user)
	..()
	if(user.incapacitated())
		return
	go_out()



/obj/machinery/vr_sleeper/emp_act(var/severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(occupant)
		// This will eject the user from VR
		// ### Fry the brain? Yes. Maybe.
		if(prob(15 / ( severity / 4 )) && occupant.species.has_organ[O_BRAIN] && occupant.internal_organs_by_name[O_BRAIN])
			var/obj/item/organ/O = occupant.internal_organs_by_name[O_BRAIN]
			O.take_damage(severity * 2)
			visible_message(span_danger("\The [src]'s internal lighting flashes rapidly, before the hatch swings open with a cloud of smoke."))
			smoke.set_up(severity, 0, src)
			smoke.start("#202020")
		go_out()

	..(severity)

/obj/machinery/vr_sleeper/verb/eject()
	set src in view(1)
	set category = "Object"
	set name = "Eject VR Capsule"

	if(usr.incapacitated())
		return

	var/forced = FALSE

	if(stat & (BROKEN|NOPOWER) || occupant && occupant.stat == DEAD)
		forced = TRUE

	go_out(forced)
	add_fingerprint(usr)

/obj/machinery/vr_sleeper/verb/climb_in()
	set src in oview(1)
	set category = "Object"
	set name = "Enter VR Capsule"

	if(usr.incapacitated())
		return
	go_in(usr, usr)
	add_fingerprint(usr)

/obj/machinery/vr_sleeper/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/vr_sleeper/proc/go_in(var/mob/M, var/mob/user)
	if(!M)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(!ishuman(M))
		to_chat(user, span_warning("\The [src] rejects [M] with a sharp beep."))
		return
	if(occupant)
		to_chat(user, span_warning("\The [src] is already occupied."))
		return

	if(M == user)
		visible_message("\The [user] starts climbing into \the [src].")
	else
		visible_message("\The [user] starts putting [M] into \the [src].")

	if(do_after(user, 20))
		if(occupant)
			to_chat(user, span_warning("\The [src] is already occupied."))
			return
		M.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		//update_use_power(USE_POWER_ACTIVE)
		occupant = M

		update_icon()

		//VOREstation edit - crashes borers
		if(!M.has_brain_worms())
			update_use_power(USE_POWER_ACTIVE)
			enter_vr()
		else
			to_chat(user, span_warning("\The [src] rejects [M] with a sharp beep."))
		//VOREstation edit end
	return

/obj/machinery/vr_sleeper/proc/go_out(var/forced = TRUE)
	if(!occupant)
		return

	if(!forced && avatar && tgui_alert(avatar, "Someone wants to remove you from virtual reality. Do you want to leave?", "Leave VR?", list("Yes", "No")) != "Yes")
		return

	if(avatar)
		avatar.exit_vr()
	avatar = null

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = src.loc
	occupant = null
	for(var/atom/movable/A in src) // In case an object was dropped inside or something
		if(A == circuit)
			continue
		if(A in component_parts)
			continue
		A.loc = src.loc
	update_use_power(USE_POWER_IDLE)
	update_icon()

/obj/machinery/vr_sleeper/proc/enter_vr()

	// No mob to transfer a mind from
	if(!occupant)
		return

	// No mind to transfer
	if(!occupant.mind)
		return

	// Mob doesn't have an active consciousness to send/receive from
	if(occupant.stat == DEAD)
		return

	avatar = occupant.vr_link
	// If they've already enterred VR, and are reconnecting, prompt if they want a new body
	if(avatar && tgui_alert(occupant, "You already have a [avatar.stat == DEAD ? "" : "deceased "]Virtual Reality avatar. Would you like to use it?", "New avatar", list("Yes", "No")) != "Yes")
		// Delink the mob
		occupant.vr_link = null
		avatar = null

	if(!avatar)
		// Get the desired spawn location to put the body
		var/S = null
		var/list/vr_landmarks = list()
		for(var/obj/effect/landmark/virtual_reality/sloc in landmarks_list)
			vr_landmarks += sloc.name

		S = tgui_input_list(occupant, "Please select a location to spawn your avatar at:", "Spawn location", vr_landmarks)
		if(!S)
			return 0

		//CHOMPedit: mob TF masquerading as mob spawning because that's somehow less spaghetti
		var/tf = null
		if(tgui_alert(occupant, "Would you like to play as a different creature?", "Join as a mob?", list("Yes", "No")) == "Yes")
			var/k = tgui_input_list(occupant, "Please select a creature:", "Mob list", vr_mob_tf_options)
			if(!k)
				return 0
			tf = vr_mob_tf_options[k]

		for(var/obj/effect/landmark/virtual_reality/i in landmarks_list)
			if(i.name == S)
				S = i
				break

		avatar = new(S, "Virtual Reality Avatar")
		//CHOMPedit start: rewriting this to spawn a copy of the user and allow mob TF.
		// I know this is a modular file now but perhaps keeping old comments will help with documentation.
		if(mirror_first_occupant && occupant.client && occupant.client.prefs)
			occupant.client.prefs.copy_to(avatar)

		avatar.forceMove(get_turf(S))			// Put the mob on the landmark, instead of inside it
		occupant.enter_vr(avatar)
		avatar.regenerate_icons()
		avatar.update_transform()
		job_master.EquipRank(avatar,"Visitor", 1, FALSE)
		add_verb(avatar,/mob/living/carbon/human/proc/exit_vr)  //CHOMPEdit
		add_verb(avatar,/mob/living/carbon/human/proc/vr_transform_into_mob)  //CHOMPEdit
		add_verb(avatar,/mob/living/proc/set_size) //CHOMPEdit TGPanel // Introducing NeosVR
		avatar.virtual_reality_mob = TRUE

		// Prompt for username after they've enterred the body.
		var/newname = sanitize(tgui_input_text(avatar, "You are entering virtual reality. Your username is currently [src.name]. Would you like to change it to something else?", "Name change", null, MAX_NAME_LEN), MAX_NAME_LEN)
		if(newname)
			avatar.real_name = newname
			avatar.name = newname

		if(tf)
			var/mob/living/new_form = avatar.transform_into_mob(tf, TRUE) // No need to check prefs when the occupant already chose to transform.
			if(isliving(new_form)) // Make sure the mob spawned properly.
				add_verb(new_form,/mob/living/proc/vr_revert_mob_tf)  //CHOMPEdit
				new_form.virtual_reality_mob = TRUE

	else
		// If TFed, revert TF. Easier than coding mind transfer stuff for edge cases.
		if(avatar.tfed_into_mob_check())
			var/mob/living/M = loc
			if(istype(M)) // Sanity check, though shouldn't be needed since this is already checked by the proc.
				M.revert_mob_tf()
		occupant.enter_vr(avatar)

// I am not making a new file just for vr-specific mob procs.
/mob/living/carbon/human/proc/vr_transform_into_mob()
	set name = "Transform Into Creature"
	set category = "Abilities.VR"
	set desc = "Become a different creature"

	var/tf = null
	var/k = tgui_input_list(usr, "Please select a creature:", "Mob list", vr_mob_tf_options)
	if(!k)
		return 0
	tf = vr_mob_tf_options[k]

	var/mob/living/new_form = transform_into_mob(tf, TRUE, TRUE)
	if(isliving(new_form)) // Sanity check
		add_verb(new_form,/mob/living/proc/vr_revert_mob_tf)  //CHOMPEdit
		new_form.virtual_reality_mob = TRUE

/mob/living/proc/vr_revert_mob_tf()
	set name = "Revert Transformation"
	set category = "Abilities.VR"

	revert_mob_tf()

// Exiting VR but for ghosts
/mob/living/carbon/human/proc/fake_exit_vr()
	set name = "Log Out Of Virtual Reality"
	set category = "Abilities.VR"

	if(tgui_alert(usr, "Would you like to log out of virtual reality?", "Log out?", list("Yes", "No")) == "Yes")
		release_vore_contents(TRUE)
		for(var/obj/item/I in src)
			drop_from_inventory(I)
		qdel(src)
//CHOMPedit end
