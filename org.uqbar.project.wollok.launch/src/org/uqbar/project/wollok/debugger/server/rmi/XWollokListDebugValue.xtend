package org.uqbar.project.wollok.debugger.server.rmi

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.collections.WollokList

/**
 * Special value for wollok lists.
 * Shows its content as children
 * @author jfernandes
 */
class XWollokListDebugValue extends XDebugValue {
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList
	
	new(WollokList list) {
		super('''List (id=«System.identityHashCode(list)»)''')
		var i = 0
		for (e : list.wrapped) 
			variables.add(new XDebugStackFrameVariable(new WVariable(String.valueOf(i++), false), e))
	}
	
}