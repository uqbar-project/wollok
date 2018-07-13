package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch void analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		log.trace('''Variable «tvar.owner.debugInfoInContext»''')
		if (tvar.sealed) {
			log.trace('Variable is sealed => Ignored')
			return
		} 
		if (messages.empty) {
			log.trace('Variable receives no messages => Ignored')
			return;
		}
		
		var maxTypes = tvar.maxTypes
		log.trace('''maxTypes = «maxTypes»''')
		if (!maxTypes.empty && !maximalConcreteTypes.contains(maxTypes)) {
			log.debug('''	New max(«maxTypes») type for «tvar.debugInfoInContext»''')
			val newChanges = setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes.map[TypeVariable.instance(it)].toSet), tvar)
			changed = changed || newChanges
		}
	}
	
	def maxTypes(TypeVariable tvar) {
		allTypes.filter[newMaxTypeFor(tvar)].toList
	}

	def contains(MaximalConcreteTypes maxTypes, List<? extends WollokType> types) {
		(maxTypes !== null && maxTypes.containsAll(types))
	}

	def newMaxTypeFor(AbstractContainerWollokType type, TypeVariable it) {
		typeInfo.messages.forall[type.respondsTo(it) => [result |
			log.trace('''  «type» «if (result) "responds" else "does not respond"» to «it»''')
		]]
	}

	def getAllTypes() {
		registry.typeSystem.allTypes
	}
}
