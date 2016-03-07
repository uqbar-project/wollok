package org.uqbar.project.wollok.model

import java.util.List
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WBlockExpression

/**
 * Extension methods for WBlocks
 * 
 * @author jfernandes
 */
class WBlockExtensions {
	
	def static getExpressionsAfter(WBlockExpression it, WExpression one) {
		expressions.allAfter(one) 
	}
	
	// move to a new uqbar.ListExtensions
	def static <T> allAfter(List<T> it, T one) { subList(indexOf(one) + 1, size) }
	
}