package org.uqbar.project.wollok.renaming

import com.google.inject.Inject
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.emf.ecore.EObject
import org.eclipse.ui.progress.UIJob
import org.eclipse.xtext.common.types.ui.refactoring.participant.JdtRenameParticipant
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.edit.IssueModificationContext
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.uqbar.project.wollok.scoping.WollokResourceCache
import org.uqbar.project.wollok.wollokDsl.Import

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

class WollokResourceRenameParticipant extends JdtRenameParticipant {

	@Inject
	IResourceSetProvider resourceSetProvider

	@Inject
	IssueModificationContext.Factory modificationContextFactory

	override protected initialize(Object originalTargetElement) {
		WollokResourceCache.clearResourceCache
		super.initialize(originalTargetElement)
	}
	
	override createRenameElementContexts(Object element) {
		val result = super.createRenameElementContexts(element)
		element.replaceImports(newName, modificationContextFactory, resourceSetProvider)
		result
	}

	def static dispatch replaceImports(IFile file, String newName, IssueModificationContext.Factory modificationContextFactory, IResourceSetProvider resourceSetProvider) {
		val package = file.getPackage
		val oldImport = package + "." + file.nameForImport
		val newImport = package + "." + newName.split("\\.").get(0)
		val fileToChangePath = file.rawLocationURI.path
		file.project.allWollokResources.forEach [ wollokFile |
			val mainFile = wollokFile.convertToEclipseURI
			val currentFilePath = mainFile.toIFile.rawLocationURI.path
			if (!fileToChangePath.equals(currentFilePath)) {
				val modificationContext = modificationContextFactory.createModificationContext(mainFile, IMPORT + " " + newName + ".*")
				val refactorJob = new UIJob("Refactoring imports") {
					override runInUIThread(IProgressMonitor monitor) {
						val xtextDocument = modificationContext.getXtextDocument(mainFile)
						val importToSearch = '''«IMPORT» «oldImport».'''
						xtextDocument.modify(new IUnitOfWork<Object, XtextResource>() {
							override exec(XtextResource state) throws Exception {
								var offset = xtextDocument.search(0, importToSearch, true, true, false)
								while (offset !== -1) {
									xtextDocument.replace(offset, importToSearch.length, '''«IMPORT» «newImport».''')
									offset = xtextDocument.search(offset + 1, importToSearch, true, true, false)
								}
								return null
							}
						})
						activePage.saveEditor(activeEditor, false)
						Status.OK_STATUS
					}
				}
				refactorJob.schedule
			}
		]
	}
	
	def static dispatch replaceImports(Object object, String newName, IssueModificationContext.Factory modificationContextFactory, IResourceSetProvider resourceSetProvider) {}
	
	def static dispatch relatedToImport(EObject o, String oldName) {}
	def static dispatch relatedToImport(Import it, String oldName) {
		importedNamespace.contains(oldName)
	}

}

