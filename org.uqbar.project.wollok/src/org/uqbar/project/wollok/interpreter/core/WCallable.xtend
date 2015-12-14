package org.uqbar.project.wollok.interpreter.core

/**
 * Interface for all callable objects.
 * 
 * This is kind of the outside interface for all wollok objects.
 * There are different impls for:
 * 	- made-in-wollok object
 *  - call to super (not sure it's the best way to model it)
 *  - native objects (not any more ! We should remove them)
 * 
 * @author jfernandes
 */
interface WCallable {
	def WollokObject call(String message, WollokObject... parameters)
}