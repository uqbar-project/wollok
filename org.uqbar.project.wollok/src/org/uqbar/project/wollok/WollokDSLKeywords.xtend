package org.uqbar.project.wollok

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
class WollokDSLKeywords {
	public static val THIS = "this"
	public static val METHOD = "method"
	public static val VAR = "var"
	public static val OVERRIDE = "override"
	
	public static val MULTIOPS_REGEXP = "[+\\-*/%]="
}