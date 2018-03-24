package org.uqbar.project.wollok.ui.console.actions

import java.net.URL
import org.eclipse.core.resources.IResourceChangeEvent
import org.eclipse.core.resources.IResourceChangeListener
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ControlContribution
import org.eclipse.jface.action.Separator
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.osgi.util.NLS
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.CLabel
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IActionBars
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsoleConstants
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.uqbar.project.wollok.ui.console.WollokReplConsole

import static org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages.*

/**
 * Contributes with buttons to wollok repl console
 * 
 * @author jfernandes
 */
class WollokReplConsoleActionsParticipant implements IConsolePageParticipant {
	IPageBookViewPage page
	ShowOutdatedAction outdated
	Action export
	Action stop
	IActionBars bars
	WollokReplConsole console
	IResourceChangeListener resourceListener
	Long lastTimeActivation
	
	def hasAssociatedFile() {
		!this.console.fileName.equals("")
	}

	def projectName() {
		if(hasAssociatedFile) this.console.project else ""
	}

	override init(IPageBookViewPage page, IConsole console) {
		this.console = console as WollokReplConsole
		this.page = page
		val site = page.site
		this.bars = site.actionBars
		val _self = this
		this.resourceListener = new IResourceChangeListener() {

			override resourceChanged(IResourceChangeEvent evt) {
				if (!hasAssociatedFile) {
					return;
				}
				if (evt.delta.affectedChildren.size < 1) {
					return;
				}
				val project = new Path(_self.console.project)
				val resourceDelta = evt.delta.findMember(project)
				if (resourceDelta === null) {
					return;
				}
				_self.outdated.markOutdated
			}

		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener, IResourceChangeEvent.POST_CHANGE)

		createTerminateAllButton
		createRemoveButton
		this.outdated = new ShowOutdatedAction(this)

		bars => [
			menuManager.add(new Separator)
			menuManager.add(export)

			toolBarManager => [
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, outdated)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, new Separator)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, stop)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, export)
			]

			updateActionBars
		]
		outdated.update(_self.console.project)
	}

	def createTerminateAllButton() {
		val imageDescriptor = ImageDescriptor.createFromFile(getClass, "/icons/stop_active.gif")
		this.stop = new Action(WollokRepl_STOP_TITLE, imageDescriptor) {
			override run() {
				this.enabled = false
				console.shutdown
			}
		}
	}

	def createRemoveButton() {
		val imageDescriptor = ImageDescriptor.createFromFile(getClass(), "/icons/export.png")
		this.export = new Action(WollokRepl_EXPORT_HISTORY_TITLE, imageDescriptor) {
			override run() {
				console.exportSession
			}
		}
	}

	override activated() {
		if (page === null)
			return;
		if (console.running) {
			stop.enabled = true
		}
		if (lastTimeActivation !== null && lastTimeActivation > this.console.timeStart) {
			outdated.update
		} else {
			outdated.init
		}
		lastTimeActivation = System.currentTimeMillis
		bars.updateActionBars
	}

	override deactivated() {
		stop.enabled = false
	}

	override dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceListener)
		outdated.dispose
		stop = null
		bars = null
		page = null
		export = null
		outdated = null
		resourceListener = null
	}

	override getAdapter(Class adapter) {
	}

}

/**
 * Shows current file in toolbar as a read-only label
 */
class ShowOutdatedAction extends ControlContribution {
	CLabel label
	boolean synced = true
	WollokReplConsoleActionsParticipant parent
	String projectName
	
	new(WollokReplConsoleActionsParticipant parent) {
		super("showOutdatedAction")
		this.parent = parent
	}
	
	override protected createControl(Composite parent) {
		synced = true
		label = new CLabel(parent, SWT.LEFT) => [
			background = new Color(Display.current, 240, 241, 240)
		]
		configureLabel
		label
	}

	def configureLabel() {
		this.projectName = parent.projectName
		label => [
			if (!isDisposed) {
				text = if(synced) "  " + WollokRepl_SYNCED_MESSAGE + "  " else WollokRepl_OUTDATED_MESSAGE
				toolTipText = if(synced) NLS.bind(WollokRepl_SYNCED_TOOLTIP, projectName) else NLS.bind(
					WollokRepl_OUTDATED_TOOLTIP, projectName)
				val imageURL = if(synced) "platform:/plugin/org.eclipse.ui.ide/icons/full/elcl16/synced.png" else "platform:/plugin/org.eclipse.ui.ide/icons/full/dlcl16/synced.png"
				image = ImageDescriptor.createFromURL(new URL(imageURL)).createImage
				visible = projectName !== null && !projectName.equals("")
			}
		]
	}

	override void update() {
		update(!parent.projectName.equals(this.projectName))
	}

	def void init() {
		update(true)
	}
	
	private def void update(boolean updateSync) {
		if (updateSync) {
			synced = true
		}
		Display.^default.asyncExec([|
			configureLabel
		])
	}

	def markOutdated() {
		synced = false
		Display.^default.asyncExec([|
			configureLabel
		])
	}

}
