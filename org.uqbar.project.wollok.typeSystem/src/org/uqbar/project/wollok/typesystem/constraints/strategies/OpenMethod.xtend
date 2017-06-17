package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class OpenMethod extends AbstractInferenceStrategy {
	
	override analiseVariable(TypeVariable it) {
		it.typeInfo.messages.forEach [ message |
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
