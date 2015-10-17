package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.INode

import static extension org.uqbar.project.wollok.ui.console.highlight.WTextExtensions.*

/**
 * Moved this logic to its own class.
 * It basically computes styles ranges for highligthing wollok code.
 * Contrary to WollokHighlightingCalculator this works at AST level.
 * 
 * From the console (repl) we tried to use WollokHighlightingCalculator (we are actually using it)
 * but that object just calculates "customs" highlights (like variables / parameters, etc).
 * It doesn't compute the core basic highlights like keywords, or terminals like Strings and numbers.
 * 
 * I didn't find a way to reuse that from the xtext editor, so I had to made part of that again
 * here with my own code.
 * 
 * @author jfernandes
 */
class WollokConsoleHighlighter {
	var KEYWORD_COLOR = new Color(null, new RGB(127, 0, 85))
	var STRING_COLOR = new Color(null, new RGB(42, 0, 255))
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, Keyword it, LineStyleEvent event, int headerLength) { 
		if (value.length > 1) {
			val s = new StyleRange(event.lineOffset + n.offset - headerLength, n.length, KEYWORD_COLOR, null, SWT.BOLD)
			s.data = "KEYWORD"
			styles.merge(s)
		}
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, RuleCall it, LineStyleEvent event, int headerLength) {
		if ("STRING" == rule.name) {
			val s = new StyleRange(event.lineOffset + n.offset - headerLength, n.length, STRING_COLOR, null)
			s.data = "STRING"
			styles.merge(s)
		}
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, EObject it, LineStyleEvent event, int headerLength) {
//		println("UNKNOWN " + it.grammarDescription)
	}

	def dispatch processASTNode(List<StyleRange> styles, INode n, Void it, LineStyleEvent event, int headerLength) { }
	
}