package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import java.util.List

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {

	private Iterable<ClassBasedWollokType> allTypes = newArrayList()
	
	override analiseSimpleType(TypeVariable tvar, SimpleTypeInfo it) {
		var maxTypes = allTypes(tvar).filter[newMaxTypeFor(tvar)].toList
		if (!tvar.sealed && !maxTypes.empty && !maximalConcreteTypes.contains(maxTypes) && tvar.subtypes.empty) { // Last condition is because some test fail, but I don't know if it's OK
			println('''New max(«maxTypes») type for «tvar»''')
			maximalConcreteTypes = new MaximalConcreteTypes(maxTypes.map[it as WollokType].toSet)
			changed = true
		}
	}
	
	def contains(MaximalConcreteTypes maxTypes, List<ClassBasedWollokType> types) {
		maxTypes != null && maxTypes.maximalConcreteTypes.containsAll(types)
	}

	def newMaxTypeFor(ClassBasedWollokType type, TypeVariable it) {
		!typeInfo.messages.empty && typeInfo.messages.forall[acceptMessage(type)]
	}

	def acceptMessage(MessageSend message, ClassBasedWollokType it) {
		// TODO: query by name only, maybe we need match by parameters too.
		it.container.allMethods.map[name].toList.contains(message.selector)
	}

	def allTypes(TypeVariable tvar) {
		var types = registry.typeSystem.allTypes(tvar.owner)
		if (types.size > allTypes.size) allTypes = types // TODO: Fix typeSystem.allTypes 
		allTypes
	}
}
