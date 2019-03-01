package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation

import static org.uqbar.project.wollok.sdk.WollokDSK.*

class UnaryOperationsConstraintsGenerator {
	extension TypeVariablesRegistry registry
	extension ConstraintBasedTypeSystem typeSystem
	val Map<String, String> opTypes = newHashMap(
		"not" -> BOOLEAN,
		"!" -> BOOLEAN,
		"-" -> NUMBER,
		"+" -> NUMBER
	)

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
	}

	def void generate(WUnaryOperation it) {
		val type = opTypes.get(feature)
		// operand and return types are the same
		newTypeVariable.beSealed(classType(type))
		operand.tvar.beSealed(classType(type))
	}

}
