package org.uqbar.project.wollok.libraries

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.xbase.lib.Functions.Function1

class WollokManifest {
	val uris = <URI>newArrayList
	public static val WOLLOK_MANIFEST_EXTENSION = ".wollokmf"
	val Logger log = Logger.getLogger(this.class)
	
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
				log.error("Error while closing input stream on finally",e)
			}
		}
	}

	def getAllURIs() {
		uris
	}
		
}
