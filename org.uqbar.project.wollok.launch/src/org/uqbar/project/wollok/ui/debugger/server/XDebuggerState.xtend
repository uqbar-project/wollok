package org.uqbar.project.wollok.ui.debugger.server

import org.eclipse.emf.ecore.EObject

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Represents the different states a debugger
 * could be at any moment.
 * Depending on the commands performed by the user.
 * For example it could be just running all the way, in which case it will
 * only pause on a breakpoint.
 * Could be stepping-over, meaning that it won't pause on an inner evaluation.
 * Could be stepping-in, in which case it will pause on inner evaluations (actually in all evals)
 * 
 * @author jfernandes
 */
abstract class XDebuggerState {
	def void before(XDebuggerImpl d, EObject e)
	def void after(XDebuggerImpl d, EObject e)
}

/**
 * Runs the whole program checking for breakpoints hits.
 * @author jfernandes
 */
class RunThroughDebuggerState extends XDebuggerState {
	override before(XDebuggerImpl d, EObject e) { }
	override after(XDebuggerImpl d, EObject e) { }
	override toString() { "RUN_THROUGH" }
}

/**
 * Evaluating the given object but won't evaluate the inner elements
 * Once the debugger tell us that it has finished with our object, then
 * It will suspend on the next step (changing the state to PauseOnNext)
 */
class SteppingOver extends XDebuggerState {
	var EObject currentStepObject
	new(EObject step) { currentStepObject = step }
	
	override before(XDebuggerImpl d, EObject e) { /* wont suspend for inner evaluations */ }
	override after(XDebuggerImpl d, EObject e) {
		if (e == currentStepObject) {
			d.state = new PauseOnNext
		}
	}
	override toString() { "STEPPING_OVER(" + currentStepObject.shortSouceCode + "-" + System.identityHashCode(currentStepObject) + ")" }
}

/**
 * Next evaluation will get paused
 * 
 * @author jfernandes
 */
class PauseOnNext extends XDebuggerState {
	override before(XDebuggerImpl d, EObject e) { if (!e.isTransparent()) d.sleep }
	override after(XDebuggerImpl d, EObject e) { }
	override toString() { "PAUSE_ON_NEXT" }
}

/**
 * Will only pause on the first object to be evaluated on one-level up 
 * the stack.
 * At creation time it knows the current stack depth.
 * So when the current depth is < originalDepth means we have already stepped out.  
 * 
 * @author jfernandes
 */
class SteppingOut extends XDebuggerState {
	int originalStackDepth
	
	new(int originalStackDepth) {
		this.originalStackDepth = originalStackDepth
	}
	
	override before(XDebuggerImpl d, EObject e) {
		if (d.stack.size < originalStackDepth) d.sleep
	}
	override after(XDebuggerImpl d, EObject e) {}
}

