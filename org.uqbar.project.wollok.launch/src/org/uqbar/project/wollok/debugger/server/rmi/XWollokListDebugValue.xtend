package org.uqbar.project.wollok.debugger.server.rmi

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

/**
 * Special value for wollok lists.
 * Shows its content as children
 * 
 * @author jfernandes
 */
class XWollokListDebugValue extends XDebugValue {
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList
	
	new(WollokObject list) {
		super('''List (id=«System.identityHashCode(list)»)''')
		var i = 0
		for (e : list.elements) 
			variables.add(new XDebugStackFrameVariable(new WVariable(String.valueOf(i++), false), e))
	}
	
	def getElements(WollokObject object) {
		val wrapped = object.getNativeObject(LIST) as JavaWrapper<List<WollokObject>>
		wrapped.wrapped
	}
	
}