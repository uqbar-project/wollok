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
	
		new()
		new(_message) = this(_message, null)
		new(_message, _cause) { message = _message ; cause = _cause }
		
		method printStackTrace() { this.printStackTraceWithPreffix("") }
		
		/**@private */
		method printStackTraceWithPreffix(preffix) {
			console.println(preffix + "Exception " + this.className() + (if (message != null) (" :" + message.toString()) else "")
			
			// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
			this.getStackTrace().forEach[e|
				console.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
			]
			
			if (cause != null)
				cause.printStackTraceWithPreffix("Caused by: ")
		}
		
		/**@private */
		method createStackTraceElement(contextDescription, location) = new StackTraceElement(contextDescription, location)
		
		method getStackTrace() native
		
		method getMessage() = message
	}
	
	class StackTraceElement {
		val contextDescription
		val location
		new(_contextDescription, _location) {
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
		
		method ==(other) {
			return this === other
		}
		
		method equals(other) = this == other
		
		method ->(other) {
			return new Pair(this, other)
		}
		
		method randomBetween(start, end) native
		
		method toString() {
			// TODO: should be a set
			// return this.toSmartString(#{})
			return this.toSmartString(#[])
		}
		method toSmartString(alreadyShown) {
			if (alreadyShown.exists[e| e.identity() == this.identity()] ) { 
				return this.kindName() 
			}
			else {
				alreadyShown.add(this)
				return this.internalToSmartString(alreadyShown)
			}
		} 
		method internalToSmartString(alreadyShown) {
			return this.kindName() + "[" 
				+ this.instanceVariables().map[v| 
					v.name() + "=" + v.valueToSmartString(alreadyShown)
				].join(', ') 
			+ "]"
		}
	}
	
	class Pair {
		val x
		val y
		new (_x, _y) {
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
		  *       #["a", "ab", "abc", "d" ].max[e| e.length() ]    ->  returns "abc"		 
		  */
		method max(closure) = this.absolute(closure, [a,b | a > b])
		
		/**
		  * Returns the element that is considered to be/have the minimum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       #["ab", "abc", "hello", "wollok world"].max[e| e.length() ]    ->  returns "wollok world"		 
		  */
		method min(closure) = this.absolute(closure, [a,b | a < b])
		
		method absolute(closure, criteria) {
			val result = this.fold(null, [acc, e|
				val n = closure.apply(e) 
				if (acc == null)
					new Pair(e, n)
				else {
					if (criteria.apply(n, acc.getY()))
						new Pair(e, n)
					else
						acc
				}
			])
			return if (result == null) null else result.getX()
		}
		 
		// non-native methods
		
		/**
		  * Adds all elements from the given collection parameter to this collection
		  */
		method addAll(elements) { elements.forEach[e| this.add(e) ] }
		
		/** Tells whether this collection has no elements */
		method isEmpty() = this.size() == 0
				
		/**
		 * Performs an operation on every elements of this collection.
		 * The logic to execute is passed as a closure that takes a single parameter.
		 * @returns nothing
		 * Example:
		 *      plants.forEach[ plant |   plant.takeSomeWater() ]
		 */
		method forEach(closure) { this.fold(null, [ acc, e | closure.apply(e) ]) }
		
		/**
		 * Tells whether all the elements of this collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.forAll[ plant | plant.hasFlowers() ]
		 */
		method forAll(predicate) = this.fold(true, [ acc, e | if (!acc) acc else predicate.apply(e) ])
		/**
		 * Tells whether at least one element of this collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.exists[ plant | plant.hasFlowers() ]
		 */
		method exists(predicate) = this.fold(false, [ acc, e | if (acc) acc else predicate.apply(e) ])
		/**
		 * Returns the element of this collection that satisfy a given condition.
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition
		 * Example:
		 *      users.detect[ user | user.name() == "Cosme Fulanito" ]
		 */
		method detect(predicate) = this.fold(null, [ acc, e |
			 if (acc != null)
			 	acc
			 else
			 	if (predicate.apply(e)) e else null
		])
		/**
		 * Counts all elements of this collection that satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a number.
		 * @returns an integer number
		 * Example:
		 *      plants.count[ plant | plant.hasFlowers() ]
		 */
		method count(predicate) = this.fold(0, [ acc, e | if (predicate.apply(e)) acc++ else acc  ])
		/**
		 * Collects the sum of each value for all e
		 * This is similar to call a map[] to transform each element into a number object and then adding all those numbers.
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns an integer
		 * Example:
		 *      val totalNumberOfFlowers = plants.sum[ plant | plant.numberOfFlowers() ]
		 */
		method sum(closure) = this.fold(0, [ acc, e | acc + closure.apply(e) ])
		
		/**
		 * Returns a new collection that contains the result of transforming each of this collection's elements
		 * using a given closure.
		 * The condition is a closure argument that takes a single element and returns an object.
		 * @returns another collection (same type as this one)
		 * Example:
		 *      val ages = users.map[ user | user.age() ]
		 */
		method map(closure) = this.fold(this.newInstance(), [ acc, e |
			 acc.add(closure.apply(e))
			 acc
		])
		
		method flatMap(closure) = this.fold(this.newInstance(), [ acc, e |
			acc.addAll(closure.apply(e))
			acc
		])

		method filter(closure) = this.fold(this.newInstance(), [ acc, e |
			 if (closure.apply(e))
			 	acc.add(e)
			 acc
		])

		method contains(e) = this.exists[one | e == one ]
		method flatten() = this.flatMap[ e | e ]
		
		override method internalToSmartString(alreadyShown) {
			return this.toStringPrefix() + this.map[e| e.toSmartString(alreadyShown) ].join(', ') + this.toStringSufix()
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
	
		override method newInstance() = #{}
		override method toStringPrefix() = "#{"
		override method toStringSufix() = "}"
		
		override method asList() { 
			val result = #[]
			result.addAll(this)
			return result
		}
		
		override method asSet() = this

		method any() = this.first()
		
		method first() native
		
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
		
		override method newInstance() = #[]
		
		method any() {
			if (this.isEmpty()) 
				throw new Exception() //("Illegal operation 'any' on empty collection")
			else 
				return this.get(this.randomBetween(0, this.size()))
		}
		
		override method toStringPrefix() = "#["
		override method toStringSufix() = "]"

		override method asList() = this
		
		override method asSet() { 
			val result = #{}
			result.addAll(this)
			return result
		}
		
		
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
		new(_start, _end) { start = _start ; end = _end }
		
		method forEach(closure) native
		
		override method internalToSmartString(alreadyShown) = start.toString() + ".." + end.toString()
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
	}

object wgame{
	method addVisual(element) native
	method addVisualCharacter(element) native
	method addVisualWithReference(element, property) native
	method whenKeyPressedDo(key, action) native
	method whenCollideDo(element, action) native
	method getObjectsIn(position) native
	method clear() native
	method start() native
	
	method setTittle(tittle) native
	method getTittle() native
	method setWidth(cant) native
	method getWidth() native
	method setHeight(cant) native
	method getHeight() native
}

object keys {
	method getKeyCode(aKey) native
	
	method onPress(key) {
		return new ProtoKeyListener(this.getKeyCode(key))
	}
}

class ProtoKeyListener {
	val key

	new(_key) {
		key = _key
	}
	
	method do(action) {
		wgame.whenKeyPressedDo(key, action)
	}
}

class Position {
	var x = 0
	var y = 0
	
	new() { }
	
	new(_x, _y) {
		x = _x
		y = _y
	}
	
	method moveLeft(num) {
		x = x - num
	}
	method moveRight(num) {
		x = x + num
	}
	method moveDown(num) {
		y = y - num
	}
	method moveUp(num) {
		y = y + num
	}
	
	method clone() = new Position(x, y)
	
	method == (other) {
		return x == other.getX() and y == other.getY()
	}
	
	method drawCharacterWithReferences(element, reference){
		element.setPosicion(this.clone())
		wgame.addVisualCharacterWithRefence(element, reference)
	}
	
	method drawCharacter(element){
		element.setPosicion(this.clone())
		wgame.addVisualCharacter(element)
	}
	
	method drawElementWithReferences(element, reference){
		element.setPosicion(this.clone())
		wgame.addVisualWithReference(element, reference)
	}
	
	method drawElement(element){
		element.setPosicion(this.clone())
		wgame.addVisual(element)
	}
	
	method getX() {
		return x
	}
	method setX(_x) {
		x = _x
	}
	method getY() {
		return y
	}
	method setY(_y) {
		y = _y
	}
}

package mirror {

	class InstanceVariableMirror {
		val target
		val name
		new(_target, _name) { target = _target ; name = _name }
		method name() = name
		method value() = target.resolve(name)
		
		method valueToSmartString(alreadyShown) {
			val v = this.value()
			return if (v == null) "null" else v.toSmartString(alreadyShown)
		}

		method toString() = name + "=" + this.value()
	}
}
