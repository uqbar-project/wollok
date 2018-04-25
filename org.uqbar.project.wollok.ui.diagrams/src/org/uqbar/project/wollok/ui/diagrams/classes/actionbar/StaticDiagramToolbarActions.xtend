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
import org.eclipse.jface.action.ControlContribution
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.layout.FormData
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.FileDialog
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.PlatformUI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration

import static extension org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ImageSaveUtil.*

/**
 * 
 * Toolbar Actions for Static Diagram
 * 
 * @author dodain
 *   
 */
 
/**
 * Exports diagram to an image file
 */ 
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


/**
 * Exports diagram to .wsdi file
 */ 
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
			filterExtensions = #["*." + WollokConstants.STATIC_DIAGRAM_EXTENSION]
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

/**
 * Loads a .wsdi file into this diagram
 */ 
class LoadStaticDiagramConfigurationAction extends Action {
	StaticDiagramConfiguration configuration
	
	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/etool16/opentype.png"))
	}
	
	override run() {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
		val FileDialog fileSelecter = new FileDialog(shell, SWT.OPEN) => [
			text = Messages.StaticDiagram_OpenFile
			filterExtensions = #["*." + WollokConstants.STATIC_DIAGRAM_EXTENSION ]
		]
		val fileName = fileSelecter.open
		if (fileName !== null && !fileName.equals("")) {
			val file = new FileInputStream(fileName)
			val ois = new ObjectInputStream(file)
			val newConfiguration = ois.readObject as StaticDiagramConfiguration
			configuration.copyFrom(newConfiguration)
		}
	}
}

/**
 * Sets configuration to show variable of every component (wko, class, mixin)
 */ 
class ShowVariablesToggleButton extends Action implements Observer {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title, AS_CHECK_BOX)
		this.configuration = configuration
		this.configuration.addObserver(this)
		this.checked = configuration.showVariables
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/wollok-icon-variable_16.png")
	}

	override run() {
		configuration.showVariables = !configuration.showVariables
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.showVariables
		}
	}

}

/**
 * Sets configuration to remember every time you move or change size of a component
 */
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
		this.update(null, StaticDiagramConfiguration.CONFIGURATION_CHANGED)
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.rememberLocationAndSizeShapes
		}
	}
	
}

/**
 * Resets the layout and modifications made in the diagram.
 */
class CleanShapePositionsAction extends Action {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.e4.ui.workbench.swt/icons/full/etool16/clear_co.gif"))
	}

	override run() {
		configuration.initLocationsAndSizes
	}
	
}

/**
 * Shows current file in toolbar as a read-only label
 */
class ShowFileAction extends ControlContribution implements Observer {
	StaticDiagramConfiguration configuration
	Label label

	new(String id, StaticDiagramConfiguration configuration) {
		super(id)
		this.configuration = configuration
		this.configuration.addObserver(this)
	}

	override update(Observable o, Object event) {
		if ((event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) && (label !== null) && !(label.disposed)) {
			label.text = "  " + configuration.originalFileName + "  "
			label.parent.requestLayout
		}
	}
	
	override protected createControl(Composite parent) {
		label = new Label(parent, SWT.LEFT) => [
			text = "  " + configuration.originalFileName + "  "
			background = new Color(Display.current, 240, 241, 240)
			layoutData = new FormData => [
				width = 450
			]
		]
		label
	}
	
}

/**
 * Clears all relationships in the configuration state
 */
class CleanAllRelashionshipsAction extends Action {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromFile(this.class, "/icons/association_delete_all.png")
	}

	override run() {
		configuration.initRelationships
	}
	
}

/**
 * Clears all hidden componentes from the configuration state
 */
class ShowHiddenComponents extends Action {

	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/obj16/innerclass_default_obj.png"))
	}

	override run() {
		configuration.showAllComponents
	}
	
}

/**
 * Clears all hidden parts (variables and methods) of all components in the configuration state
 */
class ShowHiddenParts extends Action {

	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.doc.user/images/org.eclipse.debug.ui/elcl16/changevariablevalue_co.png"))
	}

	override run() {
		configuration.showAllParts
	}
	
}

/**
 * Adds an outsider class of this project into static diagram
 */
class AddOutsiderClass extends Action {

	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/etool16/newclass_wiz.png"))
	}

	override run() {
		new AddOutsiderClassView(configuration).open
	}
	
}

class DeleteAllOutsiderClasses extends Action {

	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/obj16/classfo_obj.png"))
	}

	override run() {
		configuration.initOutsiderElements
	}
	
}
