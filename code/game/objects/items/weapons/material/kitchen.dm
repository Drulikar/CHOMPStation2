/obj/item/material/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/material/kitchen/utensil
	drop_sound = 'sound/items/drop/knife.ogg'
	pickup_sound = 'sound/items/pickup/knife.ogg'
	w_class = ITEMSIZE_TINY
	thrown_force_divisor = 1
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("attacked", "stabbed", "poked")
	sharp = TRUE
	edge = TRUE
	force_divisor = 0.1 // 6 when wielded with hardness 60 (steel)
	thrown_force_divisor = 0.25 // 5 when thrown with weight 20 (steel)
	var/scoop_volume = 5
	var/loaded // Name for currently loaded food object.
	var/loaded_color // Color for currently loaded food object.

	var/list/food_inserted_micros

/obj/item/material/kitchen/utensil/Initialize(mapload)
	. = ..()
	if (prob(60))
		src.pixel_y = rand(0, 4)
	create_reagents(scoop_volume)

/obj/item/material/kitchen/utensil/Destroy()
	if(food_inserted_micros)
		for(var/mob/M in food_inserted_micros)
			M.dropInto(loc)
			food_inserted_micros -= M
	. = ..()

	return

/obj/item/material/kitchen/utensil/update_icon()
	. = ..()
	cut_overlays()
	if(loaded)
		var/image/I = new(icon, "loadedfood")
		I.color = loaded_color
		add_overlay(I)

/obj/item/material/kitchen/utensil/proc/load_food(var/mob/user, var/obj/item/reagent_containers/food/snacks/loading)
	if (reagents.total_volume > 0)
		to_chat(user, span_danger("There is already something on \the [src]."))
		return
	if (!loading?.reagents?.total_volume)
		to_chat(user, span_notice("Nothing to scoop up in \the [loading]!"))


	loaded = "\the [loading]"
	user.visible_message( \
		span_infoplain(span_bold("\The [user]") + " scoops up some of [loaded] with \the [src]!"),
		span_notice("You scoop up some of [loaded] with \the [src]!")
	)
	loading.bitecount++
	loading.reagents.trans_to_obj(src, min(loading.reagents.total_volume, scoop_volume))
	loaded_color = loading.filling_color

	if(loading.food_inserted_micros && loading.food_inserted_micros.len)
		if(!food_inserted_micros)
			food_inserted_micros = list()

		for(var/mob/living/F in loading.food_inserted_micros)
			var/do_transfer = FALSE

			if(!loading.reagents.total_volume)
				do_transfer = TRUE
			else
				var/transfer_chance = (loading.bitecount/(loading.bitecount + (loading.bitesize / loading.reagents.total_volume) + 1))*100
				if(prob(transfer_chance))
					do_transfer = TRUE

			if(do_transfer)
				F.forceMove(src)
				loading.food_inserted_micros -= F
				src.food_inserted_micros += F

	if (loading.reagents.total_volume <= 0)
		qdel(loading)
	update_icon()

/obj/item/material/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != I_HELP)
		if(user.zone_sel.selecting == BP_HEAD || user.zone_sel.selecting == O_EYES)
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if (loaded && reagents.total_volume > 0)
		reagents.trans_to_mob(M, reagents.total_volume, CHEM_INGEST)
		if(food_inserted_micros && food_inserted_micros.len)
			for(var/mob/living/F in food_inserted_micros)
				food_inserted_micros -= F
				if(!F.can_be_drop_prey || !F.food_vore)
					F.forceMove(get_turf(src))
				else
					F.forceMove(M.vore_selected)
		if(M == user)
			if(!M.can_eat(loaded))
				return
			M.visible_message(span_bold("\The [user]") + " eats some of [loaded] with \the [src].")
		else
			user.visible_message(span_warning("\The [user] begins to feed \the [M]!"))
			if(!(M.can_force_feed(user, loaded) && do_mob(user, M, 5 SECONDS)))
				return
			M.visible_message(span_bold("\The [user]") + " feeds some of [loaded] to \the [M] with \the [src].")
		playsound(src,'sound/items/eatfood.ogg', rand(10,40), 1)
		loaded = null
		update_icon()
		return
	else
		to_chat(user, span_warning("You don't have anything on \the [src]."))	//if we have help intent and no food scooped up DON'T STAB OURSELVES WITH THE FORK
		return

/obj/item/material/kitchen/utensil/on_rag_wipe()
	. = ..()
	if(reagents.total_volume > 0)
		reagents.clear_reagents()
		cut_overlays()
	return

/obj/item/material/kitchen/utensil/container_resist(mob/living/M)
	if(food_inserted_micros)
		food_inserted_micros -= M
	M.forceMove(get_turf(src))
	to_chat(M, span_warning("You climb off of \the [src]."))

/obj/item/material/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"
	sharp = TRUE
	edge = FALSE

/obj/item/material/kitchen/utensil/fork/plastic
	default_material = MAT_PLASTIC

/obj/item/material/kitchen/utensil/foon
	name = "foon"
	desc = "It's a foon. The forgotten cousin of the spork."
	icon_state = "foon"
	sharp = TRUE
	edge = FALSE

/obj/item/material/kitchen/utensil/foon/plastic
	default_material = MAT_PLASTIC

/obj/item/material/kitchen/utensil/spork
	name = "spork"
	desc = "It's a spork. The (un)holy merger of a spoon and fork."
	icon_state = "spork"
	sharp = TRUE
	edge = FALSE

/obj/item/material/kitchen/utensil/spork/plastic
	default_material = MAT_PLASTIC

/obj/item/material/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")
	edge = FALSE
	sharp = FALSE
	force_divisor = 0.1 //2 when wielded with weight 20 (steel)

/obj/item/material/kitchen/utensil/spoon/plastic
	default_material = MAT_PLASTIC

/*
 * Knives
 */

/* From the time of Clowns. Commented out for posterity, and sanity.
/obj/item/material/knife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with \the [src]."))
		user.take_organ_damage(20)
		return
	return ..()
*/
/obj/item/material/knife/plastic
	default_material = MAT_PLASTIC

/*
 * Rolling Pins
 */

/obj/item/material/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the " + JOB_BARTENDER+ "."
	icon_state = "rolling_pin"
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	default_material = MAT_WOOD
	force_divisor = 0.7 // 10 when wielded with weight 15 (wood)
	dulled_divisor = 0.75	// Still a club
	thrown_force_divisor = 1 // as above
	drop_sound = 'sound/items/drop/wooden.ogg'
	pickup_sound = 'sound/items/pickup/wooden.ogg'

/obj/item/material/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, span_warning("\The [src] slips out of your hand and hits your head."))
		user.take_organ_damage(10)
		user.Paralyse(2)
		return
	return ..()
