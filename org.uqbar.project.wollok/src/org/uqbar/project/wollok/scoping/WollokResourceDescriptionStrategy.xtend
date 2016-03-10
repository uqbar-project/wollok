package org.uqbar.project.wollok.scoping

import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WPackage

/**
 * Customizes the strategy in order to avoid exporting all "named" objects
 * to other files.
 * In wollok "exportable" objects are only packages, named objects and classes.
 * You cannot export variables or any WExpression
 * 
 * @author jfernandes
 */
@Singleton
class WollokResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	
	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (eObject instanceof WFile)
			super.createEObjectDescriptions(eObject, acceptor)
		else if (eObject instanceof WPackage)
			super.createEObjectDescriptions(eObject, acceptor)
		else if (eObject instanceof WClass) {
			super.createEObjectDescriptions(eObject, acceptor)
			false
		}
		else if (eObject instanceof WNamedObject) {
			super.createEObjectDescriptions(eObject, acceptor)
			false
		}
		else
			false
	}
	
}