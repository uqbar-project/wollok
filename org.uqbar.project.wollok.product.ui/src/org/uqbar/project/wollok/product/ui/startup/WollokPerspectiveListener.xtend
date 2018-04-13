package org.uqbar.project.wollok.product.ui.startup

import org.eclipse.jface.action.GroupMarker
import org.eclipse.jface.action.IContributionItem
import org.eclipse.jface.action.MenuManager
import org.eclipse.jface.action.Separator
import org.eclipse.ui.IPerspectiveDescriptor
import org.eclipse.ui.IPerspectiveListener
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.internal.ActionSetContributionItem
import org.eclipse.ui.internal.Workbench
import org.eclipse.ui.internal.WorkbenchWindow
import org.eclipse.ui.internal.ide.actions.BuildSetMenu

class WollokPerspectiveListener implements IPerspectiveListener {
	
	override perspectiveActivated(IWorkbenchPage arg0, IPerspectiveDescriptor perspective) {
		println("Activation " + perspective.id)
		removeUnwantedActions
	}
	
	override perspectiveChanged(IWorkbenchPage arg0, IPerspectiveDescriptor arg1, String arg2) {
		println("Changed " + arg1.id + " " + arg2)
		removeUnwantedActions
	}
	
	def void removeUnwantedActions() {
		val window = Workbench.getInstance().getActiveWorkbenchWindow() as WorkbenchWindow
		val menuManager = window.menuManager
		menuManager.visit
	}

	def dispatch void visit(MenuManager manager) {
		manager.items.forEach [ visit ]
	}
	
	static val unwantedContributionItems = {
		#[
		// Navigate
		"org.eclipse.ant.ui.openExternalDoc", 
		"org.eclipse.mylyn.tasks.ui.command.goToPreviousUnread",
		"org.eclipse.mylyn.tasks.ui.command.goToNextUnread", 
		"org.eclipse.xtext.ui.shared.OpenXtextElementCommand",
		"org.eclipse.xtext.xbase.ui.OpenImplementationCommand",
		"org.eclipse.pde.ui.openPluginArtifactSeparator",
		"org.eclipse.pde.ui.openPluginArtifact",
		// Help 
		"helpContents", 
		"helpSearch", 
		"dynamicHelp", 
		"tipsAndTricks",
		"org.eclipse.debug.ui.actions.BreakpointTypesContribution",
		// Project Properties
		"projectProperties",
		// Navigate - Open Attached Javadoc and Source files
		"org.eclipse.xtext.ui.shared.OpenSourceFileCommand"
		].map [ toLowerCase ]
	}
	
	def dispatch void visit(IContributionItem it) {
		println("IContribution: [" + id + "] class [" + class + "]")
		if (id !== null && unwantedContributionItems.contains(id.toLowerCase)) {
			visible = false
			update
			println("   it.visible " + visible)
		}
	}
	
	def dispatch void visit(Separator it) {
		println("IContribution: [" + id + "] class [" + class + "]")
		if (id !== null && (id.equalsIgnoreCase("run") || id.equalsIgnoreCase("debug"))) {
			visible = false
			update
			println("   it.visible " + visible)
		}
	}
	
	static val unwantedActionSets = {
		#[
		// Project - hidden items
		"org.eclipse.team.ui.ApplyPatchAction",  
		"org.eclipse.jdt.ui.JavaActionSet",
		"exportJavadoc",
		"org.eclipse.ui.cheatsheets.actions.CheatSheetHelpMenuAction",
		// Navigate - Java hidden items
		"org.eclipse.jdt.ui.actions.OpenExternalJavaDoc",
		"org.eclipse.jdt.ui.actions.OpenTypeHierarchy",
		"org.eclipse.jdt.ui.actions.OpenImplementation",
		"org.eclipse.jdt.ui.actions.OpenSuperImplementation",
		"openType",
		"openTypeInHierarchy",
		"org.eclipse.jdt.ui.actions.OpenCallHierarchy",
		// DEBUG - we should remove them when Wollok debugger is up again
		"org.eclipse.debug.ui.actions.DebugLast",
		"org.eclipse.debug.internal.ui.actions.DebugHistoryMenuAction",
		"org.eclipse.debug.internal.ui.actions.DebugWithConfigurationAction",
		"org.eclipse.debug.ui.actions.OpenDebugConfigurations",
		"org.eclipse.debug.ui.actions.ToggleBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleLineBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleMethodBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleWatchpoint",
		"org.eclipse.debug.ui.actions.SkipAllBreakpoints",
		"org.eclipse.debug.ui.actions.RemoveAllBreakpoints",
		"org.eclipse.jdt.debug.ui.actions.AddExceptionBreakpoint",
		"org.eclipse.jdt.debug.ui.actions.AddClassPrepareBreakpoint",
		"jdtGroup",
		"ExternalToolsGroup",
		"org.eclipse.jdt.debug.ui.actions.AllReferences",
		"org.eclipse.jdt.debug.ui.actions.AllInstances",
		"org.eclipse.jdt.debug.ui.actions.InstanceCount",
		"org.eclipse.jdt.debug.ui.Watch",
		"org.eclipse.jdt.debug.ui.actions.Inspect",
		"org.eclipse.jdt.debug.ui.actions.Display",
		"org.eclipse.jdt.debug.ui.actions.Execute",
		"org.eclipse.jdt.debug.ui.actions.ForceReturn",
		// Run external tools - if you want to allow you have to remove these lines 
		"ExternalToolsGroup",
		"org.eclipse.ui.externaltools.ExternalToolMenuDelegateMenu",
		// Source (Java) menu item
		"org.eclipse.jdt.ui.source.menu",
		// Mylyn Tasks
		"org.eclipse.mylyn.tasks.ui.openTask",
		"org.eclipse.mylyn.tasks.ui.switchTask",
		"org.eclipse.mylyn.tasks.ui.deactivateAllTasks"
		].map [ toLowerCase ]	
	}
	
	def dispatch void visit(BuildSetMenu it) {
		visible = false
	}
	
	def dispatch void visit(ActionSetContributionItem it) {
		println("ActionSetContributionItem: [" + id + "] actionSetId [" + actionSetId + "]")
		if (id !== null && shouldHideActionSet) {
			visible = false
			update
			println("   it.visible " + visible)
			println("   inner item " + innerItem)
			if (innerItem !== null) {
				innerItem.visible = false
			}
		}
	}
	
	def unwantedNullActionSets() {
		#["org.eclipse.ui.NavigateActionSet"]
	}
	
	def shouldHideActionSet(ActionSetContributionItem it) {
		unwantedActionSets.contains(id.toLowerCase) || (id.equals("") && unwantedNullActionSets.contains(actionSetId))
	}
	
	static val unwantedGroupMarkers = {
		#["build.ext", "additions", "group.tutorials", "group.tools", "group.main.ext"].map [ toLowerCase ]
	}

	def dispatch void visit(GroupMarker it) {
		println("GroupMarker: [" + id + "]")
		if (id !== null && unwantedGroupMarkers.contains(id.toLowerCase)) {
			println("    visible false")
			visible = false
			update
		}
	}

}