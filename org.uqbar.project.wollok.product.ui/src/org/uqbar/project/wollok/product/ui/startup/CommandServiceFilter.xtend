package org.uqbar.project.wollok.product.ui.startup

import org.eclipse.ui.commands.ICommandService
import org.eclipse.core.commands.IExecutionListener
import org.eclipse.core.commands.common.NotDefinedException
import org.eclipse.core.commands.SerializationException
import org.eclipse.core.commands.Command
import java.util.Map
import org.eclipse.ui.commands.IElementReference
import org.eclipse.core.commands.ParameterizedCommand
import org.eclipse.ui.menus.UIElement
import org.eclipse.core.commands.IHandler

class CommandServiceFilter implements ICommandService {
	
	ICommandService decorated
	String[] filters
	
	new (ICommandService decorated, String[] filters) {
		this.decorated = decorated
		this.filters = filters
	} 
	
	override addExecutionListener(IExecutionListener listener) {
		 decorated.addExecutionListener(listener)
	}
	
	override defineUncategorizedCategory(String name, String description) {
		decorated.defineUncategorizedCategory(name, description)
	}
	
	override deserialize(String serializedParameterizedCommand) throws NotDefinedException, SerializationException {
		decorated.deserialize(serializedParameterizedCommand)
	}
	
	override getCategory(String categoryId) {
		decorated.getCategory(categoryId)
	}
	
	override getCommand(String commandId) {
		decorated.getCommand(commandId)
	}
	
	override getDefinedCategories() {
		decorated.definedCategories
	}
	
	override getDefinedCategoryIds() {
		decorated.definedCategoryIds
	}
	
	override getDefinedCommandIds() {
		decorated.definedCommandIds
	}
	
	override getDefinedCommands() {
		decorated.definedCommands
	}
	
	override getDefinedParameterTypeIds() {
		decorated.definedParameterTypeIds
	}
	
	override getDefinedParameterTypes() {
		decorated.definedParameterTypes
	}
	
	override getHelpContextId(Command command) throws NotDefinedException {
		decorated.getHelpContextId(command)
	}
	
	override getHelpContextId(String commandId) throws NotDefinedException {
		decorated.getHelpContextId(commandId)
	}
	
	override getParameterType(String parameterTypeId) {
		decorated.getParameterType(parameterTypeId)
	}
	
	override readRegistry() {
		decorated.readRegistry()
	}
	
	override refreshElements(String commandId, Map filter) {
		decorated.refreshElements(commandId, filter)
	}
	
	override registerElement(IElementReference elementReference) {
		decorated.registerElement(elementReference)
	}
	
	override registerElementForCommand(ParameterizedCommand command, UIElement element) throws NotDefinedException {
		decorated.registerElementForCommand(command, element)
	}
	
	override removeExecutionListener(IExecutionListener listener) {
		decorated.removeExecutionListener(listener)
	}
	
	override setHelpContextId(IHandler handler, String helpContextId) {
		decorated.setHelpContextId(handler, helpContextId)
	}
	
	override unregisterElement(IElementReference elementReference) {
		decorated.unregisterElement( elementReference)
	}
	
	override dispose() {
		decorated.dispose()
	}
	
}