package org.uqbar.project.wollok.interpreter.core

import java.util.Map
import org.uqbar.project.wollok.interpreter.nativeobj.collections.AbstractWollokCollection
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

class ToStringBuilder {
	val alreadyShown = <WollokObject>newHashSet()
	
	def static shortLabel(WollokObject obj) {
		obj.behavior.objectDescription
	}

	def static dispatch objectDescription(WClass clazz) { "a " + clazz.name  }
	def static dispatch objectDescription(WObjectLiteral obj) { "anObject" }
	def static dispatch objectDescription(WNamedObject namedObject) { namedObject.name }
	
	def String smartToString(Object obj) {
		if (obj == null)
			"null"
		else
			obj.doSmartToString
	}

	def dispatch String doSmartToString(WollokObject obj){
		val toString = obj.behavior.lookupMethod("toString")
		if (toString != null) {
			obj.call("toString").toString
		}
		else{
			if (alreadyShown.contains(obj)) {
				obj.behavior.objectDescription
			} 
			else {
				alreadyShown.add(obj)
				obj.behavior.objectDescription + obj.instanceVariables.smartToString
			}
		}
	}
	
	def dispatch String doSmartToString(AbstractWollokCollection<?> col){
		col.wollokName + "[" + col.wrapped.map[ smartToString ].join(", ") + "]"
	}
	
	def dispatch String doSmartToString(Map<String,Object> obs){
		"[" + obs.entrySet.map[ key + "=" + value.smartToString ].join(", ") +  "]"
	}
	
	def dispatch String doSmartToString(Object obj){
		obj.toString
	}
}