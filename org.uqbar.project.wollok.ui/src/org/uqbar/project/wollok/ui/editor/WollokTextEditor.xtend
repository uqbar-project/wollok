package org.uqbar.project.wollok.ui.editor

import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.core.runtime.IProgressMonitor

/**
 * I had to subclass the editor to add breakpoints.
 * Because the adapter conflicted with some others.
 * See https://bugs.eclipse.org/bugs/show_bug.cgi?id=422633
 * 
 * 
 * @author jfernandes
 */
class WollokTextEditor extends XtextEditor {
	
	public static String ID = "org.uqbar.project.wollok.WollokDsl"
	
}