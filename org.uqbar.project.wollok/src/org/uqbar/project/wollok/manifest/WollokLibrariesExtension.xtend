package org.uqbar.project.wollok.manifest

class WollokLibrariesExtension {
	
	/** remove path and extension foo/bar.jar => bar 
	 * if path is not a jar file return path*/
	static def libName(String path) {
		val s = path.split("/")
		val r = s.get(s.size - 1)
		return if (r.endsWith(".jar")) r.substring(0,r.length()-4) else path
	}

}