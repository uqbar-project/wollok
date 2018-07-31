package org.uqbar.project.wollok.ui.validator

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.ui.validation.DefaultResourceUIValidatorExtension
import org.eclipse.xtext.ui.validation.IResourceUIValidatorExtension
import org.eclipse.xtext.validation.CheckMode

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokResourceUIValidatorExtension extends DefaultResourceUIValidatorExtension implements IResourceUIValidatorExtension {
	
	override updateValidationMarkers(IFile file, Resource resource, CheckMode mode, IProgressMonitor monitor) throws OperationCanceledException {

		synchronized (resource) {
			if (!file.shouldProcess) {
				return
			}
			addMarkers(file, resource, mode, monitor)
			resource.resourceSet.resources.forEach[ res |
				val f = res.IFile
				if (f !== null && f.shouldProcess) {
					addMarkers(f, res, mode, monitor)
				}
			]
		}
	}

}