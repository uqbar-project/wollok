package org.uqbar.project.wollok.ui.diagrams.objects

import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.ui.contexts.DebugContextEvent
import org.eclipse.debug.ui.contexts.IDebugContextListener
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.StructuredSelection

/**
 * 
 * @author jfernandes
 */
class DebugContextListener implements IDebugContextListener {
	
	IStackFrameConsumer consumer
	
	new(IStackFrameConsumer consumer) {
		this.consumer = consumer
	}
	
	override debugContextChanged(DebugContextEvent event) {
		if ((event.flags.bitwiseAnd(DebugContextEvent.ACTIVATED)) > 0) {
			contextActivated(event.context)
		}
	}
	
	def void contextActivated(ISelection context) {
		if (context instanceof StructuredSelection) {
			val data = (context as StructuredSelection).firstElement
			if (data instanceof IStackFrame) {
				consumer.stackFrame = data as IStackFrame
			} else {
				consumer.stackFrame = null
			}
		}
	}
	
}

public interface IStackFrameConsumer {

	def void setStackFrame(IStackFrame stackframe)

}