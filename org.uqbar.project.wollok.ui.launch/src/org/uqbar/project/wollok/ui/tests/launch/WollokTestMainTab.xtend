package org.uqbar.project.wollok.ui.tests.launch

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.debug.ui.AbstractLaunchConfigurationTab
import org.eclipse.jface.window.Window
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.dialogs.ResourceListSelectionDialog
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants

/**
 * Main tab for wollok run configurations
 * 
 * @author jfernandes
 */
class WollokTestMainTab extends AbstractLaunchConfigurationTab {
	Text programText
	Button programButton
	
	override getName() { "Main" }
	
	override createControl(Composite parent) {
		val font = parent.font
		val comp = new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				verticalSpacing = 0
				numColumns = 3
			]
			it.font = font	
		]
		control = comp
		createContent(comp, font)
	}
	
	def createContent(Composite comp, Font font) {
		createVerticalSpacer(comp, 3)
		
		// label
		new Label(comp, SWT.NONE) => [
			text = "&Program:"
			layoutData = new GridData(GridData.BEGINNING)
			it.font = font			
		]
		
		programText = new Text(comp, SWT.SINGLE.bitwiseOr(SWT.BORDER)) => [
			layoutData = new GridData(GridData.FILL_HORIZONTAL) 
			it.font = font
			addModifyListener[e| updateLaunchConfigurationDialog ]	
		]
		
		programButton = createPushButton(comp, "&Browse...", null)
		programButton.addSelectionListener(new SelectionAdapter {
			override widgetSelected(SelectionEvent e) {
				browsePDAFiles
			}
		})
	}
	
	def void browsePDAFiles() {
		val dialog = new ResourceListSelectionDialog(shell, ResourcesPlugin.workspace.root, IResource.FILE) => [
			title = "Wollok Program"
			message = "Select Wollok Program"	
		]
		// TODO: single select
		if (dialog.open == Window.OK) {
			val files = dialog.result
			val file = files.get(0) as IFile
			programText.text = file.fullPath.toString
		}
		
	}
	
	override initializeFrom(ILaunchConfiguration configuration) {
		try {
			val program = configuration.getAttribute(WollokLaunchConstants.ATTR_WOLLOK_FILE, null as String)
			if (program != null)
				programText.text = program
		} catch (CoreException e) {
			setErrorMessage(e.message)
		}
	}
	
	override performApply(ILaunchConfigurationWorkingCopy configuration) {
		var program = programText.text.trim
		if (program.length == 0) {
			program = null;
		}
		configuration.setAttribute(WollokLaunchConstants.ATTR_WOLLOK_FILE, program)
	}
	
	override isValid(ILaunchConfiguration launchConfig) {
		val text = programText.text
		if (text.length() > 0) {
			val path = new Path(text)
			if (ResourcesPlugin.workspace.root.findMember(path) == null) {
				errorMessage = "Specified program does not exist"
				return false
			}
		} else {
			message = "Specify a program"
		}
		return super.isValid(launchConfig);
	}
	
	override setDefaults(ILaunchConfigurationWorkingCopy configuration) { }
	
}