package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

/**
 * This strategy takes a message send for which receiver we know a possible concrete type (i.e. a Wollok Class) 
 * Then look up for the concrete method in that class and use the type information of that method.
 */
class OpenMethod extends SimpleTypeInferenceStrategy {
	override analiseSimpleType(TypeVariable user, SimpleTypeInfo it) {
		messages.forEach [ message |
			minimalConcreteTypes.keySet.forEach [ minType |
				message.openMethod(minType)
			]
		]
	}

	def openMethod(MessageSend it, WollokType type) {
		if (addOpenType(type)) {
			val methodTypeInfo = registry.methodTypeInfo(type as ConcreteType, selector, arguments)
			println('''	Feeding message send «it» with method type info from type «type»''')
			changed = true
			returnType.beSupertypeOf(methodTypeInfo.returnType)
			arguments.biForEach(methodTypeInfo.parameters)[arg, param|arg.beSubtypeOf(param)]
		}
	}
}
