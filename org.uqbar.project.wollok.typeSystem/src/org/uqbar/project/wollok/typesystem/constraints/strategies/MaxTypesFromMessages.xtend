package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {
	private Iterable<AbstractContainerWollokType> allTypes = newArrayList()

	val Logger log = Logger.getLogger(this.class)

	def dispatch void analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		var maxTypes = allTypes(tvar).filter[newMaxTypeFor(tvar)].toList
		if (!tvar.sealed && 
			!maxTypes.empty && 
			!maximalConcreteTypes.contains(maxTypes)
		) {
			log.debug('''	New max(«maxTypes») type for «tvar»''')
			setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes.map[it as WollokType].toSet), tvar)
			changed = true
		}
	}

	def contains(MaximalConcreteTypes maxTypes, List<? extends WollokType> types) {
		maxTypes !== null && maxTypes.containsAll(types)
	}

	def newMaxTypeFor(AbstractContainerWollokType type, TypeVariable it) {
		!typeInfo.messages.empty && typeInfo.messages.forall[type.respondsTo(it)]
	}

	def allTypes(TypeVariable tvar) {
		var types = registry.typeSystem.allTypes(tvar.owner)
		if(types.size > allTypes.size) allTypes = types // TODO: Fix typeSystem.allTypes 
		allTypes
	}
}
