package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.function.BiConsumer
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable

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
			val methodTypeInfo = registry.methodTypeInfo(type, selector, arguments)
			println('''	Feeding message send «it» with method type info from type «type»''')
			changed = true
			returnType.beSupertypeOf(methodTypeInfo.returnType)
			arguments.biForEach(methodTypeInfo.parameters)[arg, param|arg.beSubtypeOf(param)]
		}
	}

	def <T, U> biForEach(Iterable<T> it1, Iterable<U> it2, BiConsumer<T, U> function) {
		val iter1 = it1.iterator()
		val iter2 = it2.iterator()

		while (iter1.hasNext() && iter2.hasNext()) {
			function.accept(iter1.next(), iter2.next())
		}

		if (iter1.hasNext() || iter2.hasNext()) {
			throw new TypeSystemException(
				"Method has different argument count than message sent... this should not happen and is most probably a bug in the type system.")
		}
	}
}
