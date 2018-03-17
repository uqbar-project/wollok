package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch void analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		log.trace('''Variable «tvar.owner.debugInfoInContext»''')
		if (tvar.sealed) {
			log.trace('Variable is sealed => Ignored')
			return
		} 
		if (messages.empty) {
			log.trace('Variable receives no messages => Ignored')
			return;
		}
		
		var maxTypes = allTypes.filter[newMaxTypeFor(tvar)].toList
		log.trace('''maxTypes = «maxTypes»''')
		if (!maxTypes.empty && !maximalConcreteTypes.contains(maxTypes)) {
			log.debug('''	New max(«maxTypes») type for «tvar.debugInfoInContext»''')
			val newChanges = setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes.map[it as WollokType].toSet), tvar)
			changed = changed || newChanges
		}
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
		// TODO: Fix typeSystem.allTypes 
//		tvar.owner
		registry.typeSystem.allTypes
	}
}
