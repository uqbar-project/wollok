import wollok.vm.*

/** 
 * Console is a global wollok object that implements a character-based console device
 * called "standard input/output" stream 
 */
object console {

	/** Prints a String with end-of-line character */
	method println(obj) native
	
	/** Reads a line from input stream */
	method readLine() native
	
	/** Reads an int character from input stream */
	method readInt() native
	
	/** Returns the system's representation of a new line:
	 * - \n in Unix systems
	 * - \r\n in Windows systems
	 */
	 method newline() native
}

/**
 * Assert object simplifies testing conditions
 */
object assert {

	/** 
	 * Tests whether value is true. Otherwise throws an exception.
	 * Example:
	 * 		var number = 7
	 *		assert.that(number.even())   ==> throws an exception "Value was not true"
	 * 		var anotherNumber = 8
	 *		assert.that(anotherNumber.even())   ==> no effect, ok		
	 */
	method that(value) native
	
	/** Tests whether value is false. Otherwise throws an exception. 
	 * @see assert#that(value) 
	 */
	method notThat(value) native
	
	/** 
	 * Tests whether two values are equal, based on wollok == method
	 * 
	 * Example:
	 *		 assert.equals(10, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.0, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.01, 100.div(10)) ==> throws an exception 
	 */
	method equals(expected, actual) native
	
	/** Tests whether two values are equal, based on wollok != method */
	method notEquals(expected, actual) native
	
	/** 
	 * Tests whether a block throws an exception. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		assert.throwsException({ 7 / 0 })  ==> Division by zero error, it is expected, ok
	 *		assert.throwsException("hola".length() ) ==> throws an exception "Block should have failed"
	 */
	method throwsException(block) native
	
	/**
	 * Throws an exception with a custom message. Useful when you reach an unwanted code in a test.
	 */
	method fail(message) native
	
}

class StringPrinter {
	var buffer = ""
	method println(obj) {
		buffer += obj.toString() + console.newline()
	}
	method getBuffer() = buffer
}	

object game {
	method addVisual(element) native
	method addVisualIn(element, position) native
	method addVisualCharacter(element) native
	method addVisualCharacterIn(element, position) native
	method removeVisual(element) native
	method whenKeyPressedDo(key, action) native
	method whenKeyPressedSay(key, function) native
	method whenCollideDo(element, action) native
	method getObjectsIn(position) native
	method say(element, message) native
	method clear() native
	method stop() native
	
	method start() {
		self.doStart(runtime.isInteractive())
	}
	
	method at(x, y) {
		return new Position(x, y)
	}
	
	
	method setTitle(title) native
	method getTitle() native
	method setWidth(width) native
	method getWidth() native
	method setHeight(height) native
	method getHeight() native
	method setGround(image) native
	
	/** 
	* @private
	*/
	method doStart(isRepl) native
}

class Position {
	var x = 0
	var y = 0
	
	constructor() { }		
			
	constructor(_x, _y) {
		x = _x
		y = _y
	}
	
	method moveRight(num) { x += num }
	method moveLeft(num) { x -= num }
	method moveUp(num) { y += num }
	method moveDown(num) { y -= num }

	method drawElement(element) { game.addVisualIn(element, self) }
	method drawCharacter(element) { game.addVisualCharacterIn(element, self) }		
	method deleteElement(element) { game.removeVisual(element) }
	method say(element, message) { game.say(element, message) }
	method allElements() = game.getObjectsIn(self)
	
	method clone() = new Position(x, y)

	method clear() {
		self.allElements().forEach{it => game.removeVisual(it)}
	}
	
	method getX() = x
	method setX(_x) { x = _x }
	method getY() = y
	method setY(_y) { y = _y }
	
	method == other { return x == other.getX() && y == other.getY()}
}
