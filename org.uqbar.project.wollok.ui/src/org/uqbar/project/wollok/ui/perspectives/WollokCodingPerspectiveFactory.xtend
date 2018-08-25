package org.uqbar.project.wollok.ui.perspectives

import org.eclipse.jdt.ui.JavaUI
import org.eclipse.ui.IPageLayout
import org.eclipse.ui.IPerspectiveFactory
import org.eclipse.ui.console.IConsoleConstants
import org.uqbar.project.wollok.ui.wizard.WollokDslNewProjectWizard
import org.uqbar.project.wollok.ui.wizard.objects.NewWollokObjectsWizard
import org.uqbar.project.wollok.ui.wizard.program.NewWollokProgramWizard
import org.uqbar.project.wollok.ui.wizard.tests.NewWollokDescribeWizard
import org.uqbar.project.wollok.ui.wizard.tests.NewWollokTestWizard

/**
 * Wollok coding perspective.
 * Hides away many java menus and stuffs.
 * Then focus on wollok features like wizards, etc.
 * 
 * @author jfernandes
 */
class WollokCodingPerspectiveFactory implements IPerspectiveFactory {
	private IPageLayout factory

	override createInitialLayout(IPageLayout factory) {
		this.factory = factory 
		factory => [
			addViews
			addActionSets
			addNewWizardShortcuts
			addPerspectiveShortcuts
			addViewShortcuts
		]
		
		//I force the opening of the debug perspective. So both are together and usable.
		// FED - commenting it until Wollok Debugger works
		//PlatformUI.workbench.showPerspective("org.eclipse.debug.ui.DebugPerspective", PlatformUI.workbench.activeWorkbenchWindow)
	}
	
	def addViews(IPageLayout it) {
		createFolder("bottomRight",	IPageLayout.BOTTOM, 0.75f, factory.editorArea) => [
			addView(IPageLayout.ID_PROBLEM_VIEW)
			addView(IConsoleConstants.ID_CONSOLE_VIEW)
			addView("org.uqbar.project.wollok.ui.diagrams.class")
			addView("org.eclipse.team.ui.GenericHistoryView")
		]

		createFolder("topLeft", IPageLayout.LEFT, 0.25f, factory.editorArea) => [
			addView(JavaUI.ID_PACKAGES)
			addView("org.uqbar.project.wollok.ui.launch.resultView")
		]
		
		createFolder("topRight", IPageLayout.RIGHT, 0.75f, factory.editorArea) => [
			addView("org.eclipse.ui.views.ContentOutline")
		]
		
		// It has no effect since 4.6 (Eclipse Neon) - we should discuss if we want them
		// visible or not
		// addFastView("org.eclipse.team.ccvs.ui.RepositoriesView", 0.50f)
		// addFastView("org.eclipse.team.sync.views.SynchronizeView", 0.50f)
	}

	def addActionSets(IPageLayout it) {
		#[	
			"org.eclipse.debug.ui.launchActionSet",
			"org.eclipse.team.ui.actionSet",
			IPageLayout.ID_NAVIGATE_ACTION_SET,
			"org.eclipse.jdt.ui.actions.Rename",
			"org.eclipse.jdt.ui.actions.Move",
			"org.eclipse.jdt.ui.actions.ExtractMethod"
		]
		.forEach[ a| addActionSet(a) ]
	}
	
	def addPerspectiveShortcuts(IPageLayout it) {
		#[
			"org.eclipse.team.ui.TeamSynchronizingPerspective"
		]
		.forEach[a| addPerspectiveShortcut(a) ]
	}	
	
	def addNewWizardShortcuts(IPageLayout it) {
		#[
			// WOLLOK
			WollokDslNewProjectWizard.ID,
			
			// OTHERs
			"org.eclipse.ui.wizards.new.folder",
			"org.eclipse.ui.wizards.new.file",
			NewWollokObjectsWizard.ID,
			NewWollokTestWizard.ID,
			NewWollokDescribeWizard.ID,
			NewWollokProgramWizard.ID
		]
		.forEach[ a| addNewWizardShortcut(a) ]
	}
	
	def addViewShortcuts(IPageLayout it) {
		#[
			"org.eclipse.team.ccvs.ui.AnnotateView",
			"org.eclipse.jdt.junit.ResultView",
			"org.eclipse.team.ui.GenericHistoryView",
			JavaUI.ID_PACKAGES,
			IPageLayout.ID_RES_NAV,
			IPageLayout.ID_PROBLEM_VIEW,
			IPageLayout.ID_OUTLINE
		]
		.forEach[a| addShowViewShortcut(a) ]
	}
	
}