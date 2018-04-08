package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

/**
 * Base class for creating inference strategies that are only meant for GenericTypeInfo variables.
 */
abstract class SimpleTypeInferenceStrategy extends AbstractInferenceStrategy {
	/**
	 * Delegate to the dispatch method that will select the right behavior according to the type info.
	 * If typeInfo is null it means we have no information yet, so just ignore this variable for now.
	 */
	override analiseVariable(TypeVariable tvar) {
		if (tvar.typeInfo !== null) analiseVariable(tvar, tvar.typeInfo)
	}

	def dispatch void analiseVariable(TypeVariable tvar, TypeInfo typeInfo) {
		// This strategy is intended only for variables with a GenericTypeInfo, the rest are ignored.
	}
}
