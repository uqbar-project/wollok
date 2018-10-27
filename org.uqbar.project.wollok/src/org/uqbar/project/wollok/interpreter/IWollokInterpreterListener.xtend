package org.uqbar.project.wollok.interpreter

import org.uqbar.project.wollok.wollokDsl.WFile

interface IWollokInterpreterListener {
	
	def void messageSent(WollokInterpreter interpreter, WFile mainFile)
	
}