package org.uqbar.project.wollok.sdk

/**
 * Contains class names for Wollok core SDK.
 * The interpreter is now instantiating this classes
 * for example for list literals or strings, booleans, etc.
 * But they are in another project, and the interpreter doesn't depend on it
 * (there's a circularity there), so we need to make refereces using the FQN
 * String.
 * 
 * This just defines the strings in a single place for easing maintenance.
 * 
 * import static extension org.uqbar.project.wollok.sdk.WollokDSK.*
 * 
 * @author jfernandes
 */
class WollokDSK {
	
	public static val OBJECT = "wollok.lang.Object"

	public static val STRING = "wollok.lang.String"
	public static val INTEGER = "wollok.lang.Integer"
	public static val DOUBLE = "wollok.lang.Double"
	public static val BOOLEAN = "wollok.lang.Boolean"

	public static val COLLECTION = "wollok.lang.Collection"
	public static val LIST = "wollok.lang.List"
	public static val SET = "wollok.lang.Set"
	
}