package org.uqbar.project.wollok.ui.validator

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.ui.validation.DefaultResourceUIValidatorExtension
import org.eclipse.xtext.ui.validation.IResourceUIValidatorExtension
import org.eclipse.xtext.validation.CheckMode

/**
 * This behavior was replaced by WollokTypeSystemBuilderParticipant 
 */
class WollokResourceUIValidatorExtension extends DefaultResourceUIValidatorExtension implements IResourceUIValidatorExtension {
	
	override updateValidationMarkers(IFile file, Resource resource, CheckMode mode, IProgressMonitor monitor) throws OperationCanceledException {}

}