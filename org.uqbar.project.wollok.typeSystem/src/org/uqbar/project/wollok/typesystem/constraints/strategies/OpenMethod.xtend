package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
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

	def dispatch analiseVariable(TypeVariable tvar, ClosureTypeInfo info) {
		log.trace('''Trying to open closure methods for «tvar.debugInfoInContext»''')
		val type = tvar.owner.closureType
		info.validMessages.forEach[openClosureMethod(type, info)]
	}

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
			log.debug('''  Feeding message send «it» with method type info from type «type»''')
			val methodTypeInfo = registry.methodTypes.forType(type, selector, arguments)
			changed = true
			methodTypeInfo.returnType.beSubtypeOf(returnType)
			methodTypeInfo.parameters.biForEach(arguments)[param, arg|param.beSupertypeOf(arg)]
		}
	}

	// ****************************************************************************
	// ** Closure management
	// ** TODO This methods should be deleted in the context of solving
	// ** https://github.com/uqbar-project/wollok/issues/1105
	// ** General management of generic types should be enough for closures.
	// ****************************************************************************

	def openClosureMethod(MessageSend it, WollokType type, ClosureTypeInfo info) {
		if (addOpenType(type)) {
			log.debug('''  Feeding message send «it» with method type info from type «type»''')
			val methodTypeInfo = registry.methodTypes.forType(type, selector, arguments)
			changed = true
			methodTypeInfo.returnType.beSubtypeOf(returnType)
			info.parameters.biForEach(arguments)[param, arg|param.beSupertypeOf(arg)] 
		}
	}
	
	def closureType(EObject context) {
		registry.typeSystem.classType(WollokClassFinder.instance.getClosureClass(context))
	}
}
