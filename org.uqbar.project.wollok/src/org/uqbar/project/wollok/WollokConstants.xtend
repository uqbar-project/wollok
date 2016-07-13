package org.uqbar.project.wollok

import org.uqbar.project.wollok.wollokDsl.WBinaryOperation

/**
 * Contains language keywords defined in the grammar
 * but then used by the interpreter or any other processing (like quickfixes).
 * 
 * Avoids hardcoding strings all over the places.
 * So that if we decide to change the grammar sintax we can just change here.
 * 
 * There's probably a way to get this via xtext but I'm not sure how
 * 
 * @author jfernandes
 */
class WollokConstants {
	
	public static val NATURE_ID = "org.uqbar.project.wollok.wollokNature"
	public static val CLASS_OBJECTS_EXTENSION = "wlk"
	public static val PROGRAM_EXTENSION = "wpgm"
	public static val TEST_EXTENSION = "wtest"
	
	// grammar elements here for being used in quickfixes, validators, and
	// any code that generates wollok code
	
	public static val OPMULTIASSIGN = #['+=', '-=', '*=', '/=', '%=', '<<=', '>>=']
	public static val OP_EQUALITY = #['==', '!=', '===', '!==']
	
	public static val OP_BOOLEAN_AND = #['and', "&&"]
	public static val OP_BOOLEAN_OR = #["or", "||"]
	
	public static val OP_BOOLEAN = #['and', "&&", "or", "||"]
	public static val OP_UNARY_BOOLEAN = #['!', "not"]
	
	public static val THIS = "this"
	public static val METHOD = "method"
	public static val VAR = "var"
	public static val OVERRIDE = "override"
	public static val RETURN = "return"
	public static val CLASS = "class"
	
	public static val MULTIOPS_REGEXP = "[+\\-*/%]="

	public static def isMultiOpAssignment(WBinaryOperation it) { feature.isMultiOpAssignment }
	public static def isMultiOpAssignment(String operator) { operator.matches(MULTIOPS_REGEXP) }
}