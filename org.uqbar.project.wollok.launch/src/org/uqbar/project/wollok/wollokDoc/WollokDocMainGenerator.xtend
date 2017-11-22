package org.uqbar.project.wollok.wollokDoc

import java.io.File

class WollokDocMainGenerator {
	
	val static WOLLOK_LIB_FOLDER = "/org.uqbar.project.wollok.lib/src/wollok/"
	
	def static Filter filterWollokElements() {
		[ int level, String path, File file |
			path.endsWith("lang.wlk")
		]
	}
	
	def static FileHandler generateWollokDoc() {
		[ int level, String path, File file | 
			new WollokDocParser().parse(file)
		]
	}
	
    def static void main(String[] args) {
    	val rootDir = System.getProperty("user.dir")
    	val finalRootDir = rootDir.substring(0, rootDir.lastIndexOf(File.separator))
        val projectDir = new File(finalRootDir + WOLLOK_LIB_FOLDER)
        new DirExplorer(filterWollokElements, generateWollokDoc).explore(projectDir)
    }
 
}