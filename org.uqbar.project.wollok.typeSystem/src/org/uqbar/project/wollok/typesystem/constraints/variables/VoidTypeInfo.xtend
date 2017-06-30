package org.uqbar.project.wollok.typesystem.constraints.variables

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

class VoidTypeInfo extends TypeInfo {
	var hasErrors = false
	
	// ************************************************************************
	// ** Queries
	// ************************************************************************

	override getType(TypeVariable user) {
		return WollokType.WVoid
	}

	override hasErrors() {
		return hasErrors
	}

	override reportErrors(TypeVariable user, ConfigurableDslValidator validator) {
		if (hasErrors)
			validator.report('''This statement does not produce a value''', user.owner)
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	
	override beVoid() {
		// Do nothing, I am void
	}	

	
	// ************************************************************************
	// ** Misc
	// ************************************************************************
	
	override fullDescription() '''
		void
	'''

	// ************************************************************************
	// ** Not yet implemented
	// ************************************************************************
	
	override beSealed() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addMinimalType(WollokType type) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}