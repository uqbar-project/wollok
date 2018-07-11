package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.constraints.variables.ClassParameterTypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo

class VariableSubtypingRules {
	// ************************************************************************
	// ** Type Info
	// ************************************************************************

	/** Missing type info => I can always be super or subtype */
	static def dispatch boolean isSupertypeOf(Void supertype, Void subtype) { true }

	/** Missing type info => I can always be super or subtype */
	static def dispatch boolean isSupertypeOf(Void supertype, TypeInfo subtype) { true }

	/** Missing type info => I can always be super or subtype */
	static def dispatch boolean isSupertypeOf(TypeInfo supertype, Void subtype) { true }

	/** 
	 * Void is supertype of anything, i.e. we can receive anything where void is expected.
	 * The opposite is not true, void is unacceptable where another type of value is expected.
	 */
	static def dispatch boolean isSupertypeOf(VoidTypeInfo supertype, TypeInfo subtype) { true }

	/** The maxTypes of the supertype has to include every minType in subtype */
	static def dispatch boolean isSupertypeOf(GenericTypeInfo supertype, GenericTypeInfo subtype) {
		supertype.maximalConcreteTypes === null 
		||
		subtype.minTypes.keySet.forall[
			supertype.maximalConcreteTypes.contains(it)
		]
	}

	/** Default impl, will arrive to this rule if everything else fails, type infos of different kind => impossible subtyping */
	static def dispatch boolean isSupertypeOf(TypeInfo supertype, TypeInfo subtype) { false }
	
	// ************************************************************************
	// ** Type Variables
	// ************************************************************************

	static def dispatch boolean isSuperVarOf(TypeVariable supertype, TypeVariable subtype) { 
		supertype.typeInfo.isSupertypeOf(subtype.typeInfo)
	}

	static def dispatch boolean isSuperVarOf(ClassParameterTypeVariable supertype, TypeVariable subtype) {
		true // TODO
	} 

	static def dispatch boolean isSuperVarOf(TypeVariable supertype, ClassParameterTypeVariable subtype) {
		true // TODO
	} 
}
