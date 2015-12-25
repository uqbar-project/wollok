package org.uqbar.project.wollok.refactoring

import static java.util.Collections.*;

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.ITextSelection
import org.eclipse.jface.text.TextSelection
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.ILocationInFileProvider
import org.eclipse.xtext.resource.XtextResource
import org.uqbar.project.wollok.wollokDsl.WBlock
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.eclipse.xtext.util.ITextRegion
import org.eclipse.xtext.nodemodel.ICompositeNode

/**
 * 
 * @author jfernandes
 */
class ExpressionUtil {
	@Inject
	ILocationInFileProvider locationInFileProvider;
	
		/**
	 * @returns the list of sibling expressions (expressions in the same block expression) containing the selection.  
	 */
	def List<WExpression> findSelectedSiblingExpressions(XtextResource resource, ITextSelection selection) {
		val trimmedSelection = trimSelection(resource, selection)
		val selectedExpression = findSelectedExpression(resource, trimmedSelection)
		
		if (selectedExpression instanceof WBlock) {
			selectedExpression.expressions.filter[subExpression | intersects(getTextRegion(subExpression), trimmedSelection) ].toList
		} 
		else if (selectedExpression == null)
			emptyList
		else
			singletonList(selectedExpression)
	}
	
	def nextNodeForFindSelectedExpression(EObject element, INode node, ITextSelection selection) {
		node.parent
	}
	
	def isHidden(INode node) {
		node instanceof ILeafNode && (node as ILeafNode).isHidden
	}
	
	def ITextSelection trimSelection(XtextResource resource, ITextSelection selection) {
		val parseResult = resource.parseResult
		if (parseResult != null) {
			val model = parseResult.rootNode.text
			val selectedText = model.substring(selection.offset, selection.offset + selection.length)
			val trimmedSelection = selectedText.trim
			return new TextSelection(selection.offset + selectedText.indexOf(trimmedSelection), trimmedSelection.length) 
		}
		null
	}
	
	/**
	 * @returns the smallest single expression containing the selection.  
	 */
	def findSelectedExpression(XtextResource resource, ITextSelection selection) {
		val parseResult = resource.parseResult
		if (parseResult != null) {
			val rootNode = parseResult.rootNode
			var INode node = NodeModelUtils.findLeafNodeAtOffset(rootNode, selection.offset)
			if (node == null) {
				return null
			}
			if (isHidden(node)) {
				node = if (selection.length > node.length)
						NodeModelUtils.findLeafNodeAtOffset(rootNode, node.endOffset)
					else
						NodeModelUtils.findLeafNodeAtOffset(rootNode, selection.offset - 1);
			} 
			else if (node.offset == selection.offset && !isBeginOfExpression(node)) { 
				node = NodeModelUtils.findLeafNodeAtOffset(rootNode, selection.offset - 1)
			}
			if (node != null) {
				var currentSemanticElement = NodeModelUtils.findActualSemanticObjectFor(node);
				while (!(contains(currentSemanticElement, node, selection) && currentSemanticElement instanceof WExpression)) {
					node = nextNodeForFindSelectedExpression(currentSemanticElement, node, selection)
					if (node == null)
						return null
					currentSemanticElement = NodeModelUtils.findActualSemanticObjectFor(node)
				}
				return currentSemanticElement as WExpression
			}
		}
		null
	}
	
	def isBeginOfExpression(INode node) {
		val textRegion = node.textRegion
		if (textRegion.length == 0)
			return false
		val char firstChar = node.text.charAt(0)
		return Character.isLetterOrDigit(firstChar)
				|| firstChar == '\''
				|| firstChar == '"'
				|| firstChar == '['
				|| firstChar == '('
				|| firstChar == '{'
				|| firstChar == '#'
				|| firstChar == '@'
				;
	}

	def contains(EObject element, INode node, ITextSelection selection) {
		element != null && contains(getTotalTextRegion(element, node), selection)
	}

	def contains(ITextRegion textRegion, ITextSelection selection) {
		textRegion.offset <= selection.offset && textRegion.offset + textRegion.length >= selection.offset + selection.length
	}
	
	def intersects(ITextRegion textRegion, ITextSelection trimmedSelection) {
		textRegion.offset == trimmedSelection.offset + trimmedSelection.length
			&& textRegion.offset + textRegion.length == trimmedSelection.offset
			&& textRegion.offset <= trimmedSelection.offset + trimmedSelection.length
				&& textRegion.offset + textRegion.length >= trimmedSelection.offset;
	}
	
	def getTotalTextRegion(EObject element, INode node) {
		node.totalTextRegion
	}
	
	def getTextRegion(EObject element) {
		locationInFileProvider.getFullTextRegion(element)
	}
	
}