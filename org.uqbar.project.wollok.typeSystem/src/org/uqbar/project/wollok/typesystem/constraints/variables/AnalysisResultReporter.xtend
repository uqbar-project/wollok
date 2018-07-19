package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

/**
 * Used for iterating through the map of minTypes of a {@link GenericTypeInfo}. 
 * Allows to change the state of each entry in the map (Pending, Ready, Error). 
 * In case of an error, it is reported to the 'origin' type variable.
 * 
 * @author npasserini
 */
class AnalysisResultReporter<T> {
	/** The type variable where to forward the errors that are found while processing current minType. */
	@Accessors(PUBLIC_GETTER)
	TypeVariable origin

	@Accessors(PROTECTED_SETTER)
	Map.Entry<T, ConcreteTypeState> currentEntry

	new(TypeVariable origin) {
		this.origin = origin
	}

	def type() { currentEntry.key }

	def state() { currentEntry.value }

	def ready() { currentEntry.value = Ready }

	def pending() { currentEntry.value = Pending }

	def error(TypeSystemException typeError) {
		origin.addError(typeError)
		currentEntry.value = Error
	}
	
	/**
	 * Execute an action for each entry in a map which values are propagation States, 
	 * updating each state according to action result 
	 * and reporting errors to the indicated type variable.
	 */
	static def <T> statesDo(Map<T, ConcreteTypeState> states, TypeVariable errorTarget, Consumer<AnalysisResultReporter<T>> action) {
		val reporter = new AnalysisResultReporter(errorTarget)
		states.entrySet.forEach [
			reporter.currentEntry = it
			action.accept(reporter)
		]
	}

	static def <T> pendingStatesDo(Map<T, ConcreteTypeState> states, TypeVariable errorTarget, Consumer<AnalysisResultReporter<T>> action) {
		val reporter = new AnalysisResultReporter(errorTarget)
		states.entrySet.forEach [
			if (value == Pending) {
				reporter.currentEntry = it
				action.accept(reporter)
			}
		]
	}
}
