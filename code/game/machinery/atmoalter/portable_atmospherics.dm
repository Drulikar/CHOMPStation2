/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = USE_POWER_OFF
	layer = OBJ_LAYER // These are mobile, best not be under everything.
	var/datum/gas_mixture/air_contents

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/start_pressure = ONE_ATMOSPHERE
	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/Initialize(mapload)
	..()
	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/portable_atmospherics/LateInitialize()
	var/obj/machinery/atmospherics/portables_connector/port = locate() in loc
	if(port)
		connect(port)
		update_icon()

/obj/machinery/portable_atmospherics/Destroy()
	QDEL_NULL(air_contents)
	QDEL_NULL(holding)
	return ..()

/obj/machinery/portable_atmospherics/process()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/blob_act()
	qdel(src)

/obj/machinery/portable_atmospherics/proc/StandardAirMix()
	return list(
		GAS_O2 = O2STANDARD * MolesForPressure(),
		GAS_N2 = N2STANDARD *  MolesForPressure())

/obj/machinery/portable_atmospherics/proc/MolesForPressure(var/target_pressure = start_pressure)
	return (target_pressure * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	connected_port.on = 1 //Activate port updates

	anchored = TRUE //Prevent movement

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !network.gases.Find(air_contents))
		network.gases += air_contents
		network.update = 1

	return 1

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= air_contents

	anchored = FALSE

	connected_port.connected_device = null
	connected_port = null

	return 1

/obj/machinery/portable_atmospherics/proc/update_connected_network()
	if(!connected_port)
		return

	var/datum/pipe_network/network = connected_port.return_network(src)
	if (network)
		network.update = 1

/obj/machinery/portable_atmospherics/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if ((istype(W, /obj/item/tank) && !( src.destroyed )))
		if (src.holding)
			return
		var/obj/item/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if (W.has_tool_quality(TOOL_WRENCH) && !(src.destroyed)) // CHOMPEdit - Make sure it's not broken
		if(connected_port)
			disconnect()
			to_chat(user, span_notice("You disconnect \the [src] from the port."))
			update_icon()
			playsound(src, W.usesound, 50, 1)
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, span_notice("You connect \the [src] to the port."))
					update_icon()
					playsound(src, W.usesound, 50, 1)
					return
				else
					to_chat(user, span_notice("\The [src] failed to connect to the port."))
					return
			else
				to_chat(user, span_notice("Nothing happens."))
				return
	return



/obj/machinery/portable_atmospherics/powered
	var/power_rating
	var/power_losses
	var/last_power_draw = 0
	var/obj/item/cell/cell
	var/use_cell = TRUE
	var/removeable_cell = TRUE

/obj/machinery/portable_atmospherics/powered/powered()
	if(use_power) //using area power
		return ..()
	if(cell && cell.charge)
		return 1
	return 0

/obj/machinery/portable_atmospherics/powered/attackby(obj/item/I, mob/user)
	if(use_cell && istype(I, /obj/item/cell))
		if(cell)
			to_chat(user, "There is already a power cell installed.")
			return

		var/obj/item/cell/C = I

		user.drop_item()
		C.add_fingerprint(user)
		cell = C
		C.loc = src
		user.visible_message(span_notice("[user] opens the panel on [src] and inserts [C]."), span_notice("You open the panel on [src] and insert [C]."))
		power_change()
		return

	if(I.has_tool_quality(TOOL_SCREWDRIVER) && removeable_cell)
		if(!cell)
			to_chat(user, span_warning("There is no power cell installed."))
			return

		user.visible_message(span_notice("[user] opens the panel on [src] and removes [cell]."), span_notice("You open the panel on [src] and remove [cell]."))
		playsound(src, I.usesound, 50, 1)
		cell.add_fingerprint(user)
		cell.loc = src.loc
		cell = null
		power_change()
		return
	..()

/obj/machinery/portable_atmospherics/proc/log_open()
	if(air_contents.gas.len == 0)
		return

	var/gases = ""
	for(var/gas in air_contents.gas)
		if(gases)
			gases += ", [gas]"
		else
			gases = gas
	log_admin("[usr] ([usr.ckey]) opened '[src.name]' containing [gases].")
	message_admins("[usr] ([usr.ckey]) opened '[src.name]' containing [gases].")
