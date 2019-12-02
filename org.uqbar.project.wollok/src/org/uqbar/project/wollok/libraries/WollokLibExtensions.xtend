package org.uqbar.project.wollok.libraries

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager

/**
 * Common methods between AbstractWollokLibrary 
 * and ui.ManifestEntryAdapter used by ClassPathEntryAdapter
 * 
 */
class WollokLibExtensions {
	
	public static val LANG_LIB = "wollok.lang"
	public static val LIB_LIB = "wollok.lib"
	public static val VM_LIB = "wollok.vm"
	public static val GAME_LIB = "wollok.game"
	public static val MIRROR_LIB = "wollok.mirror"
	
	public static val ALL_LIBS_FILE = #["lang.wlk", "lib.wlk", "game.wlk", "mirror.wlk", "vm.wlk"]
	public static val ALL_LIBS = #[LANG_LIB, LIB_LIB, VM_LIB, GAME_LIB, MIRROR_LIB]
	public static val IMPLICIT_IMPORTS = #[LIB_LIB, LANG_LIB]
	public static val NON_IMPLICIT_IMPORTS = #[GAME_LIB, VM_LIB, MIRROR_LIB]

	/**
	 * loads the objects without cache
	 */
	static def load(URI uri, Resource resource, Manager manager) {
		val newResource = resource.resourceSet.getResource(uri, true)
		resource.load(#{})
		manager.getResourceDescription(newResource).exportedObjects
	}
	
	
	/** 
	 * remove path and extension foo/bar.jar => bar 
	 * if path is not a jar file return path
	 * 
	 * foo/bar.wollokmf => bar
	 * 
	 * But, if the library is not a jar or manifest file, then is other project, 
	 * the path must be projectName/sourceFolder. In this case the
	 * the lib name is  projectName
	 * 
	 */
	 //TODO maybe differents methods are necessary for manifest and jar/project
	static def libName(String path) {
		var newPath = if( path.startsWith("/") ) path.substring(1) else path
		
		return if(newPath.endsWith(".jar") || newPath.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)) {
			val s = newPath.split("/")
			newPath = s.get(s.size - 1)
			newPath.substring(0, newPath.indexOf("."))
		} else {
			return newPath.substring(0, newPath.indexOf("/"))
		}	
	
	}
	
	static def boolean isCoreLib(String fqn) {
		(fqn ?: "").belongsTo(ALL_LIBS)
	}
	
	static def boolean importRequired(String fqn) {
		!(fqn ?: "").belongsTo(IMPLICIT_IMPORTS)
	}
	
	static def boolean belongsTo(String fqn, List<String> libraries) {
		libraries.exists [ lib | fqn.startsWith(lib) ]
	}

}