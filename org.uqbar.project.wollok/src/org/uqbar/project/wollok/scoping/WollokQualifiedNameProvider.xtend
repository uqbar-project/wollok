package org.uqbar.project.wollok.scoping

import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Customizes FQN named provider for
 * <li>objectliterals</li>
 * <li>Wfile name</li>
 * 
 */
@Singleton
class WollokQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	
	def QualifiedName qualifiedName(WObjectLiteral obj) {
		var EObject container = obj
		var QualifiedName fqn 
		do {
			container = container.eContainer
			fqn = container.fullyQualifiedName
		} while (fqn === null)
		
		val idx = container.eAllContents.indexed.findFirst[ it.value == obj ].key
		
		fqn.append("$" + idx)
	}
	
	def qualifiedName(WFile ele) {
		QualifiedName.create(ele.implicitPackage.split("\\."))		
	}
	
	def qualifiedName(WConstructor c) {
		val size = if (c.parameters !== null) c.parameters.size else 0
		QualifiedName.create(WollokConstants.CONSTRUCTOR + size)
	}
	
}