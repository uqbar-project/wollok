package org.uqbar.project.wollok.ui.wizard

import org.uqbar.project.wollok.WollokConstants

/**
 * Sets-up the new project with:
 * - dependency to wollok.launch plugin
 * 
 * @author jfernandes
 */
class WollokProjectCreator extends AbstractWollokProjectCreator {
	
	override protected getRequiredBundles() {
		super.requiredBundles => [
			add(org.uqbar.project.wollok.ui.wizard.AbstractWollokProjectCreator.DSL_GENERATOR_PROJECT_NAME + ".launch")
			add(org.uqbar.project.wollok.ui.wizard.AbstractWollokProjectCreator.DSL_GENERATOR_PROJECT_NAME + ".lib")
			add("org.eclipse.xtext.ui")
		]
	}
	
	override protected getProjectNatures() {
		newArrayList(super.projectNatures) => [
			add(WollokConstants.NATURE_ID)
		]
	}
}