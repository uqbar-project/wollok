package org.uqbar.project.wollok.manifest

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import org.eclipse.emf.common.util.URI

class WollokManifest {
	val uris = <URI>newArrayList
	public static val WOLLOK_MANIFEST_EXTENSION = ".wollokmf"
	
	new(InputStream is) {
		val reader = new BufferedReader(new InputStreamReader(is))
		var String name = null
		while((name = reader.readLine) != null){
			uris += URI.createURI("classpath:/" + name)
		}
	}

	def getAllURIs() {
		uris
	}
}
