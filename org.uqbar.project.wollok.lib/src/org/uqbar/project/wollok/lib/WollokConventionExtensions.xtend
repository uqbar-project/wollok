package org.uqbar.project.wollok.lib

import java.util.List
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.utils.OptionalExtensions.*

class WollokConventionExtensions {
		
	public static val POSITION_CONVENTIONS = #["posicion", "position"]
	public static val IMAGE_CONVENTIONS = #["imagen", "image"]
	public static val DEFAULT_IMAGE = "wko.png"

	def static getAllConventions() {
		POSITION_CONVENTIONS + IMAGE_CONVENTIONS
	}
	
	def static getPosition(WollokObject it) {
		findConvention(POSITION_CONVENTIONS)
		.orElseThrow([new WollokRuntimeException('''Visual object doesn't have any position: «it.toString»''')])
	}

	def static getImage(WollokObject it) {
		findConvention(IMAGE_CONVENTIONS)
		.orElse(DEFAULT_IMAGE.javaToWollok)
	}
	
	def static getPrintableVariables(WollokObject it) {
		instanceVariables.entrySet.filter[key.printableVariable]
	}
	
	def static findConvention(WollokObject it, List<String> conventions) {		
		findVariable(conventions)
		.or(findGetter(conventions))
	}
	
	def static findVariable(WollokObject it, List<String> conventions) {
		conventions
		.map[c | instanceVariables.get(c)]
		.firstNotNull
	}
	
	def static findGetter(WollokObject it, List<String> conventions) {
		allMethods
		.firstOrOptional[it.name.isGetter(conventions)]
		.map[m | call(m)]
	}

	def static isGetter(String it, List<String> conventions) {
		conventions.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
	}
	
	def static isConvention(String it) {
		allConventions.toList.contains(it)
	}
	
	def static isPrintableVariable(String it) {
		!it.isConvention && !it.startsWith("_")
	}
}