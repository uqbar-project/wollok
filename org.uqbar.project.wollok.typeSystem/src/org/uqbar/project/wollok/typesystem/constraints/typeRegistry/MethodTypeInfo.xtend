package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.exceptions.MessageNotUnderstoodException
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.findProperty
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod

class MethodTypeProvider {
	val TypeVariablesRegistry registry
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry	
	}
	
	def methodTypeDo(WollokType type, MessageSend it, (MethodTypeInfo) => void actions) {
		val methodType = this.methodType(type, it)
		if (methodType === null) throw new MessageNotUnderstoodException(type, it)
		actions.apply(methodType)
	}
	
	def dispatch methodType(ConcreteType type, MessageSend it) {
		val method = type.lookupMethod(selector, arguments)
		if (method !== null) 
			return new RegularMethodTypeInfo(registry, method)
			
		val property = type.container.findProperty(selector, arguments.size)
		if (property !== null) {
			if (arguments.size == 0) new PropertyGetterTypeInfo(registry, property)
			else new PropertySetterTypeInfo(registry, property)
		} 
		else null	
	}

	def dispatch methodType(WollokType type, MessageSend it) {
		throw new UnsupportedOperationException('''Can't extract methodTypeInfo for methods of «type»''')
	}

	def forClass(WClass container, String selector, List<?> arguments) {
		new RegularMethodTypeInfo(registry, container.lookupMethod(selector, arguments, true))
	}

}

abstract class MethodTypeInfo {
	TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def ITypeVariable returnType()

	def List<ITypeVariable> parameters()
	
	def tvarOrParam(EObject object) {
		registry.tvarOrParam(object)
	}
}

class RegularMethodTypeInfo extends MethodTypeInfo {
	WMethodDeclaration method

	new(TypeVariablesRegistry registry, WMethodDeclaration method) {
		super(registry)
		this.method = method
	}

	override returnType() {
		method.tvarOrParam
	}

	override parameters() {
		method.parameters.map[tvarOrParam]
	}
}

class PropertyGetterTypeInfo extends MethodTypeInfo {
	WVariableDeclaration declaration
	
	new(TypeVariablesRegistry registry, WVariableDeclaration declaration) {
		super(registry)
		this.declaration = declaration
	}
	
	override returnType() {
		declaration.variable.tvarOrParam
	}
	
	override parameters() {
		#[]
	}
	
}

class PropertySetterTypeInfo extends MethodTypeInfo {
	
	WVariableDeclaration declaration
	
	new(TypeVariablesRegistry registry, WVariableDeclaration declaration) {
		super(registry)
		this.declaration = declaration
	}
	
	override returnType() {
		// This is a hack because the declaration is void and the setter also is, but they are different things.
		declaration.tvarOrParam
	}
	
	override parameters() {
		#[declaration.variable.tvarOrParam]
	}
	
}

