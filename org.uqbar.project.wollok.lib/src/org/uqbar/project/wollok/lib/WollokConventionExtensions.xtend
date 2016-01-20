package org.uqbar.project.wollok.lib

import java.util.List
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

class WollokConventionExtensions {
		
	public static val POSITION_CONVENTIONS = #["posicion", "position"]
	public static val IMAGE_CONVENTIONS = #["imagen", "image"]

	def static getPosition(WollokObject it) {
		findConvention(POSITION_CONVENTIONS)
	}

	def static getImage(WollokObject it) {
		findConvention(IMAGE_CONVENTIONS)
	}	
	
	def static findConvention(WollokObject it, List<String> conventions) {
		var getter = allMethods.map[it.name].findFirst[isGetter(conventions)]
		if (getter != null)
			return call(getter)

		var attribute = conventions.map[c|instanceVariables.get(c)].filterNull.head
		if (attribute != null)
			return attribute

		throw new WollokRuntimeException(String.format("Visual object doesn't have any position: %s", it.toString))
	}

	def static isGetter(String it, List<String> conventions) {
		conventions.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
	}
	
	def static getAllConventions() {
		POSITION_CONVENTIONS + IMAGE_CONVENTIONS
	}
}