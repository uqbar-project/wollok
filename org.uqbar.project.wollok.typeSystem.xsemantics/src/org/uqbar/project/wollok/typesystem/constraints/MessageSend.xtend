package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class MessageSend {
	@Accessors(PUBLIC_GETTER)
	String selector

	@Accessors(PUBLIC_GETTER)
	List<TypeVariable> arguments

	@Accessors(PUBLIC_GETTER)
	TypeVariable returnType
	
	new(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		this.selector = selector
		this.arguments = arguments
		this.returnType = returnType
	}
}

