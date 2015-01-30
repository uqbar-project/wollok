package org.uqbar.project.wollok.ui.editor.hyperlinking

import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkHelper

/**
 * Extends the default hyperlink helper
 * in order to include navigation for messages->methods.
 * At least for those that have been inferred by the
 * type system.
 * There are cases were using structural types were
 * you cannot have a reference to a particular method
 * 
 * // TODO:
 * (Actually in the future it should search all over types
 * to find compatible methods and suggest you a list of options)
 * 
 * @author jfernandes
 */
class WollokHyperlinkHelper extends HyperlinkHelper {
	
	
	
}