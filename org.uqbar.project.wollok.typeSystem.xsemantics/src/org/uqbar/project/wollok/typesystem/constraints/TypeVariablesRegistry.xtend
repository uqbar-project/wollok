package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType

import static org.uqbar.project.wollok.sdk.WollokDSK.*

class TypeVariablesRegistry {
	val Map<EObject, TypeVariable> typeVariables = newHashMap

	ConstraintBasedTypeSystem typeSystem
	
	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
	}
	
	// ************************************************************************
	// ** Creating type variables.
	// ************************************************************************
	
	def newTypeVariable(EObject obj) {
		new TypeVariable(obj) => [ typeVariables.put(obj, it) ]
	}
	
	def newWithSubtype(EObject it, EObject... subtypes) {
		newTypeVariable => [ subtypes.forEach [ subtype | it.beSupertypeOf(subtype.tvar) ]]
	}

	def newSealed(EObject it, WollokType type) {
		newTypeVariable => [
			addMinimalType(type)
			beSealed
		]
	}
	
	def beVoid(EObject it) {
		newSealed(typeSystem.classType(it, VOID))
	}
		
	// ************************************************************************
	// ** Retrieve type variables
	// ************************************************************************
	
	def allVariables() {
		typeVariables.values
	}
	
	def TypeVariable tvar(EObject obj) {
		typeVariables.get(obj) => [ typeVar | 
			if (typeVar == null) throw new RuntimeException("I don't have type information for " + obj)
		]
	}
	
	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	
	def fullReport() {
		typeVariables.values.forEach[println(fullDescription)]
	}	
}
