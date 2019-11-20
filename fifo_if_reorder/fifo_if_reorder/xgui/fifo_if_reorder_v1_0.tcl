# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "IF_TYPE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "IF_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DIVISOR" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.DIVISOR { PARAM_VALUE.DIVISOR } {
	# Procedure called to update DIVISOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIVISOR { PARAM_VALUE.DIVISOR } {
	# Procedure called to validate DIVISOR
	return true
}

proc update_PARAM_VALUE.IF_TYPE { PARAM_VALUE.IF_TYPE } {
	# Procedure called to update IF_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IF_TYPE { PARAM_VALUE.IF_TYPE } {
	# Procedure called to validate IF_TYPE
	return true
}

proc update_PARAM_VALUE.IF_WIDTH { PARAM_VALUE.IF_WIDTH } {
	# Procedure called to update IF_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IF_WIDTH { PARAM_VALUE.IF_WIDTH } {
	# Procedure called to validate IF_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.IF_TYPE { MODELPARAM_VALUE.IF_TYPE PARAM_VALUE.IF_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IF_TYPE}] ${MODELPARAM_VALUE.IF_TYPE}
}

proc update_MODELPARAM_VALUE.IF_WIDTH { MODELPARAM_VALUE.IF_WIDTH PARAM_VALUE.IF_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IF_WIDTH}] ${MODELPARAM_VALUE.IF_WIDTH}
}

proc update_MODELPARAM_VALUE.DIVISOR { MODELPARAM_VALUE.DIVISOR PARAM_VALUE.DIVISOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIVISOR}] ${MODELPARAM_VALUE.DIVISOR}
}

