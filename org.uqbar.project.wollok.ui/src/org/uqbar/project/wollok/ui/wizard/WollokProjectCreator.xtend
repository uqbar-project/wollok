package org.uqbar.project.wollok.ui.wizard

import org.uqbar.project.wollok.WollokConstants

/**
 * Sets-up the new project with:
 * - dependency to wollok.launch plugin
 * - dependency to xsemantics
 * 
 * @author jfernandes
 */
class WollokProjectCreator extends WollokDslProjectCreator {
	
	override protected getRequiredBundles() {
		super.requiredBundles => [
			add(DSL_GENERATOR_PROJECT_NAME + ".launch")
			add(DSL_GENERATOR_PROJECT_NAME + ".lib")
			add("it.xsemantics.runtime")
			add("org.eclipse.xtext.ui")
		]
	}
	
	override protected getProjectNatures() {
		newArrayList(super.projectNatures) => [
			add(WollokConstants.NATURE_ID)
		]
	}
	
}