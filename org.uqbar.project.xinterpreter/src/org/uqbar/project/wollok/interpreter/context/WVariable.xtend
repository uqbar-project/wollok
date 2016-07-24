package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
@Accessors
class WVariable implements Serializable {
	String name
	boolean local
	
	new(String name, boolean local) {
		this.name = name
		this.local = local
	}
}