package org.uqbar.project.wollok.ui.editor.annotations

import com.google.common.collect.Maps
import java.util.Collections
import java.util.Map
import java.util.Set
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.ISchedulingRule
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.jface.text.ISynchronizable
import org.eclipse.jface.text.Position
import org.eclipse.jface.text.source.Annotation
import org.eclipse.jface.text.source.IAnnotationModel
import org.eclipse.jface.text.source.IAnnotationModelExtension
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.IXtextEditorCallback
import org.eclipse.xtext.ui.editor.SchedulingRuleFactory
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextModelListener
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

/**
 * @author jfernandes
 */
class WOverrideIndicatorModelListener extends IXtextEditorCallback.NullImpl implements IXtextModelListener {
	public static final String JOB_NAME = "Override Indicator Updater"
	private static ISchedulingRule SCHEDULING_RULE = SchedulingRuleFactory.INSTANCE.newSequence()
	private Job currentJob
	private XtextEditor xtextEditor
	var Set<Annotation> overrideIndicatorAnnotations = newHashSet()
	
	// listening
	
	override afterCreatePartControl(XtextEditor xtextEditor) {
		this.xtextEditor = xtextEditor
		installModelListener(xtextEditor)
	}

	override afterSetInput(XtextEditor xtextEditor) {
		installModelListener(xtextEditor)
	}

	override beforeDispose(XtextEditor xtextEditor) {
		if (this.xtextEditor !== null) {
			this.xtextEditor = null
		}
	}
	
	def installModelListener(XtextEditor xtextEditor) {
		if (xtextEditor.getDocument !== null) {
			asyncUpdateAnnotationModel
			xtextEditor.document.addModelListener(this)
		}
	}
	
	// event reaction
	
	override modelChanged(XtextResource resource) {
		asyncUpdateAnnotationModel
	}
	
	private def asyncUpdateAnnotationModel() {
		if (currentJob !== null) {
			currentJob.cancel
		}

		currentJob = new Job(JOB_NAME) {
			override run(IProgressMonitor monitor) {
				updateAnnotationModel(monitor)
			}
		}
		currentJob.rule = SCHEDULING_RULE
		currentJob.priority = Job.DECORATE
		currentJob.system = true
		currentJob.schedule
	}
	
	private def updateAnnotationModel(IProgressMonitor monitor) {
		if (anyIsNull)
			return Status.OK_STATUS
		val xtextDocument = xtextEditor.document
		val annotationModel = xtextEditor.internalSourceViewer.annotationModel
		val annotationToPosition = xtextDocument
				.readOnly(new IUnitOfWork<Map<Annotation, Position>, XtextResource>() {
					override exec(XtextResource xtextResource) {
						if (xtextResource === null)
							Collections.emptyMap
						else
							createOverrideIndicatorAnnotationMap(xtextResource)
					}

				})

		if (monitor.isCanceled)
			return Status.CANCEL_STATUS
		if (annotationModel instanceof IAnnotationModelExtension) {
			synchronized (getLockObject(annotationModel)) {
				annotationModel.replaceAnnotations(overrideIndicatorAnnotations, annotationToPosition)
			}
			overrideIndicatorAnnotations = annotationToPosition.keySet()
		}
		Status.OK_STATUS
	}
	
	private def anyIsNull() {
		xtextEditor === null || xtextEditor.getDocument() === null || xtextEditor.internalSourceViewer.annotationModel === null
	}
	
	def private getLockObject(IAnnotationModel annotationModel) {
		if (annotationModel instanceof ISynchronizable) {
			val lock = (annotationModel as ISynchronizable).lockObject
			if (lock !== null)
				return lock
		}
		return annotationModel
	}
	
	// metodo posta (todo lo demás era burocracia 
	def protected Map<Annotation, Position> createOverrideIndicatorAnnotationMap(XtextResource xtextResource) {
		val contents = xtextResource.contents
		if (contents.isEmpty)
			return Maps.newHashMap
		val eObject = contents.get(0)
		if (!(eObject instanceof WFile)) {
			return Maps.newHashMap
		}
		val Map<Annotation, Position> annotationToPosition = Maps.newHashMap()
		eObject.eAllContents.filter(WMethodDeclaration).forEach[m|
			createOverrideAnnotationIfApplies(m, annotationToPosition)			
		]
		annotationToPosition
	}
	
	def createOverrideAnnotationIfApplies(WMethodDeclaration method, Map<Annotation, Position> map) {
		if (method.overrides)
			map.put(new WOverrideAnnotation("Overrides", method), new Position(method.node.offset))
	}
	
}
