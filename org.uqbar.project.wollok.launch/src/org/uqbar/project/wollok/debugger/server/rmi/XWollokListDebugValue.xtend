package org.uqbar.project.wollok.debugger.server.rmi

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Special value for wollok lists.
 * Shows its content as children
 * @author jfernandes
 */
class XWollokListDebugValue extends XDebugValue {
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList
	
	new() {
		super('''List (id=DUMMY)''')
	}
	
	// TODO: reimplement with new wollok lists
//	new(WollokList list) {
//		super('''List (id=«System.identityHashCode(list)»)''')
//		var i = 0
//		for (e : list.wrapped) 
//			variables.add(new XDebugStackFrameVariable(new WVariable(String.valueOf(i++), false), e))
//	}
	
}