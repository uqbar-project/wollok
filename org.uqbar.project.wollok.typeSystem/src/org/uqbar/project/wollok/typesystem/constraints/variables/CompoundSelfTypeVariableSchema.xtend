package org.uqbar.project.wollok.typesystem.constraints.variables

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericTypeSchema

class CompoundSelfTypeVariableSchema extends TypeVariableSchema {
	GenericTypeSchema schema

	new(TypeVariableOwner owner, GenericTypeSchema schema) {
		super(owner)
		this.schema = schema
	}

	override getType() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	// ************************************************************************
	// ** Instantiation
	// ************************************************************************
	override instanceFor(TypeVariable variable) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override instanceFor(ConcreteType concreteReceiver) {
		val typeSchema = new GenericTypeSchema((concreteReceiver as GenericTypeInstance).rawType, schema.typeParameters)
		registry.newSealed(owner, typeSchema.instanceFor(concreteReceiver))
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	override toString() '''Self<«schema.typeParameters»>'''
}
