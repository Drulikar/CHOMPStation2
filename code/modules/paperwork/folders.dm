/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi' //CHOMPEdit: Continues using new folder sprite, contrary to YW
	icon_state = "folder"
	w_class = ITEMSIZE_SMALL
	pressure_resistance = 2
	drop_sound = 'sound/items/drop/paper.ogg'
	pickup_sound = 'sound/items/pickup/paper.ogg'
	slot_flags = SLOT_BELT | SLOT_HOLSTER

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/folder/blue_captain
	desc = "A blue folder with " + JOB_SITE_MANAGER + " markings."
	icon_state = "folder_captain"

/obj/item/folder/blue_hop
	desc = "A blue folder with HoP markings."
	icon_state = "folder_hop"

/obj/item/folder/white_cmo
	desc = "A white folder with CMO markings."
	icon_state = "folder_cmo"

/obj/item/folder/white_rd
	desc = "A white folder with RD markings."
	icon_state = "folder_rd"

/obj/item/folder/white_rd/Initialize(mapload)
	. = ..()
	//add some memos
	var/obj/item/paper/P = new()
	P.name = "Memo RE: proper analysis procedure"
	P.info = "<br>We keep test dummies in pens here for a reason"
	src.contents += P
	update_icon()

/obj/item/folder/yellow_ce
	desc = "A yellow folder with CE markings."
	icon_state = "folder_ce"

/obj/item/folder/red_hos
	desc = "A red folder with HoS markings."
	icon_state = "folder_hos"

/obj/item/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")
	return

/obj/item/folder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/paper_bundle))
		user.drop_item()
		W.loc = src
		to_chat(user, span_notice("You put the [W] into \the [src]."))
		update_icon()
	else if(istype(W, /obj/item/pen))
		var/n_name = sanitizeSafe(tgui_input_text(user, "What would you like to label the folder?", "Folder Labelling", null, MAX_NAME_LEN), MAX_NAME_LEN)
		if(in_range(user, src) && user.stat == 0)
			name = "folder[(n_name ? text("- '[n_name]'") : null)]"
	return

/obj/item/folder/afterattack(turf/T as turf, mob/user as mob)
	for(var/obj/item/paper/P in T)
		P.loc = src
		update_icon()
		to_chat(user, span_notice("You tuck the [P] into \the [src]."))

/obj/item/folder/attack_self(mob/user as mob)
	var/dat = "<title>[name]</title>"

	for(var/obj/item/paper/P in src)
		dat += "<A href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A> <A href='byond://?src=\ref[src];rename=\ref[P]'>Rename</A> - <A href='byond://?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='byond://?src=\ref[src];remove=\ref[Ph]'>Remove</A> <A href='byond://?src=\ref[src];rename=\ref[Ph]'>Rename</A> - <A href='byond://?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"
	for(var/obj/item/paper_bundle/Pb in src)
		dat += "<A href='byond://?src=\ref[src];remove=\ref[Pb]'>Remove</A> <A href='byond://?src=\ref[src];rename=\ref[Pb]'>Rename</A> - <A href='byond://?src=\ref[src];browse=\ref[Pb]'>[Pb.name]</A><BR>"
	user << browse("<html>[dat]</html>", "window=folder")
	onclose(user, "folder")
	add_fingerprint(user)
	return

/obj/item/folder/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(src.loc == usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && (P.loc == src) && istype(P))
				P.loc = usr.loc
				usr.put_in_hands(P)

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(P && (P.loc == src) && istype(P))
				if(!(ishuman(usr) || isobserver(usr) || issilicon(usr)))
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P))
				P.show(usr)
		else if(href_list["browse"])
			var/obj/item/paper_bundle/P = locate(href_list["browse"])
			if(P && (P.loc == src) && istype(P))
				P.attack_self(usr)
				onclose(usr, "[P.name]")
		else if(href_list["rename"])
			var/obj/item/O = locate(href_list["rename"])

			if(O && (O.loc == src))
				if(istype(O, /obj/item/paper))
					var/obj/item/paper/to_rename = O
					to_rename.rename()

				else if(istype(O, /obj/item/photo))
					var/obj/item/photo/to_rename = O
					to_rename.rename()

				else if(istype(O, /obj/item/paper_bundle))
					var/obj/item/paper_bundle/to_rename = O
					to_rename.rename()

		//Update everything
		attack_self(usr)
		update_icon()
	return
