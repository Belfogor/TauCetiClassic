//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#define SHOCK_COOLDOWN 400
/obj/machinery/computer/prisoner
	name = "Implant Management"
	icon = 'icons/obj/computer.dmi'
	icon_state = "explosive"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	light_color = "#a91515"
	req_access = list(access_armory)
	circuit = /obj/item/weapon/circuitboard/prisoner
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed

/obj/machinery/computer/prisoner/ui_interact(mob/user)
	var/dat
	dat += "<B>Prisoner Implant Manager System</B><BR>"
	if(screen == 0)
		dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		dat += "<HR>Chemical Implants<BR>"
		var/turf/Tr = null
		for(var/obj/item/weapon/implant/chem/C in implant_list)
			Tr = get_turf(C)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!C.implanted) continue
			dat += "[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
			dat += "<A href='?src=\ref[src];inject1=\ref[C]'>(<font color=red>(1)</font>)</A>"
			dat += "<A href='?src=\ref[src];inject5=\ref[C]'>(<font color=red>(5)</font>)</A>"
			dat += "<A href='?src=\ref[src];inject10=\ref[C]'>(<font color=red>(10)</font>)</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/weapon/implant/tracking/T in implant_list)
			Tr = get_turf(T)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!T.implanted) continue
			var/loc_display = "Unknown"
			var/mob/living/carbon/M = T.imp_in
			if(is_station_level(M.z) && !istype(M.loc, /turf/space))
				var/turf/mob_loc = get_turf_loc(M)
				loc_display = mob_loc.loc
			if(T.malfunction)
				loc_display = pick(teleportlocs)
			dat += "[T.imp_in.name] <BR>"
			dat += "Location: [loc_display]<BR>"
			dat += "<A href='?src=\ref[src];warn=\ref[T]'>(<font color=red><i>Message Holder</i></font>)</A> |<BR>"
		//	dat += "<A href='?src=\ref[src];Explode=\ref[T]'>(<font color=red>(Explode)</font>)</A><BR>"
			dat += "<A href='?src=\ref[src];Shock=\ref[T]'>(<font color=red>Shock</font>)</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"
	user << browse(entity_ja(dat), "window=computer;size=400x500")
	onclose(user, "computer")


/obj/machinery/computer/prisoner/process()
	if(!..())
		src.updateDialog()
	return


/obj/machinery/computer/prisoner/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["inject1"])
		var/obj/item/weapon/implant/I = locate(href_list["inject1"])
		if(I && istype(I) && I in implant_list)	I.activate(1)

	else if(href_list["inject5"])
		var/obj/item/weapon/implant/I = locate(href_list["inject5"])
		if(I && istype(I) && I in implant_list)	I.activate(5)

	else if(href_list["inject10"])
		var/obj/item/weapon/implant/I = locate(href_list["inject10"])
		if(I && istype(I) && I in implant_list)	I.activate(10)

	else if(href_list["lock"])
		if(src.allowed(usr))
			screen = !screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["warn"])
		var/warning = sanitize(input(usr,"Message:","Enter your message here!",""))
		if(!warning) return
		var/obj/item/weapon/implant/I = locate(href_list["warn"])
		if(I && istype(I) && I.imp_in)
			var/mob/living/carbon/R = I.imp_in
			to_chat(R, "<span class='notice'>You hear a voice in your head saying: '[warning]'</span>")

	else if(href_list["Shock"])
		var/obj/item/weapon/implant/I = locate(href_list["Shock"])
		if(I && istype(I) && I.imp_in)
			if(I.nextUse + SHOCK_COOLDOWN > world.time)
				to_chat(usr, "It isn't ready to use.")
			else
				var/mob/living/carbon/R = I.imp_in
				R.electrocute_act(15, null, 1.0, I.part.body_zone)
				R.Stun(7)
				playsound(R, 'sound/items/surgery/defib_zap.ogg')
				I.nextUse = world.time

	src.updateUsrDialog()
#undef SHOCK_COOLDOWN