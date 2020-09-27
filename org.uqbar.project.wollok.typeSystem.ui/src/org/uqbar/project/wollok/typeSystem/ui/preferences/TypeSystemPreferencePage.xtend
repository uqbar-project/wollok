package org.uqbar.project.wollok.typeSystem.ui.preferences

import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.jface.preference.IPreferencePageContainer
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IWorkbenchPropertyPage
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.Constants
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage
import org.uqbar.project.wollok.typesystem.Messages

import static org.eclipse.xtext.ui.XtextProjectHelper.*
import static org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * @author jfernandes
 */
class TypeSystemPreferencePage extends PropertyAndPreferencePage implements IWorkbenchPropertyPage {
	@Inject @Named(Constants.LANGUAGE_NAME) String languageName
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	TypeSystemConfigurationBlock builderConfigurationBlock

	override protected getPreferencePageID() { languageName + "typeSystem.preferencePage" }
	override protected getPropertyPageID() { languageName + "typeSystem.propertyPage"}
	
	override createControl(Composite parent) {
		val container = container as IWorkbenchPreferenceContainer
		val preferenceStore = preferenceStoreAccess.getWritablePreferenceStore(project)
		builderConfigurationBlock = new TypeSystemConfigurationBlock(project, preferenceStore, container)
		builderConfigurationBlock.statusChangeListener = newStatusChangedListener
		super.createControl(parent)
	}
	
	override protected createPreferenceContent(Composite composite, IPreferencePageContainer preferencePageContainer) {
		builderConfigurationBlock.createContents(composite)
	}
	
	override protected hasProjectSpecificOptions(IProject project) {
		builderConfigurationBlock.hasProjectSpecificOptions(project)
	}
	
	override dispose() {
		if (builderConfigurationBlock !== null)
			builderConfigurationBlock.dispose
		super.dispose
	}
	
	override enableProjectSpecificSettings(boolean useProjectSpecificSettings) {
		super.enableProjectSpecificSettings(useProjectSpecificSettings)
		if (builderConfigurationBlock !== null)
			builderConfigurationBlock.useProjectSpecificSettings(useProjectSpecificSettings)
	}

	override performDefaults() {
		super.performDefaults
		if (builderConfigurationBlock !== null)
			builderConfigurationBlock.performDefaults
	}

	override performOk() {
		if (builderConfigurationBlock !== null) {
			scheduleCleanerJobIfNecessary(container)
			if (!builderConfigurationBlock.performOk)
				return false
		}
		super.performOk
	}

	override performApply() {
		if (builderConfigurationBlock !== null) {
			scheduleCleanerJobIfNecessary(null)
			builderConfigurationBlock.performApply
			super.performApply
		}
	}
	
	def scheduleCleanerJobIfNecessary(IPreferencePageContainer preferencePageContainer) {
		//TODO: podría ser inteligente y solo buildear si hubo cambios en ciertas propiedades.
		// ver BuilderPreferencePage
		val c = container as IWorkbenchPreferenceContainer
		c.registerUpdateJob(new Job(Messages.WollokTypeSystemPreference_REBUILD_JOB_TITLE) {
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