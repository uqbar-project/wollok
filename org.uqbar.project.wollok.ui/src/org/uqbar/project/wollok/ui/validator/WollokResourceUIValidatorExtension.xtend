package org.uqbar.project.wollok.ui.validator

import com.google.inject.Inject
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescriptionsProvider
import org.eclipse.xtext.ui.validation.DefaultResourceUIValidatorExtension
import org.eclipse.xtext.ui.validation.IResourceUIValidatorExtension
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.emf.common.util.URI

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

class WollokResourceUIValidatorExtension extends DefaultResourceUIValidatorExtension implements IResourceUIValidatorExtension {
	
	@Inject IResourceDescriptionsProvider resourceDescriptionsProvider
	
	override updateValidationMarkers(IFile file, Resource resource, CheckMode mode, IProgressMonitor monitor) throws OperationCanceledException {

		val filesToUpdate = <URI>newHashSet()

		if (!doShouldProcess(file)) {
			return
		}
		
		resourceDescriptionsProvider.getResourceDescriptions(resource.resourceSet).allResourceDescriptions.forEach[it.referenceDescriptions.forEach[x | 			
			if(x.targetEObjectUri.trimQuery.trimFragment == resource.URI.trimQuery.trimFragment){
				filesToUpdate.add(x.sourceEObjectUri.trimQuery.trimFragment)
			}
		]]

		addMarkers(file, resource, mode, monitor);
		
		filesToUpdate.forEach[ uri | 
			val res = resource.resourceSet.getResource(uri, true)
			val f = res.IFile
			if (!doShouldProcess(file)) {
				addMarkers(f, res, mode, monitor)
			}
		]
	}

	def doShouldProcess(IFile file) {
		val uri = file.locationURI.toString
		file.isWollokExtension && !uri.isCoreLib && file.shouldProcess
	}	
}