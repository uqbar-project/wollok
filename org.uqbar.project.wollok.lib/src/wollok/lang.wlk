 
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
		 * Tells whether self object is identical (the same) to the given one.
		 * It does it by comparing their identities.
		 * So self basically relies on the wollok.lang.Integer equality (which is native)
		 */
		method ===(other) {
			return self.identity() == other.identity()
		}
		
		method equals(other) = self == other
		
		method randomBetween(start, end) native
		
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
		  * Returns the element that is considered to be/have the minimum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["ab", "abc", "hello", "wollok world"].min { e => e.length() }    =>  returns "ab"		 
		  */
		method min(closure) = self.absolute(closure, { a, b => a < b} )
		
		method absolute(closure, criteria) {
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
			return if (result == null) null else result.getX()
		}
		 
		// non-native methods
		
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
				return self.get(self.randomBetween(0, self.size()))
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
		method **(other) native
		method %(other) native
		
		method toString() native
		
		method stringValue() native	
		
		method ..(end) = new Range(self, end)
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native

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
		constructor(_start, _end) { start = _start ; end = _end }
		
		method forEach(closure) native
		
		method map(closure) {
			const l = []
			self.forEach{e=> l.add(closure.apply(e)) }
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