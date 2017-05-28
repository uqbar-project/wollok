package org.uqbar.project.wollok.manifest

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.uqbar.project.wollok.scoping.WollokResourceCache
import org.eclipse.xtext.xbase.lib.Functions.Function1

class WollokManifest {
	val uris = <URI>newArrayList
	public static val WOLLOK_MANIFEST_EXTENSION = ".wollokmf"
	
	new(InputStream is) {
		this(is, [String line | URI.createURI("classpath:/" + line)])
	}
	
	new(InputStream is, Function1<String, URI> uriTransformer) {
		try {
			val reader = new BufferedReader(new InputStreamReader(is))
			var String name = null
			while((name = reader.readLine) !== null){
				uris += uriTransformer.apply(name)
			}
		}
		finally {
			try {
				is.close
			}
			catch (Exception e) {
				println("Error while closing input stream on finally")
				e.printStackTrace
			}
		}
	}

	def getAllURIs() {
		uris
	}
		
}
