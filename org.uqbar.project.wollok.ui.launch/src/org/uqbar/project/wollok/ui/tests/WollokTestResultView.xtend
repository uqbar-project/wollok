package org.uqbar.project.wollok.ui.tests

import java.util.Observable
import java.util.Observer
import javax.inject.Inject
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
import org.eclipse.osgi.util.NLS
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.SashForm
import org.eclipse.swt.custom.ScrolledComposite
import org.eclipse.swt.dnd.Clipboard
import org.eclipse.swt.dnd.DND
import org.eclipse.swt.dnd.RTFTransfer
import org.eclipse.swt.dnd.TextTransfer
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Link
import org.eclipse.swt.widgets.Text
import org.eclipse.swt.widgets.ToolBar
import org.eclipse.swt.widgets.ToolItem
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.GlobalURIEditorOpener
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.tests.model.WollokTestContainer
import org.uqbar.project.wollok.ui.tests.model.WollokTestFileContainer
import org.uqbar.project.wollok.ui.tests.model.WollokTestGlobalContainer
import org.uqbar.project.wollok.ui.tests.model.WollokTestResult
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults
import org.uqbar.project.wollok.ui.tests.model.WollokTestState
import org.uqbar.project.wollok.ui.tests.shortcut.WollokAllTestsLaunchShortcut
import org.uqbar.project.wollok.ui.tests.shortcut.WollokTestLaunchShortcut
import org.uqbar.project.wollok.utils.WEclipseUtils

import static extension org.uqbar.project.wollok.utils.StringUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * @author tesonep
 * @author dodain
 */
class WollokTestResultView extends ViewPart implements Observer {
	public val static NAME = "org.uqbar.project.wollok.ui.launch.resultView"

	// opening tag "[<a href=\"" + fileName + STACKELEMENT_SEPARATOR + lineNumber + "\">"
	public static String STACK_TRACE_LINK_OPENING_TAG = "\\[<(?:\"[^\"]*\"['\"]*|'[^']*'['\"]*|[^'\">])+>"
	// closing tag "</a>]\n"
	public static String STACK_TRACE_LINK_CLOSING_TAG = "<(?:\"[^\"]*\"['\"]*|'[^']*'['\"]*|[^'\">])+>\\]"

	TreeViewer testTree
	Link textOutput
	Text totalTextBox
	Text failedTextBox
	Text errorTextBox
	// bar
	Label bar
	Color noResultColor
	Color pendingColor
	Color successColor
	Color failedColor
	Color erroredColor
	ResourceManager resManager

	public val static BAR_COLOR_NO_RESULT = new RGB(200, 200, 200)
	public val static BAR_COLOR_PENDING = new RGB(239, 222, 205)
	public val static BAR_COLOR_SUCCESS = new RGB(99, 184, 139)
	public val static BAR_COLOR_FAILED = new RGB(255, 197, 3)
	public val static BAR_COLOR_ERRORED = new RGB(237, 17, 18)

	@Inject
	WollokTestResults results
	@Inject
	GlobalURIEditorOpener opener

	@Inject
	WollokTestLaunchShortcut testLaunchShortcut

	@Inject
	WollokAllTestsLaunchShortcut allTestsLaunchShortcut

	// First toolbar
	ToolBar toolbar
	ToolItem showFailuresAndErrors
	ToolItem runAgain
//	ToolItem debugAgain

	// Second toolbar
	Label lblMilliseconds
	Button copyTextOutputToClipboard

//	static IViewPart previousActivePart

	def static activate() {
		RunInUI.runInUI [
			// issue #1266 - dodain - this fixes the problem
			// but only when Wollok Tests are in a different tab that Project Explorer 
			// val activePart = activePage?.activePart
			//if (activePart !== null && !(activePart instanceof WollokTestResultView)) {
			//	previousActivePart = activePage?.activePart as IViewPart
			//}
			// 
		    val view = openView(WollokTestResultView.NAME)
			(view as WollokTestResultView).cleanView
		]
	}

	def canRelaunch() {
		results !== null && results.fileContainer !== null && results.fileContainer.mainResource !== null
	}

	def relaunch() {
		this.relaunch("run")
	}

	def relaunchDebug() {
		this.relaunch("debug")
	}

	def relaunch(String mode) {
		if (results.globalContainer.processingManyFiles) {
			allTestsLaunchShortcut.launch(results.globalContainer.project, mode)
		} else {
			testLaunchShortcut.launch(testFile, mode)
		}
	}

	/** this method is invoked between test executions */
	def cleanView() {
		bar.background = pendingColor
		bar.text = Messages.WollokTestResultView_runningTests
		totalTextBox.text = ""
		failedTextBox.text = ""
		errorTextBox.text = ""
		lblMilliseconds.text = ""
		runAgain.enabled = false
		//debugAgain.enabled = false
		(testTree.contentProvider as WTestTreeContentProvider).results.globalContainer = new WollokTestGlobalContainer()
		testTree.refresh(true)
	}

	def testFile() {
		results.getFileContainer.mainResource.toIFile
	}

	def toggleShowFailuresAndErrors() {
		results.showFailuresAndErrorsOnly(showFailuresAndErrors.selection)
	}

	def copySelectedTextOutputToClipboard() {
		val clipboard = new Clipboard(Display.current)
        val plainText = textOutput.text.parseLinksToPlain
        val rtfText = "{\\rtf1\\deff0{\\fonttbl {\\f0 \\fcharset0 Ubuntu Mono;}}" + textOutput.text.parseLinksToRTF + "}"
        val data = #[rtfText, plainText]
		val types = #[RTFTransfer.instance, TextTransfer.instance]
        clipboard.setContents(data, types, DND.CLIPBOARD)
        clipboard.dispose()
	}
	
	def String parseLinksToPlain(String text) {
    	text.replaceAll(STACK_TRACE_LINK_OPENING_TAG, "")
			.replaceAll(STACK_TRACE_LINK_CLOSING_TAG, "")
	}

	def String parseLinksToRTF(String text) {
    	text.replaceAll("\n", "\\\\line")
    		.replaceAll("\t", "\\\\tab")
    		.replaceAll(STACK_TRACE_LINK_OPENING_TAG, "")
			.replaceAll(STACK_TRACE_LINK_CLOSING_TAG, "")
	}
	
	override createPartControl(Composite parent) {
		parent.background = new Color(Display.current, new RGB(220, 220, 220))
		resManager = new LocalResourceManager(JFaceResources.getResources(), parent)
		new GridLayout() => [
			marginWidth = 5
			marginHeight = 5
			numColumns = 1
			verticalSpacing = 1
			parent.setLayout(it)
			parent.setLayoutData(new GridData => [
				horizontalAlignment = GridData.FILL
				verticalAlignment = GridData.FILL
				grabExcessHorizontalSpace = true
				grabExcessVerticalSpace = true
				horizontalSpan = 2
			])
		]
		createToolbar(parent)
		createSeparator(parent)
		createResults(parent)
		createBar(parent)
		val sash = new Composite(parent, SWT.NONE) => [
			layout = new FillLayout
			layoutData = new GridData(GridData.FILL_BOTH)
		]
		val sashForm = new SashForm(sash, SWT.VERTICAL)
		createTree(sashForm)
		createTextOutput(sashForm)
		createToolbarForTextOutput(parent)
	}

	def createSeparator(Composite parent) {
		val separator = new Label(parent, SWT.HORIZONTAL.bitwiseOr(SWT.SEPARATOR))
		separator.layoutData = new GridData(GridData.FILL_HORIZONTAL)
	}

	def createToolbar(Composite parent) {
		toolbar = new ToolBar(parent, SWT.RIGHT)

		GridDataFactory.fillDefaults().align(SWT.END, SWT.BEGINNING).grab(true, false).applyTo(toolbar)

		showFailuresAndErrors = new ToolItem(toolbar, SWT.CHECK) => [
			toolTipText = Messages.WollokTestResultView_showOnlyFailuresAndErrors
			val pathImage = Activator.getDefault.getImageDescriptor(
				"platform:/plugin/org.eclipse.jdt.junit/icons/full/obj16/failures.gif")
			image = resManager.createImage(pathImage)
			addListener(SWT.Selection)[this.toggleShowFailuresAndErrors]
			enabled = true
		]

		runAgain = new ToolItem(toolbar, SWT.PUSH) => [
			toolTipText = Messages.WollokTestResultView_runAgain
			val pathImage = Activator.getDefault.getImageDescriptor(
				"platform:/plugin/org.eclipse.jdt.junit/icons/full/elcl16/relaunch.gif")
			image = resManager.createImage(pathImage)
			addListener(SWT.Selection)[this.relaunch]
			enabled = false
		]

//		debugAgain = new ToolItem(toolbar, SWT.PUSH) => [
//			toolTipText = Messages.WollokTestResultView_debugAgain
//			image = resManager.createImage(
//				Activator.getDefault.getImageDescriptor(
//					"platform:/plugin/org.eclipse.debug.ui/icons/full/elcl16/debuglast_co.png"))
//			addListener(SWT.Selection)[this.relaunchDebug]
//			enabled = false
//		]
	}

	def createBar(Composite parent) {
		bar = new Label(parent, SWT.SHADOW_IN.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.CENTER))
		// creates and cache colors
		noResultColor = resManager.createColor(BAR_COLOR_NO_RESULT)
		pendingColor = resManager.createColor(BAR_COLOR_PENDING)
		successColor = resManager.createColor(BAR_COLOR_SUCCESS)
		failedColor = resManager.createColor(BAR_COLOR_FAILED)
		erroredColor = resManager.createColor(BAR_COLOR_ERRORED)

		bar.background = noResultColor
		new GridData => [
			heightHint = 18
			verticalIndent = 4
			horizontalIndent = 2
			grabExcessHorizontalSpace = true
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.FILL
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
			textOutput.text = if(selection.empty) "" else getOutputText((selection as ITreeSelection).firstElement)
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
		val textParent = new ScrolledComposite(parent, SWT.BORDER.bitwiseOr(SWT.WRAP.bitwiseOr(SWT.V_SCROLL.bitwiseOr(SWT.H_SCROLL))))
		val parentGridLayout = new GridLayout => [
			marginWidth = 0
			marginHeight = 0
		]
		textParent => [
			layout = parentGridLayout
			layoutData = new GridData
			expandHorizontal = true
			expandVertical = true
			setMinSize(300, 300)
		]
		textOutput = new Link(
			textParent,
			SWT.BORDER.bitwiseOr(SWT.WRAP).bitwiseOr(SWT.MULTI).bitwiseOr(SWT.V_SCROLL).bitwiseOr(SWT.H_SCROLL)
		) => []
		textOutput.background = new Color(Display.current, 255, 255, 255)
		textOutput.foreground = new Color(Display.current, 50, 50, 50)

		new GridData => [
			minimumHeight = 80
			grabExcessHorizontalSpace = true
			grabExcessVerticalSpace = true
			horizontalAlignment = GridData.FILL
			verticalAlignment = GridData.FILL
			verticalSpan = 5
			textOutput.layoutData = it
		]

		textOutput.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent event) {
					val fileOpenerStrategy = AbstractWollokFileOpenerStrategy.buildOpenerStrategy(event.text,
						results.container.project)
					val ITextEditor textEditor = fileOpenerStrategy.getTextEditor(opener)
					val String fileName = fileOpenerStrategy.fileName
					val Integer lineNumber = fileOpenerStrategy.lineNumber
					textEditor.openEditor(fileName, lineNumber)
				}
			}
		)
		
		textParent.content = textOutput
	}

	def createResults(Composite parent) {
		val panel = new Composite(parent, SWT.NONE)

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

		createResultNumberLabel(panel, WollokLaunchUIMessages.WollokTestResultView_FAILED_TESTS)
		failedTextBox = createResultNumberTextBox(panel)

		createResultNumberLabel(panel, WollokLaunchUIMessages.WollokTestResultView_ERROR_TESTS)
		errorTextBox = createResultNumberTextBox(panel)
	}

	def createToolbarForTextOutput(Composite parent) {
		val parentToolbar = new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				numColumns = 2
				makeColumnsEqualWidth = false
			]
		]

		copyTextOutputToClipboard = new Button(parentToolbar, SWT.PUSH) => [
			toolTipText = Messages.WollokTestResultView_copySelectedResultToClipboard
			val pathImage = Activator.getDefault.getImageDescriptor(
				"platform:/plugin/org.eclipse.compare/icons/full/elcl16/copycont_r_co.gif")
			image = resManager.createImage(pathImage)
			addListener(SWT.Selection)[this.copySelectedTextOutputToClipboard]
			enabled = true
			layoutData = new GridData
		]

		lblMilliseconds = new Label(parentToolbar, SWT.LEFT) => [
			text = ""
			layoutData = new GridData => [
				widthHint = 250
			]
		]
	}

	def createResultNumberLabel(Composite panel, String labelText) {
		new Label(panel, SWT.NONE) => [
			text = labelText
		]
	}

	def createResultNumberTextBox(Composite panel) {
		new Text(panel, SWT.BORDER.bitwiseOr(SWT.CENTER)) => [
			it.layoutData = new GridData => [
				horizontalSpan = 2
				widthHint = 40
				heightHint = 15
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

		val millisecondsElapsed = results.globalContainer.millisecondsElapsed
		if (millisecondsElapsed > 0) {
			lblMilliseconds.text = NLS.bind(Messages.WollokTestResultView_timeTestsElapsed, millisecondsElapsed.asSeconds)	
		}
		
		if (results.globalContainer.hasTests) {
			val runningCount = count[state == WollokTestState.RUNNING]
			val pendingCount = count[state == WollokTestState.PENDING]
			
			val runned = total - pendingCount
			totalTextBox.text = runned.toString + "/" + total.toString

			val errorCount = count[state == WollokTestState.ERROR]
			errorTextBox.text = errorCount.toString

			val failedCount = count[state == WollokTestState.ASSERT]
			failedTextBox.text = failedCount.toString

			val noErrors = errorCount == 0 && failedCount == 0
			
			if (runningCount > 0 || pendingCount > 0) {
				bar.background = pendingColor
				bar.text = Messages.WollokTestResultView_runningTests
			} else {
				bar.background = if (noErrors) successColor else if(errorCount > 0) erroredColor else failedColor
				bar.text = ""
			}

			runAgain.enabled = true
//			debugAgain.enabled = true
		} else {
			totalTextBox.text = ""
			failedTextBox.text = ""
			errorTextBox.text = ""
			runAgain.enabled = false
//			debugAgain.enabled = false
		}

		// issue #1266 - dodain - this fixes the problem
		// but only when Wollok Tests are in a different tab that Project Explorer 
		//if (previousActivePart !== null) 
		//	previousActivePart.site.page.activate(previousActivePart)
	}

	def count((WollokTestResult)=>Boolean predicate) {
		results.globalContainer.allTest(predicate).size
	}

	def total() {
		results.globalContainer.allTest.size
	}

	override setFocus() {
	}
	
	def dispatch openElement(WollokTestGlobalContainer container) { }
	
	def dispatch openElement(WollokTestFileContainer container) {
		if (container.mainResource !== null) {
			opener.open(container.mainResource, true)
		}
	}
	
	def dispatch openElement(WollokTestContainer container) {
		// @dodain - in case we are running all tests
		if (container.mainResource !== null) {
			opener.open(container.mainResource, true)
		}
	}

	def dispatch openElement(WollokTestResult result) {
		opener.open(result.state.getURI(result), true)
	}

	def dispatch openElement(URI uri) {
		opener.open(uri, true)
	}

	def dispatch getOutputText(WollokTestContainer container) { container.asText }
	
	def dispatch getOutputText(WollokTestGlobalContainer container) { "" }

	def dispatch getOutputText(WollokTestFileContainer container) { container.asText }

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
	
	def dispatch getImage(WollokTestContainer element) {
		val imageDescriptor = element.getImage()
		resourceManager.createImage(imageDescriptor)
	}
	
	def dispatch getImage(WollokTestFileContainer element) {
		val imageDescriptor = element.getImage()
		resourceManager.createImage(imageDescriptor)
	}

	def dispatch getText(WollokTestContainer element) {
		return element.asText()
	}
	
	def dispatch getText(WollokTestFileContainer element) {
		return element.asText()
	}
	
	def dispatch getText(WollokTestGlobalContainer element) {
		return element.asText()
	}
	
	def dispatch getText(WollokTestResult element) {
		element.testInfo.name
	}

	override def dispose() {
		super.dispose
		resourceManager.dispose
	}
}

class WTestTreeContentProvider implements ITreeContentProvider {

	@Accessors
	var WollokTestResults results

	def dispatch getChildren(WollokTestResults element) {
		if(element.globalContainer.hasTests)
			#[element.globalContainer]
		else
			return newArrayOfSize(0)	
		
	}
	
	def dispatch getChildren(WollokTestFileContainer element) {
		element.noEmptyDescribes
	}
	
	def dispatch getChildren(WollokTestGlobalContainer globalContainer){
		globalContainer.noEmptyFiles
	}
	
	def dispatch getChildren(WollokTestContainer element) {
		element.tests
	}

	def dispatch getChildren(WollokTestResult element) {
		newArrayList(0)
	}

	
	def dispatch getElements(WollokTestResults inputElement) {
		if(inputElement.globalContainer.hasTests)
			#[inputElement.globalContainer]
		else
			return newArrayOfSize(0)
	}

	def dispatch getElements(WollokTestContainer inputElement) {
		inputElement.tests
	}

	def dispatch getElements(WollokTestResult inputElement) {
		newArrayList(0)
	}

	def dispatch getParent(WollokTestResults element) { null }
	
	def dispatch getParent(WollokTestGlobalContainer element) { results }
	
	def dispatch getParent(WollokTestFileContainer element) { results.globalContainer }

	def dispatch getParent(WollokTestContainer element) { results.getFileContainer }
	
	def dispatch hasChildren(WollokTestGlobalContainer element) { true }
	
	def dispatch hasChildren(WollokTestFileContainer element) { true }
	
	def dispatch hasChildren(WollokTestContainer element) { true }
	
	def dispatch hasChildren(Object element) { false }

	override dispose() {}

	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {}

}
