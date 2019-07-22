proc create_drp_interface {drpName drpNumber} {
	set ldrp_name [string tolower $drpName]
	set drp_addr _addr
	set drp_do _do
	set drp_rdy _rdy
	set drp_we _we
	set drp_en _en
	set drp_di _di
	# concat
	set drp_addr [concat $ldrp_name$drp_addr]
	set drp_do [concat $ldrp_name$drp_do]
	set drp_rdy [concat $ldrp_name$drp_rdy]
	set drp_we [concat $ldrp_name$drp_we]
	set drp_en [concat $ldrp_name$drp_en]
	set drp_di [concat $ldrp_name$drp_di]
	ipx::add_bus_interface $drpName [ipx::current_core]
	set_property abstraction_type_vlnv xilinx.com:interface:drp_rtl:1.0 [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property bus_type_vlnv xilinx.com:interface:drp:1.0 [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property interface_mode master [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property enablement_dependency spirit:decode(id('MODELPARAM_VALUE.DRP_COUNT'))>$drpNumber [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	ipx::add_port_map DADDR [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_addr [ipx::get_port_maps DADDR -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
	ipx::add_port_map DO [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_do [ipx::get_port_maps DO -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
	ipx::add_port_map DRDY [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_rdy [ipx::get_port_maps DRDY -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
	ipx::add_port_map DWE [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_we [ipx::get_port_maps DWE -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
	ipx::add_port_map DEN [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_en [ipx::get_port_maps DEN -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
	ipx::add_port_map DI [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]
	set_property physical_name $drp_di [ipx::get_port_maps DI -of_objects [ipx::get_bus_interfaces $drpName -of_objects [ipx::current_core]]]
}