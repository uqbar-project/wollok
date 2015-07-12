package org.uqbar.project.wollok.ui.editor

import org.eclipse.jdt.internal.ui.JavaPlugin
import org.eclipse.jdt.internal.ui.text.javadoc.JavaDocScanner
import org.eclipse.jface.text.rules.DefaultDamagerRepairer
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.xtext.ui.editor.XtextPresentationReconciler
import org.eclipse.xtext.ui.editor.XtextSourceViewerConfiguration
import org.uqbar.project.wollok.ui.autoedit.TokenTypeToPartitionMapper

/**
 * 
 * @author jfernandes
 */
class WollokSourceViewerConfiguration extends XtextSourceViewerConfiguration {
	
	override getPresentationReconciler(ISourceViewer sourceViewer) {
		val reconciler = super.getPresentationReconciler(sourceViewer) as XtextPresentationReconciler
		val store = JavaPlugin.getDefault().getCombinedPreferenceStore();
		val colorManager = JavaPlugin.getDefault().getJavaTextTools().getColorManager();
		val javaDocScanner = new JavaDocScanner(colorManager, store, null);
		val dr = new DefaultDamagerRepairer(javaDocScanner);
		reconciler.setRepairer(dr, TokenTypeToPartitionMapper.JAVA_DOC_PARTITION);
		reconciler.setDamager(dr, TokenTypeToPartitionMapper.JAVA_DOC_PARTITION);
		return reconciler;
	}
	
}