package org.uqbar.project.wollok.interpreter.core

/**
 * Interface for all callable objects.
 * 
 * This is kind of the outside interface for all wollok objects.
 * There are different impls for:
 * 	- made-in-wollok object
 *  - native objects.
 * 
 * @author jfernandes
 */
interface WCallable {
	
	def Object call(String message, Object... parameters)
	
}