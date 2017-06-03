package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import java.util.function.BiConsumer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry

class OpenMethod extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable it) {
		it.typeInfo.messages.forEach[message|
			minimalConcreteTypes.keySet.forEach[minType|
				message.openMethod(minType)
			]
		]
	}
	
	def openMethod(MessageSend it, WollokType type) {
		val methodTypeInfo = type.methodTypeInfo(selector, arguments)
		
		returnType.beSupertypeOf(methodTypeInfo.tvar(registry))
		arguments.biForEach(methodTypeInfo.parametersTvar(registry))[arg, param|arg.beSubtypeOf(param)]
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
	
	
	def dispatch MethodTypeInfoImpl methodTypeInfo(WollokType type, String selector, List<TypeVariable> arguments) {
		throw new UnsupportedOperationException("TODO: generate MethodTypeInfo for non concrete types")
	}
	
	def dispatch MethodTypeInfoImpl methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		val method = type.lookupMethod(selector, arguments)
		new MethodTypeInfoImpl(method)
	}
}

interface MethodTypeInfo {
	def TypeVariable tvar(TypeVariablesRegistry registry)
	
	def List<TypeVariable> parametersTvar(TypeVariablesRegistry registry)
	
}

class MethodTypeInfoImpl implements MethodTypeInfo {
	WMethodDeclaration method
	
	new(WMethodDeclaration method) {
		this.method = method
	}
	
	override tvar(TypeVariablesRegistry registry) {
		registry.tvar(method)
	}
	
	override parametersTvar(TypeVariablesRegistry registry) {
		method.parameters.map[registry.tvar(it)]
	}
}