package org.uqbar.project.wollok.utils

import com.google.inject.Singleton
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.common.types.access.IJvmTypeProvider

/**
 * @author jfernandes
 */
class DummyJvmTypeProvider implements IJvmTypeProvider {
	ResourceSet set
	
	new() {
		
	}
	
	new(ResourceSet set) {
		this.set = set
	}
	
	override findTypeByName(String name) {
		null
	}
	
	override findTypeByName(String name, boolean binaryNestedTypeDelimiter) {
		null
	}
	
	override getResourceSet() {
		set
	}
	
}

@Singleton
class DummyJvmTypeProviderFactory implements IJvmTypeProvider.Factory {
	
	override createTypeProvider() throws UnsupportedOperationException {
		new DummyJvmTypeProvider(null)
	}
	
	override createTypeProvider(ResourceSet resourceSet) {
		new DummyJvmTypeProvider(resourceSet)
	}
	
	override findOrCreateTypeProvider(ResourceSet resourceSet) {
		new DummyJvmTypeProvider(resourceSet)
	}
	
	override findTypeProvider(ResourceSet resourceSet) {
		new DummyJvmTypeProvider(resourceSet)
	}
	
}