package org.uqbar.project.wollok.ui.wizard

import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtext.ui.util.PluginProjectFactory

class WollokProjectFactory extends PluginProjectFactory {

	override protected createBuildProperties(IProject project, IProgressMonitor progressMonitor) {
		val StringBuilder content = new StringBuilder("source.. = ");
		content => [
			append(folders.map[it + "/"].join(",\\\n"))
			append("\n");
			append("bin.includes = META-INF/,\\\n");
			append("               .");
		]

		createFile("build.properties", project, content.toString(), progressMonitor);
	}

}
