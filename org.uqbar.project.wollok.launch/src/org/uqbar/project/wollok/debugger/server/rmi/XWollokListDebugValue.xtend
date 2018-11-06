package org.uqbar.project.wollok.debugger.server.rmi

import java.util.Collection
import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.WCollection

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Special value for wollok lists.
 * Shows its content as children
 * 
 * @author jfernandes
 */
class XWollokListDebugValue extends XDebugValue {
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList
	
	new(WollokObject list, String concreteNativeType) {
		super('''List (id=«System.identityHashCode(list)»)''')
		var i = 0
		for (e : list.getElements(concreteNativeType)) 
			variables.add(new XDebugStackFrameVariable(new WVariable(String.valueOf(i++), false), e))
	}
	
	def getElements(WollokObject object, String concreteNativeType) {
		val native = object.getNativeObject(concreteNativeType) as WCollection<Collection<WollokObject>>
		if (native.wrapped === null) Collections.EMPTY_LIST else native.wrapped
	}
	
}