/**
 * Base class for all Exceptions. Every exception and its subclasses 
 * indicates conditions that a reasonable application might want to catch.
 * 
 * @author jfernandes
 * @since 1.0
 */
class Exception {
	/** specified detail message. */
	const property message = null
	
	/** specified cause */
	const property cause = null

	/** Prints this exception and its backtrace to the console */
	method printStackTrace() { self.printStackTrace(console) }

	/** Prints this exception and its backtrace as a string value */
	method getStackTraceAsString() {
		const printer = new StringPrinter()
		self.printStackTrace(printer)
		return printer.getBuffer()
	}
	
	/**
	  * @private
	  * Prints this exception and its backtrace to the specified printer 
	  */
	method printStackTrace(printer) { self.printStackTraceWithPrefix("", printer) }
	
	/** @private */
	method printStackTraceWithPrefix(prefix, printer) {
		printer.println(prefix + self.className() + (if (message != null) (": " + message.toString()) else ""))
		
		// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
		self.getStackTrace().forEach { e =>
			printer.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
		}
		
		if (cause != null)
			cause.printStackTraceWithPrefix("Caused by: ", printer)
	}
	
	/** @private */
	method createStackTraceElement(contextDescription, location) = new StackTraceElement(contextDescription = contextDescription, location = location)

	/** Provides programmatic access to the stack trace information
	 * printed by printStackTrace() with full path files for linking 
	 */
	method getFullStackTrace() native
	
	/** Provides programmatic access to the stack trace information
	 * printed by printStackTrace(). 
	 */
	method getStackTrace() native
	
	/** Overrides the behavior to compare exceptions */
	override method equals(other) = other.className().equals(self.className()) && other.message() == self.message()
}

/**
 * Thrown when a stack overflow occurs because an application recurses too deeply.
 *
 * @author jfernandes
 * @since 1.5.1
 */
class StackOverflowException inherits Exception {}

/**
 * An exception that is thrown when a specified element cannot be found
 */
class ElementNotFoundException inherits Exception {}

/**
 * An exception that is thrown when an object cannot understand a certain message
 */
class MessageNotUnderstoodException inherits Exception {
	
	/*
	'''«super.message()»
		«FOR m : wollokStack»
		«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
		«ENDFOR»
		'''
	*/
}

/**
 * An element in a stack trace, represented by a context and a location
 * of a method where a message was sent
 */
class StackTraceElement {
	const property contextDescription
	const property location
}

/**
 *
 * Representation of Wollok Object
 *
 * Class Object is the root of the class hierarchy. 
 * Every class has Object as a superclass.  
 * 
 * @author jfernandes
 * since 1.0
 */
class Object {
	/** 
	 * Answers object identity of a Wollok object, represented by
	 * a unique number in Wollok environment 
	 */
	method identity() native
	
	/** 
	 * Answers a list of instance variables for this Wollok object
	 * @private 
	 */
	method instanceVariables() native
	
	/** 
	 * Retrieves a specific variable. Expects a name
	 * @private 
	 */
	method instanceVariableFor(name) native
	
	/**
	 * @private 
	 * Accesses a variable by name, in a reflexive way. 
	 */
	method resolve(name) native
	
	/** Object description in english/spanish/... (depending on i18n configuration)
	 *
	 * Examples:
	 * 		"2".kindName()  => Answers "a String"
	 *  	2.kindName()    => Answers "a Integer"
	 *
	 * @private
	 */
	method kindName() native
	
	/** 
	 * Full name of Wollok object class
	 * @private 
	 */
	method className() native
	
	/**
	 * Tells whether self object is "equal" to the given object
	 * The default behavior compares them in terms of identity (===)
	 */
	method ==(other) = other != null && self === other 
	
	/** Tells whether self object is not equal to the given one */
	method !=(other) = ! (self == other)
	
	/**
	 * Tells whether self object is identical (the same) to the given one.
	 * It does it by comparing their identities.
	 * So self basically relies on the wollok.lang.Integer equality (which is native)
	 */
	method ===(other) = self.identity() == other.identity()

	/**
	 * Tells whether self object is not identical (the same) to the given one.
	 * @See === message.
	 */
	method !==(other) = ! (self === other)
	
	/**
	 * o1.equals(o2) is a synonym for o1 == o2
	 */
	method equals(other) = self == other

	/**
	 * Generates a Pair key-value association. @see Pair.
	 */
	method ->(other) {
		return new Pair(x = self, y = other)
	}

	/**
	 * String representation of Wollok object
	 */
	method toString() {
		return self.toSmartString([])
	}

	/**
	 * Shows a short, internal representation
	 */
	method shortDescription() = self.toString()
	
	/**
	 * Provides a visual representation of Wollok Object
	 * By default, same as toString but can be overridden
	 * like in String
	 */
	method printString() = self.toString()

	/** @private */
	method toSmartString(alreadyShown) {
		if (alreadyShown.any { e => e.identity() == self.identity() } ) { 
			return self.simplifiedToSmartString() 
		}
		else {
			alreadyShown.add(self)
			return self.internalToSmartString(alreadyShown)
		}
	} 
	
	/** @private */
	method simplifiedToSmartString() = self.kindName()
	
	/** @private */
	method internalToSmartString(alreadyShown) {
		return self.kindName() + "[" 
			+ self.instanceVariables().map { v => 
				v.name() + "=" + v.valueToSmartString(alreadyShown)
			}.join(', ') 
		+ "]"
	}
	
	/** @private */
	method messageNotUnderstood(messageName, parameters) {
		const target = if (messageName != "toString") 
					self.toString()
				 else 
				 	self.kindName()
		const aMessage = self.generateDoesNotUnderstandMessage(target, messageName, parameters.size())
		throw new MessageNotUnderstoodException(message = aMessage)
	}

	/**
	  * @private
	  *
	  * internal method: generates a does not understand message
	  * parametersSize must be an integer value
	  */
	method generateDoesNotUnderstandMessage(target, messageName, parametersSize) native
	
	/** Builds an exception with a message */		
	method error(aMessage) {
		throw new Exception(message = aMessage)
	}
}

/** Representation for methods that only have side effects */
object void { }

/** 
 * Representation of a Key/Value Association.
 * It is also useful if you want to model a Point. 
 */
class Pair {
	const property x
	const property y
	constructor (_x, _y) {
		x = _x
		y = _y
	}
	method key() = x
	method value() = y
}

/**
 * The root class in the collection hierarchy. 
 * A collection represents a group of objects, known as its elements.
 */	
class Collection {
	/**
	  * Answers the element that is considered to be/have the maximum value.
	  * The criteria is given by a closure that receives a single element 
	  * as input (one of the element). The closure must return a comparable
	  * value (something that understands the >, >= messages).
	  * If collection is empty, an ElementNotFound exception is thrown.
	  *
	  * Example:
	  *       ["a", "ab", "abc", "d" ].max({ e => e.length() }) 
	  *            => Answers "abc"
	  *
	  *       [].max({ e => e.length() })                       
	  *            => Throws error, list must not be empty            
	  */
	method max(closure) = self.maxIfEmpty(closure, { throw new ElementNotFoundException(message = "collection is empty") })

	/**
	  * Answers the element that represents the maximum value in the collection.
	  * The criteria is by direct comparison of the elements.
	  * If collection is empty, an ElementNotFound exception is thrown.
	  *
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].max() =>  Answers 15
	  *       [].max()                      =>  Throws error, list must not be empty
	  */
	method max() = self.max({it => it})		

	/**
	  * Answers the element that is considered to be/have the maximum value,
	  * or applies a closure if the collection is empty.
	  * The criteria is given by a closure that receives a single element
	  * as input (one of the element). The closure must return a comparable
	  * value (something that understands the >, >= messages).
	  * The closure to execute when the collection is empty is given as a second
	  * argument.
	  *
	  * Example:
	  *       ["a", "ab", "abc", "d" ].maxIfEmpty({ e => e.length() }, { "default" })
	  *            => Answers "abc"
	  *
	  *       [].maxIfEmpty({ e => e.length() }, { "default" })
	  *            => Answers "default"
	  */
	method maxIfEmpty(toComparableClosure, emptyCaseClosure) = self.absolute(toComparableClosure, { a, b => a > b }, emptyCaseClosure)

	/**
	  * Answers the element that is considered to be/have the maximum value,
	  * or applies a closure if the collection is empty.
	  * The criteria is by direct comparison of the elements.
	  * The closure to execute when the collection is empty is given as a second
	  * argument.
	  *
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].maxIfEmpty({ 99 }) =>  Answers 15
	  *       [].maxIfEmpty({ 99 })                      =>  Answers 99
	  */
	method maxIfEmpty(emptyCaseClosure) = self.maxIfEmpty({it => it}, emptyCaseClosure)
	
	/**
	  * Answers the element that is considered to be/have the minimum value.
	  * The criteria is given by a closure that receives a single element
	  * as input (one of the element). The closure must return a comparable
	  * value (something that understands the <, <= messages).
	  *
	  * Example:
	  *       ["ab", "abc", "hello", "wollok world"].min({ e => e.length() })    
	  *             =>  Answers "ab"
	  *		 
	  *       [].min({ e => e.length() })
	  *             => Throws error, list must not be empty
	  */
	method min(closure) = self.absolute(closure, { a, b => a < b }, { throw new ElementNotFoundException(message = "collection is empty") })

	/**
	  * Answers the element that represents the minimum value in the 
	  * non-empty collection.
	  * The criteria is by direct comparison of the elements.
	  *
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].min()  => Answers 1
	  *       [].min()                       => Throws error, list must not be empty
	  */
	method min() = self.min({it => it})

	/**
	  * Answers the element that is considered to be/have the minimum value,
	  * or applies a closure if the collection is empty.
	  * The criteria is given by a closure that receives a single element
	  * as input (one of the element). The closure must return a comparable
	  * value (something that understands the >, >= messages).
	  * The closure to execute when the collection is empty is given as a second
	  * argument.
	  *
	  * Example:
	  *       ["ab", "abc", "hello", "wollok world"].minIfEmpty({ e => e.length() }, { "default" })
	  *             =>  Answers "ab"
	  *
	  *       [].minIfEmpty({ e => e.length() }, { "default" })
	  *             => Answers "default"
	  */
	method minIfEmpty(toComparableClosure, emptyCaseClosure) = self.absolute(toComparableClosure, { a, b => a < b }, emptyCaseClosure)

	/**
	  * Answers the element that is considered to be/have the minimum value,
	  * or applies a closure if the collection is empty.
	  * The criteria is by direct comparison of the elements.
	  * The closure to execute when the collection is empty is given as a second
	  * argument.
	  *
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].minIfEmpty({ 99 })  => Answers 1
	  *       [].minIfEmpty({ 99 })                       => Answers 99
	  */
	method minIfEmpty(emptyCaseClosure) = self.minIfEmpty({it => it}, emptyCaseClosure)

	/** @private */
	method absolute(closure, criteria, emptyCaseClosure) {
		if (self.isEmpty())
			return emptyCaseClosure.apply()
		const result = self.fold(null, { acc, e =>
			const n = closure.apply(e) 
			if (acc == null)
				e -> n
			else {
				if (criteria.apply(n, acc.y()))
					new Pair(x = e, y = n)
				else
					acc
			}
		})
		return result.x()
	}
	 
	// non-native methods

	/**
	  * Concatenates this collection to all elements from the given 
	  * collection parameter giving a new collection
	  * (no side effect)
	  *
	  * Example:
	  *		[1, 2] + [3]   => Answers [1, 2, 3]
	  *     [1, 2] + #{3}  => supports concatenation between lists and sets, answers [1, 2, 3]
	  *     #{} + []       => Answers #{} 
	  */
	method +(elements) {
		const newCol = self.copy() 
		newCol.addAll(elements)
		return newCol 
	}
	
	/**
	  * Adds all elements from the given collection parameter to self collection. 
	  * This is a side effect operation.
	  *
	  * Example:
	  *		const list = []
	  *     list.addAll(#{2, 4})  => list == [2, 4], always pointing to a list
	  */
	method addAll(elements) { elements.forEach { e => self.add(e) } }
	
	/**
	  * Removes all elements of the given collection parameter from self collection. 
	  * This is a side effect operation.
	  *
	  * Example:
	  *		const list = [1, 6, 5]
	  *     list.removeAll([6]) => list == [1, 5]
	  */
	method removeAll(elements) { 
		elements.forEach { e => self.remove(e) } 
	}
	
	/**
	  * Removes those elements that meet a given condition. 
	  * This is a side effect operation.
	  * Supports empty collections.
	  *
	  * Example:
	  *		const list = [1, 6, 5]
	  *     list.removeAllSuchThat { e => e.even() } => list == [1, 5]
	  */
	 method removeAllSuchThat(closure) {
	 	self.removeAll( self.filter(closure) )
	 }

	/** 
	  * Tells whether self collection has no elements 
	  *
	  * Example:
	  *		[1, 6, 5].isEmpty() => Answers false
	  *     [].isEmpty()        => Answers true
	  */
	method isEmpty() = self.size() == 0
			
	/**
	 * Performs an operation on every element of self collection.
	 * The logic to execute is passed as a closure that takes a single parameter.
	 * Supports empty collections.
	 * @returns nothing
	 *
	 * Example:
	 *      plants.forEach { plant => plant.takeSomeWater() }
	 */
	method forEach(closure) { self.fold(null, { acc, e => closure.apply(e) }) }
	
	/**
	 * Answers whether all the elements of self collection satisfy a given
	 * condition. The condition is a closure argument that takes a single
	 * element and answers a boolean value.
	 *
	 * @returns true/false
	 *
	 * Example:
	 *      plants.all({ plant => plant.hasFlowers() })
	 *      [1, 3, 5].all { number => number.odd() }    => Answers true
	 *      [].all { number => number.odd() }           => Answers true
	 */
	method all(predicate) = self.fold(true, { acc, e => if (!acc) acc else predicate.apply(e) })
	
	/**
	 * Tells whether at least one element of self collection satisfies a
	 * given condition. The condition is a closure argument that takes a
	 * single element and answers a boolean value.
	 * @returns true/false
	 *
	 * Example:
	 *      plants.any({ plant => plant.hasFlowers() })
	 *      [1, 2, 3].any { number => number.even() }   ==> Answers true
	 *      [].any { number => number.even() }   ==> Answers false
	 */
	method any(predicate) = self.fold(false, { acc, e => if (acc) acc else predicate.apply(e) })
	
	/**
	 * Answers the element of self collection that satisfies a given condition.
	 * If more than one element satisfies the condition then it depends
	 * on the specific collection class which element will be returned.
	 *
	 * @returns the element that complies the condition
	 * @throws ElementNotFoundException if no element matched the given predicate
	 *
	 * Example:
	 *      users.find { user => user.name() == "Cosme Fulanito" }
	 *      #{1, 4, 5}.find { number => number.even() }  => Answers 4
	 *      #{1, 3}.find { number => number.even() }     => Throws ElementNotFoundException
	 *      #{}.find { number => number.even() }         => Throws ElementNotFoundException
	 */
	method find(predicate) = self.findOrElse(predicate, { 
		throw new ElementNotFoundException(message = "there is no element that satisfies the predicate")
	})

	/**
	 * Answers the element of self collection that satisfies a given condition, 
	 * or the given default otherwise, if no element matched the predicate.
	 * If more than one element satisfies the condition then it depends on the specific
	 * collection class which element will be returned.
	 *
	 * @returns the element that complies the condition or the default value
	 *
	 * Example:
	 *      users.findOrDefault({ user => user.name() == "Cosme Fulanito" }, homer)
	 *      [1, 3, 5].findOrDefault({ number => number.even() }, 0)  => Answers 0
	 *      [].findOrDefault({ number => number.even() }, 0)         => Answers 0
	 */
	method findOrDefault(predicate, value) =  self.findOrElse(predicate, { value })
	
	/**
	 * Answers the element of self collection that satisfies a given condition, 
	 * or the the result of evaluating the given continuation. 
	 * If more than one element satisfies the condition then it depends on the
	 * specific collection class which element will be returned.
	 *
	 * @returns the element that complies the condition or the result
	 * of evaluating the continuation
	 *
	 * Example:
	 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, { homer })
	 *      [1, 3, 5].findOrElse({ number => number.even() }, { 6.max(4) }) => Answers 6
	 *      [].findOrElse({ number => number.even() }, { false })           => Answers false
	 */
	method findOrElse(predicate, continuation) native

	/**
	 * Counts all elements of self collection that satisfies a given condition
	 * The condition is a closure argument that takes a single element and 
	 * answers a number.
	 * @returns an integer number
	 *
	 * Example:
	 *      plants.count { plant => plant.hasFlowers() }
	 *      #{1, 2, 3, 4, 5}.count { number => number.odd() }  => Answers 3
	 *      #{}.count { number => number.odd() }               => Answers 0
	 */
	method count(predicate) = self.fold(0, { acc, e => if (predicate.apply(e)) acc+1 else acc  })

	/**
	 * Counts the occurrences of a given element in self collection.
	 * @returns an integer number
	 *
	 * Example:
	 *      [1, 8, 4, 1].occurrencesOf(1)  => Answers 2
	 *      [].occurrencesOf(2)            => Answers 0
	 */
	method occurrencesOf(element) = self.count({it => it == element})
	
	/**
	 * Collects the sum of each value for all elements.
	 * This is similar to call a map {} to transform each element into a
	 * number object and then adding all those numbers.
	 * The condition is a closure argument that takes a single element and
	 * answers a boolean value.
	 *
	 * @returns an integer
	 *
	 * Example:
	 *      const totalNumberOfFlowers = plants.sum{ plant => plant.numberOfFlowers() }
	 *      [].sum { employee => employee.salary() }   => Answers 0
	 */
	method sum(closure) = self.fold(0, { acc, e => acc + closure.apply(e) })
	
	/**
	 * Sums all elements in the collection.
	 * @returns an integer
	 *
	 * Example:
	 *      [1, 2, 3, 4, 5].sum()  => Answers 15
	 *      [].sum()               => Answers 0 
	 */
	method sum() = self.sum( {it => it} )
	
	/**
	 * Answers a new collection that contains the result of transforming 
	 * each of self collection's elements using a given closure.
	 * The condition is a closure argument that takes a single element 
	 * and answers an object.
	 * @returns another list
	 *
	 * Example:
	 *      const ages = users.map({ user => user.age() })
	 *      [1, 2, 3].map { number => number.odd() }  => Answers [true, false, true]
	 *      [].map { number => number.odd() }         => Answers []
	 */
	method map(closure) = self.fold([], { acc, e =>
		 acc.add(closure.apply(e))
		 acc
	})
	
	/**
	 * Map + flatten operation
	 * @see map
	 * @see flatten
	 * 
	 * Example:
	 * 		object klaus { 
	 *  		method languages() = ["c", "cobol", "pascal"]
	 *		}
	 *
	 *		object fritz {
	 * 			method languages() = ["java", "perl"]
	 * 		}
	 *
	 *
	 * 		[klaus, fritz].flatMap({ person => person.languages() })
	 *			=> Answers ["c", "cobol", "pascal", "java", "perl"]
	 */
	method flatMap(closure) = self.fold(self.newInstance(), { acc, e =>
		acc.addAll(closure.apply(e))
		acc
	})

	/**
	 * Answers a new collection that contains the elements that 
	 * meet a given condition. The condition is a closure argument that
	 * takes a single element and answers a boolean.
	 * @returns another collection (same type as self one)
	 *
	 * Example:
	 *      const overageUsers = users.filter({ user => user.age() >= 18 })
	 *      #{1, 2, 3, 4, 5}.filter { number => number.even() }   => Answers #{2, 4}
	 *      #{}.filter { number => number.even() }                => Answers #{}
	 */
	 method filter(closure) = self.fold(self.newInstance(), { acc, e =>
		 if (closure.apply(e))
		 	acc.add(e)
		 acc
	})

	/**
	 * Answers whether this collection contains the specified element.
	 *
	 * Example:
	 *      [].contains(3)        => Answers false
	 *      [1, 2, 3].contains(2) => Answers true
	 */
	method contains(e) = self.any {one => e == one }
	
	/**
	 * Flattens a collection of collections
	 *
	 * Example:
	 * 		[ [1, 2], [3], [4, 0], [] ].flatten()  => Answers [1, 2, 3, 4, 0]
	 *
	 */
	method flatten() = self.flatMap { e => e }
	
	/** @private */
	/*
	 * Optimized version for long collections
	 *  
	 * @see Object#toString()
	 */
	override method internalToSmartString(alreadyShown) {
		const size = self.size()
		const internalCollection = if (size > 50) "..." + size + " elements" else self.map{ e => e.toSmartString(alreadyShown) }.join(", ")
		return self.toStringPrefix() + internalCollection + self.toStringSuffix()
	}
	
	/** @private */
	method toStringPrefix()
	
	/** @private */
	method toStringSuffix()
	
	/** Converts a collection to a list */
	method asList()
	
	/** Converts a collection to a set (no duplicates) */
	method asSet()

	/**
	 * Answers a new collection of the same type and with the same content 
	 * as self. Supports empty collections.
	 *
	 * @returns a new collection
	 *
	 * Example:
	 *      const usersCopy = users.copy() 
	 */
	method copy() {
		var copy = self.newInstance()
		copy.addAll(self)
		return copy
	}
	
	/**
	 * Answers a new List that contains the elements of self collection 
	 * sorted by a criteria given by a closure. The closure receives two objects
	 * X and Y and answers a boolean, true if X should come before Y in the 
	 * resulting collection. Supports empty collections.
	 *
	 * @returns a new List
	 *
	 * Example:
	 *      const usersByAge = users.sortedBy({ a, b => a.age() < b.age() })
	 *      const studentsByNameDesc = students.sortedBy({ a, b => a.name() > b.name() })
	 *      [1, 5, 9, 2, 4].sortedBy { a, b => a < b } => Answers [1, 2, 4, 5, 9]
	 *      [1, 5, 9, 2, 4].sortedBy { a, b => a > b } => Answers [9, 5, 4, 2, 1]
	 *      [].sortedBy { a, b => a > b }              => Answers []
	 *
	 */
	method sortedBy(closure) {
		var copy = self.copy().asList()
		copy.sortBy(closure)
		return copy
	}
	
	
	/**
	 * Answers a new, empty collection of the same type as self.
	 * @returns a new collection
	 *
	 * Example:
	 *      const newCollection = users.newInstance() 
	 */
	method newInstance()
	
	/**
	* @see subclasses implementations
	*/
	method anyOne() = throw new Exception(message = "Should be implemented by the subclasses")
	
	/**
	* @see subclasses implementations
	*/
	method add(element) = throw new Exception(message = "Should be implemented by the subclasses")
	
	/**
	* @see subclasses implementations
	*/
	method remove(element) = throw new Exception(message = "Should be implemented by the subclasses")
	
	/**
	* @see subclasses implementations
	*/
	method fold(element, closure) = throw new Exception(message = "Should be implemented by the subclasses")
	
	/**
	 * @see subclasses implementations
	 */
	method size() = throw new Exception(message = "Should be implemented by the subclasses")

	/** 
	 * Removes all of the elements from this set. This is a side effect operation.
	 * 
	 * @see subclasses implementations
	 */
	method clear()
	
	/**
	 * Answers the concatenated string representation of the elements in the given set.
	 * You can pass an optional character as an element separator (default is ",")
	 */
	method join(separator)
	
	/**
	 * Answers the concatenated string representation of the elements in the given set
	 * with default element separator (",")
	 */
	method join()
}

/**
 *
 * A collection that contains no duplicate elements. 
 * It models the mathematical set abstraction. 
 * A Set guarantees no order of elements.
 * 
 * @author jfernandes
 * @since 1.3
 */	
class Set inherits Collection {
	
	/** @private */
	override method newInstance() = #{}
	
	/** @private */
	override method toStringPrefix() = "#{"
	
	/** @private */
	override method toStringSuffix() = "}"
	
	/** 
	 * Converts this set to a list.
	 *
	 * Examples
	 *		#{1, 2, 3}.asList() => Answers [1, 2, 3]
	 * 		#{}.asList()        => Answers [] 
	 *
	 * @see List
	 */
	override method asList() { 
		const result = []
		result.addAll(self)
		return result
	}
	
	/**
	 * Converts an object to a Set. No effect on Sets.
	 *
	 * Examples
	 *		#{1, 2, 3}.asSet() => Answers #{1, 2, 3}
	 * 		#{}.asSet()        => Answers #{} 
	 */
	override method asSet() = self

	/**
	 * Answers any element of a non-empty collection
	 *
	 * Examples
	 *		#{1, 2, 3}.anyOne() => Answers 1, for example
	 * 		#{}.anyOne()        => Throws error, set must not be empty 
	 *  
	 */
	override method anyOne() native

	/**
	 * Answers a new Set with the elements of both self and another collection.
	 *
	 * Examples
	 * 		#{1, 2}.union(#{5, 2})   => #{1, 2, 5}
	 * 		#{}.union(#{3})          => #{3}
	 *
	 * @returns a Set
	 */
	 method union(another) = self + another

	/**
	 * Answers a new Set with the elements of self that exist in another collection
	 *
	 * Examples
	 * 		#{1, 2}.intersection(#{5, 2})   => #{2}
	 * 		#{}.intersection(#{3})          => #{}
	 *
	 * @returns a Set
	 */
	 method intersection(another) = 
	 	self.filter({it => another.contains(it)})
	 	
	/**
	 * Answers a new Set with the elements of self that don't exist in another collection
	 *
	 * Examples
	 * 		#{1, 2}.difference(#{5, 2}) => #{1}
	 * 		#{3}.difference(#{})        => #{3}
	 *
	 * @returns a Set
	 */
	 method difference(another) =
	 	self.filter({it => not another.contains(it)})
	
	// REFACTORME: DUP METHODS
	/** 
	 * Reduce a collection to a certain value, beginning with a seed or initial value.
	 * 
	 * Examples
	 * 		#{1, 9, 3, 8}.fold(0, {acum, each => acum + each}) 
	 *           => Answers 21, the sum of all elements
	 *
	 *      #{}.fold(0, {acum, each => acum + each})           
	 *           => Answers 0, the seed.
	 *
	 * 		var numbers = #{3, 2, 9, 1, 7}
	 * 		numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) }) 
	 *           => Answers 9, the maximum of all elements
     *
	 */
	override method fold(initialValue, closure) native
	
	/**
	 * @see Collection#filter(closure)
	 */
	override method filter(closure) native
	
	
	/**
	 * @see Collection#max()
	 */
	override method max() native
	
	/**
	 * Tries to find an element in a collection (based on a closure) or
	 * applies a continuation closure.
	 *
	 * Examples:
	 * 		#{1, 9, 3, 8}.findOrElse({ n => n.even() }, { 100 })  => Answers  8
	 * 		#{1, 5, 3, 7}.findOrElse({ n => n.even() }, { 100 })  => Answers  100
	 */
	override method findOrElse(predicate, continuation) native
	
	/**
	 * Adds the specified element to this set if it is not already present.
	 *
	 * Example:
	 * 		const set = #{}
	 *		set.add(3)   => set = #{3}
	 * 		set.add(2)   => set = #{2, 3}
	 * 		set.add(2)   => set = #{2, 3}, second add produces no effect	 
	 */
	override method add(element) native
	
	/**
	 * Removes the specified element from this set if it is present.
	 *
	 * Example:
	 * 		const set = #{2, 3}
	 *		set.remove(3) => set = #{2}
	 * 		set.remove(4) => set = #{2}, remove operation produces no effect
	 */
	override method remove(element) native
	
	/** Answers the number of elements in this set (its cardinality).
	 *
	 * Example:
	 * 		#{2, 3}.size()   => Answers 2
	 *		#{}.size()       => Answers 0
	 */
	override method size() native
	
	/** 
	 * Removes all of the elements from this set. This is a side effect operation.
	 *
	 * Example:
	 * 		const set = #{2, 3}
	 *		set.clear()         => set = #{}
	 */
	override method clear() native

	/**
	 * Answers the concatenated string representation of the elements in the given set.
	 * You can pass an optional character as an element separator (default is ",")
	 *
	 * Examples:
	 * 		#{1, 5, 3, 7}.join(":")                   => Answers "1:5:3:7"
	 * 		#{"you","will","love","wollok"}.join(" ") => Answers "love will wollok you"
	 *      #{}.join(",")                             => Answers ""
	 */
	override method join(separator) native
	
	/**
	 * Answers the concatenated string representation of the elements in the given set
	 * with default element separator (",")
	 *
	 * Example:
	 * 		#{"you","will","love","wollok"}.join()    => Answers "love,will,wollok,you"
	 */
	override method join() native
	
	/**
	 *
	 * @see List#contains(other)
	 */
	override method contains(other) native
	
	/**
	 * Two sets are equals if they have the same elements
	 *
	 * Examples:
	 * 		#{}.equals(#{})         => Answers true
	 *      #{1, 2}.equals(#{2, 1}) => Answers true
	 *      #{3, 2}.equals(#{2, 1}) => Answers false
	 */
	override method equals(other) native
	
	/**
	 * 
	 * Set equality operator as defined by equals
	 *
	 * #{1, 2} == #{2, 1}  => Answers true
	 * #{} == #{}          => Answers true
	 *
	 * @see Object#==
	 */
	override method ==(other) native
	
}

/**
 *
 * An ordered collection (also known as a sequence). 
 * You iterate the list the same order elements are inserted. 
 * The user can access elements by their integer index (position in the list).
 * A List can contain duplicate elements.
 *
 * @author jfernandes
 * @since 1.3
 */
class List inherits Collection {

	/** 
	 * Answers the element at the specified position in this non-empty list.
	 * 
	 * The first char value of the sequence is at index 0, 
	 * the next at index 1, and so on, as for array indexing.
	 * Index must be a positive and integer value.
	 *
	 * Examples:
	 * 		[].get(0)        => Throws error, list must not be empty
	 * 		[1].get(-1)      => Throws error, index must be 0 or positive
	 * 		[1, 2, 3].get(3) => Throws error, index exceeds list size
	 *      [5, 2, 7].get(0) => Answers 5
	 */
	method get(index) native
	
	/** Creates a new list */
	override method newInstance() = []
	
	/**
	 * Answers any element of a non-empty collection.
	 *
	 * Examples
	 *		#[1, 2, 3].anyOne() => Answers 3, for example
	 * 		#[].anyOne()        => Throws error, list must not be empty	  
	 */
	override method anyOne() {
		if (self.isEmpty()) 
			throw new Exception(message = "Illegal operation 'anyOne' on empty collection")
		else 
			return self.get(0.randomUpTo(self.size()))
	}
	
	/**
	 * Answers first element of the non-empty list
	 *
	 * @returns first element
	 *
	 * Example:
	 *		[1, 2, 3, 4].first()  => Answers 1
	 *      [].first()            => Throws error, list must not be empty
	 */
	method first() = self.head()
	
	/**
	 * Synonym for first method 
	 */
	method head() = self.get(0)
	
	/**
	 * Answers the last element of the non-empty list.
	 *
	 * @returns last element
	 *
	 * Examples:	
	 *		[1, 2, 3, 4].last()  => Answers 4
	 *      [].last()            => Throws error, list must not be empty	
	 */
	method last() = self.get(self.size() - 1)

	/** @private */		 
	override method toStringPrefix() = "["
	
	/** @private */
	override method toStringSuffix() = "]"

	/** 
	 * Converts this collection to a list. No effect on Lists.
	 *
	 * @see List
	 */
	override method asList() = self
	
	/**
	 * Converts this list to a set (removing duplicate elements)
	 *
	 * Examples:	
	 *		[1, 2, 3].asSet()       => Answers #{1, 2, 3}
	 *      [].asSet()              => Answers #{}
	 *      [1, 2, 1, 1, 2].asSet() => Answers #{1, 2}	
	 *
	 * @see Set
	 */
	override method asSet() { 
		const result = #{}
		result.addAll(self)
		return result
	}
	
	/** 
	 * Answers a view of the portion of this list between the specified fromIndex 
	 * and toIndex, both inclusive. Remember first element is position 0, 
	 * second is position 1, and so on.
	 * If toIndex exceeds length of list, no error is thrown.
	 *
	 * Example:
	 *		[1, 5, 3, 2, 7, 9].subList(2, 3) => Answers [3, 2]	
	 *		[1, 5, 3, 2, 7, 9].subList(4, 6) => Answers [7, 9]
	 *      [].subList(1, 2)                 => Answers [] 
	 */
	method subList(start, end) {
		if(self.isEmpty())
			return self.newInstance()
		
		const newList = self.newInstance()
		const _start = start.coerceToInteger().limitBetween(0, self.size() - 1)
		const _end = end.coerceToInteger().limitBetween(0, self.size() - 1)
		(_start.._end).forEach { i => newList.add(self.get(i)) }
		return newList
	}
	 
	/**
	 *
	 * Sorts elements of a list by a specific closure. 
	 * Order of elements is modified (produces effect).
	 * 
	 * Examples:
	 *		const list = [2, 9, 3]
	 *      list.sortBy { el1, el2 => el1 > el2 }
	 * 		list.get(0)           => Answers 9
	 *
	 * @see List#sortedBy
	 */
	method sortBy(closure) native
	
	/**
	 * Takes first n elements of a list.
	 *
	 * Examples:
	 * 		[1,9,2,3].take(5)  ==> Answers [1, 9, 2, 3]
	 *  	[1,9,2,3].take(2)  ==> Answers [1, 9]
	 *  	[1,9,2,3].take(-2) ==> Answers []
	 *      [].take(2)         ==> Answers []		 
	 */
	method take(n) =
		if(n <= 0)
			self.newInstance()
		else
			self.subList(0, n - 1)
		
	/**
	 * Answers a new list dropping first n elements of a list. 
	 * This operation has no side effect.
	 *
	 * Examples:
	 * 		[1, 9, 2, 3].drop(3)  ==> Answers [3]
	 * 		[1, 9, 2, 3].drop(1)  ==> Answers [9, 2, 3]
	 * 		[1, 9, 2, 3].drop(-2) ==> Answers [1, 9, 2, 3]
	 *      [].drop(2)            ==> Answers []
	 */
	method drop(n) = 
		if(n >= self.size())
			self.newInstance()
		else
			self.subList(n, self.size() - 1)
		
	/**
	 * Answers a new list reversing the elements, 
	 * so that first element becomes last element of the new list and so on.
	 * This operation has no side effect.
	 * 
	 * Example:
	 *  	[1, 9, 2, 3].reverse()  ==> Answers [3, 2, 9, 1]
	 *      [1, 2].reverse()        ==> Answers [2, 1]	 
	 *      [].reverse()            ==> Answers []
	 *
	 */
	method reverse() = self.subList(self.size() - 1, 0)

	/**
	 * @see Collection#filter(closure)
	 */
	override method filter(closure) native

	/**
	 * @see Collection#contains(obj)
	 */
	override method contains(obj) native
	
	/**
	 * @see Collection#max()
	 */
	override method max() native
	
	// REFACTORME: DUP METHODS
	/** 
	 * Reduce a collection to a certain value, beginning with a seed or initial value
	 * 
	 * Examples
	 * 		#{1, 9, 3, 8}.fold(0, {acum, each => acum + each}) 
	 *           => Answers 21, the sum of all elements
	 *
	 *      [].fold(0, {acum, each => acum + each})           
	 *           => Answers 0, the seed.
	 *
	 * 		var numbers = #{3, 2, 9, 1, 7}
	 * 		numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) }) 
	 *           => Answers 9, the maximum of all elements
     *
	 */
	override method fold(initialValue, closure) native
	
	/**
	 * Finds the first element matching the boolean closure, 
	 * or evaluates the continuation block closure if no element is found
	 *
	 * Examples:
	 * 		[1, 9, 3, 8].findOrElse({ n => n.even() }, { 100 })  => Answers  8
	 * 		[1, 5, 3, 7].findOrElse({ n => n.even() }, { 100 })  => Answers  100
	 */
	override method findOrElse(predicate, continuation) native
	
	/**  
	 * Adds the specified element as last one
	 *
	 * Example:
	 * 		const list = []
	 *		list.add(3)   => list = [3]
	 * 		list.add(2)   => list = [3, 2]
	 * 		list.add(2)   => list = [3, 2, 2]	 
	 */
	override method add(element) native
	
	/** 
	 * Removes an element in this list, if it is present.
	 * 
	 * Example:
	 * 		const list = [2, 3]
	 *		list.remove(3) => list = [2]
	 * 		list.remove(4) => list = [2], remove operation produces no effect
	 */	  
	override method remove(element) native
	
	/** 
	 * Answers the number of elements
	 *
	 * Example:
	 * 		[2, 3].size()   => Answers 2
	 *		[].size()       => Answers 0
	 */
	override method size() native
	
	/** 
	 * Removes all of the mappings from this Dictionary. 
	 * This is a side effect operation.
	 *
	 * Example:
	 * 		const list = [2, 3]
	 *		list.clear()     => list = []
	 */
	override method clear() native

	/**
	 * Answers the concatenated string representation of the elements in the given set.
	 * You can pass an optional character as an element separator (default is ",")
	 *
	 * Examples:
	 * 		[1, 5, 3, 7].join(":") => Answers "1:5:3:7"
	 * 		["you","will","love","wollok"].join(" ") => Answers "you will love wollok"
	 */
	override method join(separator) native
	
	/**
	 *
	 * Answers the concatenated string representation of the elements in the given set,
	 * using default element separator (",")
	 *
	 * Examples:
	 * 		["you","will","love","wollok"].join()    => Answers "you,will,love,wollok"
	 */
	override method join() native
	
	/**
	 * @see == message
	 */
	override method equals(other) native
	
	/** 
	 * A list is == another list if all elements are equal (defined by == message)
	 *
	 *
	 * Examples:
	 * 		[].equals([])         => Answers true
	 *      [1, 2].equals([2, 1]) => Answers false
	 *      [1, 2].equals([1, 2]) => Answers true
	 */
	override method ==(other) native

	/**
	 * Answers the list without duplicate elements
	 *
	 * [1, 3, 1, 5, 1, 3, 2, 5].withoutDuplicates() => Answers [1, 2, 3, 5]
	 * [].withoutDuplicates()                       => Answers []
	 */
	method withoutDuplicates() = self.asSet().asList()

}

/**
 * Represents a set of key -> values
 * 
 */
class Dictionary {

	/**
	 * Adds or updates a value based on a key.
	 * If key is not present, a new value is added. 
	 * If key is present, value is updated. 
	 * This is a side effect operation.
	 *
	 * Example:
	 *     const phones = new Dictionary()
	 *     phones.put("4004-4004", rolo)
	 *         => phones == a Dictionary ["4004-4004" -> rolo]
	 */
	method put(_key, _value) native
	
	/**
	 * Answers the value to which the specified key is mapped, 
	 * or null if this Dictionary contains no mapping for the key.
	 *
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.basicGet("4004-4004")  => Answers rolo
	 *     phones.basicGet("4004-4005")  => Answers null
	 */
	method basicGet(_key) native

	/**
	 * Answers the value to which the specified key is mapped, 
	 * or evaluates a non-parameter closure otherwise.
	 * 
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.getOrElse("4004-4004", { 0 })  => Answers rolo
	 *     phones.getOrElse("4004-4005", { 0 })  => Answers 0
	 */
	method getOrElse(_key, _closure) {
		const value = self.basicGet(_key)
		if (value == null) 
			return _closure.apply()
		else 
			return value
	}
	
	/**
	 * Answers the value to which the specified key is mapped. 
	 * If this Dictionary contains no mapping for the key, an error is thrown.
	 *
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.get("4004-4004")  => Answers rolo
	 *     phones.get("4004-4005")  => Throws ElementNotFoundException
	 */
	method get(_key) = self.getOrElse(_key,{ => throw new ElementNotFoundException(message = "there is no element associated with key " + _key) })

	/**
	 * Answers the number of key-value mappings in this Dictionary.
	 *
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.size()           => Answers 1
	 *     new Dictionary().size() => Answers 0
	 */
	method size() = self.values().size()
	
	/**
	 * Answers whether the dictionary has no elements
	 *
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.isEmpty()           => Answers false
	 *     new Dictionary().isEmpty() => Answers true
	 */
	method isEmpty() = self.size() == 0
	
	/**
	 * Answers whether this Dictionary contains a mapping for the specified key.
	 *
	 * Example, assuming phones is the dictionary created in put example:
	 *     phones.containsKey("4004-4004")  => Answers true
	 *     phones.containsKey("4004-4005")  => Answers false
	 *     new Dictionary().containsKey(1)  => Answers false
	 */
	method containsKey(_key) = self.keys().contains(_key)
	
	/**
	 * Answers whether if this Dictionary maps one or more keys to the specified value.
	 *
	 * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
	 *     numbers.containsValue(2)          => Answers true
     *     numbers.containsValue(5)          => Answers false
     *     new Dictionary().containsValue(3) => Answers false
	 */
	method containsValue(_value) = self.values().contains(_value)
	
	/**
	 * Removes the mapping for a key from this Dictionary if it is present.
	 * If key is not present nothing happens.
	 * This is a side effect operation.
	 *
	 * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
	 *     numbers.remove("one")   => numbers is a dictionary ("two" -> 2)
	 *     numbers.remove("three") => nothing happens  
	 */
	method remove(_key) native
	
	/**
	 * Answers a list of the keys contained in this Dictionary.
	 *
	 * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
     *     numbers.keys()   => ["one", "two"]	 
	 */
	method keys() native
	
	/**
	 * Answers a list of the values contained in this Dictionary.
	 *
	 * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
     *     numbers.values()   => [1, 2]	 
	 */
	method values() native
	
	/**
	 * Performs the given action for each entry in this Dictionary 
	 * until all entries have been processed or the action throws an exception.
	 * 
	 * Expected closure with two parameters: the first associated with key and
	 * second with value.
	 *
	 * Example:
	 * 		mapaTelefonos.forEach({ k, v => result += k.size() + v.size() })
	 * 
	 */
	method forEach(closure) native
	
	/** 
	 * Removes all of the mappings from this Dictionary. 
	 * This is a side effect operation.
	 *
     * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
	 *     numbers.clear()  => phones == empty dictionary
	 */
	method clear() native
	
	/**
	 * String representation of a Dictionary
	 *
     * Example:
	 *     const numbers = new Dictionary()
     *     numbers.put("one", 1)
     *     numbers.put("two", 2)
	 *         => Answers a Dictionary ["one" -> 1, "two" -> 2]
	 */
	override method toString() {
		var result = "a Dictionary ["
		self.forEach { key, value => result = result + (key.printString() + " -> " + value.printString() + ", ") }
		if (self.size() > 0) result = result.substring(0, result.length() - 2) 
		return result + "]"
	}
	
}

/**
 *
 * In Wollok we have numbers as immutable representation. You can customize
 * how many decimals you want to work with, and printing strategies. So
 * number two could be printed as "2", "2,00000", "2,000", etc.
 *
 * Coercing strategy for numbers can be 
 * 1) rounding up: 2,3258 using 3 decimals will result in 2,326
 * 2) rounding down or truncation: 2,3258 using 3 decimals will
 *    result in 2,325 
 * 3) not allowed: 2,3258 using 3 decimals will throw an exception 
 *    since decimals exceeds maximum allowed
 *
 * @author jfernandes
 * @author dodain (unification between Double and Integer in a single Number class)
 *
 * @since 1.3
 * @noInstantiate
 */	
class Number {

	/** @private */
	override method simplifiedToSmartString(){ return self.stringValue() }
	
	/** @private */
	override method internalToSmartString(alreadyShown) { return self.stringValue() }
	
	/** @private */
	method checkNotNull(value, operation) native
	
	/** 
	 * @private
	 *
	 * Applies coercing strategy to integer. If it is an integer, nothing happens. 
	 * Otherwise, if it is a decimal, defined coercing algorithm is applied 
	 * (see definition of class Number)
	 */
	method coerceToInteger() native

	/** 
	 * @private
	 * @see coerceToInteger
	 *
	 * Applies coercing strategy to integer. And throws exception if it is negative.
	 */
	method coerceToPositiveInteger() native
	
	/**
	 * Two references are identical if they are the same number
	 */
	override method ===(other) native

	method +(other) native
	method -(other) native
	method *(other) native
	method /(other) native

	/** 
	 * Integer division between self and other
	 *
	 * Example:
	 *		8.div(3)  ==> Answers 2
	 * 		15.div(5) ==> Answers 3
	 *		8.2.div(3.3)  ==> Answers 2
	 */
	method div(other) native
	
	/**
	 * raisedTo operation
     *
	 * Example:
	 *      3.2 ** 2 ==> Answers 10.24
	 * 		3 ** 2 ==> Answers 9
	 */
	method **(other) native
	
	/**
	 * Answers remainder of division between self and other
	 */
	method %(other) native
	
	/** String representation of self number */
	override method toString() native
	
	/** 
	 * Builds a Range between self and end
	 * 
	 * Example:
	 * 		1..4   		Answers ==> a new Range object from 1 to 4
	 */
	method ..(_end) = new Range(start = self, end = _end)
	
	method >(other) native
	method <(other) native

	method >=(other) = self > other || self == other
	method <=(other) = self < other || self == other

	/** 
	 * Answers absolute value of self 
	 *
	 * Example:
	 * 		2.abs() ==> 2
	 * 		(-3).abs() ==> 3 (be careful with parentheses)
	 * 		2.7.abs() ==> Answers 2.7
	 *		(-3.2).abs() ==> Answers 3.2 (be careful with parentheses)
	 */		
	method abs() native
	
	/**
	 * Inverts sign of self
	 *
	 * Example:
	 * 		3.invert() ==> Answers -3
	 * 		(-2).invert() ==> Answers 2 (be careful with parentheses)
	 * 		3.2.invert() ==> -3.2
	 * 		(-2.4).invert() ==> 2.4 (be careful with parentheses)
	 */
	method invert() native

	/** 
	 * Answers the greater number between two
	 * Example:
	 * 		5.max(8)    ==> Answers 8 
	 */
	method max(other) {
		self.checkNotNull(other, "max")
		return if (self >= other) self else other
	}
	
	/** 
	  * Answers the lower number between two. @see max 
	  * Example:
	  *     5.min(8)    ==> Answers 5 
	  */
	method min(other) {
		self.checkNotNull(other, "min")
		return if (self <= other) self else other
	}
	
	/**
	 * Given self and a range of integer values, 
	 * answers self if it is in that range
	 * or nearest value from self to that range 
	 *
	 * Examples
	 * 4.limitBetween(2, 10) ==> Answers 4, because 4 is in the range
	 * 4.limitBetween(6, 10) ==> Answers 6, because 4 is not in range 6..10, and 6 is nearest value to 4
	 * 4.limitBetween(1, 2)  ==> Answers 2, because 4 is not in range 1..2, but 2 is nearest value to 4
	 *
	 */   
	method limitBetween(limitA,limitB) = if(limitA <= limitB) 
											limitA.max(self).min(limitB) 
										 else 
										 	limitB.max(self).min(limitA)

	/** 
	  * Answers whether self is between min and max 
	  *
	  * Example:
	  *     2.between(2, 3) ==> Answers true
	  *     6.between(4, 6) ==> Answers true
	  *     3.between(4, 6) ==> Answers false	 
	  */
	method between(min, max) { return (self >= min) && (self <= max) }
	
	/** Answers squareRoot of self
 	  *
	  * Example:	 
	  * 		9.squareRoot() => Answers 3 
	  */
	method squareRoot() = self ** 0.5
	
	/** Answers square of self
	  *
	  * Example:	 
	  * 		3.square() => Answers 9 
	  */
	method square() = self * self
	
	/** 
	  * Answers whether self is an even number 
	  * (divisible by 2, mathematically 2k).
	  * 
	  * Self must be an integer value
	  */
	method even() {
		const intValue = self.coerceToInteger()
		return intValue % 2 == 0 
	}
	
	/** 
	 * Answers whether self is an odd number 
	 * (not divisible by 2, mathematically 2k + 1).
	 * 
	 * Self must be an integer value
	 */
	method odd() { 
		const intValue = self.coerceToInteger()
		return intValue.even().negate() 
	}
	
	/** Answers remainder between self and other
	 *
	 * Example:
	 *     5.rem(3) 	==> Answers 2
	 *     5.5.rem(3) 	==> Answers 2
	 */
	method rem(other) = self % other
	
	/*
	 * Self as String value. Equivalent: toString()
	 */
	method stringValue() = self.toString()

	/**
	 * Rounds up self up to a certain amount of decimals.
	 * Amount of decimals must be a positive and integer value.
	 *
	 * Example:	 
	 *     1.223445.roundUp(3) ==> 1.224
	 *     -1.223445.roundUp(3) ==> -1.224
	 *     14.6165.roundUp(3) ==> 14.617
	 *     5.roundUp(3) ==> 5
	 */
	 method roundUp(_decimals) native

	/**
	 * Truncates self up to a certain amount of decimals.
	 * Amount of decimals must be a positive and integer value.
	 *
	 * Example:	 
	 *     1.223445.truncate(3) ==> 1.223
	 *     14.6165.truncate(3) ==> 14.616
	 *     -14.6165.truncate(3) ==> -14.616
	 *     5.truncate(3) ==> 5
	 */
	method truncate(_decimals) native

	/**
	 * Answers a random number between self and max
	 */
	method randomUpTo(max) native
	
	/**
	 * Answers the next integer greater than self
	 * 13.224.roundUp() ==> 14
	 * -13.224.roundUp() ==> -14
	 * 15.942.roundUp() ==> 16
	 */
	method roundUp() = self.roundUp(0)

 	/**
  	 * greater common divisor. 
  	 * Both self and "other" parameter are coerced to be integer values.
  	 *
  	 * Example:
  	 * 		8.gcd(12) ==> Answers 4
  	 *		5.gcd(10) ==> Answers 5
  	 */
  	method gcd(other) native

	/**
	 * least common multiple. 
	 * Both self and "other" parameter are coerced to be integer values.
	 *
	 * Example:
	 * 		3.lcm(4) ==> Answers 12
	 * 		6.lcm(12) ==> Answers 12
	 */
	method lcm(other) {
		self.checkNotNull(other, "lcm")
		const mcd = self.gcd(other)
		return self * (other / mcd)
	}
	
	/**
	 * Number of digits of self (without sign)
	 * 
	 * Examples:
	 *     600.digits()  ==> Answers 3
	 *     6.00012.digits() ==> Answers 6
	 *     -100.digits() ==> Answers -3
	 */
	method digits() {
		var digits = self.toString().size()
		if (self < 0) {
			digits -= 1
		}
		if (!self.isInteger()) {
			digits -= 1
		}
		return digits
	}
	
	/** 
	 * Tells if this number can be considered an integer number.
	 *
	 * Examples:
	 *     2.isInteger() ==> Answers true
	 *     (2.0).isInteger() ==> Answers true
	 *     (2.3).isInteger() ==> Answers false
	 * 
	 * This could depend also on the rounding strategy, for example:
	 *     (2.0001).isInteger() ==> Answers false if rounding strategy is set to 5 decimal places (default)
	 *     (2.0001).isInteger() ==> Answers true if rounding strategy is set to 3 decimal places
	 */
	method isInteger() native
	
	/** Answers whether self is a prime number, 
	  * like 2, 3, 5, 7, 11 ... 
	  * Self must be an integer positive value
	  */
	method isPrime() {
		const intValue = self.coerceToInteger()
		if (intValue == 1) return false
		return (2..(intValue.div(2) + 1)).any({ i => intValue % i == 0 }).negate()
	}

	/**
	 * Executes the given action n times (n = self)
	 *
	 * Self must be a positive integer value.
	 * The closure must have one argument (index goes from 1 to self)
	 *
	 * Example:
	 * 		4.times({ i => console.println(i) }) ==> Answers 
	 * 			1
	 * 			2
	 * 			3
	 * 			4
	 */
	method times(action) {
	    self.checkNotNull(action, "times")
		const intValue = self.coerceToInteger()
		if (intValue < 0) self.error("times requires a positive integer number")
		if (intValue > 0) (1..intValue).forEach(action)
	}

	/** Allows users to define a positive number with 1 or +1 */
	method plus() = self	
}

/**
 * Strings are constant; 
 * their values cannot be changed after they are created.
 *
 * @author jfernandes
 * @noInstantiate
 */
class String {
	/** Answers the number of elements */
	method length() native
	
	/** 
	 * Answers the char value at the specified index. An index ranges 
	 * from 0 to length() - 1. The first char value of the sequence is
	 * at index 0, the next at index 1, and so on, as for array indexing.
	 * Parameter index must be a positive integer value.
	 */
	method charAt(index) native
	
	/** 
	 * Concatenates the specified string to the end of this string.
	 * Example:
	 * 		"cares" + "s" => Answers "caress"
	 */
	method +(other) native
	
	/** 
	 * Tests if this string starts with the specified prefix. 
	 * It is case sensitive.
	 *
	 * Examples:
	 * 		"mother".startsWith("moth")  ==> Answers true
	 *      "mother".startsWith("Moth")  ==> Answers false
	 */ 
	method startsWith(other) native
	
	/** 
	 * Tests if this string ends with the specified suffix. 
	 * It is case sensitive.
	 * @see startsWith
	 */
	method endsWith(other) native
	
	/** 
	 * Answers the index within this string of the first occurrence
	 * of the specified character.
	 * If character is not present, Answers -1
	 * 
	 * Examples:
	 * 		"pototo".indexOf("o")  ==> Answers 1
	 * 		"unpredictable".indexOf("o")  ==> Answers -1 		
	 */
	method indexOf(other) native
	
	/**
	 * Answers the index within this string of the last 
	 * occurrence of the specified character.
	 * If character is not present, Answers -1
	 *
	 * Examples:
	 * 		"pototo".lastIndexOf("o")  ==> Answers 5
	 * 		"unpredictable".lastIndexOf("o")  ==> Answers -1 		
	 */
	method lastIndexOf(other) native
	
	/** 
	 * Converts all of the characters in this String to lower case
	 *
	 * Examples:
	 * 		"Fer".toLowerCase()  ==> Answers "fer"
	 * 		"".toLowerCase()     ==> Answers ""
	 */
	method toLowerCase() native
	
	/** 
	 * Converts all of the characters in this String to upper case
	 *
	 * Examples:
	 * 		"Fer".toUpperCase()  ==> Answers "FER"
	 * 		"".toUpperCase()     ==> Answers ""
	 */
	method toUpperCase() native
	
	/** 
	 * Answers a string whose value is this string, 
	 * with any leading and trailing whitespace removed.
	 * 
	 * Example:
	 * 		"   emptySpace  ".trim()  ==> "emptySpace"
	 */
	method trim() native
	
	/** 
	 * Answers a string reversing this string,
	 * so that first character becomes last character of the new string and so on.
	 * 
	 * Example:
	 * 		"hola".reverse()  ==> "aloh"
	 */
	method reverse() native
		
	/** 
	 * @see take
	 * 
	 * Example:
	 *     "word".takeLeft(3)  ==> Answers "wor"
	 *     "word".takeLeft(0)  ==> Answers ""
	 *     "word".takeLeft(-1) ==> Throws error
	 *     "".takeLeft(2)      ==> Answers "" 
	 */
	method takeLeft(length) = self.take(length)
		
	/** 
	 * Takes last n characters of this string.
	 * n must be zero-positive integer.
	 * 
	 * Example:
	 *     "word".takeRight(3)  ==> Answers "ord"
	 *     "word".takeRight(0)  ==> Answers ""
	 *     "word".takeRight(-1) ==> Throws error
	 *     "".takeRight(2)      ==> Answers "" 
	 */
	method takeRight(_length) {
		const length = _length.coerceToPositiveInteger().min(self.size())
		return self.drop(self.size() - length)
	}
		
	method <(aString) native
	method <=(aString) {
		return self < aString || (self.equals(aString))
	}
	method >(aString) native
	method >=(aString) {
		return self > aString || (self.equals(aString))
	}
	
	/**
	 * Answers whether this string contains the specified sequence of char values.
	 * It is a case sensitive test.
	 *
	 * Examples:
	 * 		"unusual".contains("usual")  ==> Answers true
	 * 		"become".contains("CO")      ==> Answers false
	 */
	method contains(other) native
	
	/** Answers whether this string has no characters */
	method isEmpty() = self.size() == 0

	/** 
	 * Compares this String to another String, ignoring case considerations.
	 *
	 * Example:
	 *		"WoRD".equalsIgnoreCase("Word")  ==> Answers true
	 */
	method equalsIgnoreCase(aString) = self.toUpperCase() == aString.toUpperCase()
	
	/**
	 * Answers a substring of this string beginning from
	 * an inclusive index. Parameter index must be a positive 
	 * integer value.
	 *
	 * Examples:
	 * 		"substitute".substring(6)  ==> Answers "tute", second "t" is in position 6
	 * 		"effect".substring(0)      ==> Answers "effect", has no effect at all
	 */
	method substring(index) native
	
	/**
	 * Answers a substring of this string beginning 
	 * from an inclusive index up to another inclusive index
	 *
	 * Examples:
	 * 		"walking".substring(2, 4)   ==> Answers "lk"
	 * 		"walking".substring(3, 5)   ==> Answers "ki"
	 *		"walking".substring(0, 5)	==> Answers "walki"
	 *		"walking".substring(0, 45)	==> throws an out of range exception 
	 */
	method substring(startIndex, length) native
	
	/**
	 * Splits this string around matches of the given string.
	 * Answers a list of strings.
	 *
	 * Example:
	 * 		"this,could,be,a,list".split(",")   
	 *          ==> Answers ["this", "could", "be", "a", "list"]
	 */
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

	/** 
	 * Answers a string resulting from replacing all occurrences of
	 * expression in this string with replacement
	 *
	 * Example:
	 *		 "stupid is what stupid does".replace("stupid", "genius") 
	 *           ==> Answers "genius is what genius does"
	 */
	method replace(expression, replacement) native
	
	/** This object (which is already a string!) is itself returned */
	override method toString() native
	
	/** String implementation of printString, 
	 * simply adds quotation marks 
	 */
	override method printString() = '"' + self.toString() + '"'
	
	/** @private */
	override method toSmartString(alreadyShown) native
	
	/** Compares this string to the specified object. 
	 * The result is true if and only if the
	 * argument is not null and is a String object 
	 * that represents the same sequence of characters as this object.
	 */
	override method ==(other) native
	
	/** A synonym for length */
	method size() = self.length()
	
	/** 
	 * Takes first n characters of this string.
	 * n must be zero-positive integer.
	 *
	 * Examples:
	 *     "lowercase".take(3)  ==> Answers "low"
	 *     "lowercase".take(0)  ==> Answers ""
	 *     "lowercase".take(-1) ==> Throws error
	 *     "".take(2)           ==> Answers "" 
	 */
	method take(n) = self.substring(0, n.min(self.size()))
	
	/** 
	 * Answers a new string dropping 
	 * first n characters of this string.
	 * n must be zero-positive integer.
	 *
	 * Examples:
	 *      "caption".drop(4)    ==> Answers "ion"
	 *      "caption".drop(0)    ==> Answers "caption" 
	 *      "caption".drop(-1)   ==> Throws error 
	 *      "".drop(2)           ==> Answers "" 
	 */
	method drop(n) = self.substring(n.min(self.size()), self.size())
	
	/** 
	 * Splits this strings into several words.
	 * 
	 * Examples:
	 *      "how does words work?".words() 
	 *            ==> Answers ["how", "does", "words", "work?"]
	 *
	 *      "".words() ==> Answers [] 
	 */
	method words() = self.split(" ")
	
	/**
	 * Changes the first letter of every word to
	 * upper case in this string. 
	 * 
	 * Example:
	 *      "javier fernandes".capitalize() ==> Answers "Javier Fernandes"
	 */
	method capitalize() {
		const capitalizedPhrase = self.words().fold("", { words, word => words + word.take(1).toUpperCase() + word.drop(1).toLowerCase() + " " })
		return capitalizedPhrase.take(capitalizedPhrase.size() - 1)
	}
 	
}

/**
 * Represents a Boolean value (true or false)
 *
 * @author jfernandes
 * @noInstantiate
 */
class Boolean {

	/** 
	 * Answers the result of applying the logical AND operator 
	 * to the specified boolean operands self and other 
	 */
	method and(other) native
	
	/** A synonym for and operation */
	method &&(other) native
	
	/** Answers the result of applying the logical OR operator
	 * to the specified boolean operands self and other 
	 */
	method or(other) native
	
	/** A synonym for or operation */
	method ||(other) native
	
	/** Answers a String object representing this Boolean's value. */
	override method toString() native
	
	/** @private */
	override method toSmartString(alreadyShown) native
	
	/** Compares this string to the specified object. 
	 * The result is true if and only if the
	 * argument is not null and represents same value 
	 * (true or false)
	 */
	override method ==(other) native
	
	/** NOT logical operation */
	method negate() native
}

/**
 * Represents a finite arithmetic progression 
 * of integer numbers with optional step
 * If start = 1, end = 8, Range will represent [1, 2, 3, 4, 5, 6, 7, 8]
 * If start = 1, end = 8, step = 3, Range will represent [1, 4, 7]
 *
 * @author jfernandes
 * @since 1.3
 */
class Range {
	const property start
	const property end
	var step = null
	
	/**
	  * Instantiates a Range. 
	  * Both start and end must be integer values.
	  */
	method initialize() {
		start.coerceToInteger()
		end.coerceToInteger()
		if (step == null) {
			if (start > end) { 
				step = -1 
			} else {
				step = 1
			}
		}
	}

	method step(_step) {
		step = _step
	}
	
	/** 
	 * Iterates over a Range from start to end, based on step.
	 *
	 * Example:
	 *     new Range(start = 1, end = 3).forEach { value => console.println(value) }
	 *     => prints 1, 2, 3
	 */
	method forEach(closure) native
	
	/**
	 * Answers a new collection that contains the result of 
	 * transforming each of self collection's elements using
	 * a given closure.
	 *
	 * The condition is a closure argument that takes an integer 
	 * and answers an object.
	 * @returns another list
	 *
	 * Example:
	 *      (1..10).map({ n => n * 2}) ==> Answers [2, 4, 6, 8, 10, 12, 14, 16, 18, 20] 
	 */
	method map(closure) {
		const l = []
		self.forEach{e=> l.add(closure.apply(e)) }
		return l
	}

	/**
	 * Map + flatten operation
	 * @see map
	 * @see flatten
	 *
	 * Example:
	 *      (1..4).flatMap({ n => 1 .. n }) ==> Answers [1, 1, 2, 1, 2, 3, 1, 2, 3, 4] 
	 */
	method flatMap(closure) = self.fold([], { acc, e =>
		acc.addAll(closure.apply(e))
		acc
	})
	
	/** @private */
	method asList() {
		return self.map({ elem => return elem })
	}
	
	/** 
	 * Answers whether this range contains no elements
	 * @see Collection#isEmpty() 
	 */
	method isEmpty() = self.size() == 0

	/** @see List#fold(seed, foldClosure) */
	method fold(seed, foldClosure) { return self.asList().fold(seed, foldClosure) }
	
	/** 
	 * Answers the number of elements
	 *
	 * Examples:
	 *     new Range(start = 0, end = 2).size() ==> Answers 3
	 *     new Range(start = -2, end = 2).size() ==> Answers 5  
	 */
	method size()  {
	    const base = (end - start) / step
	    return if (base >= 0) base.truncate(0) + 1 else 0
	}
	
	/** @see List#any(closure) */
	method any(closure) = self.asList().any(closure)
	
	/** @see List#all(closure) */
	method all(closure) = self.asList().all(closure)
	
	/** @see List#filter(closure) */
	method filter(closure) = self.asList().filter(closure)
	
	/** @see List#min() */
	method min() = self.asList().min()
	
	/** @see List#max() */
	method max() = self.asList().max()
	
	/**
	 * Answers a random integer contained in the range
	 *
	 * Example:
	 *     new Range(start = 1, end = 3).anyOne() ==> Answers 1 or 2 or 3
	 */		
	method anyOne() native
	
	/** 
	 * Tests whether a number e is contained in the range
	 *
	 * Examples:
	 *     new Range(start = 2, end = 5).contains(4) ==> Answers true 
	 *     new Range(start = 2, end = 5).contains(0) ==> Answers false
	 */
	method contains(e) = self.asList().contains(e)
	
	/** @see List#sum() */
	method sum() = self.asList().sum()
	
	/**
	 * Sums all elements that match the boolean closure 
	 *
	 * Example:
	 * 		(1..9).sum({ i => if (i.even()) i else 0 }) ==> Answers 20
	 */
	method sum(closure) = self.asList().sum(closure)
	
	/**
	 * Counts how many elements match the boolean closure
	 *
	 * Example:
	 * 		(1..9).count({ i => i.even() }) ==> Answers 4 (2, 4, 6 and 8 are even)
	 */
	method count(closure) = self.asList().count(closure)
	
	/** @see List#find(closure) */
	method find(closure) = self.asList().find(closure)
	
	/** @see List#findOrElse(predicate, continuation)	 */
	method findOrElse(closure, continuation) = self.asList().findOrElse(closure, continuation)
	
	/** @see List#findOrDefault(predicate, value) */
	method findOrDefault(predicate, value) = self.asList().findOrDefault(predicate, value)
	
	/** @see List#sortBy */
	method sortedBy(closure) = self.asList().sortedBy(closure)
	
	/** @private */
	override method internalToSmartString(alreadyShown) = start.toString() + ".." + end.toString()
}

/**
 * 
 * Represents an executable piece of code. You can create a closure, 
 * assign it to a reference, evaluate it many times, 
 * send it as parameter to another object, and many useful things.
 *
 * @author jfernandes
 * @since 1.3
 * @noInstantiate
 */
class Closure {

	/** Evaluates this closure passing its parameters
	 *
	 * Example: 
	 * 		{ number => number + 1 }.apply(8) ==> Answers 9 // 1 parameter
	 *		{ "screw" + "driver" }.apply() ==> Answers "screwdriver" // no parameter 
	 */
	method apply(parameters...) native
	
	/** Answers a string representation of this closure object */
	override method toString() native
	
}

/** Represents days of week. */	

object monday { }
object tuesday { }
object wednesday { }
object thursday { }
object friday { }
object saturday { }
object sunday { }
const daysOfWeek = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]

/**
 *
 * Represents a Date (without time). A Date is immutable, once created you can not change it.
 *
 * @since 1.4.5
 */	
class Date {

	const property day
	const property month
	const property year
	
	/** String representation of a date */
	override method toString() = self.toSmartString(false) 
	
	/** Two dates are equals if they represent the same date */
	override method ==(_aDate) native
	
	/** 
	  * Answers a copy of this Date with the specified number of days added. 
	  * Parameter must be an integer value.
	  * This operation has no side effect (a new date is returned).	  
	  *
	  * Example:
	  *     new Date(day = 12, month = 5, year = 2018).plusDays(1) 
	  *        ==> Answers a Date[day = 13, month = 5, year = 2018], a day forward
	  *     
	  *     new Date(day = 12, month = 5, year = 2018).plusDays(-1)
	  *        ==> Answers a Date[day = 11, month = 5, year = 2018], a day back
	  */
	method plusDays(_days) native
	
	/** 
	  * Answers a copy of this Date with the specified number of months added. 
	  * Parameter must be an integer value.
	  * This operation has no side effect (a new date is returned).
	  *
	  * Example:
	  *     new Date(day = 31, month = 1, year = 2018).plusMonths(1)
      *        ==> Answers a Date[day = 28, month = 2, year = 2018], a month forward 
	  *     
	  *     new Date(day = 12, month = 5, year = 2018).plusMonths(-1)
	  *        ==> Answers a Date[day = 12, month = 4, year = 2018], a month back
	  */
	method plusMonths(_months) native
	
	/** 
	  * Answers a copy of this Date with the specified number of years added. 
	  * Parameter must be an integer value.
	  * This operation has no side effect (a new date is returned).
	  *
	  * Example:
	  *     new Date(day = 31, month = 1, year = 2018).plusYears(1)
      *        ==> Answers a Date[day = 31, month = 1, year = 2019], a year forward 
	  *     
	  *     new Date(day = 12, month = 5, year = 2018).plusYears(-1)
	  *        ==> Answers a Date[day = 12, month = 5, year = 2017], a year back
	  */
	method plusYears(_years) native
	
	/** 
	  * Checks if the year is a leap year, like 2000, 2004, 2008...
	  *
	  * Example:
	  *     new Date(day = 12, month = 5, year = 2018).isLeapYear() ==> Answers false 
	  */
	method isLeapYear() native
	
	/** Answers the day of the week of the Date with an object representation.
	 * There is a wko (well known object) for every day of the week.
	 *
	 * Example:
	 *     new Date(day = 24, month = 2, year = 2018).dayOfWeek() ==> Answers saturday object
	 */
	method dayOfWeek() = daysOfWeek.get(self.internalDayOfWeek() - 1)
	
	/** Answers the day of week of the Date, where
	 * 1 = MONDAY
	 * 2 = TUESDAY
	 * 3 = WEDNESDAY
	 * ...
	 * 7 = SUNDAY
	 *
	 * Example:
	 *     new Date(day = 24, month = 2, year = 2018).internalDayOfWeek() ==> Answers 6 (SATURDAY) 
	 */
	method internalDayOfWeek() native
	
	/** 
	 * Answers the difference in days between two dates, assuming self is minuend and _aDate is subtrahend. 
	 * 
	 * Examples:
	 * 		new Date().plusDays(4) - new Date() ==> Answers 4
	 *		new Date() - new Date().plusDays(2) ==> Answers -2
	 */
	method -(_aDate) native
	
	/** 
	 * Answers a copy of this date with the specified number of days subtracted.
	 * This instance is immutable and unaffected by this method call.
	 * Parameter must be an integer value.
	 * This operation has no side effect (a new date is returned).	 
     *
	 * Examples:
	 * 		new Date(day = 1, month = 1, year = 2009).minusDays(1) 
	 *          ==> Answers a Date[day = 31, month = 12, year = 2008], a day back 
	 *
	 * 		new Date(day = 1, month = 1, year = 2009).minusDays(-1) 
	 *          ==> Answers a Date[day = 2, month = 1, year = 2009], a day forward 
	 */
	method minusDays(_days) native
	
	/** 
	  * Answers a copy of this date with the specified number of months subtracted.
	  * Parameter must be an integer value.
	  * This operation has no side effect (a new date is returned).	  
	  *
	  * Examples:
	  * 		new Date(day = 1, month = 1, year = 2009).minusMonths(1) 
	  *             ==> Answers a Date[day = 1, month = 12, year = 2008], a month back
	  *
	  * 		new Date(day = 1, month = 1, year = 2009).minusMonths(-1) 
	  *             ==> Answers a Date[day = 1, month = 2, year = 2009], a month forward
	  */
	method minusMonths(_months) native
	
	/** 
	  * Answers a copy of this date with the specified number of years subtracted.
	  * Parameter must be an integer value.
	  * This operation has no side effect (a new date is returned).	  
	  *
	  * Examples:
	  * 		new Date(day = 1, month = 1, year = 2009).minusYears(1) 
	  *             ==> Answers a Date[day = 1, month = 1, year = 2008], a year back
	  *
	  * 		new Date(day = 1, month = 1, year = 2009).minusYears(-1) 
	  *             ==> Answers a Date[day = 1, month = 1, year = 2010], a year forward
	  */
	method minusYears(_years) native
	
	method <(_aDate) native
	method >(_aDate) native
	method <=(_aDate) = (self < _aDate) || (self.equals(_aDate))
	method >=(_aDate) = (self > _aDate) || (self.equals(_aDate)) 
	
	/**
	  * Answers whether self is between two dates (both inclusive comparison)
	  *
	  * Example:
	  *     new Date(day = 2, month = 4, year = 2018).between(new Date(day = 1, month = 4, year = 2018), new Date(day = 2, month = 4, year = 2018))
	  *         ==> Answers true 
	  */
	method between(_startDate, _endDate) = (self >= _startDate) && (self <= _endDate) 

	/** Shows nicely an internal representation of a date **/
	override method toSmartString(alreadyShown) =
		"a Date[day = " + day + ", month = " + month + ", year = " + year + "]"

	/** 
	  * Shows a short, internal representation of a date 
	  * 
	  * Example:
	  *     new Date(day = 2, month = 4, year = 2018).shortDescription()
	  *         ==> Answers "2/4/2018"
	  */
	override method shortDescription() =
		"" + day + "/" + month + "/" + year

}
