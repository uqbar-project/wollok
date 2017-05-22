package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.net.URL
import java.util.Observable
import java.util.Observer
import org.eclipse.gef.GraphicalViewer
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.FileDialog
import org.eclipse.ui.PlatformUI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.ClassDiagramView
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration

import static extension org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ImageSaveUtil.*

class ExportAction extends Action {
	
	@Accessors GraphicalViewer viewer
	
	new() {
		init
	}
	
	new(GraphicalViewer _viewer) {
		init
		viewer = _viewer
	}
	
	def void init() {
		toolTipText = Messages.StaticDiagram_Export_Description
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/export.png")	
	}
	
	override run() {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
		val FileDialog fileSelecter = new FileDialog(shell, SWT.SAVE) => [
			filterExtensions = #[".png"]
			overwrite = true
		]
		val fileName = fileSelecter.open
		if (fileName !== null && !fileName.equals("")) {
			viewer.save(fileName, SWT.IMAGE_PNG)		
		}
	}
	
}


class SaveStaticDiagramConfigurationAction extends Action {
	@Accessors StaticDiagramConfiguration configuration
	
	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.ui/icons/full/etool16/save_edit.png"))
	}
	
	override run() {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
		val FileDialog fileSelecter = new FileDialog(shell, SWT.SAVE) => [
			filterExtensions = #["*.wsdi"]
			overwrite = true
		]
		val fileName = fileSelecter.open
		if (fileName !== null && !fileName.equals("")) {
			val file = new FileOutputStream(fileName)
			val oos = new ObjectOutputStream(file)
			oos.writeObject(configuration)
		}
	}
}

class LoadStaticDiagramConfigurationAction extends Action {
	@Accessors StaticDiagramConfiguration configuration
	ClassDiagramView view
	
	new(String title, StaticDiagramConfiguration configuration, ClassDiagramView view) {
		super(title)
		this.configuration = configuration
		this.view = view
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/etool16/opentype.png"))
	}
	
	override run() {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
		val FileDialog fileSelecter = new FileDialog(shell, SWT.OPEN) => [
			text = Messages.StaticDiagramOpenFile
			filterExtensions = #["*.wsdi"]
		]
		val fileName = fileSelecter.open
		if (fileName !== null && !fileName.equals("")) {
			val file = new FileInputStream(fileName)
			val ois = new ObjectInputStream(file)
			val newConfiguration = ois.readObject as StaticDiagramConfiguration
			configuration.copyFrom(newConfiguration)
			view.refresh
		}
	}
}

class ShowVariablesToggleButton extends Action implements Observer {
	StaticDiagramConfiguration configuration
	ClassDiagramView view

	new(String title, StaticDiagramConfiguration configuration, ClassDiagramView view) {
		super(title, AS_CHECK_BOX)
		this.configuration = configuration
		this.configuration.addObserver(this)
		this.view = view
		this.checked = configuration.showVariables
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/wollok-icon-variable_16.png")
	}

	override run() {
		configuration.showVariables = !configuration.showVariables
		this.update(null, null)
	}
	
	override update(Observable o, Object arg) {
		this.checked = configuration.showVariables
		view.refresh
	}

}

class RememberShapePositionsToggleButton extends Action implements Observer {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title, AS_CHECK_BOX)
		this.configuration = configuration
		this.configuration.addObserver(this)
		this.checked = configuration.rememberLocationAndSizeShapes
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.ui/icons/full/ovr16/pinned_ovr@2x.png"))
	}

	override run() {
		configuration.rememberLocationAndSizeShapes = !configuration.rememberLocationAndSizeShapes
		configuration.initLocationsAndSizes  // just in case we don't want to remember anymore, cleaning up
		this.update(null, null)
	}
	
	override update(Observable o, Object arg) {
		this.checked = configuration.rememberLocationAndSizeShapes
	}
	
}

class CleanShapePositionsAction extends Action {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.team.svn.ui/icons/wizards/find-clear.gif"))
	}

	override run() {
		configuration.initLocationsAndSizes
	}
	
}
