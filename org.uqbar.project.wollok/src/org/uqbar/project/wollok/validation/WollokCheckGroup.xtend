package org.uqbar.project.wollok.validation

/**
 * Groups of validations/checks
 * Currently only used to aggregate validations in the preferences / UI
 * 
 * @author jfernandes
 */
class WollokCheckGroup {
	public static val INITIALIZATION = "INITIALIZATION"
	public static val NAMING_CONVENTION = "NAMING CONVENTION"
	public static val CODE_STYLE = "CODE STYLE"
	public static val POTENTIAL_PROGRAMMING_PROBLEM = "POTENTIAL PROGRAMMING PROBLEM"
	public static val POTENTIAL_DESIGN_PROBLEM = "POTENTIAL DESIGN PROBLEM"
	public static val UNNECESARY_CODE = "UNNECESARY CODE"
	public static val GLOBAL_REFERENCE = "GLOBAL REFERENCE"
	public static val EXPLICIT_INTENTION = "EXPLICIT INTENTION"
}