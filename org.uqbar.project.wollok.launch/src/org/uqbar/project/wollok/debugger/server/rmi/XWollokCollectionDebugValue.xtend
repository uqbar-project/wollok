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
class XWollokCollectionDebugValue extends XDebugValue {
	
	new(WollokObject collection, String concreteNativeType, String simpleType) {
		super(simpleType, System.identityHashCode(collection))
		var i = 0
		val result = newArrayList
		for (e : collection.getElements(concreteNativeType)) {
			// TODO: Hay que usar el toVariable de XDebugStackFrame porque no lo está agregando
			// a la colección de variables ni de valores
			result.add(new XDebugStackFrameVariable(new WVariable(String.valueOf(i++), System.identityHashCode(e), false), e))
		}
		variables = newArrayList(result)
	}
	
	def getElements(WollokObject object, String concreteNativeType) {
		val native = object.getNativeObject(concreteNativeType) as WCollection<Collection<WollokObject>>
		if (native.wrapped === null) Collections.EMPTY_LIST else native.wrapped
	}

}