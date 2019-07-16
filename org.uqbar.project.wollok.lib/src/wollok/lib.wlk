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
 * Exception to handle other values expected in assert.throwsException... methods
 */
class OtherValueExpectedException inherits wollok.lang.Exception {}

/**
 * Exception to handle difference between current and expected values
 * in assert.throwsException... methods
 */
class AssertionException inherits Exception {
	const property expected = null
	const property actual = null
}

/**
 * Assert object simplifies testing conditions
 */
object assert {

	/** 
	 * Tests whether value is true. Otherwise throws an exception.
	 *
	 * Example:
	 *		assert.that(7.even())   ==> throws an exception "Value was not true"
	 *		assert.that(8.even())   ==> ok, nothing happens	
	 */
	method that(value) {
		self.checkNotNull(value, "that")
		if (!value) throw new AssertionException(message = "Value was not true")
	}
	
	/** Tests whether value is false. Otherwise throws an exception. 
	 * @see assert#that(value) 
	 */
	method notThat(value) {
		self.checkNotNull(value, "notThat")
		if (value) throw new AssertionException(message = "Value was not false")
	}
	
	/*
	 * This method avoids confusion with equals definition in Object
	 */
	override method equals(value) {
		throw new AssertionException(message = "assert.equals(expected, actual): missing second parameter")
	}
	
	/** 
	 * Tests whether two values are equal, based on wollok ==, != methods
	 * 
	 * Examples:
	 *		 assert.equals(10, 100.div(10)) ==> ok, nothing happens
	 *		 assert.equals(10.0, 100.div(10)) ==> ok, nothing happens
	 *		 assert.equals(10.01, 100.div(10)) ==> throws an exception 
	 */
	method equals(expected, actual) {
		if (expected != actual) throw new AssertionException(message = "Expected [" + expected.printString() + "] but found [" + actual.printString() + "]")
	}
	
	/** 
	 * Tests whether two values are equal, based on wollok ==, != methods
	 * 
	 * Examples:
	 *       const value = 5
	 *		 assert.notEquals(10, value * 3) ==> ok, nothing happens
	 *		 assert.notEquals(10, value)     ==> throws an exception
	 */
	method notEquals(expected, actual) {
		if (expected == actual) throw new AssertionException(message = "Expected to be different, but [" + expected.printString() + "] and [" + actual.printString() + "] match")
	}
	
	/** 
	 * Tests whether a block throws an exception. Otherwise an exception is thrown.
	 *
	 * Examples:
	 * 		assert.throwsException({ 7 / 0 })  
	 *         ==> Division by zero error, it is expected, ok
	 *
	 *		assert.throwsException({ "hola".length() }) 
	 *         ==> throws an exception "Block should have failed"
	 */
	method throwsException(block) {
		self.checkNotNull(block, "throwsException")
		var failed = false
		try {
			block.apply()
		} catch e {
			failed = true
		}
		if (!failed) throw new AssertionException(message = "Block " + block + " should have failed")
	}
	
	/** 
	 * Tests whether a block throws an exception and this is the same expected. 
	 * Otherwise an exception is thrown.
	 *
	 * Examples:
	 *		assert.throwsExceptionLike(new BusinessException("hola"), 
	 *            { => throw new BusinessException("hola") } 
	 *            => Works! Exception class and message both match.
	 *
	 *		assert.throwsExceptionLike(new BusinessException("chau"),
	 *            { => throw new BusinessException("hola") } 
	 *            => Doesn't work. Exception class matches but messages are different.
	 *
	 *		assert.throwsExceptionLike(new OtherException("hola"),
	 *            { => throw new BusinessException("hola") } 
	 *            => Doesn't work. Messages matches but they are instances of different exceptions.
	 */	 
	method throwsExceptionLike(exceptionExpected, block) {
		self.checkNotNull(exceptionExpected, "throwsExceptionLike")
		self.checkNotNull(block, "throwsExceptionLike")
		try 
		{
			self.throwsExceptionByComparing(block, {a => a.equals(exceptionExpected)})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new AssertionException(message = "The Exception expected was " + exceptionExpected + " but got " + ex.cause())
		} 
	}

	/** 
	 * Tests whether a block throws an exception and it has the error message as is expected. 
	 * Otherwise an exception is thrown.
	 *
	 * Examples:
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new BusinessException(message = "hola") } 
	 *           => Works! Both have the same message.
	 *
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new OtherException(message = "hola") } 
	 *           => Works! Both have the same message.
	 *
	 *		assert.throwsExceptionWithMessage("chau",{ => throw new BusinessException(message = "hola") } 
	 *           => Doesn't work. Both are instances of BusinessException but their messages differ.
	 */	 
	method throwsExceptionWithMessage(errorMessage, block) {
		self.checkNotNull(errorMessage, "throwsExceptionWithMessage")
		self.checkNotNull(block, "throwsExceptionWithMessage")
		try 
		{
			self.throwsExceptionByComparing(block, {a => errorMessage.equals(a.message())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new AssertionException(message = "The error message expected was " + errorMessage + " but got " + ex.cause().message())
		}
	}

	/** 
	 * Tests whether a block throws an exception and this is the same exception class expected.
	 * Otherwise an exception is thrown.
	 *
	 * Examples:
	 *		assert.throwsExceptionWithType(new BusinessException("hola"),{ => throw new BusinessException("hola") } 
     *          => Works! Both exceptions are instances of the same class.
     *
	 *		assert.throwsExceptionWithType(new BusinessException("chau"),{ => throw new BusinessException("hola") } 
	 *          => Works again! Both exceptions are instances of the same class.
	 *
	 *		assert.throwsExceptionWithType(new OtherException("hola"),{ => throw new BusinessException("hola") } 
	 *          => Doesn't work. Exception classes differ although they contain the same message.
	 */	 	
	method throwsExceptionWithType(exceptionExpected, block) {
		self.checkNotNull(exceptionExpected, "throwsExceptionWithType")
		self.checkNotNull(block, "throwsExceptionWithType")
		try 
		{
			self.throwsExceptionByComparing(block,{a => exceptionExpected.className().equals(a.className())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new AssertionException(message = "The exception expected was " + exceptionExpected.className() + " but got " + ex.cause().className())
		}
	}

	/** 
	 * Tests whether a block throws an exception and compare this exception with other block 
	 * called comparison. Otherwise an exception is thrown. The block comparison
	 * receives a value (an exception thrown) that is compared in a boolean expression
	 * returning the result.
	 *
	 * Examples:
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{ex => "hola".equals(ex.message())}} 
	 *          => Works!.
	 *
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{ex => new BusinessException("lele").className().equals(ex.className())} } 
	 *          => Works again!
	 *
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{ex => "chau!".equals(ex.message())} } 
	 *          => Doesn't work. The block evaluation resolves to a false value.
	 */		
	method throwsExceptionByComparing(block, comparison){
		self.checkNotNull(block, "throwsExceptionByComparing")
		self.checkNotNull(comparison, "throwsExceptionByComparing")
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
					throw new OtherValueExpectedException(message = "Expected other value", cause = ex)
			}
		if (continue) throw new AssertionException(message = "Should have thrown an exception")
	}
	
	/**
	 * Throws an exception with a custom message. 
	 * Useful when you reach code that should not be reached.
	 */
	method fail(message) {
		self.checkNotNull(message, "fail")
		throw new AssertionException(message = message)
	}
	
}

class StringPrinter {
	var buffer = ""
	
	method println(obj) {
		self.checkNotNull(obj, "println")
		buffer += obj.toString() + console.newline()
	}
	
	method getBuffer() = buffer
}	
