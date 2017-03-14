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

class AssertionException inherits Exception {

	var expected = null
	var actual = null

	constructor(message) = super(message)
	
	constructor(message, cause) = super(message, cause)
	
	constructor(message, _expected, _actual) = self(message) {
		expected = _expected
		actual = _actual
	}
	
	/** Answers the expected value, if present */
	method getExpected() = expected
	
	/** Answers the actual value, if present */
	method getActual() = actual
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
	method that(value) {
		if (!value) throw new AssertionException("Value was not true")
	}
	
	/** Tests whether value is false. Otherwise throws an exception. 
	 * @see assert#that(value) 
	 */
	method notThat(value) {
		if (value) throw new AssertionException("Value was not false")
	}
	
	/** 
	 * Tests whether two values are equal, based on wollok ==, != methods
	 * 
	 * Example:
	 *		 assert.equals(10, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.0, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.01, 100.div(10)) ==> throws an exception 
	 */
	method equals(expected, actual) {
		if (expected != actual) throw new AssertionException("Expected [" + expected.printString() + "] but found [" + actual.printString() + "]", expected.printString(), actual.printString()) 
	}
	
	/** Tests whether two values are equal, based on wollok ==, != methods */
	method notEquals(expected, actual) {
		if (expected == actual) throw new AssertionException("Expected to be different, but [" + expected.printString() + "] and [" + actual.printString() + "] match")
	}
	
	/** 
	 * Tests whether a block throws an exception. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		assert.throwsException({ 7 / 0 })  ==> Division by zero error, it is expected, ok
	 *		assert.throwsException("hola".length() ) ==> throws an exception "Block should have failed"
	 */
	method throwsException(block) {
		var failed = false
		try {
			block.apply()
		} catch e {
			failed = true
		}
		if (!failed) throw new AssertionException("Block should have failed")
	}
	
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
	method fail(message) {
		throw new AssertionException(message)
	}
	
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
	 * That object should known a position (by reference or getter method).
	 */
	method addVisual(positionable) native

	/**
	 * Adds an object to the board for drawing it on a specific position.
	 */
	method addVisualIn(element, position) native

	
	/**
	 * Adds an object to the board for drawing it. It can be moved with arrow keys.
	 * That object should known a position (by reference or getter method).
	 */
	method addVisualCharacter(positionable) native

	/**
	 * Adds an object to the board for drawing it on a specific position. It can be moved with arrow keys.
	 */	
	method addVisualCharacterIn(element, position) native

	/**
	 * Removes an object from the board for stop drawing it.
	 */
	method removeVisual(visual) native
	
	/**
	 * Adds a block that will be executed always the specific key is pressed.
	 */	
	method whenKeyPressedDo(key, action) native

	/**
	 * Adds a block that will be executed always the given object collides with other. Two objects collide when are in the same position.
	 * The block should expect the other object as parameter.
	 */	
	method whenCollideDo(visual, action) native

	/**
	 * Returns all objects in given position.
	 */	
	method getObjectsIn(position) native

	/**
	 * Draw a dialog balloon with given message in given visual object position.
	 */	
	method say(visual, message) native

	/**
	 * Removes all visual objects on board and configurations (colliders, keys, etc).
	 */	
	method clear() native

	/**
	 * Returns all objects that are in same position of given object.
	 */	
	method colliders(visual) native

	/**
	 * Stops render the board and finish the game.
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

	/**
	 * Returns the position (0,0).
	 */	
	method origin() = self.at(0, 0)

	/**
	 * Returns the center board position (rounded down).
	 */	
	method center() = self.at(self.width().div(2), self.height().div(2))

	/**
	 * Sets game title.
	 */		
	method title(title) native

	/**
	 * Returns game title.
	 */		
	method title() native
	
	/**
	 * Sets board width (in cells).
	 */			
	method width(width) native

	/**
	 * Returns board width (in cells).
	 */		
	method width() native

	/**
	 * Sets board height (in cells).
	 */			
	method height(height) native

	/**
	 * Returns board height (in cells).
	 */		
	method height() native

	/**
	 * Sets cells image.
	 */			
	method ground(image) native
	
	/** 
	* @private
	*/
	method doStart(isRepl) native
}

class Position {
	var x = 0
	var y = 0
	
	/**
	 * Returns the position at origin: (0,0).
	 */		
	constructor() = self(0,0)
			
	/**
	 * Returns a position with given x and y coordinates.
	 */	
	constructor(_x, _y) {
		x = _x
		y = _y
	}
	
	/**
	 * Sums n to x coordinate.
	 */		
	method moveRight(n) { x += n }
	
	/**
	 * Substract n to x coordinate.
	 */		
	method moveLeft(n) { x -= n }
	
	/**
	 * Sums n to y coordinate.
	 */		
	method moveUp(n) { y += n }
	
	/**
	 * Substract n to y coordinate.
	 */		
	method moveDown(n) { y -= n }
	
	/**
	 * Adds an object to the board for drawing it in self.
	 */
	method drawElement(element) { game.addVisualIn(element, self) } //TODO: Implement native
	
	/**
	 * Adds an object to the board for drawing it in self. It can be moved with arrow keys.
	 */
	method drawCharacter(element) { game.addVisualCharacterIn(element, self) } //TODO: Implement native

	/**
	 * Removes an object from the board for stop drawing it.
	 */
	method deleteElement(element) { game.removeVisual(element) } //TODO: Remove

	/**
	 * Draw a dialog balloon with given message in given visual object position.
	 */	
	method say(element, message) { game.say(element, message) } //TODO: Implement native

	/**
	 * Returns all objects in self.
	 */	
	method allElements() = game.getObjectsIn(self) //TODO: Implement native
	
	/**
	 * Returns a new position with same coordinates.
	 */	
	method clone() = new Position(x, y)

	/**
	 * Returns the distance between given position and self.
	 */	
	method distance(position) {
	    const deltaX = x - position.x()
	    const deltaY = y - position.y()
	    return (deltaX.square() + deltaY.square()).squareRoot() 
	}

	/**
	 * Removes all objects in self from the board for stop drawing it.
	 */
	method clear() {
		self.allElements().forEach{it => game.removeVisual(it)}
	}
	
	/**
	 * Returns x coordinate.
	 */	
	method x() = x

	/**
	 * Sets x coordinate.
	 */	
	method x(_x) { x = _x }
	
	/**
	 * Returns y coordinate.
	 */	
	method y() = y

	/**
	 * Sets y coordinate.
	 */	
	method y(_y) { y = _y }
	
	/**
	 * Two positions are equals if have same coordinates.
	 */	
	override method ==(other) = x == other.x() && y == other.y()
	
	override method toString() = "(" + x + "," + y + ")"
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
