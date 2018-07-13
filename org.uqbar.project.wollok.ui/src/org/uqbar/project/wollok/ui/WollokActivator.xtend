package org.uqbar.project.wollok.ui

import com.google.inject.Inject
import java.net.URL
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.jface.viewers.ILabelProvider
import org.eclipse.swt.widgets.Display
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionProvider
import org.eclipse.xtext.ui.editor.utils.EditorUtils
import org.eclipse.xtext.ui.editor.validation.MarkerCreator
import org.eclipse.xtext.ui.validation.MarkerTypeProvider
import org.eclipse.xtext.validation.IResourceValidator
import org.osgi.framework.BundleContext
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

/**
 * Customized activator.
 * 
 * @author jfernandes
 */
class WollokActivator extends org.uqbar.project.wollok.ui.internal.WollokActivator {
	public static val BUNDLE_NAME = "org.uqbar.project.wollok.ui.messages"
	public static val POINT_STARTUP_ID = "org.uqbar.project.wollok.ui.startup"

	/* TODAS ESTAS REFERENCIAS HAY QUE PASARLAS AL BUILDER Y PASAR EL BUILDER AL UI */
	@Accessors @Inject
	IResourceValidator validator

	@Accessors @Inject
	MarkerCreator markerCreator

	@Accessors @Inject
	MarkerTypeProvider markerTypeProvider

	@Accessors @Inject
	IssueResolutionProvider issueResolutionProvider

	public static XtextEditor editor 
	
	/* FIN TODAS ESTAS REFERENCIAS HAY QUE PASARLAS AL BUILDER Y PASAR EL BUILDER AL UI */
	def static WollokActivator getInstance() {
		return org.uqbar.project.wollok.ui.internal.WollokActivator.getInstance as WollokActivator
	}

	override start(BundleContext context) throws Exception {
		super.start(context)
		callStartupExtensions
	}

	def callStartupExtensions() {
		startupExtensions.forEach[startup]
	}

	def startupExtensions() {
		val configs = Platform.getExtensionRegistry.getConfigurationElementsFor(POINT_STARTUP_ID)
		configs.map[it.createExecutableExtension("class") as WollokUIStartup]
	}

	def static getStandardDisplay() {
		val display = Display.getCurrent
		if (display == null)
			return Display.getDefault
		return display;
	}

	def getImageDescriptor(String name) {
		val u = new URL(bundle.getEntry("/"), name)
		return ImageDescriptor.createFromURL(u);
	}

	def getLabelProvider() {
		this.getInjector(ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL).getInstance(ILabelProvider)
	}

	def getOpener() {
		this.getInjector(ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL).getInstance(IURIEditorOpener)
	}

	def void runInXtextEditorFor(URI uri, Procedure1<XtextEditor> editorBlock) {
		Display.getDefault().syncExec([
			val editorPart = opener.open(uri, true)
			editor = EditorUtils.getXtextEditor(editorPart)
			editorBlock.apply(editor)
		])
	}

}
