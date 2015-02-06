package org.uqbar.project.wollok.scoping

import javax.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.impl.ImportUriResolver
import org.eclipse.xtext.ui.resource.XtextResourceSetProvider
import org.uqbar.project.wollok.wollokDsl.Import

class WollokImportURIResolver extends ImportUriResolver {

	override resolve(EObject object) {
		this.doResolve(object)
	}

	def dispatch doResolve(Import imp) {
		
//		val project = imp.getIFile.project
//		val XtextResourceSet set = resourceSetProvider.get(project) as XtextResourceSet;
//		val javaProject = set.classpathURIContext as IJavaProject
//		val resolvedClassPath = javaProject.getResolvedClasspath(false)
		
		var fullImported = this.removeLastPart(imp.importedNamespace)

		fullImported = fullImported.replaceAll("\\.","/")

		return "classpath:/" + fullImported + ".wlk"
	}
	
	def dispatch doResolve(EObject object) {
		super.resolve(object)
	}

	def removeLastPart(String imp){
		val lastPoint = imp.lastIndexOf('.')
		imp.substring(0, lastPoint)
	}
	
}
