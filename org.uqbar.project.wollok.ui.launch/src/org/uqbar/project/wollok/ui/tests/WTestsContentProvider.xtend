package org.uqbar.project.wollok.ui.tests

import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.Viewer

class WTestsContentProvider implements ITreeContentProvider {
	
	override getChildren(Object parentElement) {
		newArrayOfSize(0)
	}
	
	override getElements(Object inputElement) {
		#[]
	}
	
	override getParent(Object element) {
		null
	}
	
	override hasChildren(Object element) {
		false
	}
	
	override dispose() {
		
	}
	
	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}
}