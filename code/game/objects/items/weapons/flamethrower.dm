/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_icons = list(
			slot_l_hand_str = 'icons/mob/items/lefthand_guns.dmi',
			slot_r_hand_str = 'icons/mob/items/righthand_guns.dmi',
			)
	item_state = "flamethrower_0"
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEMSIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 1, TECH_PHORON = 1)
	matter = list(MAT_STEEL = 500)
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/phoron/ptank = null


/obj/item/flamethrower/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(igniter)
	QDEL_NULL(ptank)
	. = ..()

/obj/item/flamethrower/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/living/M = location
		if(M.item_is_in_hands(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return


/obj/item/flamethrower/update_icon()
	cut_overlays()
	if(igniter)
		add_overlay("+igniter[status]")
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	// Make sure our user is still holding us
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	if(W.has_tool_quality(TOOL_WRENCH) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	if(W.has_tool_quality(TOOL_SCREWDRIVER) && igniter && !lit)
		status = !status
		to_chat(user, span_notice("[igniter] is now [status ? "secured" : "unsecured"]!"))
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		user.drop_item()
		I.loc = src
		igniter = I
		update_icon()
		return

	if(istype(W,/obj/item/tank/phoron))
		if(ptank)
			to_chat(user, span_notice("There appears to already be a phoron tank loaded in [src]!"))
			return
		user.drop_item()
		ptank = W
		W.loc = src
		update_icon()
		return

	..()
	return


/obj/item/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		to_chat(user, span_notice("Attach a phoron tank first!"))
		return
	var/dat = text("<htmk><TT><B>Flamethrower (<A href='byond://?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A href='byond://?src=\ref[src];amount=-100'>-</A> <A href='byond://?src=\ref[src];amount=-10'>-</A> <A href='byond://?src=\ref[src];amount=-1'>-</A> [throw_amount] <A href='byond://?src=\ref[src];amount=1'>+</A> <A href='byond://?src=\ref[src];amount=10'>+</A> <A href='byond://?src=\ref[src];amount=100'>+</A><BR>\n<A href='byond://?src=\ref[src];remove=1'>Remove phorontank</A> - <A href='byond://?src=\ref[src];close=1'>Close</A></TT></html>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


/obj/item/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.gas[GAS_PHORON] < 1)	return
		if(!status)	return
		lit = !lit
		if(lit)
			START_PROCESSING(SSobj, src)
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(5000, throw_amount))
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	return


//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)	return
	operating = 1
	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && LinkBlocked(previousturf, T))
			break
		ignite_turf(T)
		sleep(1)
	previousturf = null
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/flamethrower/proc/ignite_turf(turf/target)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(0.02*(throw_amount/100))
	//air_transfer.toxins = air_transfer.toxins * 5 // This is me not comprehending the air system. I realize this is mischievious and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	new/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(target,air_transfer.gas[GAS_PHORON],get_dir(loc,target))
	air_transfer.gas[GAS_PHORON] = 0
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	//target.hotspot_expose(part4.air_contents.temperature*2,300)
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)
	return

/obj/item/flamethrower/full/New(var/loc)
	..()
	weldtool = new /obj/item/weldingtool(src)
	weldtool.status = 0
	igniter = new /obj/item/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()
	return
