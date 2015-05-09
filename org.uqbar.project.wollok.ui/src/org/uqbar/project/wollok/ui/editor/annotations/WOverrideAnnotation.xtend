package org.uqbar.project.wollok.ui.editor.annotations

import org.eclipse.jface.text.source.Annotation
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A marker on wollok editor that represents the fact
 * that a given WMethodDeclaration overrides another one.
 * 
 * @author jfernandes
 */
@Accessors
class WOverrideAnnotation extends Annotation {
	public static val ANNOTATION_TYPE = "org.uqbar.project.wollok.ui.overrideIndicator"
	String methodURI
	
	new(String text, WMethodDeclaration method) {
		super(ANNOTATION_TYPE, false, text);
		this.methodURI = method.objectURI
	}
	
}