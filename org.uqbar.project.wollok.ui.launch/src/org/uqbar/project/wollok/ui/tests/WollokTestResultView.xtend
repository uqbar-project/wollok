package org.uqbar.project.wollok.ui.tests

import java.util.Observable
import java.util.Observer
import javax.inject.Inject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.ITreeSelection
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.part.ViewPart
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.GlobalURIEditorOpener
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.tests.model.WollokTestContainer
import org.uqbar.project.wollok.ui.tests.model.WollokTestResult
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults
import org.uqbar.project.wollok.ui.tests.model.WollokTestState
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages

class WollokTestResultView extends ViewPart implements Observer {

	public val static NAME = "org.uqbar.project.wollok.ui.launch.resultView"

	var TreeViewer testTree
	var Text textOutput
	
	var Text totalTextBox;
	var Text runTextBox;
	var Text errorTextBox;

	@Inject
	var WollokTestResults results
	
	@Inject
	var GlobalURIEditorOpener opener;

	override createPartControl(Composite parent) {
		new GridLayout() => [
			marginWidth = 0
			marginHeight = 0
			numColumns = 1
			verticalSpacing = 2
			parent.setLayout(it)
		]
		
		createResults(parent)

		testTree = new TreeViewer(parent, SWT.V_SCROLL.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.SINGLE))
		var WTestTreeContentProvider contentProvider = new WTestTreeContentProvider
		contentProvider.results = results

		testTree.contentProvider = contentProvider
		testTree.input = results
		testTree.labelProvider = new WTestTreeLabelProvider

		testTree.addSelectionChangedListener[e |
			if(e.selection.empty){
				textOutput.text = ""
			}else{
				val sel = e.selection as ITreeSelection
				textOutput.text = getOutputText(sel.firstElement)
			}
		]

		testTree.addDoubleClickListener[ e | 
			if(!e.selection.empty){
				val s = e.selection as ITreeSelection
				s.firstElement.openElement
			}
		]


		testTree.refresh

		results.addObserver(this)

		val layoutData = new GridData();
		layoutData.grabExcessHorizontalSpace = true;
		layoutData.grabExcessVerticalSpace = true;
		layoutData.horizontalAlignment = GridData.FILL;
		layoutData.verticalAlignment = GridData.FILL;
		testTree.control.layoutData = layoutData;

		val layoutDataText = new GridData();
		layoutDataText.grabExcessHorizontalSpace = true;
		layoutDataText.grabExcessVerticalSpace = true;
		layoutDataText.horizontalAlignment = GridData.FILL;
		layoutDataText.verticalAlignment = GridData.FILL;
		
		textOutput = new Text(parent, SWT.MULTI.bitwiseOr(SWT.WRAP).bitwiseOr(SWT.BORDER));
		textOutput.editable = false
		textOutput.layoutData = layoutDataText;
	}

	def createResults(Composite parent){
		val panel = new Composite(parent,SWT.NONE)
		
		new GridLayout() => [
			marginWidth = 0
			marginHeight = 0
			numColumns = 9
			verticalSpacing = 0
			horizontalSpacing = 4
			panel.setLayout(it)
		]
		
		val layoutData = new GridData();
		layoutData.horizontalSpan = 2 
		layoutData.widthHint = 30
		
		new Label(panel, SWT.NONE) => [
			text = WollokLaunchUIMessages.WollokTestResultView_TOTAL_TESTS;
		]
		
		totalTextBox = new Text(panel, SWT.BORDER);
		totalTextBox.layoutData = layoutData
		totalTextBox.editable = false

		new Label(panel, SWT.NONE) => [
			text = WollokLaunchUIMessages.WollokTestResultView_RUN_TESTS;
		]

		runTextBox = new Text(panel, SWT.BORDER);
		runTextBox.layoutData = layoutData
		runTextBox.editable = false

		new Label(panel, SWT.NONE) => [
			text = WollokLaunchUIMessages.WollokTestResultView_ERROR_TESTS;
		]

		errorTextBox = new Text(panel, SWT.BORDER);
		errorTextBox.layoutData = layoutData
		errorTextBox.editable = false
	}

	override dispose() {
		super.dispose()
		results.deleteObserver(this)
	}

	override update(Observable o, Object arg) {
		testTree.refresh(true)
		testTree.expandAll
		
		if(results.container != null){
			totalTextBox.text = results.container.tests.size.toString;
			runTextBox.text = (results.container.tests.size - results.container.tests.filter[ state == WollokTestState.PENDING].size).toString
			errorTextBox.text = (results.container.tests.filter[ state == WollokTestState.ASSERT || state == WollokTestState.ERROR].size).toString
		}else{
			totalTextBox.text = ""
			runTextBox.text = ""
			errorTextBox.text = ""
		}
	}

	override setFocus() {
	}
	
	def dispatch openElement(WollokTestContainer container){
		opener.open(container.mainResource, true)
	}
	
	def dispatch openElement(WollokTestResult result){
		opener.open(result.state.getURI(result), true)
	}
	
	def dispatch getOutputText(WollokTestContainer container){
		""
	}
	
	def dispatch getOutputText(WollokTestResult result){
		result.state.getOutputText(result)
	}
}

class WTestTreeLabelProvider extends LabelProvider {

	def dispatch getImage(WollokTestResult element) {
		element.state.image
	}

	def dispatch getImage(Object element) {
		Activator.getDefault.getImageDescriptor("icons/w.png").createImage
	}

	def dispatch getText(WollokTestContainer element) {
		val base = URI.createURI(ResourcesPlugin.getWorkspace.root.locationURI.toString + "/")
		element.mainResource.deresolve(base).toFileString
	}

	def dispatch getText(WollokTestResult element) {
		element.testInfo.name
	}

}

class WTestTreeContentProvider implements ITreeContentProvider {

	@Accessors
	var WollokTestResults results

	def dispatch getChildren(WollokTestResults element) {
		if (element.container == null)
			newArrayOfSize(0)
		else
			#[element.container]
	}

	def dispatch getChildren(WollokTestContainer element) {
		element.tests
	}

	def dispatch getChildren(WollokTestResult element) {
		newArrayList(0)
	}

	def dispatch getElements(WollokTestResults inputElement) {
		if (inputElement.container == null)
			return newArrayOfSize(0)
		else
			return #[inputElement.container]
	}

	def dispatch getElements(WollokTestContainer inputElement) {
		inputElement.tests
	}

	def dispatch getElements(WollokTestResult inputElement) {
		newArrayList(0)
	}

	def dispatch getParent(WollokTestResults element) { null }

	def dispatch getParent(WollokTestContainer element) { results }

	def dispatch getParent(WollokTestResult element) { results.container }

	def dispatch hasChildren(WollokTestContainer element) { true }

	def dispatch hasChildren(WollokTestResults element) { true }

	def dispatch hasChildren(Object element) { false }

	override dispose() {
	}

	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}

}
