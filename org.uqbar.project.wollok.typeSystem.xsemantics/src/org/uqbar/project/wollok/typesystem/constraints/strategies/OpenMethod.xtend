package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import java.util.function.BiConsumer
import org.uqbar.project.wollok.typesystem.TypeSystemException

class OpenMethod extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable it) {
		it.typeInfo.messages.forEach[message|
			minimalConcreteTypes.keySet.forEach[minType|
				message.openMethod(minType)
			]
		]
	}
	
	def openMethod(MessageSend it, WollokType type) {
		val method = (type as ConcreteType).lookupMethod(selector, arguments)
		
		returnType.beSupertypeOf(method.tvar)
		arguments.biForEach(method.parameters.map[tvar])[arg, param|arg.beSubtypeOf(param)]
	}
	
	def <T,U> biForEach(Iterable<T> it1, Iterable<U> it2, BiConsumer<T,U> function) {
		val iter1 = it1.iterator()
		val iter2 = it2.iterator()

		while(iter1.hasNext() && iter2.hasNext()) {
			function.accept(iter1.next(), iter2.next())
		}
		
		if (iter1.hasNext() || iter2.hasNext()) {
			throw new TypeSystemException("Method has different argument count than message sent... this should not happen and is most probably a bug in the type system.")
		}
	}
}