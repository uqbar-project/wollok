package org.uqbar.project.wollok.lib

import java.util.List
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import java.util.Optional

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WollokConventionExtensions {
		
	public static val POSITION_CONVENTIONS = #["posicion", "position"]
	public static val IMAGE_CONVENTIONS = #["imagen", "image"]

	def static getAllConventions() {
		POSITION_CONVENTIONS + IMAGE_CONVENTIONS
	}
	
	def static getPosition(WollokObject it) {
		findConvention(POSITION_CONVENTIONS)
		.orElseThrow([new WollokRuntimeException('''Visual object doesn't have any position: «it.toString»''')])
	}

	def static getImage(WollokObject it) {
		findConvention(IMAGE_CONVENTIONS)
		.orElse("wko.png".javaToWollok)
	}
	
	def static getPrintableVariables(WollokObject it) {
		instanceVariables.entrySet.filter[key.printableVariable]
	}
	
	def static findConvention(WollokObject it, List<String> conventions) {
		var WollokObject value = null
		
		var attribute = conventions.map[c|instanceVariables.get(c)].filterNull.head
		if (attribute != null)
			value = attribute
			
		var getter = allMethods.map[it.name].findFirst[isGetter(conventions)]
		if (getter != null)
			value = call(getter)
			
		Optional.ofNullable(value)
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