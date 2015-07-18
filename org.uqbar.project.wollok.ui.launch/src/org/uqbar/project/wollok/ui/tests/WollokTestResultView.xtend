package org.uqbar.project.wollok.ui.tests

import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT

class WollokTestResultView extends ViewPart {
	
	var TreeViewer testTree
	
	override createPartControl(Composite parent) {
		new GridLayout() => [
			marginWidth = 0;
			marginHeight = 0;
			parent.setLayout(it);
		]
		
		testTree = new TreeViewer(parent, SWT.V_SCROLL) 
	}
	
	override setFocus() {
		
	}
	
}