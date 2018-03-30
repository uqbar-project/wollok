package org.uqbar.project.wollok.typesystem

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * @author npasserini
 */
	@Accessors
class GenericType extends ClassBasedWollokType {
	String[] typeParameterNames
	
	new(WClass clazz, TypeSystem typeSystem, String... typeParameterNames) {
		super(clazz, typeSystem)
		this.typeParameterNames = typeParameterNames
	}
	
}