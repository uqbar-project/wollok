package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.uqbar.project.wollok.wollokDsl.WMixin
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
@Accessors
class MixinModel extends Shape {
	WMixin mixin
	
	new(WMixin mixin) {
		this.mixin = mixin
	}

	override toString() {
		"Mixin<" + mixin.name + ">"		
	}
}