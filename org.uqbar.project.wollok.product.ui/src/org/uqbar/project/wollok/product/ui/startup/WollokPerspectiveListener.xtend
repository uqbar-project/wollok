package org.uqbar.project.wollok.product.ui.startup

import java.util.List
import org.eclipse.jface.action.ActionContributionItem
import org.eclipse.jface.action.GroupMarker
import org.eclipse.jface.action.IContributionItem
import org.eclipse.jface.action.MenuManager
import org.eclipse.jface.action.Separator
import org.eclipse.ui.IPerspectiveDescriptor
import org.eclipse.ui.IPerspectiveListener
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.actions.NewWizardMenu
import org.eclipse.ui.internal.ActionSetContributionItem
import org.eclipse.ui.internal.ActionSetMenuManager
import org.eclipse.ui.internal.PluginActionContributionItem
import org.eclipse.ui.internal.Workbench
import org.eclipse.ui.internal.WorkbenchWindow
import org.eclipse.ui.internal.ide.actions.BuildSetMenu
import org.eclipse.ui.keys.IBindingService
import org.uqbar.project.wollok.utils.ReflectionExtensions

class WollokPerspectiveListener implements IPerspectiveListener {
	
	override perspectiveActivated(IWorkbenchPage arg0, IPerspectiveDescriptor perspective) {
		//removeUnwantedActions
	}

	override perspectiveChanged(IWorkbenchPage arg0, IPerspectiveDescriptor perspective, String event) {
		removeUnwantedActions
		removeUnwantedKeyBindings
	}
	
	def void removeUnwantedActions() {
		val window = Workbench.getInstance().getActiveWorkbenchWindow() as WorkbenchWindow
		window.menuManager => [
			visit
			update(true)			
		]
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
		// Debug
		"org.eclipse.debug.internal.ui.actions.Debug",
		// Project Properties
		"projectProperties",
		// Navigate - Open Attached Javadoc and Source files
		"org.eclipse.xtext.ui.shared.OpenSourceFileCommand",
		// Refactor
		"org.eclipse.jdt.ui.actions.ModifyParameters",
		"org.eclipse.jdt.ui.actions.ExtractTemp",
		"org.eclipse.jdt.ui.actions.ExtractConstant",
		"org.eclipse.jdt.ui.actions.Inline",
		"reorgGroup2",
		"org.eclipse.jdt.ui.actions.ConvertLocalToField",
		"org.eclipse.jdt.ui.actions.ConvertAnonymousToNested",
		"org.eclipse.jdt.ui.actions.ConvertNestedToTop",
		"typeGroup",
		"org.eclipse.jdt.ui.actions.ExtractSuperclass",
		"org.eclipse.jdt.ui.actions.ExtractInterface",
		"org.eclipse.jdt.ui.actions.UseSupertype",
		"org.eclipse.jdt.ui.actions.PushDown",
		"org.eclipse.jdt.ui.actions.PullUp",
		"typeGroup2",
		"org.eclipse.jdt.ui.actions.ExtractClass",
		"org.eclipse.jdt.ui.actions.IntroduceParameterObject",
		"codingGroup2",
		"org.eclipse.jdt.ui.actions.IntroduceIndirection",
		"org.eclipse.jdt.ui.actions.IntroduceFactory",
		"org.eclipse.jdt.ui.actions.IntroduceParameter",
		"org.eclipse.jdt.ui.actions.SelfEncapsulateField",
		"typeGroup3",
		"org.eclipse.jdt.ui.actions.ChangeType",
		"org.eclipse.jdt.ui.actions.InferTypeArguments",
		"scriptGroup",
		"org.eclipse.jdt.ui.actions.MigrateJarFile",
		"org.eclipse.ltk.ui.actions.CreateRefactoringScript",
		"org.eclipse.ltk.ui.actions.ApplyRefactoringStript",
		"org.eclipse.ltk.ui.actions.ShowRefactoringHistory",
		// File New ...
		"New Project|P&roject...",
		"New|&Other..."
		]
	}
	
	def dispatch String identifier(IContributionItem it) { id }
	def dispatch String identifier(ActionContributionItem it) { 
		if (id === null) {
			(action.description ?: "") + "|" + (action.text ?: "")
		} else {
			id
		}
	}
	
	def dispatch void visit(IContributionItem it) {
		if (unwantedContributionItems.includesCase(identifier)) {
			visible = false
		}
	}

	def dispatch void visit(Separator it) {
		if (#["run", "debug"].includesCase(id)) {
			visible = false
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
		"org.eclipse.jdt.ui.actions.GoToType",
		"org.eclipse.jdt.ui.actions.GoToPackage",
		// DEBUG - we should remove them when Wollok debugger is up again
		"DebugGroup",
		"org.eclipse.debug.ui.actions.DebugLast",
		"org.eclipse.debug.internal.ui.actions.Debug",
		"org.eclipse.debug.internal.ui.actions.DebugDropDownAction",
		"org.eclipse.debug.internal.ui.actions.DebugHistoryMenuAction",
		"org.eclipse.debug.internal.ui.actions.DebugWithConfigurationAction",
		"org.eclipse.debug.ui.actions.OpenDebugConfigurations",
		"org.eclipse.debug.ui.actions.ToggleBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleLineBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleMethodBreakpoint",
		"org.eclipse.debug.ui.actions.ToggleWatchpoint",
		"org.eclipse.debug.ui.actions.SkipAllBreakpoints",
		"org.eclipse.debug.ui.actions.RemoveAllBreakpoints",
		"org.eclipse.jdt.debug.ui.JDTDebugActionSet",
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
		"emptyStepGroup",
		"org.eclipse.debug.ui.actions.BreakpointTypesContribution",
		// Run external tools - if you want to allow you have to remove these lines 
		"ExternalToolsGroup",
		"org.eclipse.ui.externaltools.ExternalToolMenuDelegateMenu",
		// Debug
		"org.eclipse.jdt.debug.ui.commands.StepIntoSelection",
		// Search
		"org.eclipse.jdt.ui.actions.OpenJavaSearchPage",
		"junit.actions.GotoTestAction",
		// Source (Java) menu item
		"org.eclipse.jdt.ui.source.menu",
		// Mylyn Tasks
		"org.eclipse.mylyn.tasks.ui.openTask",
		"org.eclipse.mylyn.tasks.ui.switchTask",
		"org.eclipse.mylyn.tasks.ui.deactivateAllTasks",
		// Refactor - hidden items
		"codingGroup",
		"org.eclipse.jdt.ui.actions.ModifyParameters",
		"org.eclipse.jdt.ui.actions.ExtractTemp",
		"org.eclipse.jdt.ui.actions.ExtractConstant",
		"org.eclipse.jdt.ui.actions.Inline",
		"reorgGroup2",
		"org.eclipse.jdt.ui.actions.ConvertLocalToField",
		"org.eclipse.jdt.ui.actions.ConvertAnonymousToNested",
		"org.eclipse.jdt.ui.actions.ConvertNestedToTop",
		"typeGroup",
		"org.eclipse.jdt.ui.actions.ExtractSuperclass",
		"org.eclipse.jdt.ui.actions.ExtractInterface",
		"org.eclipse.jdt.ui.actions.UseSupertype",
		"org.eclipse.jdt.ui.actions.PushDown",
		"org.eclipse.jdt.ui.actions.PullUp",
		"typeGroup2",
		"org.eclipse.jdt.ui.actions.ExtractClass",
		"org.eclipse.jdt.ui.actions.IntroduceParameterObject",
		"codingGroup2",
		"org.eclipse.jdt.ui.actions.IntroduceIndirection",
		"org.eclipse.jdt.ui.actions.IntroduceFactory",
		"org.eclipse.jdt.ui.actions.IntroduceParameter",
		"org.eclipse.jdt.ui.actions.SelfEncapsulateField",
		"typeGroup3",
		"org.eclipse.jdt.ui.actions.ChangeType",
		"org.eclipse.jdt.ui.actions.InferTypeArguments",
		"scriptGroup",
		"org.eclipse.jdt.ui.actions.MigrateJarFile",
		"org.eclipse.ltk.ui.actions.CreateRefactoringScript",
		"org.eclipse.ltk.ui.actions.ApplyRefactoringStript",
		"org.eclipse.ltk.ui.actions.ShowRefactoringHistory"
		].map [ toLowerCase ]
	}
	
	def dispatch void visit(BuildSetMenu it) {
		visible = false
	}
	
	def dispatch void visit(ActionSetContributionItem it) {
		if (shouldHideActionSet(id, actionSetId)) {
			it.visible = false
			if (innerItem !== null) {
				innerItem.visible = false
			}
		}
		if (innerItem !== null) {
			innerItem.visit
		}
	}
	
	def unwantedNullActionSets() {
		#["org.eclipse.ui.NavigateActionSet"]
	}
	
	def shouldHideActionSet(String id, String actionSetId) {
		id !== null && unwantedActionSets.includesCase(id) || (id.equals("") && unwantedNullActionSets.includesCase(actionSetId))
	}
	
	static val unwantedGroupMarkers = {
		#["build.ext", "additions", "group.tutorials", "group.tools", "group.main.ext"].map [ toLowerCase ]
	}

	def dispatch void visit(GroupMarker it) {
		if (unwantedGroupMarkers.includesCase(id)) {
			visible = false
		}
	}

	def dispatch void visit(NewWizardMenu it) {
		val contributionItems = ReflectionExtensions.executeMethod(it, "getContributionItems", #[]) as IContributionItem[]
		contributionItems.forEach [ item | item.visit ]
		update
	}

	def dispatch void visit(PluginActionContributionItem it) {
		if (shouldHideActionSet(id, it.action.actionDefinitionId) && it.id?.toLowerCase.contains("debug")) {
			it.visible = false
			it.update
		}
	}

	def dispatch void visit(ActionSetMenuManager it) {
		if (shouldHideActionSet(id, actionSetId)) {
			it.visible = false
			getItems.forEach [ item | item.visible = false ]
		} else {
			getItems.forEach [ item | item.visit ]
		}
		update
	}

	static val unwantedKeyBindings = #[
		"org.eclipse.jdt.ui.edit.text.java.organize.imports",
		"org.eclipse.jdt.ui.navigate.open.type.in.hierarchy",
		"org.eclipse.jdt.ui.edit.text.java.open.call.hierarchy",
		"org.eclipse.mylyn.tasks.ui.command.openTask",
		"org.eclipse.mylyn.tasks.ui.command.openRemoteTask",
		"org.eclipse.mylyn.context.ui.commands.toggle.focus.active.view",
		"org.eclipse.xtext.ui.editor.OpenCallHierarchy",
		"org.eclipse.xtext.xbase.ui.organizeImports",
		"org.eclipse.xtext.xbase.ui.hierarchy.OpenCallHierarchy",
		"org.eclipse.jdt.ui.edit.text.java.open.hierarchy",
		"org.eclipse.xtext.xbase.ui.hierarchy.OpenTypeHierarchy",
		"org.eclipse.xtend.ide.launching.junitShortcut.run",
		"org.eclipse.xtend.ide.launching.junitPdeShortcut.debug",
		"org.eclipse.xtend.ide.launching.localJavaShortcut.run",
		"org.eclipse.xtend.ide.launching.localJavaShortcut.debug"
	].map [ toLowerCase ]
	
	def removeUnwantedKeyBindings() {
		val bindingService = PlatformUI.workbench.getAdapter(typeof(IBindingService)) as IBindingService
		bindingService.bindings.forEach [  
			if (unwantedKeyBindings.includesCase(parameterizedCommand?.command?.id)) {
				parameterizedCommand.command.enabled = false
			}
		]
	}
	
	/**
	 * EXTENSION METHODS
	 */
	def boolean includesCase(List<String> unwanted, String id) {
		val idLower = (id ?: "").toLowerCase
		unwanted.contains(idLower) || unwanted.exists [ idLower.contains(it)]
	}	
}