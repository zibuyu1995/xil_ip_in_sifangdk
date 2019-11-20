
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/fifo_if_reorder_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "IF_TYPE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "IF_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_A" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_B" -parent ${Page_0}


}

proc update_PARAM_VALUE.IF_WIDTH { PARAM_VALUE.IF_WIDTH PARAM_VALUE.WIDTH_A PARAM_VALUE.WIDTH_B } {
	# Procedure called to update IF_WIDTH when any of the dependent parameters in the arguments change
	
	set IF_WIDTH ${PARAM_VALUE.IF_WIDTH}
	set WIDTH_A ${PARAM_VALUE.WIDTH_A}
	set WIDTH_B ${PARAM_VALUE.WIDTH_B}
	set values(WIDTH_A) [get_property value $WIDTH_A]
	set values(WIDTH_B) [get_property value $WIDTH_B]
	set_property value [gen_USERPARAMETER_IF_WIDTH_VALUE $values(WIDTH_A) $values(WIDTH_B)] $IF_WIDTH
}

proc validate_PARAM_VALUE.IF_WIDTH { PARAM_VALUE.IF_WIDTH } {
	# Procedure called to validate IF_WIDTH
	return true
}

proc update_PARAM_VALUE.IF_TYPE { PARAM_VALUE.IF_TYPE } {
	# Procedure called to update IF_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IF_TYPE { PARAM_VALUE.IF_TYPE } {
	# Procedure called to validate IF_TYPE
	return true
}

proc update_PARAM_VALUE.WIDTH_A { PARAM_VALUE.WIDTH_A } {
	# Procedure called to update WIDTH_A when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_A { PARAM_VALUE.WIDTH_A } {
	# Procedure called to validate WIDTH_A
	return true
}

proc update_PARAM_VALUE.WIDTH_B { PARAM_VALUE.WIDTH_B } {
	# Procedure called to update WIDTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_B { PARAM_VALUE.WIDTH_B } {
	# Procedure called to validate WIDTH_B
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

proc update_MODELPARAM_VALUE.WIDTH_A { MODELPARAM_VALUE.WIDTH_A PARAM_VALUE.WIDTH_A } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_A}] ${MODELPARAM_VALUE.WIDTH_A}
}

proc update_MODELPARAM_VALUE.WIDTH_B { MODELPARAM_VALUE.WIDTH_B PARAM_VALUE.WIDTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_B}] ${MODELPARAM_VALUE.WIDTH_B}
}

