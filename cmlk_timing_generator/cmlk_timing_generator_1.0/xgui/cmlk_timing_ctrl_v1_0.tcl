# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLOCK_DIV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_FBMULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_PERIOD" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLOCK_DIV { PARAM_VALUE.CLOCK_DIV } {
	# Procedure called to update CLOCK_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_DIV { PARAM_VALUE.CLOCK_DIV } {
	# Procedure called to validate CLOCK_DIV
	return true
}

proc update_PARAM_VALUE.CLOCK_FBMULT { PARAM_VALUE.CLOCK_FBMULT } {
	# Procedure called to update CLOCK_FBMULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_FBMULT { PARAM_VALUE.CLOCK_FBMULT } {
	# Procedure called to validate CLOCK_FBMULT
	return true
}

proc update_PARAM_VALUE.CLOCK_PERIOD { PARAM_VALUE.CLOCK_PERIOD } {
	# Procedure called to update CLOCK_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_PERIOD { PARAM_VALUE.CLOCK_PERIOD } {
	# Procedure called to validate CLOCK_PERIOD
	return true
}


proc update_MODELPARAM_VALUE.CLOCK_PERIOD { MODELPARAM_VALUE.CLOCK_PERIOD PARAM_VALUE.CLOCK_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_PERIOD}] ${MODELPARAM_VALUE.CLOCK_PERIOD}
}

proc update_MODELPARAM_VALUE.CLOCK_FBMULT { MODELPARAM_VALUE.CLOCK_FBMULT PARAM_VALUE.CLOCK_FBMULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_FBMULT}] ${MODELPARAM_VALUE.CLOCK_FBMULT}
}

proc update_MODELPARAM_VALUE.CLOCK_DIV { MODELPARAM_VALUE.CLOCK_DIV PARAM_VALUE.CLOCK_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_DIV}] ${MODELPARAM_VALUE.CLOCK_DIV}
}

