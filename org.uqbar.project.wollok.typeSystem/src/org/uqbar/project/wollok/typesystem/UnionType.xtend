package org.uqbar.project.wollok.typesystem

import java.util.List

class UnionType extends BasicType {
	List<AbstractContainerWollokType> types
	
	new(AbstractContainerWollokType... types) {
		super(types.join('(', '|', ')', [name]))
		this.types = types.toList
	}
}
