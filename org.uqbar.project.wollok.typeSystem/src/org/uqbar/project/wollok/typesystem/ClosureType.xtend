package org.uqbar.project.wollok.typesystem

import java.util.List

/**
 * Type for closures
 * 
 * @author jfernandes
 */
class ClosureType extends BasicType {
	
	new(List<WollokType> paramTypes, WollokType returnType) {
		super('''(«paramTypes?.map[name].join(',')») => «returnType?.name»''')
	}
	
}