package org.uqbar.project.wollok.ui.console

import org.eclipse.swt.SWT
import org.eclipse.swt.events.KeyEvent
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsolePage

/**
 * Extends eclipse's console page for integrating
 * with the wollok repl console
 * 
 * Manages history
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokReplConsolePage extends TextConsolePage implements KeyListener {
	static val KEY_RETURN = 0x0d
	static val PROMPT = "[36m>>> [m"
	val WollokReplConsole console
	var int historyPosition = -1
	
	new(WollokReplConsole console, IConsoleView view) {
		super(console, view)
		this.console = console
	}
	
	override createControl(Composite oldParent) {
		super.createControl(oldParent)
		viewer.textWidget.addKeyListener(this)
		viewer.textWidget.addVerifyListener [ event |
			event.doit = console.isRunning && !console.canWriteAt(event.start)
		]
	}

	def increaseHistoryPosition() {
		historyPosition++
		
		if (historyPosition >= console.numberOfHistories)
			historyPosition = 0
		
		if (historyPosition <= 0 && console.numberOfHistories == 0) {
			historyPosition = -1
		}
	}

	def decreaseHistoryPosition() {
		historyPosition--
		
		if (historyPosition < 0)
			historyPosition = console.numberOfHistories - 1
	}

	override keyPressed(KeyEvent e) {
		if (!console.running) {
			e.doit = false
			return;
		}
		
		if (e.keyCode == SWT.ARROW_UP) {
			increaseHistoryPosition
			console.loadHistory(historyPosition)
			viewer.textWidget.selection = viewer.textWidget.charCount
			return
		}
	
		if (e.keyCode == SWT.ARROW_DOWN) {
			decreaseHistoryPosition
			console.loadHistory(historyPosition)
			viewer.textWidget.selection = viewer.textWidget.charCount
			return
		}
		if (e.keyCode == SWT.HOME){
			var strLine = viewer.textWidget.getLine(viewer.textWidget.getLineAtOffset(viewer.textWidget.charCount))
			viewer.textWidget.selection = viewer.textWidget.charCount - (strLine.length - PROMPT.length)
			return
		}
		
		if (e.keyCode == SWT.END){
			viewer.textWidget.selection = viewer.textWidget.charCount
			return
		}
		
		// return key pressed 
		if (e.keyCode == KEY_RETURN && !e.controlPressed) {
			console.sendInputBuffer
			historyPosition = -1
			return
		}
		else
			console.updateInputBuffer
		return
	}
	
	def isControlPressed(KeyEvent it) { stateMask.bitwiseAnd(SWT.CTRL) == SWT.CTRL }

	override keyReleased(KeyEvent e) {}

}
