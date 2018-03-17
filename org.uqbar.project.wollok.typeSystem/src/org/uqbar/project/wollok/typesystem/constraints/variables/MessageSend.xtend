package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

class MessageSend {
	@Accessors(PUBLIC_GETTER)
	String selector

	@Accessors(PUBLIC_GETTER)
	List<TypeVariable> arguments

	@Accessors(PUBLIC_GETTER)
	TypeVariable returnType

	Set<WollokType> openTypes = newHashSet

	new(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		this.selector = selector
		this.arguments = arguments
		this.returnType = returnType
	}

	/**
	 * @param type The wollok type which has been recognized as a minimal type for the receiver of this message send, 
	 * 			   and for which we are adding method type information onto this message send.
	 * @return true if the type received is new (not previously added).
	 */
	def addOpenType(WollokType type) {
		openTypes.add(type)
	}
	
	def fullMessage() {
		(returnType.owner as WMemberFeatureCall).fullMessage
	}
	
	def argumentNames() {
		(returnType.owner as WMemberFeatureCall).memberCallArguments.map[sourceCode]
	}

	override toString() { returnType.owner.debugInfo }
}
