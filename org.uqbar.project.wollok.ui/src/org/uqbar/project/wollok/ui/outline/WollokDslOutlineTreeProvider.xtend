package org.uqbar.project.wollok.ui.outline

import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WLibrary
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * Customization of the default outline structure.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#outline
 * 
 * @author npasserini
 * @author jfernandes
 */
class WollokDslOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	/** avoid the root element representing the file */
	def _createChildren(DocumentRootNode parentNode, WFile file) {
		createNode(parentNode, file.body)
	}
	
	def _createChildren(DocumentRootNode parentNode, WLibrary library) {
		library.elements.forEach[createNode(parentNode, it)]
	}
	
	/** avoids a separated element for the var declaration and for the inner var element */
	def _createChildren(IOutlineNode parentNode, WVariableDeclaration declaration) {
		createNode(parentNode, declaration.right)
	}
	
	/** don't want to go deep inside a method */
	def _isLeaf(WMethodDeclaration m) 	{ true }
	def _isLeaf(WConstructor c) 		{ true }
	def _isLeaf(WMemberFeatureCall c) 	{ true }
	
	/** don't want to go inside a var (unless it's assigned to an object literal) */
	def _isLeaf(WVariableDeclaration v) { v.right == null || !(v.right instanceof WObjectLiteral) }
	def _isLeaf(WAssignment v) { !(v.value instanceof WObjectLiteral) }
	 
}
