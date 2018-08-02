package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.uqbar.project.wollok.typesystem.ClosureType
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.exceptions.MessageNotUnderstoodException
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

class MethodTypeProvider {
	val TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def methodTypeDo(WollokType type, MessageSend it, (MethodTypeInfo)=>void actions) {
		val methodType = this.methodType(type, it)
		if(methodType === null) throw new MessageNotUnderstoodException(type, it)
		actions.apply(methodType)
	}

	def dispatch MethodTypeInfo methodType(ConcreteType type, MessageSend it) {
		// TODO Avoid this hard-coded decision and hack
		if (selector == "apply" && type instanceof GenericTypeInstance &&
			(type as GenericTypeInstance).rawType instanceof ClosureType) {
			return new ClosureApplyTypeInfo(registry, type as GenericTypeInstance)
		}

		type.lookupSchema(it)?.instanceFor(type)
	}
	
	def dispatch methodType(WollokType type, MessageSend it) {
		throw new UnsupportedOperationException('''Can't extract MethodTypeSchema for methods of «type»''')
	}

	def lookupSchema(ConcreteType type, MessageSend it) {
		val method = type.lookupMethod(selector, arguments)
		if (method !== null)
			return new RegularMethodTypeSchema(registry, method)

		val property = type.container.findProperty(selector, arguments.size)
		if (property !== null) {
			if(arguments.size == 0) new PropertyGetterTypeInfo(registry, property) else new PropertySetterTypeInfo(
				registry, property)
		} else
			null
	}

	def methodTypeSchema(WClass container, String selector, List<?> arguments) {
		new RegularMethodTypeSchema(registry, container.lookupMethod(selector, arguments, true))
	}
}
