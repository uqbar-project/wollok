package org.uqbar.project.wollok.server

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class WollokServerRequest {
	String program
	String programType
	
	new(CharSequence program, String programType) {
		this.program = program.toString
		this.programType = programType
	}
	
}