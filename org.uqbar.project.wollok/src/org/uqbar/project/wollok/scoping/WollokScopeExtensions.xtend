package org.uqbar.project.wollok.scoping

import org.eclipse.xtext.linking.impl.ImportedNamesAdapter.WrappingScope
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.ImportScope
import org.eclipse.xtext.scoping.impl.SelectableBasedScope
import org.eclipse.xtext.scoping.impl.SimpleScope

import static extension org.uqbar.project.wollok.utils.ReflectionExtensions.get
import static extension org.uqbar.project.wollok.utils.ReflectionExtensions.invoke

class WollokScopeExtensions {
	def static containsImport(IScope scope, String namespace) {
		val definedNames = scope.definedNames
		definedNames.exists[it.isIncludedIn(namespace)]
	}

	def static dispatch Iterable<QualifiedName> definedNames(IScope scope) {
		if(scope == IScope.NULLSCOPE)
			return emptySet
			
		throw new RuntimeException("I have no implementation for:" + scope.class)
	}

	def static dispatch Iterable<QualifiedName> definedNames(SelectableBasedScope scope) {
		(scope.invoke("getAllLocalElements") as Iterable<IEObjectDescription>).map[it.qualifiedName] +
			scope.parent.definedNames
	}

	def static dispatch Iterable<QualifiedName> definedNames(ImportScope scope) {
		scope.parent.definedNames
	}

	def static dispatch Iterable<QualifiedName> definedNames(SimpleScope scope) {
		(scope.invoke("getAllLocalElements") as Iterable<IEObjectDescription>).map[it.qualifiedName] +
			scope.parent.definedNames
	}

	def static dispatch Iterable<QualifiedName> definedNames(WrappingScope scope) {
		(scope.get("delegate") as IScope).definedNames
	}

	def static isIncludedIn(QualifiedName qn, String other) {
		qn.isIncludedIn(QualifiedName.create(other.split('\\.')))
	}

	def static isIncludedIn(QualifiedName qn, QualifiedName other) {
		val withoutWildcard = if(other.lastSegment == "*") other.skipLast(1) else other

		if (qn.segmentCount < withoutWildcard.segmentCount)
			return false

		return qn.startsWith(withoutWildcard)
	}
}
