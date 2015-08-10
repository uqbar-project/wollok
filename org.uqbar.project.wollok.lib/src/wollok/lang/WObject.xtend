package wollok.lang

/**
 * Wollok Object class. It's the native part
 * 
 * @author jfernandes
 */
class WObject {
	
	// Native methods should be able to access the WollokObject !
	def identity() { System.identityHashCode(this) }
	
}