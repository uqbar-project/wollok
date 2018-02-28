package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * This strategy takes a message send for which receiver we know a possible concrete type (i.e. a Wollok Class) 
 * Then look up for the concrete method in that class and use the type information of that method.
 */
class OpenMethod extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable tvar, ClosureTypeInfo it) {
		log.trace('''Trying to open closure methods for «tvar.debugInfoInContext»''')
		val type = WollokClassFinder.instance.getClosureClass(tvar.owner)
		messages.forEach[openClosureMethod(type)]
	}

	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		log.trace('''Trying to open methods for «tvar.debugInfoInContext»''')
		messages.forEach [ message |
			minTypes.entrySet.forEach [
				if(value != Error) message.openMethod(key)
			]
		]
	}

	def openMethod(MessageSend it, WollokType type) {
		if (addOpenType(type)) {
			log.debug('''  Feeding message send «it» with method type info from type «type»''')
			val methodTypeInfo = registry.methodTypeInfo(type as ConcreteType, selector, arguments)
			changed = true
			methodTypeInfo.returnType.beSubtypeOf(returnType)
			methodTypeInfo.parameters.biForEach(arguments)[param, arg|param.beSupertypeOf(arg)]
		} else {
			log.trace('''  Skip message «it», already been fed with method type info from type «type»''')
		}
	}

	def openClosureMethod(MessageSend it, WClass type) {
		if (addOpenType(registry.typeSystem.classType(type))) {
			log.debug('''  Feeding message send «it» with method type info from type «type»''')
			val methodTypeInfo = registry.methodTypeInfo(type, selector, arguments)
			changed = true
			methodTypeInfo.returnType.beSubtypeOf(returnType)
//			methodTypeInfo.parameters.biForEach(arguments)[param, arg|param.beSupertypeOf(arg)] //TODO: params method arguments 
		} else {
			log.trace('''  Skip message «it», already been fed with method type info from type «type»''')
		}
	}
}
