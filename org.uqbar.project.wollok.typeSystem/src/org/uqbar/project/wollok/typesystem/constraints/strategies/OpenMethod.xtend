package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

/**
 * This strategy takes a message send for which receiver we know a possible concrete type (i.e. a Wollok Class) 
 * Then look up for the concrete method in that class and use the type information of that method.
 */
class OpenMethod extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo it) {
		log.trace('''Trying to open methods for «tvar.debugInfoInContext»''')
		validMessages.forEach [ message |
			minTypes.entrySet.forEach [
				if(value != Error) message.openMethod(key)
			]
		]
	}

	def openMethod(MessageSend it, WollokType type) {
		if (addOpenType(type)) {
			log.debug('''Feeding message send «it» with method type info from type «type»''')

			registry.methodTypes.methodTypeDo(type, it) [ methodType |
				changed = true
				methodType.returnType.beSubtypeOf(returnType)
				methodType.parameters.biForEach(arguments)[param, arg|param.beSupertypeOf(arg)]				
			]
		}
	}

	def closureType(EObject context) {
		registry.typeSystem.classType(WollokClassFinder.instance.getClosureClass(context))
	}
}
