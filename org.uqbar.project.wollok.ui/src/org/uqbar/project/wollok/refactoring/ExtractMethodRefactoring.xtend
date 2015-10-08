package org.uqbar.project.wollok.refactoring

import com.google.common.collect.HashMultimap
import com.google.common.collect.Multimap
import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import java.util.Set
import org.apache.log4j.Logger
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.jdt.internal.corext.refactoring.ParameterInfo
import org.eclipse.jface.text.BadLocationException
import org.eclipse.ltk.core.refactoring.Refactoring
import org.eclipse.ltk.core.refactoring.RefactoringStatus
import org.eclipse.text.edits.TextEdit
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.resource.ILocationInFileProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.refactoring.impl.EditorDocumentChange
import org.eclipse.xtext.ui.refactoring.impl.StatusWrapper
import org.eclipse.xtext.util.ITextRegion
import org.eclipse.xtext.util.ReplaceRegion
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.xbase.XFeatureCall
import org.eclipse.xtext.xbase.compiler.ISourceAppender
import org.eclipse.xtext.xbase.compiler.StringBuilderBasedAppendable
import org.eclipse.xtext.xbase.ui.document.DocumentRewriter
import org.eclipse.xtext.xbase.ui.imports.ReplaceConverter
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static com.google.common.collect.Iterables.*
import static com.google.common.collect.Lists.*
import static com.google.common.collect.Sets.*
import static java.util.Collections.*
import static org.eclipse.xtext.util.Strings.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.refactoring.RefactoringExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * 
 * @author jfernandes
 */
// this needs to view reviewed for:
//  - extracting a method that returns a value
//  - any unnecessary code (since it was based on xtend)
@Accessors 
class ExtractMethodRefactoring extends Refactoring {
	static val Logger LOG = Logger.getLogger(ExtractMethodRefactoring)
	
	@Inject ILocationInFileProvider locationInFileProvider;
//	@Inject	NewFeatureNameUtil nameUtil
	@Inject	DocumentRewriter.Factory rewriterFactory
	@Inject	org.eclipse.xtext.xbase.ui.refactoring.ExpressionUtil expressionUtil
	@Inject	Provider<StatusWrapper> statusProvider
	@Inject ReplaceConverter replaceConverter;
	DocumentRewriter rewriter
	
	Multimap<String, XFeatureCall> externalFeatureCalls = HashMultimap.create();
	@Accessors String methodName = ""
	
	WMethodDeclaration originalMethod
	IXtextDocument document
	boolean doSave
	ITextEditor editor
	List<WExpression> expressions
	WExpression firstExpression
	WExpression lastExpression
	WExpression returnExpression
	URI resourceURI
	@Accessors WMethodContainer xtendClass
	@Accessors List<ParameterInfo> parameterInfos = newArrayList
	List<String> localFeatureNames = newArrayList
	TextEdit textEdit

	override getName() { "Extract Method Refactoring" }
	
	def initialize(XtextEditor editor, List<WExpression> expressions, boolean doSave) {
		if (expressions.empty || editor.document == null)
			return false
		
		this.document = editor.document
		this.doSave = doSave
		this.editor = editor
		this.expressions = expressions
		this.firstExpression = expressions.get(0)
		this.lastExpression = expressions.get(expressions.size - 1)
		this.resourceURI = EcoreUtil2.getPlatformResourceOrNormalizedURI(firstExpression).trimFragment
		this.xtendClass = EcoreUtil2.getContainerOfType(firstExpression, WMethodContainer)
		this.originalMethod = EcoreUtil2.getContainerOfType(firstExpression, WMethodDeclaration)
		
		if (xtendClass == null || originalMethod == null)
			return false
		
		val successorExpression = expressionUtil.findSuccessorExpressionForVariableDeclaration(lastExpression)
//		nameUtil.setFeatureScopeContext(successorExpression)
		rewriter = rewriterFactory.create(document, firstExpression.eResource as XtextResource)
		true
	}

	override checkInitialConditions(IProgressMonitor pm) throws CoreException, OperationCanceledException {
		val status = statusProvider.get
		
		try {
			val calledExternalFeatureNames = <String>newHashSet
			
			returnExpression = if (originalMethod.returnsValue) lastExpression else null
			
			val isReturnAllowed = isEndOfOriginalMethod 
			
			for (EObject element : EcoreUtil2.eAllContents(originalMethod.expression)) {
				
				pm.checkOperationCancelled
					
				var isLocalExpression = EcoreUtil.isAncestor(expressions, element)
				
				if (element instanceof WVariableReference) {
					var isLocalFeature = EcoreUtil.isAncestor(expressions, element.ref)
					if (!isLocalFeature && isLocalExpression) {
						if (element.ref instanceof WParameter || element.ref instanceof WVariableDeclaration) {
							if (!calledExternalFeatureNames.contains(element.ref.name)) {
								calledExternalFeatureNames.add(element.ref.name)
								
								var parameterInfo = new ParameterInfo(null, element.ref.name, parameterInfos.size)
								parameterInfos.add(parameterInfo)
							}
//							externalFeatureCalls.put(element.ref.name, eleme)
						}
					}
				}
				
				if (element instanceof WMemberFeatureCall) {
					val featureCall = element as WMemberFeatureCall
//					val String feature = featureCall.feature
//					
//					var isLocalFeature = EcoreUtil.isAncestor(expressions, feature)
//					
//					if (!isLocalFeature && isLocalExpression) {
//						// call-out
//						if (feature instanceof JvmFormalParameter || feature instanceof XVariableDeclaration) {
//							if (!calledExternalFeatureNames.contains(feature.simpleName)) {
//								calledExternalFeatureNames.add(feature.simpleName)
//								
//								var parameterInfo = new ParameterInfo(featureType.identifier, feature.simpleName, parameterInfos.size)
//								parameterInfos.add(parameterInfo)
//								parameter2type.put(parameterInfo, featureType)
//							}
//							externalFeatureCalls.put(feature.simpleName, featureCall)
//						}
//					} else if (isLocalFeature && !isLocalExpression) {
//						// call-in
//						if (returnExpression != null) {
//							status.add(RefactoringStatus.FATAL, "Ambiguous return value: Multiple local variables are accessed in subsequent code.");
//						}
//						else {
//							returnExpression = featureCall
//							returnType = featureType
//						}
//					}
				} else if (isLocalExpression) {
					if (element instanceof WReturnExpression && !isReturnAllowed) {
						status.add(RefactoringStatus.FATAL,	"Extracting method would break control flow due to return statements.");
					} 
					else if (element instanceof WVariableReference) {
						localFeatureNames.add(element.ref.name)
					}
				}
			}
		} catch (OperationCanceledException e) {
			throw e
		} catch (Exception exc) {
			handleException(exc, status);
		}
		status.refactoringStatus
	}
	
	def handleException(Exception exc, StatusWrapper status) {
		exc.printStackTrace
		status.add(RefactoringStatus.FATAL, "Error during refactoring: {0}", exc.toString)
	}
	
	def isEndOfOriginalMethod() {
		val eContainer = lastExpression.eContainer
		if (eContainer instanceof WBlockExpression) {
			if (eContainer.eContainer == originalMethod) {
				val siblings = (eContainer as WBlockExpression).expressions
				return siblings.indexOf(lastExpression) == siblings.size -1
			}
		}
		false
	}
	
	def String getMethodSignature() {
		(new StringBuilderBasedAppendable => [
			appendMethodSignature(it)	
		]).toString
	}
	
	def appendMethodSignature(ISourceAppender it) {
		it  << "method " << methodName << "("
			<< parameterInfos.map[newName].join(", ")
			<< ")"
	}
	
	def validateMethodName(String newMethodName) {
		new RefactoringStatus => [
//			nameUtil.checkNewFeatureName(newMethodName, true, it)
		]
	}
	
	def validateParameters() {
		val status = new RefactoringStatus
		
		parameterInfos.map[newName].duplicates.forEach[ status.addError("Duplicate parameter name '" + it + "'") ]
		
		parameterInfos.filter[ !equal(newName, oldName) && localFeatureNames.contains(newName) ].forEach[ status.addError("'" + newName + "' is already used as a name in the selected code") ]
		
		status
	}
	
	override checkFinalConditions(IProgressMonitor pm) throws CoreException, OperationCanceledException {
		val status = statusProvider.get
		try {
			status.merge(validateMethodName(methodName))
			status.merge(validateParameters)
			
			val expressionsRegion = expressionsRegion
			val predecessorRegion = locationInFileProvider.getFullTextRegion(originalMethod)
			
			pm.checkOperationCancelled
			
			val expressionSection = expressionsRegion.asSection
			val declarationSection = rewriter.newSection(predecessorRegion.offset + predecessorRegion.length, 0)
			createMethodCallEdit(expressionSection, expressionsRegion)
			
			pm.checkOperationCancelled
			
			createMethodDeclarationEdit(declarationSection, expressionSection.baseIndentLevel, expressionsRegion)
			
			pm.checkOperationCancelled
			
			textEdit = replaceConverter.convertToTextEdit(rewriter.changes)
		}
		catch (OperationCanceledException e) {
			throw e
		}
		catch (Exception exc) {
			handleException(exc, status)
		}
		status.refactoringStatus
	}
	
	def asSection(ITextRegion r) { rewriter.newSection(r.offset, r.length) }
	
	def checkOperationCancelled(IProgressMonitor pm) {
		if (pm.isCanceled) throw new OperationCanceledException
	}
	
	def getExpressionsRegion() {
		expressionUtil.getRegion(firstExpression, lastExpression)
	}
	
	def isNeedsReturnExpression() {
		returnExpression != null 
			// TODO: this seems an oversimplification
			&& !(lastExpression.eContainer instanceof WBlockExpression)  
	}
	
	def isFinalFeature(JvmIdentifiableElement returnFeature) {
		returnFeature instanceof WParameter || (returnFeature instanceof WVariableDeclaration && !(returnFeature as WVariableDeclaration).writeable)
	}
	
	def createMethodCallEdit(DocumentRewriter.Section methodCallSection, ITextRegion expressionRegion) throws BadLocationException {
//		if (isNeedsReturnExpression) {
//			val returnFeature = (returnExpression as WFeatureCall).feature
//			
//			methodCallSection.append(if (isFinalFeature(returnFeature)) "val " else "var ")
//			methodCallSection.append(returnFeature.simpleName).append(" = ")
//		}

		if (expressions.size == 1 && expressions.get(0) instanceof WReturnExpression)
			methodCallSection.append('return ')
		
		var needsSurroundingParentheses = false
		
		if (firstExpression.eContainer instanceof WMemberFeatureCall) {
			if( (firstExpression.eContainer as WMemberFeatureCall).memberCallArguments.size == 1) {
				val expressionExpanded = document.get(expressionRegion.offset - 1, expressionRegion.length + 2)
				if(!expressionExpanded.startsWith("(") || !expressionExpanded.endsWith(")")) {
					needsSurroundingParentheses = true
					methodCallSection.append("(")
				}
			}
		}
		methodCallSection << "this." << methodName << "(" << parameterInfos.map[oldName].join(", ") << ")"
		
		if (needsSurroundingParentheses)
			methodCallSection.append(")")
	}
	
	override createChange(IProgressMonitor pm) throws CoreException, OperationCanceledException {
		new EditorDocumentChange("Extract Method", editor, doSave) => [
			edit = textEdit
			textType = resourceURI.fileExtension
		]
	}
	
	def createMethodDeclarationEdit(DocumentRewriter.Section it, int expressionIndentLevel, ITextRegion expressionsRegion) throws BadLocationException {
		newLine
		newLine
		appendMethodSignature
		
		append(" {") increaseIndentation newLine
		
		
		if (isNeedsReturnExpression) {
			append('return ')
		}
		
		val expressionsAsString = getExtractedMethodBody(expressionsRegion)
		append(expressionsAsString, Math.min(0, -expressionIndentLevel))
		
//		if (isNeedsReturnExpression) {
//			newLine
//			append('return ' + (returnExpression as WMemberFeatureCall).feature)
//		}
		
		decreaseIndentation newLine append("}")
	}
	
	def getExtractedMethodBody(ITextRegion expressionsRegion) throws BadLocationException {
		val methodBody = getMethodBodyWithRenamedParameters(expressionsRegion)
		if (expressions.size == 1  
				&& firstExpression instanceof WClosure 
				&& (!methodBody.startsWith("[") || !methodBody.endsWith("]"))) {
			// legacy closure argument syntax
			return "[" + methodBody + "]"
		}
		methodBody
	}
	
	def getMethodBodyWithRenamedParameters(ITextRegion expressionsRegion) throws BadLocationException {
		val List<ReplaceRegion> parameterRenames = newArrayList
		
		for (String parameterName: externalFeatureCalls.keySet) {
			val parameter = find(parameterInfos, [ info | equal(info.oldName, parameterName) ])
			
			if (parameter.renamed) {
				for (XFeatureCall featureCall: externalFeatureCalls.get(parameterName)) {
					val textRegion = locationInFileProvider.getSignificantTextRegion(featureCall, WollokDslPackage.Literals.WMEMBER_FEATURE_CALL__FEATURE, -1);
					parameterRenames.add(new ReplaceRegion(textRegion, parameter.newName))
				}
			}
		}
		
		sort(parameterRenames, [o1, o2 | o2.offset - o1.offset ])

		parameterRenames.fold(new StringBuffer(expressionsRegion.asString)) [b, it|
			b.replace(offset - expressionsRegion.offset, endOffset - expressionsRegion.offset, text)
			b
		].toString
	}
	
	def asString(ITextRegion r) { document.get(r.offset, r.length) }
	
}