package org.uqbar.project.wollok.ui.preferences

import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.jface.preference.IPreferencePageContainer
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.Constants
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage

import static org.eclipse.xtext.ui.XtextProjectHelper.*
import static org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Preferences page for validator
 * 
 * @author jfernandes
 */
class ValidatorPreferencePage extends PropertyAndPreferencePage {
	@Inject @Named(Constants.LANGUAGE_NAME) String languageName
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	ValidatorConfigurationBlock configurationBlock

	override protected getPreferencePageID() { languageName + "validator.preferencePage" }
	override protected getPropertyPageID() { languageName + "validator.propertyPage"}
	
	override createControl(Composite parent) {
		val container = container as IWorkbenchPreferenceContainer
		val preferenceStore = preferenceStoreAccess.getWritablePreferenceStore(project)
		configurationBlock = new ValidatorConfigurationBlock(project, preferenceStore, container)
		configurationBlock.statusChangeListener = newStatusChangedListener
		super.createControl(parent)
	}

	override protected createPreferenceContent(Composite composite, IPreferencePageContainer preferencePageContainer) {
		configurationBlock.createContents(composite)
	}
	
	override protected hasProjectSpecificOptions(IProject project) {
		configurationBlock.hasProjectSpecificOptions(project)
	}
	
	override dispose() {
		if (configurationBlock != null)
			configurationBlock.dispose
		super.dispose
	}
	
		override enableProjectSpecificSettings(boolean useProjectSpecificSettings) {
		super.enableProjectSpecificSettings(useProjectSpecificSettings)
		if (configurationBlock != null)
			configurationBlock.useProjectSpecificSettings(useProjectSpecificSettings)
	}

	override performDefaults() {
		super.performDefaults
		if (configurationBlock != null)
			configurationBlock.performDefaults
	}

	override performOk() {
		if (configurationBlock != null) {
			scheduleCleanerJobIfNecessary(container)
			if (!configurationBlock.performOk)
				return false
		}
		super.performOk
	}

	override performApply() {
		if (configurationBlock != null) {
			scheduleCleanerJobIfNecessary(null)
			configurationBlock.performApply
		}
	}
	
	def scheduleCleanerJobIfNecessary(IPreferencePageContainer preferencePageContainer) {
		//TODO: podría ser inteligente y solo buildear si hubo cambios en ciertas propiedades.
		// ver BuilderPreferencePage
		val c = container as IWorkbenchPreferenceContainer
		c.registerUpdateJob(new Job("Rebuilding project") {
			override protected run(IProgressMonitor monitor) {
				rebuild(monitor)
				Status.OK_STATUS
			}
		})
	}
	
	protected def rebuild(IProgressMonitor monitor) {
		if (projectPreferencePage)
			fullBuild(project,monitor)
		else
			allProjects.filter[p| hasNature(p) ].forEach[p| fullBuild(p,monitor)]
	}
	
	override setElement(IAdaptable element) {
		super.setElement(element)
		description = null // no description for property page
	}
	
}