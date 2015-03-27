package org.uqbar.project.wollok.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral

class WollokQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	def QualifiedName qualifiedName(WObjectLiteral obj){
		var EObject container = obj
		var QualifiedName fqn 
		do{
			container = container.eContainer
			fqn = container.fullyQualifiedName
		}while(fqn == null)
		
		val idx = container.eAllContents.indexed.findFirst[ it.value == obj].key
		
		val r = fqn.append("$" + idx);
		r
	}
}