package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import java.util.Map
import java.util.function.BiConsumer
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget
import org.uqbar.project.wollok.typesystem.declarations.WollokCoreTypeDeclarations
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.typesystem.declarations.TypeDeclarations.addTypeDeclarations

class OpenMethod extends AbstractInferenceStrategy implements TypeDeclarationTarget {
	Map<String, Map<String, AnnotatedMethodTypeInfo>> methodTypeInfo = newHashMap
	
	new() {
		addTypeDeclarations(WollokCoreTypeDeclarations)
	}

	override addTypeDeclaration(String typeName, String selector, List<String> paramTypeNames, String returnTypeName) {
		var info = methodTypeInfo.get(typeName)
		if (info == null) methodTypeInfo.put(typeName, info = newHashMap)
		info.put(selector, new AnnotatedMethodTypeInfo(paramTypeNames, returnTypeName))
	}

	override analiseVariable(TypeVariable it) {
		it.typeInfo.messages.forEach [ message |
			minimalConcreteTypes.keySet.forEach [ minType |
				message.openMethod(minType)
			]
		]
	}

	def openMethod(MessageSend it, WollokType type) {
		if (addOpenType(type)) {
			val methodTypeInfo = type.methodTypeInfo(selector, arguments)
			println('''	Feeding message send «it» with method type info from type «type»''')
			changed = true
			returnType.beSupertypeOf(methodTypeInfo.returnType(registry))
			arguments.biForEach(methodTypeInfo.parameters(registry))[arg, param|arg.beSubtypeOf(param)]
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

	def dispatch methodTypeInfo(WollokType type, String selector, List<TypeVariable> arguments) {
		throw new UnsupportedOperationException("TODO: generate MethodTypeInfo for non concrete types")
	}

	def dispatch methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		methodTypeInfo.get(type.name)?.get(selector) ?: new MethodTypeInfoImpl(type.lookupMethod(selector, arguments))
	}
}

interface MethodTypeInfo {
	def TypeVariable returnType(TypeVariablesRegistry registry)

	def List<TypeVariable> parameters(TypeVariablesRegistry registry)
}

class AnnotatedMethodTypeInfo implements MethodTypeInfo {
	String returnType
	String[] parameterTypes

	new(List<String> parameterTypes, String returnType) {
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}

	override returnType(TypeVariablesRegistry registry) {
		registry.newSyntheticVar(returnType)
	}

	override parameters(TypeVariablesRegistry registry) {
		parameterTypes.map[registry.newSyntheticVar(it)]
	}
}

class MethodTypeInfoImpl implements MethodTypeInfo {
	WMethodDeclaration method

	new(WMethodDeclaration method) {
		this.method = method
	}

	override returnType(TypeVariablesRegistry registry) {
		registry.tvar(method)
	}

	override parameters(TypeVariablesRegistry registry) {
		method.parameters.map[registry.tvar(it)]
	}
}
