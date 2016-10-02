package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.interpreter.WollokREPLInterpreter

/**
 * This special implementation of the WollokGlobalScopeProvider
 * adds to the scope all the variables declared in previous runs of the REPL.
 * 
 * Allowing the usage of variables declared in previous run of the REPL
 * 
 * @author tesonep
 */
@Singleton
class WollokReplGlobalScopeProvider extends WollokGlobalScopeProvider {

	@Inject WollokREPLInterpreter interpreter

	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type,
		Predicate<IEObjectDescription> filter) {
		val parentScope = super.getScope(parent, context, ignoreCase, type, filter)

		new SimpleScope(parentScope, interpreter.previousREPLVariables.values.map [
			new EObjectDescription(QualifiedName.create(name), it, null)
		])
	}
}
