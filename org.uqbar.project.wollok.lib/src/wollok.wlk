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
		const message
		const cause
	
		constructor()
		constructor(_message) = self(_message, null)
		constructor(_message, _cause) { message = _message ; cause = _cause }
		
		method printStackTrace() { self.printStackTrace(console) }
		method getStackTraceAsString() {
			const printer = new StringPrinter()
			self.printStackTrace(printer)
			return printer.getBuffer()
		}
		
		method printStackTrace(printer) { self.printStackTraceWithPreffix("", printer) }
		
		/** @private */
		method printStackTraceWithPreffix(preffix, printer) {
			printer.println(preffix +  self.className() + (if (message != null) (": " + message.toString()) else "")
			
			// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
			self.getStackTrace().forEach { e =>
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
		const contextDescription
		const location
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
		 * Tells whether self object is "equals" to the given object
		 * The default behavior compares them in terms of identity (===)
		 */
		method ==(other) {
			return self === other
		}
		
		/** Tells whether self object is not equals to the given one */
		method !=(other) = ! (self == other)
		
		/**
		 *
		 
		 
		 
		  Tells whether self object is identical (the same) to the given one.
		 * It does it by comparing their identities.
		 * So self basically relies on the wollok.lang.Integer equality (which is native)
		 */
		method ===(other) {
			return self.identity() == other.identity()
		}
		
		method equals(other) = self == other
		
		method ->(other) {
			return new Pair(self, other)
		}

		method toString() {
			// TODO: should be a set
			// return self.toSmartString(#{})
			return self.toSmartString([])
		}
		method toSmartString(alreadyShown) {
			if (alreadyShown.any { e => e.identity() == self.identity() } ) { 
				return self.simplifiedToSmartString() 
			}
			else {
				alreadyShown.add(self)
				return self.internalToSmartString(alreadyShown)
			}
		} 
		
		method simplifiedToSmartString(){
			return self.kindName()
		}
		
		method internalToSmartString(alreadyShown) {
			return self.kindName() + "[" 
				+ self.instanceVariables().map { v => 
					v.name() + "=" + v.valueToSmartString(alreadyShown)
				}.join(', ') 
			+ "]"
		}
		
		method messageNotUnderstood(name, parameters) {
			var message = if (name != "toString") 
						self.toString()
					 else 
					 	self.kindName()
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
		const x
		const y
		constructor (_x, _y) {
			x = _x
			y = _y
		}
		method getX() { return x }
		method getY() { return y }
		method getKey() { return self.getX() }
		method getValue() { return self.getY() }
	}
	
	class Collection {
		/**
		  * Returns the element that is considered to be/have the maximum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["a", "ab", "abc", "d" ].max { e => e.length() }    =>  returns "abc"		 
		  */
		method max(closure) = self.absolute(closure, { a, b => a > b })

		/**
		  * Returns the element that represents the maximum value in the collection.
		  * The criteria is by direct comparison of the elements.
		  * Example:
		  *       [11, 1, 4, 8, 3, 15, 6].max()    =>  returns 15		 
		  */
		method max() = self.max({it => it})		
		
		/**
		  * Returns the element that is considered to be/have the minimum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["ab", "abc", "hello", "wollok world"].min({ e => e.length() })    =>  returns "ab"		 
		  */
		method min(closure) = self.absolute(closure, { a, b => a < b} )
		
		/**
		  * Returns the element that represents the minimum value in the collection.
		  * The criteria is by direct comparison of the elements.
		  * Example:
		  *       [11, 1, 4, 8, 3, 15, 6].min()    =>  returns 1 
		  */
		method min() = self.min({it => it})

		method absolute(closure, criteria) {
			if (self.isEmpty())
				throw new ElementNotFoundException("collection is empty")
			const result = self.fold(null, { acc, e =>
				const n = closure.apply(e) 
				if (acc == null)
					new Pair(e, n)
				else {
					if (criteria.apply(n, acc.getY()))
						new Pair(e, n)
					else
						acc
				}
			})
			return result.getX()
		}
		 
		// non-native methods

		/**
		  * Concatenates all elements from the given collection parameter to self collection giving a new collection
		  * (no side effect) 
		  */
		method +(elements) {
			const newCol = self.copy() 
			newCol.addAll(elements)
			return newCol 
		}
		
		/**
		  * Adds all elements from the given collection parameter to self collection
		  */
		method addAll(elements) { elements.forEach { e => self.add(e) } }
		
		/** Tells whether self collection has no elements */
		method isEmpty() = self.size() == 0
				
		/**
		 * Performs an operation on every elements of self collection.
		 * The logic to execute is passed as a closure that takes a single parameter.
		 * @returns nothing
		 * Example:
		 *      plants.forEach { plant => plant.takeSomeWater() }
		 */
		method forEach(closure) { self.fold(null, { acc, e => closure.apply(e) }) }
		
		/**
		 * Tells whether all the elements of self collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.all { plant -> plant.hasFlowers() }
		 */
		method all(predicate) = self.fold(true, { acc, e => if (!acc) acc else predicate.apply(e) })
		/**
		 * Tells whether at least one element of self collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.any { plant => plant.hasFlowers() }
		 */
		method any(predicate) = self.fold(false, { acc, e => if (acc) acc else predicate.apply(e) })
		/**
		 * Returns the element of self collection that satisfy a given condition.
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition
		 * @throws ElementNotFoundException if no element matched the given predicate
		 * Example:
		 *      users.find { user => user.name() == "Cosme Fulanito" }
		 */
		method find(predicate) = self.findOrElse(predicate, { 
			throw new ElementNotFoundException("there is no element that satisfies the predicate")
		})

		/**
		 * Returns the element of self collection that satisfy a given condition, or the given default otherwise, if no element matched the predicate
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition or the default value
		 * Example:
		 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, homer)
		 */
		method findOrDefault(predicate, value) =  self.findOrElse(predicate, { value })
		
		/**
		 * Returns the element of self collection that satisfy a given condition, 
		 * or the the result of evaluating the given continuation 
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition or the result of evaluating the continuation
		 * Example:
		 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, { homer })
		 */
		method findOrElse(predicate, continuation) native

		/**
		 * Counts all elements of self collection that satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a number.
		 * @returns an integer number
		 * Example:
		 *      plants.count { plant => plant.hasFlowers() }
		 */
		method count(predicate) = self.fold(0, { acc, e => if (predicate.apply(e)) acc++ else acc  })
		/**
		 * Collects the sum of each value for all e
		 * This is similar to call a map {} to transform each element into a number object and then adding all those numbers.
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns an integer
		 * Example:
		 *      const totalNumberOfFlowers = plants.sum{ plant => plant.numberOfFlowers() }
		 */
		method sum(closure) = self.fold(0, { acc, e => acc + closure.apply(e) })
		
		/**
		 * Sums all elements in the collection.
		 * @returns an integer
		 * Example:
		 *      const total = [1, 2, 3, 4, 5].sum() 
		 */
		method sum() = self.sum( {it => it} )
		
		/**
		 * Returns a new collection that contains the result of transforming each of self collection's elements
		 * using a given closure.
		 * The condition is a closure argument that takes a single element and returns an object.
		 * @returns another collection (same type as self one)
		 * Example:
		 *      const ages = users.map{ user => user.age() }
		 */
		method map(closure) = self.fold(self.newInstance(), { acc, e =>
			 acc.add(closure.apply(e))
			 acc
		})
		
		method flatMap(closure) = self.fold(self.newInstance(), { acc, e =>
			acc.addAll(closure.apply(e))
			acc
		})

		method filter(closure) = self.fold(self.newInstance(), { acc, e =>
			 if (closure.apply(e))
			 	acc.add(e)
			 acc
		})

		method contains(e) = self.any {one => e == one }
		method flatten() = self.flatMap { e => e }
		
		override method internalToSmartString(alreadyShown) {
			return self.toStringPrefix() + self.map{e=> e.toSmartString(alreadyShown) }.join(', ') + self.toStringSufix()
		}
		
		method toStringPrefix()
		method toStringSufix()
		method asList()
		method asSet()
		method copy() {
			var copy = self.newInstance()
			copy.addAll(self)
			return copy
		}
		method sortedBy(closure) = self.copy().asList().sortBy(closure)
		
		method newInstance()
	}

	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */	
	class Set inherits Collection {
		constructor(elements ...) {
			self.addAll(elements)
		}
		
		override method newInstance() = #{}
		override method toStringPrefix() = "#{"
		override method toStringSufix() = "}"
		
		override method asList() { 
			const result = []
			result.addAll(self)
			return result
		}
		
		override method asSet() = self

		override method anyOne() native
		
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method findOrElse(predicate, continuation) native
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
			if (self.isEmpty()) 
				throw new Exception("Illegal operation 'anyOne' on empty collection")
			else 
				return self.get(0.randomUpTo(self.size()))
		}
		
		method first() = self.head()
		method head() = self.get(0)
		
		override method toStringPrefix() = "["
		override method toStringSufix() = "]"

		override method asList() = self
		
		override method asSet() { 
			const result = #{}
			result.addAll(self)
			return result
		}
		
		method subList(start,end) {
			if(self.isEmpty)
				return self.newInstance()
			const newList = self.newInstance()
			const _start = start.limitBetween(0,self.size()-1)
			const _end = end.limitBetween(0,self.size()-1)
			(_start.._end).forEach { i => newList.add(self.get(i)) }
			return newList
		}
		 
		method sortBy(closure) native
		
		method take(n) =
			if(n <= 0)
				self.newInstance()
			else
				self.subList(0,n-1)
			
		
		method drop(n) = 
			if(n >= self.size())
				self.newInstance()
			else
				self.subList(n,self.size()-1)
			
		
		method reverse() = self.subList(self.size()-1,0)
	
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method findOrElse(predicate, continuation) native
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
	 * Represents a set of key -> values
	 * 
	 */
	class Dictionary {
	
		constructor() { }
		/**
		 * Adds or updates a value based on a key
		 */
		method put(_key, _value) native
		
		/*
		 * Returns the value to which the specified key is mapped, or null if this Dictionary contains no mapping for the key.
		 */
		method basicGet(_key) native

		/*
		 * Returns the value to which the specified key is mapped, or evaluates a non-parameter closure otherwise 
		 */
		method getOrElse(_key, _closure) {
			const value = self.basicGet(_key)
			if (value == null) 
				_closure.apply()
			else 
				return value
		}
		
		/*
		 * Returns the value to which the specified key is mapped. If this Dictionary contains no mapping for the key, an error is thrown.
		 */
		method get(_key) = self.getOrElse(_key,{ => throw new ElementNotFoundException("there is no element associated with key " + _key) })

		/**
		 * Returns the number of key-value mappings in this Dictionary.
		 */
		method size() = self.values().size()
		
		method isEmpty() = self.size() == 0
		
		/**
		 * Returns true if this Dictionary contains a mapping for the specified key.
		 */
		method containsKey(_key) = self.keys().contains(_key)
		
		/**
		 * Returns true if this Dictionary maps one or more keys to the specified value.
		 */
		method containsValue(_value) = self.values().contains(_value)
		
		/**
		 * Removes the mapping for a key from this Dictionary if it is present 
		 */
		method remove(_key) native
		
		/**
		 * Returns a list of the keys contained in this Dictionary.
		 */
		method keys() native
		
		/**
		 * Returns a list of the values contained in this Dictionary.
		 */
		method values() native
		
		/**
		 * Performs the given action for each entry in this Dictionary until all entries have been 
		 * processed or the action throws an exception.
		 * 
		 * Expected closure with two parameters: the first associated with key and second with value.
		 *
		 * Example:
		 * 		mapaTelefonos.forEach({ k, v => result += k.size() + v.size() })
		 * 
		 */
		method forEach(closure) native
		method newInstance() = new Dictionary()
		
		/**
		 * Removes all of the mappings from this Dictionary. This is a side-effect operation.
		 */
		method clear() native
		
	}
	
	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */	
	class Number {
	
		method max(other) = if (self >= other) self else other
		method min(other) = if (self <= other) self else other
		
		method limitBetween(limitA,limitB) = if(limitA <= limitB) 
												limitA.max(self).min(limitB) 
											 else 

											 	limitB.max(self).min(limitA)

		override method simplifiedToSmartString(){ return self.stringValue() }
		override method internalToSmartString(alreadyShown) { return self.stringValue() }
		method between(min, max) { return (self >= min) && (self <= max) }
		method squareRoot() { return self ** 0.5 }
		method square() { return self * self }
		method even() { return self % 2 == 0 }
		method odd() { return self.even().negate() }
		method rem(other) { return self % other }
		
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Integer inherits Number {
		// the whole wollok identity impl is based on self method
		method ===(other) native
	
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method div(other) native
		/**
		 * raisedTo
		 * 3 ** 2 = 9
		 */
		method **(other) native
		/**
		 * returns remainder of division between self and other
		 */
		method %(other) native
		
		method toString() native
		
		method stringValue() native	
		
		method ..(end) = new Range(self, end)
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		/**
		 * 3.invert() ==> -3
		 * (-2).invert() ==> 2
		 */
		method invert() native
		/*
		 * greater common divisor
		 * 8.gcd(12) ==> 4
		 * 5.gcd(10) ==> 5
		 */
		method gcd(other) native
		/**
		 * least common multiple
		 * 3.lcm(4) ==> 12
		 * 6.lcm(12) ==> 12
		 */
		method lcm(other) {
			const mcd = self.gcd(other)
			return self * (other / mcd)
		}
		/**
		 * number of digits of this numbers (without sign)
		 */
		method digits() {
			var digits = self.toString().size()
			if (self < 0) {
				digits -= 1
			}
			return digits
		}
		method isPrime() {
			if (self == 1) return false
			return (2..(self.div(2) + 1)).any({ i => self % i == 0 }).negate()
		}
		/**
		 * Returns a random between self and max
		 */
		method randomUpTo(max) native
		/**
		 * Executes the given action as much times as the receptor object
		 */
		method times(action) = (1..self).forEach(action)
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Double inherits Number {
		// the whole wollok identity impl is based on self method
		method ===(other) native
	
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method div(other) native
		method **(other) native
		method %(other) native
		
		method toString() native
		
		method stringValue() native	
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native
		method randomUpTo(max) native
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
		method <(aString) native
		method <=(aString) {
			return self < aString || (self.equals(aString))
		}
		method >(aString) native
		method >=(aString) {
			return self > aString || (self.equals(aString))
		}
		method contains(other) {
			return self.indexOf(other) > 0
		}
		method isEmpty() {
			return self.size() == 0
		}

		method equalsIgnoreCase(aString) {
			return self.toUpperCase() == aString.toUpperCase()
		}
		method substring(length) native
		method substring(startIndex, length) native
		method split(expression) {
			const result = []
			var me = self.toString() + expression
			var first = 0
			(0..me.size() - 1).forEach { i =>
				if (me.charAt(i) == expression) {
					result.add(me.substring(first, i))
					first = i + 1
				}
			}
			return result
		}

		method replace(expression, replacement) native
		method toString() native
		method toSmartString(alreadyShown) native
		method ==(other) native
		
		method size() = self.length()
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
		const start
		const end
		var step
		
		constructor(_start, _end) {
			self.validate(_start)
			self.validate(_end)
			start = _start 
			end = _end
			if (_start > _end) { 
				step = -1 
			} else {
				step = 1
			}  
		}
		
		method step(_step) { step = _step }
		
		method validate(_limit) native
		
		method forEach(closure) native
		
		method map(closure) {
			const l = []
			self.forEach{e=> l.add(closure.apply(e)) }
			return l
		}
		
		/** @private */
		method asList() {
			return self.map({ elem => return elem })
		}
		
		method isEmpty() = self.size() == 0

		method fold(seed, foldClosure) { return self.asList().fold(seed, foldClosure) }
		method size() { return end - start + 1 }
		method any(closure) { return self.asList().any(closure) }
		method all(closure) { return self.asList().all(closure) }
		method filter(closure) { return self.asList().filter(closure) }
		method min() { return self.asList().min() }
		method max() { return self.asList().max() }
		/**
		 * returns a random integer contained in the range
		 */		
		method anyOne() native
		method contains(e) { return self.asList().contains(e) }
		method sum() { return self.asList().sum() }
		/**
		 * sums all elements that match the boolean closure 
		 */
		method sum(closure) { return self.asList().sum(closure) }
		/**
		 * counts how many elements match the boolean closure
		 */
		method count(closure) { return self.asList().count(closure) }
		method find(closure) { return self.asList().find(closure) }
		/**
		 * finds the first element matching the boolean closure, 
		 * or evaluates the continuation block closure if no element is found
		 */
		method findOrElse(closure, continuation) { return self.asList().findOrElse(closure, continuation) }
		
		/**
		 * finds the first element matching the boolean closure, 
		 * or returns a default value otherwise
		 */
		method findOrDefault(predicate, value) { return self.asList().findOrDefault(predicate, value) }
		method sortedBy(closure) { return self.asList().sortedBy(closure) }
		
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
	
	/**
	 *
	 * @since 1.4.5
	 */	
	class Date {

		constructor()
		constructor(_day, _month, _year) { self.initialize(_day, _month, _year) }  
		method equals(_aDate) native
		method plusDays(_days) native
		method plusMonths(_months) native
		method plusYears(_years) native
		method isLeapYear() native
		method initialize(_day, _month, _year) native
		method day() native
		method dayOfWeek() native
		method month() native	
		method year() native
		method -(_aDate) native
		method minusDays(_days) native
		method minusMonths(_months) native
		method minusYears(_years) native
		method <(_aDate) native
		method >(_aDate) native
		method <=(_aDate) { 
			return (self < _aDate) || (self.equals(_aDate))
		}
		method >=(_aDate) { 
			return (self > _aDate) || (self.equals(_aDate)) 
		}
		method between(_startDate, _endDate) { 
			return (self >= _startDate) && (self <= _endDate) 
		}

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
		method start() native
		method stop() native
		
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
		
		method moveRight(num) { x += num }
		method moveLeft(num) { x -= num }
		method moveUp(num) { y += num }
		method moveDown(num) { y -= num }
	
		method drawElement(element) { wgame.addVisualIn(element, self) }
		method drawCharacter(element) { wgame.addVisualCharacterIn(element, self) }		
		method deleteElement(element) { wgame.removeVisual(element) }
		method say(element, message) { wgame.say(element, message) }
		method allElements() = wgame.getObjectsIn(self)
		
		method clone() = new Position(x, y)

		method clear() {
			self.allElements().forEach{it => wgame.removeVisual(it)}
		}
		
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
		const target
		const name
		constructor(_target, _name) { target = _target ; name = _name }
		method name() = name
		method value() = target.resolve(name)
		
		method valueToSmartString(alreadyShown) {
			const v = self.value()
			return if (v == null) "null" else v.toSmartString(alreadyShown)
		}

		method toString() = name + "=" + self.value()
	}
}
