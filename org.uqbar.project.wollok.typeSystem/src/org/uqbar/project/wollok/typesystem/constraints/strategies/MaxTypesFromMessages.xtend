package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.exceptions.MessageNotUnderstoodException

import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch void analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		if(tvar.sealed || tvar.hasErrors || messages.empty || maximalConcreteTypes !== null) return;

		val maxTypes = tvar.maxTypes
		if(!maxTypes.empty) {
			log.debug('''New max(«maxTypes») type for «tvar.owner.debugInfoInContext»''')

			validMessages.forEach [ message |
				maxTypes.forEach [ type |
					if(!type.respondsTo(message, true))
						message.returnType.handleOffense(new MessageNotUnderstoodException(type, message))
				]
			]

			val newChanges = setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes), tvar)
			changed = changed || newChanges
		}
	}

	/**
	 * To compute max types for a variable, all "globally known" types in the system are checked.
	 * Generic types are instantiated and they are checked only for their fixed types, 
	 * i.e. not the parametric types in their methods. 
	 * 
	 * Normal behavior would be to find types that understand all messages sent to a variable. But, 
	 * in case of an errored program (i.e. one that sends unexistent messages to an object), that could
	 * give an empty type. In this case we should report an error such as "we couldn't find an type for this", 
	 * which is not so useful. This algorithm tries to produce "smarter" error messages.
	 * 
	 * To do so, we take subsets of received messages and try to compute the set of types that understand a maximal 
	 * set of received messages. If such a set of types can be found, it is taken as the maxType of this variable.
	 * Now the errors can be reported when in the message sends, which is likely what the user expects.
	 */
	def maxTypes(TypeVariable tvar) {
		val knownTypes = allTypes.map[instanceFor(tvar)].toList
		val validMessages = tvar.typeInfo.validMessages

		for (var cantMessages = validMessages.size; cantMessages > 0; cantMessages--) {
			val messageSubsets = validMessages.subsetsOfSize(cantMessages)
			val maxTypes = messageSubsets.flatMap [ selectedMessages |
				knownTypes.filter[respondsToAll(selectedMessages, true)]
			].toList
			if(!maxTypes.isEmpty) return maxTypes.toSet
		}

		// TODO Report an error, we couldn't find any max type
		return newArrayList
	}

	def contains(MaximalConcreteTypes maxTypes, Iterable<? extends WollokType> types) {
		(maxTypes !== null && maxTypes.containsAll(types))
	}

	def getAllTypes() {
		registry.typeSystem.allTypes
	}
}
