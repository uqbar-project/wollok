package org.uqbar.project.wollok.ui.console.editor

import org.eclipse.jface.text.DocumentEvent
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.ITypedRegion
import org.eclipse.ui.console.IConsoleDocumentPartitioner
import org.uqbar.project.wollok.ui.console.WollokReplConsole

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokReplConsolePartitioner implements IConsoleDocumentPartitioner {
	val WollokReplConsole console
	var ITypedRegion partition
	
	new(WollokReplConsole console) {
		this.console = console
	}
	
	override getContentType(int offset) { IDocument.DEFAULT_CONTENT_TYPE }
	override isReadOnly(int offset) { offset < console.outputTextEnd }
	override computePartitioning(int offset, int length) { #[getPartition(offset)] }
	override getLegalContentTypes() { #[IDocument.DEFAULT_CONTENT_TYPE] }
	
	override getStyleRanges(int offset, int length) { null }
	override connect(IDocument document) { }
	override disconnect() { }
	override documentAboutToBeChanged(DocumentEvent event) { }
	override documentChanged(DocumentEvent event) {	true }
	
	override getPartition(int offset) {
		if (partition === null) {
           // DUMMY partition (1 partition for the whole doc)
           partition = new ITypedRegion() {
                   override getType() { IDocument.DEFAULT_CONTENT_TYPE }
                   override getLength() { console.document.length }
                   override getOffset() { 0 }
           }
        }
        partition
	}
}
