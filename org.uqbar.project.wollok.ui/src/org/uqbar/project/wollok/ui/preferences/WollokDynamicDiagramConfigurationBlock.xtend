package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.uqbar.project.wollok.ui.Messages

import static org.uqbar.project.wollok.ui.preferences.WPreferencesUtils.*

class WollokDynamicDiagramConfigurationBlock extends WollokAbstractConfigurationBlock {
	
	public static val ACTIVATE_DYNAMIC_DIAGRAM_REPL = "WollokDynamicDiagram_IntegrateRepl"
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
		store.setDefault(ACTIVATE_DYNAMIC_DIAGRAM_REPL, TRUE)
	}
	
	override protected doCreateContents(Composite parent) {
		new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				marginLeft = 10
				marginRight = 10
				marginTop = 10
			]
			addCheckBox(Messages.WollokDynamicDiagramPreferencePage_integrateREPL_description, ACTIVATE_DYNAMIC_DIAGRAM_REPL, booleanPrefValues, 10)
		]
		
	}
	
	override getPropertyPrefix() { "DynamicDiagramConfiguration" }
	
}