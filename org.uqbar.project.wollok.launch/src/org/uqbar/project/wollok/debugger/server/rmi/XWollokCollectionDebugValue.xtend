package org.uqbar.project.wollok.debugger.server.rmi

import java.util.Collection
import java.util.Collections
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.WCollection
import wollok.lang.WDictionary

import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*

/**
 * Special value for wollok collection.
 * Shows its content as children
 * 
 * @author jfernandes
 */
abstract class XWollokCollectionDebugValue extends XDebugValue {
	
	String concreteNativeType
	
	new(WollokObject collection, String concreteNativeType, String collectionType) {
		super(collectionType, System.identityHashCode(collection))
		this.concreteNativeType = concreteNativeType
		val result = newArrayList
		val elements = collection.getElements(concreteNativeType)
		elements.forEach [ element, i |
			result.add(new XDebugStackFrameVariable(new WVariable(i.getVariableName(collection, concreteNativeType), System.identityHashCode(element), false, false), element))
		]
		variables = newArrayList(result)
	}
	
	override getTypeName() { concreteNativeType }
	
	def getElements(WollokObject collection, String concreteNativeType) {
		val native = collection.getNativeObject(concreteNativeType) as WCollection<Collection<WollokObject>>
		if (native.wrapped === null) Collections.EMPTY_LIST else native.wrapped
	}

	def String getVariableName(int i, WollokObject collection, String concreteNativeType)
}

class XWollokListDebugValue extends XWollokCollectionDebugValue {
	
	new(WollokObject collection, String concreteNativeType) {
		super(collection, concreteNativeType, "List")
	}
	
	override getVariableName(int i, WollokObject collection, String concreteNativeType) {
		String.valueOf(i)
	}
	
}

class XWollokSetDebugValue extends XWollokCollectionDebugValue {
	
	new(WollokObject collection, String concreteNativeType) {
		super(collection, concreteNativeType, "Set")
	}
	
	override getVariableName(int i, WollokObject collection, String concreteNativeType) {
		""
	}
		
}

class XWollokDictionaryDebugValue extends XWollokCollectionDebugValue {
	
	new(WollokObject collection, String concreteNativeType) {
		super(collection, concreteNativeType, "Dictionary")
	}
	
	override getVariableName(int i, WollokObject collection, String concreteNativeType) {
		val wrapped = collection.getNativeObject(concreteNativeType) as WDictionary
		val key = wrapped.keys.get(i) 
		if (key !== null) key.asString else "null"
	}

	override getElements(WollokObject collection, String concreteNativeType) {
		val wrapped = collection.getNativeObject(concreteNativeType) as WDictionary
		if (wrapped === null) Collections.EMPTY_LIST else wrapped.values
	}

}