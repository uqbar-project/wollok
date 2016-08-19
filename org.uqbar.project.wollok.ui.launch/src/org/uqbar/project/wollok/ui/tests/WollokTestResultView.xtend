package org.uqbar.project.wollok.ui.tests

import java.util.Observable
import java.util.Observer
import javax.inject.Inject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.jface.resource.LocalResourceManager
import org.eclipse.jface.resource.ResourceManager
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.ITreeSelection
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.swt.widgets.ToolBar
import org.eclipse.swt.widgets.ToolItem
import org.eclipse.ui.part.ViewPart
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.GlobalURIEditorOpener
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.tests.model.WollokTestContainer
import org.uqbar.project.wollok.ui.tests.model.WollokTestResult
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults
import org.uqbar.project.wollok.ui.tests.model.WollokTestState
import org.uqbar.project.wollok.ui.tests.shortcut.WollokTestLaunchShortcut

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * 
 * @author tesonep
 */
class WollokTestResultView extends ViewPart implements Observer {
	public val static NAME = "org.uqbar.project.wollok.ui.launch.resultView"

	var TreeViewer testTree
	var Text textOutput
	var Text totalTextBox
	var Text runTextBox
	var Text errorTextBox
	// bar
	var Label bar
	Color noResultColor
	Color successColor
	Color failedColor
	var ResourceManager resManager
	public val static BAR_COLOR_NO_RESULT = new RGB(200, 200, 200)
	public val static BAR_COLOR_SUCCESS = new RGB(99, 184, 139)
	public val static BAR_COLOR_FAILED = new RGB(237, 17, 18)
	
	@Inject
	var WollokTestResults results
	@Inject
	var GlobalURIEditorOpener opener

	@Inject
	WollokTestLaunchShortcut testLaunchShortcut
	
	ToolBar toolbar
	
	ToolItem runAgain
	
	ToolItem debugAgain

	def canRelaunch(){
		results != null && results.container != null && results.container.mainResource != null
	}

	def relaunch(){
		this.relaunch("run")
	}
	
	def relaunchDebug(){
		this.relaunch("debug")
	}

	def relaunch(String mode){
		testLaunchShortcut.launch(results.container.mainResource.toIFile, mode)
	}

	override createPartControl(Composite parent) {
		resManager = new LocalResourceManager(JFaceResources.getResources(), parent);	
		new GridLayout() => [
			marginWidth = 0
			marginHeight = 0
			numColumns = 1
			verticalSpacing = 2
			parent.setLayout(it)
		]
		createToolbar(parent)
		createResults(parent)
		createBar(parent)
		createTree(parent)
		createTextOutput(parent)
	}

	def createToolbar(Composite parent){
		toolbar = new ToolBar(parent, SWT.RIGHT)
		
		GridDataFactory.fillDefaults().align(SWT.END, SWT.CENTER).grab(true, false).applyTo(toolbar)
		
		runAgain = new ToolItem(toolbar, SWT.PUSH) => [
			toolTipText = 'Run Again'
			image = resManager.createImage(Activator.getDefault.getImageDescriptor("icons/runlast_co.gif"))
			addListener(SWT.Selection) [ this.relaunch ]
			enabled = false
		]

		debugAgain = new ToolItem(toolbar, SWT.PUSH) => [
			toolTipText = 'Debug Again'
			image = resManager.createImage(Activator.getDefault.getImageDescriptor("icons/debuglast_co.gif"))
			addListener(SWT.Selection) [ this.relaunchDebug ]
			enabled = false
		]
	}
	
	def createBar(Composite parent) {
		bar = new Label(parent, SWT.BORDER)
		// creates and cache colors
		noResultColor =  resManager.createColor(BAR_COLOR_NO_RESULT);
		successColor = resManager.createColor(BAR_COLOR_SUCCESS)
		failedColor = resManager.createColor(BAR_COLOR_FAILED)
				
		bar.background = noResultColor 
		new GridData => [
			heightHint = 28
			verticalIndent = 2
			horizontalIndent = 4  
			grabExcessHorizontalSpace = true
//			grabExcessVerticalSpace = true
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.CENTER
//			verticalAlignment = GridData.FILL
			bar.layoutData = it
		]
	}
	
	def createTree(Composite parent) {
		testTree = new TreeViewer(parent, SWT.V_SCROLL.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.SINGLE))
		testTree.contentProvider = new WTestTreeContentProvider => [
			it.results = results			
		]
		testTree.input = results
		testTree.labelProvider = new WTestTreeLabelProvider
		
		testTree.addSelectionChangedListener [
			textOutput.text = if (selection.empty) "" else getOutputText((selection as ITreeSelection).firstElement)
		]
		
		testTree.addDoubleClickListener [ e | 
			if (!e.selection.empty)
				(e.selection as ITreeSelection).firstElement.openElement
		]
		testTree.refresh
		results.addObserver(this)
		
		new GridData => [
			grabExcessHorizontalSpace = true
			grabExcessVerticalSpace = true
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.FILL
			verticalSpan = 5
			testTree.control.layoutData = it	
		]
	}
	
	def createTextOutput(Composite parent) {
		textOutput = new Text(parent, 
			SWT.MULTI
			.bitwiseOr(SWT.WRAP)
			.bitwiseOr(SWT.BORDER)
			.bitwiseOr(SWT.V_SCROLL)
		);
		textOutput.editable = false
		new GridData => [
			grabExcessHorizontalSpace = true
			grabExcessVerticalSpace = true
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.FILL
			verticalSpan = 5
			textOutput.layoutData = it
		]
	}

	def createResults(Composite parent){
		val panel = new Composite(parent,SWT.NONE)
		
		new GridLayout => [
			marginWidth = 0
			marginHeight = 0
			numColumns = 9
			verticalSpacing = 0
			horizontalSpacing = 4
			panel.setLayout(it)
		]
		
		createResultNumberLabel(panel, WollokLaunchUIMessages.WollokTestResultView_TOTAL_TESTS)
		totalTextBox = createResultNumberTextBox(panel)

		createResultNumberLabel(panel, WollokLaunchUIMessages.WollokTestResultView_RUN_TESTS)
		runTextBox = createResultNumberTextBox(panel)

		createResultNumberLabel(panel, WollokLaunchUIMessages.WollokTestResultView_ERROR_TESTS)
		errorTextBox = createResultNumberTextBox(panel)
	}
	
	def createResultNumberLabel(Composite panel, String labelText) {
		new Label(panel, SWT.NONE) => [
			text = labelText
		]
	}
	
	def createResultNumberTextBox(Composite panel) {
		new Text(panel, SWT.BORDER) => [
			it.layoutData = new GridData => [
				horizontalSpan = 2 
				widthHint = 30	
			]
			editable = false			
		]
	}

	override dispose() {
		super.dispose
		resManager.dispose
		results.deleteObserver(this)
	}

	override update(Observable o, Object arg) {
		testTree.refresh(true)
		testTree.expandAll
		
		if (results.container != null) {
			totalTextBox.text = total.toString
			runTextBox.text = (total - count[state == WollokTestState.PENDING]).toString
			val errorCount = count[ state == WollokTestState.ASSERT || state == WollokTestState.ERROR]
			errorTextBox.text = errorCount.toString
			
			bar.background = if (errorCount > 0) failedColor else successColor
			
			runAgain.enabled = true
			debugAgain.enabled = true
		}
		else {
			totalTextBox.text = ""
			runTextBox.text = ""
			errorTextBox.text = ""
			runAgain.enabled = false
			debugAgain.enabled = false
		}
	}
	
	def count((WollokTestResult)=>Boolean predicate) {
		results.container.tests.filter(predicate).size
	}
	
	def total() {
		results.container.tests.size
	}

	override setFocus() {
	}
	
	def dispatch openElement(WollokTestContainer container) {
		opener.open(container.mainResource, true)
	}
	
	def dispatch openElement(WollokTestResult result) {
		opener.open(result.state.getURI(result), true)
	}
	
	def dispatch getOutputText(WollokTestContainer container) { "" }
	
	def dispatch getOutputText(WollokTestResult result) {
		result.state.getOutputText(result)
	}
}

class WTestTreeLabelProvider extends LabelProvider {

	private ResourceManager resourceManager = new LocalResourceManager(JFaceResources.getResources());
	
	def dispatch getImage(WollokTestResult element) {
		element.state.getImage(resourceManager)
	}

	def dispatch getImage(Object element) {
        var imageDescriptor = Activator.getDefault.getImageDescriptor("icons/w.png")
        resourceManager.createImage(imageDescriptor)
	}

	def dispatch getText(WollokTestContainer element) {
		val base = URI.createURI(ResourcesPlugin.getWorkspace.root.locationURI.toString + "/")
		element.mainResource.deresolve(base).toFileString
	}

	def dispatch getText(WollokTestResult element) {
		element.testInfo.name
	}
	override def dispose(){
		super.dispose
		resourceManager.dispose
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
	
	override dispose() {}
	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {}

}
