package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.eclipse.xtext.naming.QualifiedName

class WollokReplGlobalScopeProvider extends WollokGlobalScopeProvider {
	
	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type, Predicate<IEObjectDescription> filter) {
		val parentScope = super.getScope(parent,context,ignoreCase, type, filter)
		
		if(WollokInterpreter.getInstance != null){
			new SimpleScope(parentScope,WollokInterpreter.getInstance.programVariables.map[
				new EObjectDescription(QualifiedName.create(name), it ,null)
			])
		}else
			parentScope
	}
}