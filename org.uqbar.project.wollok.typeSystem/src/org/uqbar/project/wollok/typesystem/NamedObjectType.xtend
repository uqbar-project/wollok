package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * Type implementation for WKOs
 * 
 * @author jfernandes
 */
class NamedObjectType extends AbstractContainerWollokType {
	
	new(WNamedObject wko, TypeSystem ts) {
		super(wko, ts)
	}
	
}