package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMixin

/**
 * 
 * Model of a Mixin figure.
 * 
 * Height and width are inherited by AbstractNonClassModel & AbstractModel
 * 
 * @author jfernandes
 * @author dodain - refactored
 * 
 */
@Accessors
class MixinModel extends AbstractNonClassModel {
	
	new(WMixin mixin) {
		super(mixin)
		mixins.add(this)
	}

}