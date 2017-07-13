package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*

class GuessMinTypeFromMaxType extends SimpleTypeInferenceStrategy {
	
	val Logger log = Logger.getLogger(this.class)
	
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		if (minTypes.isEmpty && maximalConcreteTypes !== null) {
			log.debug('''	About to guess min types for «tvar.owner.debugInfo»''')
			maximalConcreteTypes.forEach[ type |
				val state = addMinType(type) 
				log.debug('''		Added min type «type»''')
				if (state == Pending) changed = true
			]
			
		}
	}
	
}
