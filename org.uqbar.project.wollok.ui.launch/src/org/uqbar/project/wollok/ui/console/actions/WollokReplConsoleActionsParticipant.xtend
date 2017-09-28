package org.uqbar.project.wollok.ui.console.actions

import java.net.URL
import org.eclipse.core.resources.IResourceChangeEvent
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ControlContribution
import org.eclipse.jface.action.Separator
import org.eclipse.jface.resource.ImageDescriptor
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

import static extension org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages.*
import org.eclipse.core.resources.IResourceChangeListener

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

	override init(IPageBookViewPage page, IConsole console) {
		this.console = console as WollokReplConsole
		this.page = page
		val site = page.site
		this.bars = site.actionBars
		this.resourceListener = new IResourceChangeListener() {
			
			override resourceChanged(IResourceChangeEvent evt) {
				WollokReplConsoleActionsParticipant.this.outdated.markOutdated
			}
			
		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener, IResourceChangeEvent.POST_CHANGE)

		createTerminateAllButton
		createRemoveButton
		this.outdated = new ShowOutdatedAction

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
		bars.updateActionBars
	}

	override deactivated() {
		stop.enabled = false
	}

	override dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceListener)
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

	new() {
		super("showOutdatedAction")
	}

	override protected createControl(Composite parent) {
		label = new CLabel(parent, SWT.LEFT) => [
			background = new Color(Display.current, 240, 241, 240)
		]
		configureLabel
		label
	}

	def configureLabel() {
		label => [
			if (!isDisposed) {
				text = if (synced) "  " + WollokRepl_SYNCED_MESSAGE + "  " else WollokRepl_OUTDATED_MESSAGE 
				val imageURL = if (synced) "platform:/plugin/org.eclipse.ui.ide/icons/full/elcl16/synced.png" else "platform:/plugin/org.eclipse.ui.ide/icons/full/dlcl16/synced.png"
				image = ImageDescriptor.createFromURL(new URL(imageURL)).createImage
			}
		]
	}

	def markOutdated() {
		synced = false
		Display.^default.asyncExec([|
			configureLabel
		])
	}

}
