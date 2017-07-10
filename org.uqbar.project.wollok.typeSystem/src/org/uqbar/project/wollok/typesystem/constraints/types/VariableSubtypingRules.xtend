package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.constraints.variables.ClassParameterTypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForAll

class VariableSubtypingRules {
	// ************************************************************************
	// ** Type Info
	// ************************************************************************

	/** Missing type info => I can allways be super or subtype */
	static def dispatch boolean isSupertypeOf(Void supertype, TypeInfo subtype) { true }

	/** Missing type info => I can allways be super or subtype */
	static def dispatch boolean isSupertypeOf(TypeInfo supertype, Void subtype) { true }

	static def dispatch boolean isSupertypeOf(VoidTypeInfo supertype, VoidTypeInfo subtype) { true }

	static def dispatch boolean isSupertypeOf(ClosureTypeInfo supertype, ClosureTypeInfo subtype) { 
		supertype.parameters.biForAll(subtype.parameters)[superParam, subParam|
			// Note that the subtype relationship is inverted for parameters
			subParam.isSuperVarOf(superParam)
		]
		&&
		(supertype.returnType as TypeVariable).typeInfo.isSupertypeOf((subtype.returnType as TypeVariable).typeInfo)
	}

	/** The maxTypes of the supertype has to include every minType in subtype */
	static def dispatch boolean isSupertypeOf(SimpleTypeInfo supertype, SimpleTypeInfo subtype) {
		supertype.maximalConcreteTypes == null 
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
