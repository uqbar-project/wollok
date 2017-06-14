package org.uqbar.project.wollok.scoping

import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.emf.ecore.EObject

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * @author tesonep
 * @author jfernandes
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
	
	/*
	 * I override this to allow the relative imports, the original version only uses absolute imports.
	 */
	override protected getImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val result = <ImportNormalizer>newArrayList()
			
		context.allImports.forEach[ e |
			val normalizer = createImportedNamespaceResolver(e.importedNamespace, ignoreCase)
			if(normalizer !== null){
				result.add(normalizer)
				this.allRelativeImports(e.importedNamespace, context).forEach[ relativeImport | 
					result.add(createImportedNamespaceResolver(relativeImport, ignoreCase))
				]
			}
		]

		result
	}
	
	def Iterable<String> allRelativeImports(String importedNamespace, EObject context){
		this.allRelativeImports(importedNamespace, context.implicitPackage)
	}

	def Iterable<String> allRelativeImports(String importedNamespace, String implicitPackage){
		val implicitPackageFQN = qualifiedNameConverter.toQualifiedName(implicitPackage)

		(0..implicitPackageFQN.segmentCount).map[ i |
			implicitPackageFQN.skipLast(i).append(importedNamespace).toString
		]
	}
}