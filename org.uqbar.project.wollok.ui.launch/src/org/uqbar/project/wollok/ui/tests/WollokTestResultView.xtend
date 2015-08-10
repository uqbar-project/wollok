package org.uqbar.project.wollok.ui.tests

import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart
import org.uqbar.project.wollok.ui.launch.Activator

class WollokTestResultView extends ViewPart {

	public val static NAME = "org.uqbar.project.wollok.ui.launch.resultView"
	 
	new() {
		super()
		Activator.getDefault().wollokTestResultView = this		
	}
	
	var TreeViewer testTree
	
	override createPartControl(Composite parent) {
		new GridLayout() => [
			marginWidth = 0
			marginHeight = 0
			numColumns = 1
			verticalSpacing = 2
			parent.setLayout(it)
		]
		
		testTree = new TreeViewer(parent, SWT.V_SCROLL) 
		testTree.contentProvider = new WTestsContentProvider
		testTree.input = "x"
		
		val layoutData = new GridData();
		layoutData.grabExcessHorizontalSpace = true;
		layoutData.grabExcessVerticalSpace = true;
		layoutData.horizontalAlignment = GridData.FILL;
		layoutData.verticalAlignment = GridData.FILL;
		testTree.control.layoutData = layoutData;
	}
	
	override setFocus() {
		
	}
	
	static def getView(){
		Activator.getDefault.wollokTestResultView
	}
}