package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

/**
 * Used for iterating through the map of minTypes of a {@link SimpleTypeInfo}. 
 * Allows to change the state of each entry in the map (Pending, Ready, Error). 
 * In case of an error, it is reported to the 'origin' type variable.
 * 
 * @author npasserini
 */
class MinTypeAnalysisResultReporter {
	/** The type variable where to forward the errors that are found while processing current minType. */
	@Accessors(PUBLIC_GETTER)
	TypeVariable origin

	@Accessors(PROTECTED_SETTER)
	Map.Entry<WollokType, ConcreteTypeState> currentEntry

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
}
