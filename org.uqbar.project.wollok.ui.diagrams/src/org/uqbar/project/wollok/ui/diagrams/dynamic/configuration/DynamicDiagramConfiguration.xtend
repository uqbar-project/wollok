package org.uqbar.project.wollok.ui.diagrams.dynamic.configuration

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.AbstractDiagramConfiguration

@Accessors
class DynamicDiagramConfiguration extends AbstractDiagramConfiguration {

	static DynamicDiagramConfiguration instance
	
	static def getInstance() {
		if (instance === null) {
			instance = new DynamicDiagramConfiguration
		}
		instance
	}
}