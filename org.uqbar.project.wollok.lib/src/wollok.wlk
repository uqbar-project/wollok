/**
 * Base class for all Exceptions.
 * 
 * @author jfernandes
 * @since 1.0
 */
package lang {
 
	/**
	 * Base class for all Exceptions.
	 * 
	 * @author jfernandes
	 * @since 1.0
	 */
	class Exception {
		val message
		val cause
	
		constructor()
		constructor(_message) = this(_message, null)
		constructor(_message, _cause) { message = _message ; cause = _cause }
		
		method printStackTrace() { this.printStackTrace(console) }
		method getStackTraceAsString() {
			val printer = new StringPrinter()
			this.printStackTrace(printer)
			return printer.getBuffer()
		}
		
		method printStackTrace(printer) { this.printStackTraceWithPreffix("", printer) }
		
		/** @private */
		method printStackTraceWithPreffix(preffix, printer) {
			printer.println(preffix +  this.className() + (if (message != null) (": " + message.toString()) else "")
			
			// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
			this.getStackTrace().forEach { e =>
				printer.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
			}
			
			if (cause != null)
				cause.printStackTraceWithPreffix("Caused by: ", printer)
		}
		
		/** @private */
		method createStackTraceElement(contextDescription, location) = new StackTraceElement(contextDescription, location)
		
		method getStackTrace() native
		
		method getMessage() = message
	}
	
	class ElementNotFoundException inherits Exception {
		constructor(_message) = super(_message)
		constructor(_message, _cause) = super(_message, _cause)
	}

	class MessageNotUnderstoodException inherits Exception {
		constructor()
		constructor(_message) = super(_message)
		constructor(_message, _cause) = super(_message, _cause)
		
		/*
		'''«super.getMessage()»
			«FOR m : wollokStack»
			«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
			«ENDFOR»
			'''
		*/
	}
	
	class StackTraceElement {
		val contextDescription
		val location
		constructor(_contextDescription, _location) {
			contextDescription = _contextDescription
			location = _location
		}
		method contextDescription() = contextDescription
		method location() = location
	}
	
	/**
	 *
	 * @author jfernandes
	 * since 1.0
	 */
	class Object {
		method identity() native
		method instanceVariables() native
		method instanceVariableFor(name) native
		method resolve(name) native
		method kindName() native
		method className() native
		
		/**
		 * Tells whether this object is "equals" to the given object
		 * The default behavior compares them in terms of identity (===)
		 */
		method ==(other) {
			return this === other
		}
		
		/** Tells whether this object is not equals to the given one */
		method !=(other) = ! (this == other)
		
		/**
		 * Tells whether this object is identical (the same) to the given one.
		 * It does it by comparing their identities.
		 * So this basically relies on the wollok.lang.Integer equality (which is native)
		 */
		method ===(other) {
			return this.identity() == other.identity()
		}
		
		method equals(other) = this == other
		
		method randomBetween(start, end) native
		
		method ->(other) {
			return new Pair(this, other)
		}

		method toString() {
			// TODO: should be a set
			// return this.toSmartString(#{})
			return this.toSmartString([])
		}
		method toSmartString(alreadyShown) {
			if (alreadyShown.any { e => e.identity() == this.identity() } ) { 
				return this.kindName() 
			}
			else {
				alreadyShown.add(this)
				return this.internalToSmartString(alreadyShown)
			}
		} 
		method internalToSmartString(alreadyShown) {
			return this.kindName() + "[" 
				+ this.instanceVariables().map { v => 
					v.name() + "=" + v.valueToSmartString(alreadyShown)
				}.join(', ') 
			+ "]"
		}
		
		method messageNotUnderstood(name, parameters) {
			var message = if (name != "toString") 
						this.toString()
					 else 
					 	this.kindName()
			message += " does not understand " + name
			if (parameters.size() > 0)
				message += "(" + (0..(parameters.size()-1)).map { i => "p" + i }.join(',') + ")"
			else
				message += "()"
			throw new MessageNotUnderstoodException(message)
		}
		
		method error(message) {
			throw new Exception(message)
		}
	}
	
	object void { }
	
	
	class Pair {
		val x
		val y
		constructor (_x, _y) {
			x = _x
			y = _y
		}
		method getX() { return x }
		method getY() { return y }
		method getKey() { return this.getX() }
		method getValue() { return this.getY() }
	}
	
	class Collection {
		/**
		  * Returns the element that is considered to be/have the maximum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["a", "ab", "abc", "d" ].max { e => e.length() }    =>  returns "abc"		 
		  */
		method max(closure) = this.absolute(closure, { a, b => a > b })
		
		/**
		  * Returns the element that is considered to be/have the minimum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["ab", "abc", "hello", "wollok world"].max { e => e.length() }    =>  returns "wollok world"		 
		  */
		method min(closure) = this.absolute(closure, { a, b => a < b} )
		
		method absolute(closure, criteria) {
			val result = this.fold(null, { acc, e =>
				val n = closure.apply(e) 
				if (acc == null)
					new Pair(e, n)
				else {
					if (criteria.apply(n, acc.getY()))
						new Pair(e, n)
					else
						acc
				}
			})
			return if (result == null) null else result.getX()
		}
		 
		// non-native methods
		
		/**
		  * Adds all elements from the given collection parameter to this collection
		  */
		method addAll(elements) { elements.forEach { e => this.add(e) } }
		
		/** Tells whether this collection has no elements */
		method isEmpty() = this.size() == 0
				
		/**
		 * Performs an operation on every elements of this collection.
		 * The logic to execute is passed as a closure that takes a single parameter.
		 * @returns nothing
		 * Example:
		 *      plants.forEach { plant => plant.takeSomeWater() }
		 */
		method forEach(closure) { this.fold(null, { acc, e => closure.apply(e) }) }
		
		/**
		 * Tells whether all the elements of this collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.all { plant -> plant.hasFlowers() }
		 */
		method all(predicate) = this.fold(true, { acc, e => if (!acc) acc else predicate.apply(e) })
		/**
		 * Tells whether at least one element of this collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.any { plant => plant.hasFlowers() }
		 */
		method any(predicate) = this.fold(false, { acc, e => if (acc) acc else predicate.apply(e) })
		/**
		 * Returns the element of this collection that satisfy a given condition.
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition
		 * @throws
		 * Example:
		 *      users.find { user => user.name() == "Cosme Fulanito" }
		 */
		method find(predicate) = this.findOrElse(predicate, { 
			throw new ElementNotFoundException("there is no element that satisfies the predicate")
		})

		method findOrDefault(predicate, value) =  this.findOrElse(predicate, { value })
		
		method findOrElse(predicate, continuation) {
			this.forEach { e =>
				if (predicate.apply(e)) 
					return e
			}
			return continuation.apply()
		}

		/**
		 * Counts all elements of this collection that satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a number.
		 * @returns an integer number
		 * Example:
		 *      plants.count { plant => plant.hasFlowers() }
		 */
		method count(predicate) = this.fold(0, { acc, e => if (predicate.apply(e)) acc++ else acc  })
		/**
		 * Collects the sum of each value for all e
		 * This is similar to call a map {} to transform each element into a number object and then adding all those numbers.
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns an integer
		 * Example:
		 *      val totalNumberOfFlowers = plants.sum{ plant => plant.numberOfFlowers() }
		 */
		method sum(closure) = this.fold(0, { acc, e => acc + closure.apply(e) })
		
		/**
		 * Returns a new collection that contains the result of transforming each of this collection's elements
		 * using a given closure.
		 * The condition is a closure argument that takes a single element and returns an object.
		 * @returns another collection (same type as this one)
		 * Example:
		 *      val ages = users.map{ user => user.age() }
		 */
		method map(closure) = this.fold(this.newInstance(), { acc, e =>
			 acc.add(closure.apply(e))
			 acc
		})
		
		method flatMap(closure) = this.fold(this.newInstance(), { acc, e =>
			acc.addAll(closure.apply(e))
			acc
		})

		method filter(closure) = this.fold(this.newInstance(), { acc, e =>
			 if (closure.apply(e))
			 	acc.add(e)
			 acc
		})

		method contains(e) = this.any {one => e == one }
		method flatten() = this.flatMap { e => e }
		
		override method internalToSmartString(alreadyShown) {
			return this.toStringPrefix() + this.map{e=> e.toSmartString(alreadyShown) }.join(', ') + this.toStringSufix()
		}
		
		method toStringPrefix()
		method toStringSufix()
		method asList()
		method asSet()
		
		method newInstance()
	}

	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */	
	class Set inherits Collection {
		constructor(elements ...) {
			this.addAll(elements)
		}
		
		override method newInstance() = #{}
		override method toStringPrefix() = "#{"
		override method toStringSufix() = "}"
		
		override method asList() { 
			val result = []
			result.addAll(this)
			return result
		}
		
		override method asSet() = this

		override method anyOne() native
		
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method add(element) native
		method remove(element) native
		method size() native
		method clear() native
		method join(separator) native
		method join() native
		method equals(other) native
		method ==(other) native
	}
	
	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */
	class List inherits Collection {

		method get(index) native
		
		override method newInstance() = []
		
		method anyOne() {
			if (this.isEmpty()) 
				throw new Exception("Illegal operation 'anyOne' on empty collection")
			else 
				return this.get(this.randomBetween(0, this.size()))
		}
		
		method first() = this.head()
		method head() = this.get(0)
		
		override method toStringPrefix() = "["
		override method toStringSufix() = "]"

		override method asList() = this
		
		override method asSet() { 
			val result = #{}
			result.addAll(this)
			return result
		}
		
		method subList(start,end) {
			if(this.isEmpty)
				return this.newInstance()
			val newList = this.newInstance()
			val _start = start.limitBetween(0,this.size()-1)
			val _end = end.limitBetween(0,this.size()-1)
			(_start.._end).forEach { i => newList.add(this.get(i)) }
			return newList
		}
		
		method take(n) =
			if(n <= 0)
				this.newInstance()
			else
				this.subList(0,n-1)
			
		
		method drop(n) = 
			if(n >= this.size())
				this.newInstance()
			else
				this.subList(n,this.size()-1)
			
		
		method reverse() = this.subList(this.size()-1,0)
	
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method add(element) native
		method remove(element) native
		method size() native
		method clear() native
		method join(separator) native
		method join() native
		method equals(other) native
		method ==(other) native
	}
	
	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */	
	class Number {
		method max(other) = if (this >= other) this else other
		method min(other) = if (this <= other) this else other
		
		method limitBetween(limitA,limitB) =if(limitA <= limitB) limitA.max(this).min(limitB) 
											else limitB.max(this).min(limitA)
			
		method !=(other) = ! (this == other)
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Integer inherits Number {
		method ==(other) native
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method **(other) native
		method %(other) native
		
		method toString() native
		
		override method internalToSmartString(alreadyShown) { return this.stringValue() }
		method stringValue() native	
		
		method ..(end) = new Range(this, end)
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Double inherits Number {
		method ==(other) native
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method **(other) native
		method %(other) native
		
		method toString() native
		
		override method internalToSmartString(alreadyShown) { return this.stringValue() }
		method stringValue() native	
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native
	}
	
	/**
	 * @author jfernandes
	 * @noInstantiate
	 */
	class String {
		method length() native
		method charAt(index) native
		method +(other) native
		method startsWith(other) native
		method endsWith(other) native
		method indexOf(other) native
		method lastIndexOf(other) native
		method toLowerCase() native
		method toUpperCase() native
		method trim() native
		
		method substring(length) native
		method substring(startIndex, length) native

		method toString() native
		method toSmartString(alreadyShown) native
		method ==(other) native
		
		
		method size() = this.length()
	}
	
	/**
	 * @author jfernandes
	 * @noinstantiate
	 */
	class Boolean {
	
		method and(other) native
		method &&(other) native
		
		method or(other) native
		method ||(other) native
		
		method toString() native
		method toSmartString(alreadyShown) native
		method ==(other) native
		
		method negate() native
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 */
	class Range {
		val start
		val end
		constructor(_start, _end) { start = _start ; end = _end }
		
		method forEach(closure) native
		
		method map(closure) {
			val l = []
			this.forEach{e=> l.add(closure.apply(e)) }
			return l
		}
		
		override method internalToSmartString(alreadyShown) = start.toString() + ".." + end.toString()
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Closure {
		method apply(parameters...) native
		method toString() native
	}
}
 
package lib {

	object console {
		method println(obj) native
		method readLine() native
		method readInt() native
	}
	
	object assert {
		method that(value) native
		method notThat(value) native
		method equals(expected, actual) native
		method notEquals(expected, actual) native
		method throwsException(block) native
		method fail(message) native
	}
	
	class StringPrinter {
		var buffer = ""
		method println(obj) {
			buffer += obj.toString() + "\n"
		}
		method getBuffer() = buffer
	}	
	

	object wgame {
		method addVisual(element) native
		method addVisualCharacter(element) native
		method addVisualWithReference(element, property) native
		method addVisualCharacterWithReference(element, property) native
		method whenKeyPressedDo(key, action) native
		method whenKeyPressedSay(key, function) native
		method whenCollideDo(element, action) native
		method getObjectsIn(position) native
		method clear() native
		method start() native
		
		method setTitle(title) native
		method getTitle() native
		method setWidth(width) native
		method getWidth() native
		method setHeight(height) native
		method getHeight() native
		method setGround(image) native
	}
	
	
	class Position {
		var x = 0
		var y = 0
		
		constructor() { }
		
		constructor(_x, _y) {
			x = _x
			y = _y
		}
		
		method moveLeft(num) { x = x - num }
		method moveRight(num) { x = x + num }
		method moveDown(num) { y = y - num }
		method moveUp(num) { y = y + num }
		
		method clone() = new Position(x, y)
		
		override method == (other) {
			return x == other.getX() and y == other.getY()
		}
		
		method drawCharacterWithReferences(element, reference) {
			element.setPosicion(this.clone())
			wgame.addVisualCharacterWithReference(element, reference)
		}
		
		method drawCharacter(element) {
			element.setPosicion(this.clone())
			wgame.addVisualCharacter(element)
		}
		
		method drawElementWithReferences(element, reference) {
			element.setPosicion(this.clone())
			wgame.addVisualWithReference(element, reference)
		}
		
		method drawElement(element) {
			element.setPosicion(this.clone())
			wgame.addVisual(element)
		}
		
		method getAllElements() = wgame.getObjectsIn(this)
		
		method getX() = x
		
		method setX(_x) { x = _x }
		
		method getY() = y
		
		method setY(_y) { y = _y }
		
	}
}

package game {
		
	class Key {	
		var keyCodes
		
		constructor(_keyCodes) {
			keyCodes = _keyCodes
		}
	
		method onPressDo(action) {
			keyCodes.forEach{ key => wgame.whenKeyPressedDo(key, action) }
		}
		
		method onPressCharacterSay(function) {
			keyCodes.forEach{ key => wgame.whenKeyPressedSay(key, function) }
		}
	}

	object ANY_KEY inherits Key([-1]) { }
  
	object NUM_0 inherits Key([7, 144]) { }
	
	object NUM_1 inherits Key([8, 145]) { }
	
	object NUM_2 inherits Key([9, 146]) { }
	
	object NUM_3 inherits Key([10, 147]) { }
	
	object NUM_4 inherits Key([11, 148]) { }
	
	object NUM_5 inherits Key([12, 149]) { }
	
	object NUM_6 inherits Key([13, 150]) { }
	
	object NUM_7 inherits Key([14, 151]) { }
	
	object NUM_8 inherits Key([15, 152]) { }
	
	object NUM_9 inherits Key([16, 153]) { }
	
	object A inherits Key([29]) { }
	
	object ALT inherits Key([57, 58]) { }
	
	object B inherits Key([30]) { }
  
	object BACKSPACE inherits Key([67]) { }
	
	object C inherits Key([31]) { }
  
	object CONTROL inherits Key([129, 130]) { }
  
	object D inherits Key([32]) { }
	
	object DEL inherits Key([67]) { }
  
	object CENTER inherits Key([23]) { }
	
	object DOWN inherits Key([20]) { }
	
	object LEFT inherits Key([21]) { }
	
	object RIGHT inherits Key([22]) { }
	
	object UP inherits Key([19]) { }
	
	object E inherits Key([33]) { }
	
	object ENTER inherits Key([66]) { }
	
	object F inherits Key([34]) { }
	
	object G inherits Key([35]) { }
	
	object H inherits Key([36]) { }
	
	object I inherits Key([37]) { }
	
	object J inherits Key([38]) { }
	
	object K inherits Key([39]) { }
	
	object L inherits Key([40]) { }
	
	object M inherits Key([41]) { }
	
	object MINUS inherits Key([69]) { }
	
	object N inherits Key([42]) { }
	
	object O inherits Key([43]) { }
	
	object P inherits Key([44]) { }
	
	object PLUS inherits Key([81]) { }
	
	object Q inherits Key([45]) { }
	
	object R inherits Key([46]) { }
	
	object S inherits Key([47]) { }
	
	object SHIFT inherits Key([59, 60]) { }
	
	object SLASH inherits Key([76]) { }
	
	object SPACE inherits Key([62]) { }
	
	object T inherits Key([48]) { }
	
	object U inherits Key([49]) { }
	
	object V inherits Key([50]) { }
	
	object W inherits Key([51]) { }
	
	object X inherits Key([52]) { }
	
	object Y inherits Key([53]) { }
	
	object Z inherits Key([54]) { }
}

package mirror {

	class InstanceVariableMirror {
		val target
		val name
		constructor(_target, _name) { target = _target ; name = _name }
		method name() = name
		method value() = target.resolve(name)
		
		method valueToSmartString(alreadyShown) {
			val v = this.value()
			return if (v == null) "null" else v.toSmartString(alreadyShown)
		}

		method toString() = name + "=" + this.value()
	}
}
