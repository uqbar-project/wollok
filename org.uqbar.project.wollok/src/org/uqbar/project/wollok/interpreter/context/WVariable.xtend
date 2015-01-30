package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable

/**
 * @author jfernandes
 */
class WVariable implements Serializable {
	@Property String name
	@Property boolean local
	
	new(String name, boolean local) {
		this.name = name
		this.local = local
	}
	
}