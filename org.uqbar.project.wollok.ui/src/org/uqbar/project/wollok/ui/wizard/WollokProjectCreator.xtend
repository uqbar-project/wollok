package org.uqbar.project.wollok.ui.wizard

import org.uqbar.project.wollok.WollokConstants

/**
 * Sets-up the new project with:
 * - dependency to wollok.launch plugin
 * 
 * @author jfernandes
 */
class WollokProjectCreator extends AbstractWollokProjectCreator {
	public static val ITEMIS = "de.itemis.xtext.antlr"
	public static val MWE2 = "org.eclipse.emf.mwe2.launch"
	
	override protected getRequiredBundles() {
		(super.requiredBundles => [
			add(org.uqbar.project.wollok.ui.wizard.AbstractWollokProjectCreator.DSL_GENERATOR_PROJECT_NAME + ".launch")
			add(org.uqbar.project.wollok.ui.wizard.AbstractWollokProjectCreator.DSL_GENERATOR_PROJECT_NAME + ".lib")
			add("org.eclipse.xtext.ui")
		]).filter [
			!startsWith(ITEMIS) && !startsWith(MWE2)
		].toList
	}
	
	override protected getProjectNatures() {
		newArrayList(super.projectNatures) => [
			add(WollokConstants.NATURE_ID)
		]
	}
}