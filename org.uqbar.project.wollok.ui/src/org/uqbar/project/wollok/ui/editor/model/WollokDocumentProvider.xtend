package org.uqbar.project.wollok.ui.editor.model

import com.google.inject.Inject
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.jface.text.IDocument
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.handlers.IHandlerService
import org.eclipse.xtext.ui.editor.model.XtextDocumentProvider
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.ui.preferences.WollokRootPreferencePage

class WollokDocumentProvider extends XtextDocumentProvider {
	val String XTEXT_FORMAT_ACTION_COMMAND_ID = "org.eclipse.xtext.ui.FormatAction";
	@Inject
	IPreferenceStoreAccess preferenceStoreAccess

	override doSaveDocument(IProgressMonitor monitor, Object element, IDocument document, boolean overwrite) throws CoreException {

		val prefStore = preferenceStoreAccess.preferenceStore

		if(prefStore.contains(WollokRootPreferencePage.FORMAT_ON_SAVE) && !prefStore.getBoolean(WollokRootPreferencePage.FORMAT_ON_SAVE)){
			return 
		}

		val service = PlatformUI.getWorkbench().getService(IHandlerService) as IHandlerService
		service.executeCommand(XTEXT_FORMAT_ACTION_COMMAND_ID, null)
		super.doSaveDocument(monitor, element, document, overwrite)
	}
}
