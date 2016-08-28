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
 * Exception to handle other values in assert.trowException*
 */
class OtherValueExpectedException inherits wollok.lang.Exception {
	constructor(_message) = super(_message)	
	constructor(_message,_cause) = super(_message,_cause)
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
	 * Tests whether a block throws an exception and this is the same expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionLike(new BusinessException("hola"),{ => throw new BusinessException("hola") } => Works! this is the same exception class and same message.
	 *		assert.throwsExceptionLike(new BusinessException("chau"),{ => throw new BusinessException("hola") } => Doesn't work. This is the same exception class but got a different message.
	 *		assert.throwsExceptionLike(new OtherException("hola"),{ => throw new BusinessException("hola") } => Doesn't work. This isn't the same exception class although it contains the same message.
	 */	 
	method throwsExceptionLike(exceptionExpected, block) {
		try 
		{
			self.throwsExceptionByComparing( block,{a => a.equals(exceptionExpected)})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The Exception expected was " + exceptionExpected + " but got " + ex.getCause())
		} 
	}

	/** 
	 * Tests whether a block throws an exception and it have the error message as is expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new BusinessException("hola") } => Works! this is the same message.
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new OtherException("hola") } => Works! this is the same message.
	 *		assert.throwsExceptionWithMessage("chau",{ => throw new BusinessException("hola") } => Doesn't work. This is the same exception class but got a different message.
	 */	 
	method throwsExceptionWithMessage(errorMessage, block) {
		try 
		{
			self.throwsExceptionByComparing(block,{a => errorMessage.equals(a.getMessage())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The error message expected was " + errorMessage + " but got " + ex.getCause().getMessage())
		}
	}

	/** 
	 * Tests whether a block throws an exception and this is the same exception class expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionWithType(new BusinessException("hola"),{ => throw new BusinessException("hola") } => Works! this is the same exception class.
	 *		assert.throwsExceptionWithType(new BusinessException("chau"),{ => throw new BusinessException("hola") } => Works again! this is the same exception class.
	 *		assert.throwsExceptionWithType(new OtherException("hola"),{ => throw new BusinessException("hola") } => Doesn't work. This isn't the same exception class although it contains the same message.
	 */	 	
	method throwsExceptionWithType(exceptionExpected, block) {
		try 
		{
			self.throwsExceptionByComparing(block,{a => exceptionExpected.className().equals(a.className())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The exception expected was " + exceptionExpected.className() + " but got " + ex.getCause().className())
		}
	}

	/** 
	 * Tests whether a block throws an exception and compare this exception with other block called comparison. Otherwise an exception is thrown.
	 * The block comparison have to receive a value (an exception thrown) that is compared in a boolean expression returning the result.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => "hola".equals(a.getMessage())}} => Works!.
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => new BusinessException("lele").className().equals(a.className())} } => Works again!
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => "chau!".equals(a.getMessage())} } => Doesn't work. The block evaluation resolve a false value.
	 */		
	method throwsExceptionByComparing(block,comparison){
		var continue = false
		try 
			{
				block.apply()
				continue = true
			} 
		catch ex 
			{
				if(comparison.apply(ex))
					self.that(true)
				else
					throw new OtherValueExpectedException("Expected other value", ex)
			}
		if (continue) throw new Exception("Should have thrown an exception")	
	}
	
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
	
	/**
	 * Adds an object to the board for drawing it.
	 * That object should known a position.
	 */
	method addVisual(element) native

	/**
	 * Adds an object to the board for drawing it on a specific position.
	 */
	method addVisualIn(element, position) native
	
	/**
	 * Adds an object to the board for drawing it and it can be moved with arrow keys.
	 * That object should known a position.
	 */
	method addVisualCharacter(element) native

	/**
	 * Adds an object to the board for drawing it on a specific position and it can be moved with arrow keys.
	 */	
	method addVisualCharacterIn(element, position) native

	/**
	 * Removes an object from the board for stop drawing it.
	 */
	method removeVisual(element) native
	
	/**
	 * Adds a block that will be executed always the specific key is pressed.
	 */	
	method whenKeyPressedDo(key, action) native

	/**
	 * Adds a block that will be executed always the specific object collides with other. Two objects collide when are in the same position.
	 * The block should expect the other object as parameter.
	 */	
	method whenCollideDo(visual, action) native

	/**
	 * Returns all objects that are on a position.
	 */	
	method getObjectsIn(position) native

	/**
	 * Draw a dialog balloon with given message in the position where the object is.
	 */	
	method say(visual, message) native

	/**
	 * Removes all objects on board and configurations (colliders, keys, etc).
	 */	
	method clear() native
	method colliders(visual) native

	/**
	 * Stops render the board.
	 */	
	method stop() native
	
	/**
	 * Starts render the board in a new windows.
	 */	
	method start() {
		self.doStart(runtime.isInteractive())
	}
	
	/**
	 * Returns a position for given coordinates.
	 */	
	method at(x, y) {
		return new Position(x, y)
	}
	
	method origin() = self.at(0, 0)
	method center() = self.at(self.getWidth().div(2), self.getHeight().div(2))
	
	
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

	method distance(position) {
	    const deltaX = self.getX() - position.getX()
	    const deltaY = self.getY() - position.getY()
	    return (deltaX.square() + deltaY.square()).squareRoot() 
	}

	method clear() {
		self.allElements().forEach{it => game.removeVisual(it)}
	}
	
	method getX() = x
	method setX(_x) { x = _x }
	method getY() = y
	method setY(_y) { y = _y }
	
	override method ==(other) = x == other.getX() && y == other.getY()
}

object error {
	/**
	 * Throws an exception with a given message.
	 * This action alters the normal flow of the program. 
	 */
	method throwWithMessage(aMessage) {
		throw new Exception(aMessage)
	}
}
