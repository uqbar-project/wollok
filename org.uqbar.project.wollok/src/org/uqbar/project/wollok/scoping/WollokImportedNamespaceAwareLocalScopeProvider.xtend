package org.uqbar.project.wollok.scoping

import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

/**
 * 
 */
class WollokImportedNamespaceAwareLocalScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	
	@Inject
	IQualifiedNameConverter qualifiedNameConverter
	
	override protected getImplicitImports(boolean ignoreCase) {
		val implicits = super.getImplicitImports(ignoreCase)
		val r = newArrayList
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lib"), true, ignoreCase))
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lang"), true, ignoreCase))
		r.addAll(implicits)
		r
	}
	
}