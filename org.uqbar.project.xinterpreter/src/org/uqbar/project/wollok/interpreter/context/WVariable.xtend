package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */

@Accessors
class WVariable implements Serializable {
	String name
	Integer id
	boolean local
	
	new(String name, Integer id, boolean local) {
		this.name = name
		this.local = local
		this.id = id
	}
	
	override toString() {
		this.name + (if (id === null) "" else " (" + id + ")")
	}
	
}