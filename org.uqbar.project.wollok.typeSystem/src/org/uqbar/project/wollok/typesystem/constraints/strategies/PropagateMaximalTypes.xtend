package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)
	
	def dispatch analiseVariable(TypeVariable user, SimpleTypeInfo it) {
		if (maximalConcreteTypes === null) return;
		if (maximalConcreteTypes.state != Pending) return;
		if (user.hasErrors) return;

		// Do propagate		
		propagateMaxTypes(user)
		maximalConcreteTypes.state = Ready
		changed = true
	}

	def void propagateMaxTypes(SimpleTypeInfo it, TypeVariable user) {
		log.debug('''	Analising maxTypes of «user»''')
		user.allSubtypes.forEach [ subtype |
			log.debug(user.fullDescription)
			
			subtype.setMaximalConcreteTypes(maximalConcreteTypes, selectOffenderVariable(subtype, user))
			log.debug('''		Propagating «maximalConcreteTypes» from: «user» to «subtype»''')
		]
	}
}
