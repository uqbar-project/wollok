package org.uqbar.project.wollok.wollokDoc

import java.io.File

class DirExplorer {

	FileHandler fileHandler
	Filter filter

	new(Filter filter, FileHandler fileHandler) {
		this.filter = filter
		this.fileHandler = fileHandler
	}

	def void explore(File root) {
		explore(0, "", root)
	}

	def void explore(int level, String path, File file) {
		if (file.isDirectory()) {
			file.listFiles.forEach [ child |
				explore(level + 1, path + "/" + child.getName(), child)
			]
		} else {
			if (filter.interested(level, path, file)) {
				fileHandler.handle(level, path, file)
			}
		}
	}

	def closeWith(()=>void closure) {
		closure.apply
	}

}

interface FileHandler {
	def void handle(int level, String path, File file)
}

interface Filter {
	def boolean interested(int level, String path, File file)
}
