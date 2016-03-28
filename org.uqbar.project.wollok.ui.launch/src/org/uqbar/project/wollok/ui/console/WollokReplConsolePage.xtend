package org.uqbar.project.wollok.ui.console

import org.eclipse.swt.SWT
import org.eclipse.swt.events.KeyEvent
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsolePage
import org.eclipse.swt.events.MouseAdapter
import org.eclipse.swt.events.MouseEvent

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
		viewer.textWidget.addMouseListener(
		new MouseAdapter() {
			override def mouseDown(MouseEvent e) {
			if (isCursorInTheLasLine && isCursorInReadOnlyZone)
				setCursorToEnd
			}
		})
		viewer.textWidget.setFocus
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
			setCursorToEnd
			return
		}

		if (e.keyCode == SWT.ARROW_DOWN) {
			decreaseHistoryPosition
			console.loadHistory(historyPosition)
			setCursorToEnd
			return
		}
		if (e.keyCode == SWT.HOME) {
			viewer.textWidget.selection = getHomePosition()
			return
		}

		if (e.keyCode == SWT.END) {
			setCursorToEnd
			return
		}
		// return key pressed 
		if (e.keyCode == KEY_RETURN && !e.controlPressed) {
			console.sendInputBuffer
			historyPosition = -1
		} else
			console.updateInputBuffer
		return
	}

	def isCursorInTheLasLine() {
		viewer.textWidget.getLineAtOffset(viewer.textWidget.getCaretOffset()) ==
			viewer.textWidget.getLineAtOffset(viewer.textWidget.charCount)
	}
	
	def isCursorInReadOnlyZone() { viewer.textWidget.selectionCount < getHomePosition }
	def setCursorToEnd() { viewer.textWidget.selection = viewer.textWidget.charCount }

	def getHomePosition() {	console.outputTextEnd }

	def isControlPressed(KeyEvent it) { stateMask.bitwiseAnd(SWT.CTRL) == SWT.CTRL }

	override keyReleased(KeyEvent e) {}

}
