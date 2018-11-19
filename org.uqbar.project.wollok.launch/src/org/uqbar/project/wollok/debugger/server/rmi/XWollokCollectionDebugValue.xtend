package org.uqbar.project.wollok.debugger.server.rmi

import java.util.Collection
import java.util.Collections
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.WCollection

/**
 * Special value for wollok collection.
 * Shows its content as children
 * 
 * @author jfernandes
 */
abstract class XWollokCollectionDebugValue extends XDebugValue {
	
	new(WollokObject collection, String concreteNativeType, String collectionType) {
		super(collectionType, System.identityHashCode(collection))
		var i = 0
		val result = newArrayList
		for (e : collection.getElements(concreteNativeType)) {
			// TODO: Hay que usar el toVariable de XDebugStackFrame porque no lo está agregando
			// a la colección de variables ni de valores
			result.add(new XDebugStackFrameVariable(new WVariable(i.variableName, System.identityHashCode(e), false), e))
			i++
		}
		variables = newArrayList(result)
	}
	
	def getElements(WollokObject object, String concreteNativeType) {
		val native = object.getNativeObject(concreteNativeType) as WCollection<Collection<WollokObject>>
		if (native.wrapped === null) Collections.EMPTY_LIST else native.wrapped
	}

	def String getVariableName(int i)
}

class XWollokListDebugValue extends XWollokCollectionDebugValue {
	
	new(WollokObject collection, String concreteNativeType) {
		super(collection, concreteNativeType, "List")
	}
	
	override getVariableName(int i) {
		String.valueOf(i)
	}
	
}

class XWollokSetDebugValue extends XWollokCollectionDebugValue {
	
	new(WollokObject collection, String concreteNativeType) {
		super(collection, concreteNativeType, "Set")
	}
	
	override getVariableName(int i) {
		""
	}
		
}