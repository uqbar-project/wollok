package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch void analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		if (tvar.sealed) {
			return
		} 
		if (messages.empty) {
			return;
		}
		
		var maxTypes = tvar.maxTypes
		if (!maxTypes.empty && !maximalConcreteTypes.contains(maxTypes)) {
			log.debug('''	New max(«maxTypes») type for «tvar.owner.debugInfoInContext»''')
			val newChanges = setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes), tvar)
			changed = changed || newChanges
		}
	}

	/**
	 * To compute max types for a variable, all "globally known" types in the system are checked.
	 * Generic types are instantiated and they are checked only for their fixed types, 
	 * i.e. not the parametric types in their methods. 
	 */	
	def maxTypes(TypeVariable tvar) {
		allTypes.map[instanceFor(tvar)].filter[respondsToAll(tvar.typeInfo.messages)]
	}

	def contains(MaximalConcreteTypes maxTypes, Iterable<? extends WollokType> types) {
		(maxTypes !== null && maxTypes.containsAll(types))
	}

	def getAllTypes() {
		registry.typeSystem.allTypes
	}
}
