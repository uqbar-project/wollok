package org.uqbar.project.wollok.ui

/**
 * An extension point for executing code at startup of the wollok ui 
 * plugin.
 * 
 * @author jfernandes
 */
interface WollokUIStartup {
	
	def void startup()
	
}