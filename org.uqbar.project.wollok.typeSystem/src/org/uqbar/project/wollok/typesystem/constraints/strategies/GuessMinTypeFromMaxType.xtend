package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class GuessMinTypeFromMaxType extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		if (minTypes.isEmpty && maximalConcreteTypes != null) {
			println('''	About to guess min types for «tvar.owner.debugInfo»''')
			maximalConcreteTypes.forEach[ type |
				val state = addMinType(type) 
				println('''		Added min type «type»''')
				if (state == Pending) changed = true
			]
			
		}
	}
	
}
