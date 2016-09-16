package org.uqbar.project.wollok.ui.console.highlight

import com.google.inject.Inject
import java.io.ByteArrayInputStream
import java.util.List
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.custom.StyledText
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.syntaxcoloring.TextAttributeProvider
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.ui.launch.Activator

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*
import static extension org.uqbar.project.wollok.ui.console.highlight.WTextExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.eclipse.xtext.diagnostics.Severity

/**
 * A line style listener for the console to highlight code
 * based on xtext infrastructure.
 * 
 * Hooks into the REPL console and computes style ranges:
 * It shows the following styles:
 * <li>WollokHighlightingCalculator: customs styles like parameters vs instvars and local vars</li>
 * <li>WollokConsoleHighlighter: some homemade styles similars to those in the editor (ie. strings, keywords, numbers)</li>
 * <li>Parser errors: in red while the user is typing</li>
 * 
 * @author jfernandes
 */
class WollokCodeHighLightLineStyleListener implements LineStyleListener {
	val static PROMPT = ">>> " // duplicated from WollokRepl
	val static PROMPT_REPLACEMENT = "    "

	val static PROMPT_ANSI = "\u001b[36m>>> [m"

	var PARSER_ERROR_COLOR = newColor(255, 0, 0)

	val programHeader = "program repl {" + System.lineSeparator
	val programFooter = System.lineSeparator + "}"
	val headerLength = programHeader.length

	@Inject ISemanticHighlightingCalculator calculator
	@Inject TextAttributeProvider stylesProvider
	@Inject XtextResourceSet resourceSet
	WollokConsoleHighlighter highlighter
	WollokChecker checker

	new() {
		Activator.getDefault.injector.injectMembers(this)
		highlighter = new WollokConsoleHighlighter // TODO: inject
		checker = new WollokChecker
	}

	override lineGetStyle(LineStyleEvent event) {
		if (event == null || event.lineText == null || event.lineText.length == 0 || !event.isCodeInputLine)
			return;

		val originalText = (event.widget as StyledText).text
		val escaped = escape(event.lineText)
		val resource = parseIt(programHeader + escaped + programFooter)
		val footerOffset = programHeader.length + escaped.length

		// original highlights (from other listeners)
		val List<StyleRange> styles = event.styles.filter[length > 0].sortBy[start].toList

		// add custom highlights
		calculator.provideHighlightingFor(resource) [ offset, length, styleIds |
			val styleId = styleIds.get(0) // just get the first one ??
			val style = stylesProvider.getAttribute(styleId)

			val s = new StyleRange(event.lineOffset + offset - headerLength, length, style.foreground, style.background)
			s.data = styleId

			if (s.start <= originalText.length && s.end <= originalText.length) {
				styles.merge(s)
			}
		]

		// try to imitate some styles as the editor "manually"
		resource.contents.get(0).node.asTreeIterable
			.filter [offset > programHeader.length && offset < footerOffset]
			.forEach [n | highlighter.processASTNode(styles, n, n.grammarElement, event, headerLength) ]
	
		// highlight errors
		resource.parseResult.syntaxErrors.filter[offset > programHeader.length && offset < footerOffset].map [
			parserError(event, offset, Math.min(length, footerOffset))
		].forEach[styles.merge(it)]

		// validations (checks)
		checker.validate(Activator.getDefault.injector, resource, [], [ issues |
			issues.filter[severity != Severity.WARNING].forEach[checkerError(event, offset, length)]
		])

		// REVIEW: I think this is not needed since we touch the original list
		event.styles = styles.sortBy[start].toList

		// FIX exceeding styles
		event.styles.filter[it != null && end > originalText.length].forEach [
			length = originalText.length - start
		]

		safelyPrintStyles(event, originalText)
	}

	// *******************************************
	// ** hand-made rules for base lang elements to imitate
	// ** the editor styles. Because I don't know how to reuse that highlight
	// ** THIS SHOULD BE EXTRACTED TO A STRATEGY CLASS
	// *******************************************
	def parseIt(String content) {
		new XtextResource => [
			URI = resourceSet.computeUnusedUri("__repl_synthetic")
			Activator.getDefault.injector.injectMembers(it)
			load(new ByteArrayInputStream(content.bytes), #{})
		]
	}

	def checkerError(LineStyleEvent event, Integer offset, Integer length) {
		errorStyle(event, offset, length, "CHECK_ERROR")
	}

	def parserError(LineStyleEvent event, Integer offset, Integer length) {
		errorStyle(event, offset, length, "PARSER_ERROR")
	}

	def errorStyle(LineStyleEvent event, Integer offset, Integer length, String type) {
		val theOffset = if(offset != null) offset else programHeader.length
		val theLength = if(length != null) length else event.lineText.length
		new StyleRange(event.lineOffset + (theOffset - programHeader.length), theLength, PARSER_ERROR_COLOR, null,
			SWT.ITALIC) => [
			data = type
		]
	}

	def static escape(String text) { text.escapeAnsi.replaceAll(PROMPT, PROMPT_REPLACEMENT) }

	def isCodeInputLine(LineStyleEvent it) { lineText.startsWith(PROMPT) || lineText.startsWith(PROMPT_ANSI) }

	protected def safelyPrintStyles(LineStyleEvent event, String originalText) {
//		if (!event.styles.empty) {
//			event.styles.filter[it != null].sortBy[start].toList.forEach[
//				try {
//					println('''[«start»,«start + length», «data», "«originalText.substring(start, end)»"]''')
//				}
//				catch (StringIndexOutOfBoundsException e) {
//					println('''//////////////// BOOM !: text size «originalText.length» and OFFENDING STYLE: «it»''')
//					// cutting it
//					length = originalText.length - start
//				}
//			]
//		}
	}
}
