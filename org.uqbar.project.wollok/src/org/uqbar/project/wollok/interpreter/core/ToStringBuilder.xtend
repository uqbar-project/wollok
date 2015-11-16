package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral

class ToStringBuilder {
	
	def static shortLabel(WollokObject obj) {
		obj.behavior.objectDescription
	}

	def static dispatch objectDescription(WClass clazz) { "a " + clazz.name  }
	def static dispatch objectDescription(WObjectLiteral obj) { "anObject" }
	def static dispatch objectDescription(WNamedObject namedObject) { namedObject.name }
	
}