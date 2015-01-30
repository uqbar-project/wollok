package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.ui.plugin.AbstractUIPlugin

/**
 * 
 */
class WollokDiagramsPlugin extends AbstractUIPlugin {
	static WollokDiagramsPlugin singleton;

	def static WollokDiagramsPlugin getDefault() {
		singleton
	}

	new() {
		if (singleton == null)
			singleton = this
	}

}