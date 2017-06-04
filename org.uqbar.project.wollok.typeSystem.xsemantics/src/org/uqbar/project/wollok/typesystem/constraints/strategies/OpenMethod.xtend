package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import java.util.function.BiConsumer
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.eclipse.emf.ecore.EObject

class OpenMethod extends AbstractInferenceStrategy {
	val methodTypeInfo = newHashMap(
		"Integer" -> newHashMap(
			 "+" -> new AnnotatedMethodTypeInfo(INTEGER, INTEGER)
			,"-" -> new AnnotatedMethodTypeInfo(INTEGER, INTEGER)
			,"*" -> new AnnotatedMethodTypeInfo(INTEGER, INTEGER)
		)
	)

	override analiseVariable(TypeVariable it) {
		it.typeInfo.messages.forEach [ message |
			minimalConcreteTypes.keySet.forEach [ minType |
				message.openMethod(minType, owner)
			]
		]
	}

	def openMethod(MessageSend it, WollokType type, EObject owner) {
		val methodTypeInfo = type.methodTypeInfo(selector, arguments)

		returnType.beSupertypeOf(methodTypeInfo.tvar(registry, owner))
		arguments.biForEach(methodTypeInfo.parametersTvar(registry, owner))[arg, param|arg.beSubtypeOf(param)]
		arguments.forEach[println(it.fullDescription)]
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

	def dispatch methodTypeInfo(WollokType type, String selector, List<TypeVariable> arguments) {
		throw new UnsupportedOperationException("TODO: generate MethodTypeInfo for non concrete types")
	}

	def dispatch methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		var methodtypeInfo = methodTypeInfo.get(type.name)?.get(selector)
		if(methodtypeInfo != null) return methodtypeInfo

		val method = type.lookupMethod(selector, arguments)
		new MethodTypeInfoImpl(method)
	}
}

interface MethodTypeInfo {
	def TypeVariable tvar(TypeVariablesRegistry registry, EObject owner)

	def List<TypeVariable> parametersTvar(TypeVariablesRegistry registry, EObject owner)

}

class AnnotatedMethodTypeInfo implements MethodTypeInfo {
	String returnType
	String[] parameterTypes

	new(String returnType, String... parameterTypes) {
		this.returnType = returnType
		this.parameterTypes = parameterTypes
	}

	override tvar(TypeVariablesRegistry registry, EObject owner) {
		registry.newSyntheticVar(returnType, owner)
	}

	override parametersTvar(TypeVariablesRegistry registry, EObject owner) {
		parameterTypes.map[registry.newSyntheticVar(it, owner)] // TODO: Este owner es una mentira
	}

}

class MethodTypeInfoImpl implements MethodTypeInfo {
	WMethodDeclaration method

	new(WMethodDeclaration method) {
		this.method = method
	}

	override tvar(TypeVariablesRegistry registry, EObject owner) {
		registry.tvar(method)
	}

	override parametersTvar(TypeVariablesRegistry registry, EObject owner) {
		method.parameters.map[registry.tvar(it)]
	}
}
