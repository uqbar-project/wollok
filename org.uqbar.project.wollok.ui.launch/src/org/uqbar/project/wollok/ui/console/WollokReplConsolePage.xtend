package org.uqbar.project.wollok.ui.console

import org.eclipse.swt.SWT
import org.eclipse.swt.events.KeyEvent
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsolePage
import org.uqbar.project.wollok.ui.console.highlight.WollokReplConsolePageParticipant

/**
 * 
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokReplConsolePage extends TextConsolePage implements KeyListener {
	val WollokReplConsole console
	var int historyPosition = -1
	WollokReplConsolePageParticipant participant

	new(WollokReplConsole console, IConsoleView view) {
		super(console, view)
		this.console = console
	}
	
	override dispose() {
		participant.dispose
		super.dispose
	}

	override createControl(Composite oldParent) {
		super.createControl(oldParent)
		viewer.textWidget.addKeyListener(this)

		viewer.textWidget.addVerifyListener [ event |
			event.doit = ! console.partitioner.isReadOnly(event.start)
		]
		
		// init participant (coloring)
		this.participant = new WollokReplConsolePageParticipant
		participant.init(this, console)
	}

	def increaseHistoryPosition(){
		historyPosition++
		
		if (historyPosition >= console.numberOfHistories)
			historyPosition = 0
		
		if (historyPosition <= 0 && console.numberOfHistories == 0) {
			historyPosition = -1
		}
	}

	def decreaseHistoryPosition(){
		historyPosition--
		
		if (historyPosition < 0)
			historyPosition = console.numberOfHistories - 1
	}

	override keyPressed(KeyEvent e) {
		if (e.keyCode == SWT.ARROW_UP) {
			increaseHistoryPosition
			console.loadHistory(historyPosition)
			return
		}

		if (e.keyCode == SWT.ARROW_DOWN) {
			decreaseHistoryPosition
			console.loadHistory(historyPosition)
			return
		}


		// return key pressed 
		if (e.keyCode == 0x0d && !e.controlPressed) {
			console.sendInputBuffer
			historyPosition = -1
		}
		else
			console.updateInputBuffer
	}
	
	def isControlPressed(KeyEvent it) { stateMask.bitwiseAnd(SWT.CTRL) == SWT.CTRL }

	override keyReleased(KeyEvent e) { }

}
