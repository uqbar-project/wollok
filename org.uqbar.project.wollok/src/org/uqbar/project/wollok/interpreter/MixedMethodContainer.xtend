package org.uqbar.project.wollok.interpreter

import org.uqbar.project.wollok.wollokDsl.impl.WMethodContainerImpl
import org.uqbar.project.wollok.wollokDsl.WClass
import org.eclipse.emf.common.util.EList
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Represents the synthetic class created due to "instantiation-time mixing".
 * For example when you do:
 * 
 *    new Animal with FourLedged with Hair with Mammal
 * 
 * @author jfernandes
 */
@Accessors
class MixedMethodContainer extends WMethodContainerImpl {
	WClass clazz
	EList<WMixin> mixins
	
	new(WClass clazz, EList<WMixin> mixins) {
		this.clazz = clazz
		this.mixins = mixins
	}
	
	override eResource() {
		clazz.eResource
	}
	
}