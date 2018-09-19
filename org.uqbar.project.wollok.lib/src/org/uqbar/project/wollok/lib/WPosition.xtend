package org.uqbar.project.wollok.lib

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class WPosition extends Position {
	WollokObject wObject
	WollokInterpreter interpreter

	new(WollokObject position) {
		this.wObject = position
		this.interpreter = position.interpreter as WollokInterpreter
	}

	override getX() { wObject.getInt("x") }

	override getY() { wObject.getInt("y") }

	def getInt(WollokObject it, String methodName) { call(methodName).asInteger }
	
	def copyFrom(Position position) {
		buildPosition(position.x, position.y)
	}
	
	override createPosition(int newX, int newY) {
		wObject = this.buildPosition(newX, newY) 
		return new WPosition(wObject)
	}

	def buildPosition(int newX, int newY) {
		((interpreter.evaluator as WollokInterpreterEvaluator).newInstance(POSITION, newX.javaToWollok, newY.javaToWollok))
	}
	
}
