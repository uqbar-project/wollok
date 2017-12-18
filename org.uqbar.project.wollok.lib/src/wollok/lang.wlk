/**
 * Base class for all Exceptions.
 * Every exception and its subclasses indicates conditions that a reasonable application might want to catch.
 * 
 * @author jfernandes
 * @since 1.0
 */
class Exception {
	const message
	const cause

	/** Constructs a new exception with no detailed message. */
	constructor() { message = null ; cause = null }
	/** Constructs a new exception with the specified detail message. */
	constructor(_message) = self(_message, null)
	/** Constructs a new exception with the specified detail message and cause. */
	constructor(_message, _cause) { message = _message ; cause = _cause }
	
	/** Prints this exception and its backtrace to the console */
	method printStackTrace() { self.printStackTrace(console) }

	/** Prints this exception and its backtrace as a string value */
	method getStackTraceAsString() {
		const printer = new StringPrinter()
		self.printStackTrace(printer)
		return printer.getBuffer()
	}
	
	/** Prints this exception and its backtrace to the specified printer */
	method printStackTrace(printer) { self.printStackTraceWithPreffix("", printer) }
	
	/** @private */
	method printStackTraceWithPreffix(preffix, printer) {
		printer.println(preffix +  self.className() + (if (message != null) (": " + message.toString()) else ""))
		
		// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
		self.getStackTrace().forEach { e =>
			printer.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
		}
		
		if (cause != null)
			cause.printStackTraceWithPreffix("Caused by: ", printer)
	}
	
	/** @private */
	method createStackTraceElement(contextDescription, location) = new StackTraceElement(contextDescription, location)

	/** Provides programmatic access to the stack trace information printed by printStackTrace() with full path files for linking */
	method getFullStackTrace() native
	
	/** Provides programmatic access to the stack trace information printed by printStackTrace(). */
	method getStackTrace() native
	
	/** Answers the cause of the exception, if present */
	method getCause() = cause
	
	/** Answers the detail message string of this exception. */
	method getMessage() = message
	
	/** Overrides the behavior to compare exceptions */
	override method equals(other) = other.className().equals(self.className()) && other.getMessage() == self.getMessage()
}

/**
 * Thrown when a stack overflow occurs because an application
 * recurses too deeply.
 *
 * @author jfernandes
 * @since 1.5.1
 */
class StackOverflowException inherits Exception {
	constructor() = super()
}

/**
 * An exception that is thrown when a specified element cannot be found
 */
class ElementNotFoundException inherits Exception {
	constructor(_message) = super(_message)
	constructor(_message, _cause) = super(_message, _cause)
}

/**
 * An exception that is thrown when an object cannot understand a certain message
 */
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

/**
 * An element in a stack trace, represented by a context and a location of a method where a message was sent
 */
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
 * Representation of Wollok Object
 *
 * Class Object is the root of the class hierarchy. Every class has Object as a superclass.  
 * 
 * @author jfernandes
 * since 1.0
 */
class Object {
	/** Answers object identity of a Wollok object, represented by a unique number in Wollok environment */
	method identity() native
	/** Answers a list of instance variables for this Wollok object */
	method instanceVariables() native
	/** Retrieves a specific variable. Expects a name */
	method instanceVariableFor(name) native
	/** Accesses a variable by name, in a reflexive way. */
	method resolve(name) native
	/** Object description in english/spanish/... (depending on i18n configuration)
	 *
	 * Examples:
	 * 		"2".kindName()  => Answers "a String"
	 *  	2.kindName()    => Answers "a Integer"
	 */
	method kindName() native
	/** Full name of Wollok object class */
	method className() native
	
	/**
	 * Tells whether self object is "equal" to the given object
	 * The default behavior compares them in terms of identity (===)
	 */
	method ==(other) {
		return other != null && self === other 
	}
	
	/** Tells whether self object is not equal to the given one */
	method !=(other) = ! (self == other)
	
	/**
	 * Tells whether self object is identical (the same) to the given one.
	 * It does it by comparing their identities.
	 * So self basically relies on the wollok.lang.Integer equality (which is native)
	 */
	method ===(other) {
		return self.identity() == other.identity()
	}

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
		return new Pair(self, other)
	}

	/**
	 * String representation of Wollok object
	 */
	method toString() {
		// TODO: should be a set
		// return self.toSmartString(#{})
		return self.toSmartString([])
	}
	
	/**
	 * Provides a visual representation of Wollok Object
	 * By default, same as toString but can be overriden
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
	method simplifiedToSmartString(){
		return self.kindName()
	}
	
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
		const message = self.generateDoesNotUnderstandMessage(target, messageName, parameters.size())
		throw new MessageNotUnderstoodException(message)
	}

	/**
	  * @private
	  *
	  * internal method: generates a does not understand message
	  * parametersSize must be an integer value
	  */
	method generateDoesNotUnderstandMessage(target, messageName, parametersSize) native
	
	/** Builds an exception with a message */		
	method error(message) {
		throw new Exception(message)
	}
}

/** Representation for methods that only have side effects */
object void { }

/** 
 * Representation of a Key/Value Association.
 * It is also useful if you want to model a Point. 
 */
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

/**
 * The root class in the collection hierarchy. 
 * A collection represents a group of objects, known as its elements.
 */	
class Collection {
	/**
	  * Answers the element that is considered to be/have the maximum value.
	  * The criteria is given by a closure that receives a single element as input (one of the element)
	  * The closure must return a comparable value (something that understands the >, >= messages).
	  * If collection is empty, an ElementNotFound exception is thrown.
	  *
	  * Example:
	  *       ["a", "ab", "abc", "d" ].max({ e => e.length() })    =>  Answers "abc"
	  */
	method max(closure) = self.absolute(closure, { a, b => a > b })

	/**
	  * Answers the element that represents the maximum value in the collection.
	  * The criteria is by direct comparison of the elements.
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].max()    =>  Answers 15		 
	  */
	method max() = self.max({it => it})		
	
	/**
	  * Answers the element that is considered to be/have the minimum value.
	  * The criteria is given by a closure that receives a single element as input (one of the element)
	  * The closure must return a comparable value (something that understands the <, <= messages).
	  * Example:
	  *       ["ab", "abc", "hello", "wollok world"].min({ e => e.length() })    =>  Answers "ab"		 
	  */
	method min(closure) = self.absolute(closure, { a, b => a < b} )
	
	/**
	  * Answers the element that represents the minimum value in the collection.
	  * The criteria is by direct comparison of the elements.
	  * Example:
	  *       [11, 1, 4, 8, 3, 15, 6].min()    =>  Answers 1 
	  */
	method min() = self.min({it => it})

	/** @private */
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
	  * Concatenates this collection to all elements from the given collection parameter giving a new collection
	  * (no side effect) 
	  */
	method +(elements) {
		const newCol = self.copy() 
		newCol.addAll(elements)
		return newCol 
	}
	
	/**
	  * Adds all elements from the given collection parameter to self collection. This is a side-effect operation.
	  */
	method addAll(elements) { elements.forEach { e => self.add(e) } }
	
	/**
	  * Removes all elements of the given collection parameter from self collection. This is a side-effect operation.
	  */
	method removeAll(elements) { 
		elements.forEach { e => self.remove(e) } 
	}
	
	/**
	 * Removes those elements that meet a given condition. This is a side-effect operation.
	 */
	 method removeAllSuchThat(closure) {
	 	self.removeAll( self.filter(closure) )
	 }

	/** Tells whether self collection has no elements */
	method isEmpty() = self.size() == 0
			
	/**
	 * Performs an operation on every element of self collection.
	 * The logic to execute is passed as a closure that takes a single parameter.
	 * @returns nothing
	 * Example:
	 *      plants.forEach { plant => plant.takeSomeWater() }
	 */
	method forEach(closure) { self.fold(null, { acc, e => closure.apply(e) }) }
	
	/**
	 * Answers whether all the elements of self collection satisfy a given condition
	 * The condition is a closure argument that takes a single element and Answers a boolean value.
	 * @returns true/false
	 * Example:
	 *      plants.all({ plant => plant.hasFlowers() })
	 */
	method all(predicate) = self.fold(true, { acc, e => if (!acc) acc else predicate.apply(e) })
	
	/**
	 * Tells whether at least one element of self collection satisfies a given condition.
	 * The condition is a closure argument that takes a single element and Answers a boolean value.
	 * @returns true/false
	 * Example:
	 *      plants.any({ plant => plant.hasFlowers() })
	 */
	method any(predicate) = self.fold(false, { acc, e => if (acc) acc else predicate.apply(e) })
	
	/**
	 * Answers the element of self collection that satisfies a given condition.
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
	 * Answers the element of self collection that satisfies a given condition, 
	 * or the given default otherwise, if no element matched the predicate.
	 * If more than one element satisfies the condition then it depends on the specific
	 * collection class which element
	 * will be returned
	 * @returns the element that complies the condition or the default value
	 * Example:
	 *      users.findOrDefault({ user => user.name() == "Cosme Fulanito" }, homer)
	 */
	method findOrDefault(predicate, value) =  self.findOrElse(predicate, { value })
	
	/**
	 * Answers the element of self collection that satisfies a given condition, 
	 * or the the result of evaluating the given continuation. 
	 * If more than one element satisfies the condition then it depends on the
	 * specific collection class which element
	 * will be returned
	 * @returns the element that complies the condition or the result of evaluating the continuation
	 * Example:
	 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, { homer })
	 */
	method findOrElse(predicate, continuation) native

	/**
	 * Counts all elements of self collection that satisfies a given condition
	 * The condition is a closure argument that takes a single element and Answers a number.
	 * @returns an integer number
	 * Example:
	 *      plants.count { plant => plant.hasFlowers() }
	 */
	method count(predicate) = self.fold(0, { acc, e => if (predicate.apply(e)) acc+1 else acc  })

	/**
	 * Counts the occurrences of a given element in self collection.
	 * @returns an integer number
	 * Example:
	 *      [1, 8, 4, 1].occurrencesOf(1)	=> Answers 2
	 */
	method occurrencesOf(element) = self.count({it => it == element})
	
	/**
	 * Collects the sum of each value for all elements.
	 * This is similar to call a map {} to transform each element into a number object and then adding all those numbers.
	 * The condition is a closure argument that takes a single element and Answers a boolean value.
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
	 * Answers a new collection that contains the result of transforming each of self collection's elements
	 * using a given closure.
	 * The condition is a closure argument that takes a single element and Answers an object.
	 * @returns another list
	 * Example:
	 *      const ages = users.map({ user => user.age() })
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
	 * Example
	 * 		object klaus {	var languages = ["c", "cobol", "pascal"]
	 *  		method languages() = languages
	 *		}
	 *		object fritz {	var languages = ["java", "perl"]
	 * 			method languages() = languages
	 * 		}
	 * 		program abc {
	 * 			console.println([klaus, fritz].flatMap({ person => person.languages() }))
	 *				=> Answers ["c", "cobol", "pascal", "java", "perl"]
	 * 		}	
	 */
	method flatMap(closure) = self.fold(self.newInstance(), { acc, e =>
		acc.addAll(closure.apply(e))
		acc
	})

	/**
	 * Answers a new collection that contains the elements that meet a given condition.
	 * The condition is a closure argument that takes a single element and Answers a boolean.
	 * @returns another collection (same type as self one)
	 * Example:
	 *      const overageUsers = users.filter({ user => user.age() >= 18 })
	 */
	 method filter(closure) = self.fold(self.newInstance(), { acc, e =>
		 if (closure.apply(e))
		 	acc.add(e)
		 acc
	})

	/**
	 * Answers whether this collection contains the specified element.
	 */
	method contains(e) = self.any {one => e == one }
	
	/**
	 * Flattens a collection of collections
	 *
	 * Example:
	 * 		[ [1, 2], [3], [4, 0] ].flatten()  => Answers [1, 2, 3, 4, 0]
	 *
	 */
	method flatten() = self.flatMap { e => e }
	
	/** @private */
	override method internalToSmartString(alreadyShown) {
		return self.toStringPrefix() + self.map{e=> e.toSmartString(alreadyShown) }.join(', ') + self.toStringSufix()
	}
	
	/** @private */
	method toStringPrefix()
	
	/** @private */
	method toStringSufix()
	
	/** Converts a collection to a list */
	method asList()
	
	/** Converts a collection to a set (no duplicates) */
	method asSet()

	/**
	 * Answers a new collection of the same type and with the same content 
	 * as self.
	 * @returns a new collection
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
	 * X and Y and Answers a boolean, true if X should come before Y in the 
	 * resulting collection.
	 * @returns a new List
	 * Example:
	 *      const usersByAge = users.sortedBy({ a, b => a.age() < b.age() })
	 */
	method sortedBy(closure) {
		var copy = self.copy().asList()
		copy.sortBy(closure)
		return copy
	}
	
	
	/**
	 * Answers a new, empty collection of the same type as self.
	 * @returns a new collection
	 * Example:
	 *      const newCollection = users.newInstance() 
	 */
	method newInstance()
	
	method anyOne() = throw new Exception("Should be implemented by the subclasses")
	method add(element) = throw new Exception("Should be implemented by the subclasses")
	method remove(element) = throw new Exception("Should be implemented by the subclasses")
	method fold(element, closure) = throw new Exception("Should be implemented by the subclasses")
	method size() = throw new Exception("Should be implemented by the subclasses")
}

/**
 *
 * A collection that contains no duplicate elements. 
 * It models the mathematical set abstraction. A Set guarantees no order of elements.
 * 
 * @author jfernandes
 * @since 1.3
 */	
class Set inherits Collection {
	constructor(elements ...) {
		self.addAll(elements)
	}
	
	/** @private */
	override method newInstance() = #{}
	
	/** @private */
	override method toStringPrefix() = "#{"
	
	/** @private */
	override method toStringSufix() = "}"
	
	/** 
	 * Converts this set to a list
	 * @see List
	 */
	override method asList() { 
		const result = []
		result.addAll(self)
		return result
	}
	
	/**
	 * Converts an object to a Set. No effect on Sets.
	 */
	override method asSet() = self

	/**
	 * Answers any element of this collection 
	 */
	override method anyOne() native

	/**
	 * Answers a new Set with the elements of both self and another collection.
	 * @returns a Set
	 */
	 method union(another) = self + another

	/**
	 * Answers a new Set with the elements of self that exist in another collection
	 * @returns a Set
	 */
	 method intersection(another) = 
	 	self.filter({it => another.contains(it)})
	 	
	/**
	 * Answers a new Set with the elements of self that don't exist in another collection
	 * @returns a Set
	 */
	 method difference(another) =
	 	self.filter({it => not another.contains(it)})
	
	// REFACTORME: DUP METHODS
	/** 
	 * Reduce a collection to a certain value, beginning with a seed or initial value
	 * 
	 * Examples
	 * 		#{1, 9, 3, 8}.fold(0, {acum, each => acum + each}) => Answers 21, the sum of all elements
	 *
	 * 		var numbers = #{3, 2, 9, 1, 7}
	 * 		numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) }) => Answers 9, the maximum of all elements
     *
	 */
	override method fold(initialValue, closure) native
	
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
	 * Adds the specified element to this set if it is not already present
	 */
	override method add(element) native
	
	/**
	 * Removes the specified element from this set if it is present
	 */
	override method remove(element) native
	
	/** Answers the number of elements in this set (its cardinality) */
	override method size() native
	
	/** Removes all of the elements from this set */
	method clear() native

	/**
	 * Answers the concatenated string representation of the elements in the given set.
	 * You can pass an optional character as an element separator (default is ",")
	 *
	 * Examples:
	 * 		[1, 5, 3, 7].join(":") => Answers "1:5:3:7"
	 * 		["you","will","love","wollok"].join(" ") => Answers "you will love wollok"
	 * 		["you","will","love","wollok"].join()    => Answers "you,will,love,wollok"
	 */
	method join(separator) native
	method join() native
	
	/**
	 * Two sets are equals if they have the same elements
	 */
	override method equals(other) native
	
	/**
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
	 * Answers the element at the specified position in this list.
	 * 
	 * The first char value of the sequence is at index 0, the next at index 1, and so on, as for array indexing.
	 * Index must be a positive and integer value. 
	 */
	method get(index) native
	
	/** Creates a new list */
	override method newInstance() = []
	
	/**
	 * Answers any element of this collection 
	 */
	override method anyOne() {
		if (self.isEmpty()) 
			throw new Exception("Illegal operation 'anyOne' on empty collection")
		else 
			return self.get(0.randomUpTo(self.size()))
	}
	
	/**
	 * Answers first element of the non-empty list
	 * @returns first element
	 *
	 * Example:
	 *		[1, 2, 3, 4].first()	=> Answers 1
	 */
	method first() = self.head()
	
	/**
	 * Synonym for first method 
	 */
	method head() = self.get(0)
	
	/**
	 * Answers the last element of the non-empty list.
	 * @returns last element
	 * Example:	
	 *		[1, 2, 3, 4].last()		=> Answers 4	
	 */
	method last() = self.get(self.size() - 1)

	/** @private */		 
	override method toStringPrefix() = "["
	
	/** @private */
	override method toStringSufix() = "]"

	/** 
	 * Converts this collection to a list. No effect on Lists.
	 * @see List
	 */
	override method asList() = self
	
	/** 
	 * Converts this list to a set (removing duplicate elements)
	 * @see List
	 */
	override method asSet() { 
		const result = #{}
		result.addAll(self)
		return result
	}
	
	/** 
	 * Answers a view of the portion of this list between the specified fromIndex 
	 * and toIndex, both inclusive. Remember first element is position 0, second is position 1, and so on.
	 * If toIndex exceeds length of list, no error is thrown.
	 *
	 * Example:
	 *		[1, 5, 3, 2, 7, 9].subList(2, 3)		=> Answers [3, 2]	
	 *		[1, 5, 3, 2, 7, 9].subList(4, 6)		=> Answers [7, 9] 
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
	 * @see List#sortedBy
	 */
	method sortBy(closure) native
	
	/**
	 * Takes first n elements of a list
	 *
	 * Examples:
	 * 		[1,9,2,3].take(5)  ==> Answers [1, 9, 2, 3]
	 *  	[1,9,2,3].take(2)  ==> Answers [1, 9]
	 *  	[1,9,2,3].take(-2)  ==> Answers []		 
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
	 */
	method drop(n) = 
		if(n >= self.size())
			self.newInstance()
		else
			self.subList(n, self.size() - 1)
		
	/**
	 * Answers a new list reversing the elements, so that first element becomes last element of the new list and so on.
	 * This operation has no side effect.
	 * 
	 * Example:
	 *  	[1, 9, 2, 3].reverse()  ==> Answers [3, 2, 9, 1]
	 *
	 */
	method reverse() = self.subList(self.size() - 1, 0)

	// REFACTORME: DUP METHODS
	/** 
	 * Reduce a collection to a certain value, beginning with a seed or initial value
	 * 
	 * Examples
	 * 		#{1, 9, 3, 8}.fold(0, {acum, each => acum + each}) => Answers 21, the sum of all elements
	 *
	 * 		var numbers = #{3, 2, 9, 1, 7}
	 * 		numbers.fold(numbers.anyOne(), { acum, number => acum.max(number) }) => Answers 9, the maximum of all elements
     *
	 */
	override method fold(initialValue, closure) native
	
	/**
	 * Finds the first element matching the boolean closure, 
	 * or evaluates the continuation block closure if no element is found
	 */
	override method findOrElse(predicate, continuation) native
	
	/** Adds the specified element as last one */
	override method add(element) native
	
	/** Removes an element in this list */ 
	override method remove(element) native
	
	/** Answers the number of elements */
	override method size() native
	
	/** Removes all of the mappings from this Dictionary. This is a side-effect operation. */
	method clear() native

	/**
	 * Answers the concatenated string representation of the elements in the given set.
	 * You can pass an optional character as an element separator (default is ",")
	 *
	 * Examples:
	 * 		[1, 5, 3, 7].join(":") => Answers "1:5:3:7"
	 * 		["you","will","love","wollok"].join(" ") => Answers "you will love wollok"
	 * 		["you","will","love","wollok"].join()    => Answers "you,will,love,wollok"
	 */
	method join(separator) native
	method join() native
	
	/**
	 * @see == message
	 */
	override method equals(other) native
	
	/** A list is == another list if all elements are equal (defined by == message) */
	override method ==(other) native

	/**
	 * Answers the list without duplicate elements
	 * [1, 3, 1, 5, 1, 3, 2, 5].withoutDuplicates() => Answers [1, 2, 3, 5]
	 */
	method withoutDuplicates() = self.asSet().asList()

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
	
	/**
	 * Answers the value to which the specified key is mapped, or null if this Dictionary contains no mapping for the key.
	 */
	method basicGet(_key) native

	/**
	 * Answers the value to which the specified key is mapped, or evaluates a non-parameter closure otherwise 
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
	 */
	method get(_key) = self.getOrElse(_key,{ => throw new ElementNotFoundException("there is no element associated with key " + _key) })

	/**
	 * Answers the number of key-value mappings in this Dictionary.
	 */
	method size() = self.values().size()
	
	/**
	 * Answers whether the dictionary has no elements
	 */
	method isEmpty() = self.size() == 0
	
	/**
	 * Answers whether this Dictionary contains a mapping for the specified key.
	 */
	method containsKey(_key) = self.keys().contains(_key)
	
	/**
	 * Answers whether if this Dictionary maps one or more keys to the specified value.
	 */
	method containsValue(_value) = self.values().contains(_value)
	
	/**
	 * Removes the mapping for a key from this Dictionary if it is present 
	 */
	method remove(_key) native
	
	/**
	 * Answers a list of the keys contained in this Dictionary.
	 */
	method keys() native
	
	/**
	 * Answers a list of the values contained in this Dictionary.
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
	
	/** Removes all of the mappings from this Dictionary. This is a side-effect operation. */
	method clear() native
	
}

/**
 *
 * In Wollok we have numbers as immutable representation. You can customize
 * how many decimals you want to work with, and printing strategies. So
 * number two could be printed as "2", "2,00000", "2,000", etc.
 *
 * You can coerce a parameter or a result to integer, in that case
 * you can customize the coercing strategy: rounding up, down or throwing an error
 * if reference points to a non-integer value.
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
	
	/** 
	 * @private
	 *
	 * Applies coercing strategy to integer. If it is an integer, nothing happens. Otherwise, 
	 * if it is a decimal, one of this coercing algorithms can be used
	 * 
	 * - self is rounded up to an integer
	 * - self is rounded down to an integer
	 * - an error is thrown
	 */
	method coerceToInteger() native
	
	/**
	 * The whole wollok identity implementation is based on self method
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
	 * 		15.0.div(5) ==> Answers 3
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
	 *      1.1..2.4 	Could lead to an error or answer a new Range object from 1 to 2
	 * 					depending on coercing strategy (see above) 
	 */
	method ..(end) = new Range(self, end)
	
	method >(other) native
	method >=(other) native
	method <(other) native
	method <=(other) native

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
	method max(other) = if (self >= other) self else other
	
	/** Answers the lower number between two. @see max */
	method min(other) = if (self <= other) self else other
	
	/**
	 * Given self and a range of integer values, Answers self if it is in that range
	 * or nearest value from self to that range 
	 *
	 * Examples
	 * 4.limitBetween(2, 10)   ==> Answers 4, because 4 is in the range
	 * 4.limitBetween(6, 10)   ==> Answers 6, because 4 is not in range 6..10, and 6 is nearest value to 4
	 * 4.limitBetween(1, 2)    ==> Answers 2, because 4 is not in range 1..2, but 2 is nearest value to 4
	 *
	 */   
	method limitBetween(limitA,limitB) = if(limitA <= limitB) 
											limitA.max(self).min(limitB) 
										 else 
										 	limitB.max(self).min(limitA)

	/** Answers whether self is between min and max */
	method between(min, max) { return (self >= min) && (self <= max) }
	
	/** Answers squareRoot of self
	 * 		9.squareRoot() => Answers 3 
	 */
	method squareRoot() { return self ** 0.5 }
	
	/** Answers square of self
	 * 		3.square() => Answers 9 
	 */
	method square() { return self * self }
	
	/** 
	 * Answers whether self is an even number (divisible by 2, mathematically 2k) 
	 * Self must be an integer value
	 */
	method even() {
		self.coerceToInteger()
		return self % 2 == 0 
	}
	
	/** 
	 * Answers whether self is an odd number (not divisible by 2, mathematically 2k + 1) 
	 * Self must be an integer value
	 */
	method odd() { 
		self.coerceToInteger()
		return self.even().negate() 
	}
	
	/** Answers remainder between self and other
	 * Example:
	 * 		5.rem(3) 	==> Answers 2
	 *      5.5.rem(3) 	==> Answers 2
	 */
	method rem(other) { return self % other }
	
	/*
	 * Self as String value. Equivalent: toString()
	 */
	method stringValue() = self.toString()

	/**
	 * Rounds up self up to a certain amount of decimals.
	 * Amount of decimals must be a positive and integer value.
	 *
	 * 1.223445.roundUp(3) ==> 1.224
	 * -1.223445.roundUp(3) ==> -1.224
	 * 14.6165.roundUp(3) ==> 14.617
	 * 5.roundUp(3) ==> 5
	 */
	 method roundUp(_decimals) native

	/**
	 * Truncates self up to a certain amount of decimals.
	 * Amount of decimals must be a positive and integer value.
	 *
	 * 1.223445.truncate(3) ==> 1.223
	 * 14.6165.truncate(3) ==> 14.616
	 * -14.6165.truncate(3) ==> -14.616
	 * 5.truncate(3) ==> 5
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
  	 * greater common divisor. Both self and "other" parameter are coerced to be integer values.
  	 *
  	 * Example:
  	 * 		8.gcd(12) ==> Answers 4
  	 *		5.gcd(10) ==> Answers 5
 	 *      7.4.gcd(10) ==> Depends on coercing strategy (error, rounding up, rounding down, etc.)
 	 *      7.gcd(10.2) ==> Depends on coercing strategy (error, rounding up, rounding down, etc.)
  	 */
  	method gcd(other) native

	/**
	 * least common multiple. Both self and "other" parameter are coerced to be integer values.
	 *
	 * Example:
	 * 		3.lcm(4) ==> Answers 12
	 * 		6.lcm(12) ==> Answers 12
	 *      6.4.lcm(12 ==> Depends on coercing strategy (error, rounding up, rounding down, etc.)
	 *      5.lcm(10.2) ==> Depends on coercing strategy (error, rounding up, rounding down, etc.)
	 */
	method lcm(other) {
		const mcd = self.gcd(other)
		return self * (other / mcd)
	}
	
	/**
	 * number of digits of self (without sign)
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
	
	/** Tells if this number could be considered an integer number */
	method isInteger() native
	
	/** Answers whether self is a prime number, like 2, 3, 5, 7, 11 ... 
	  * Self must be an integer positive value
	  */
	method isPrime() {
		self.coerceToInteger()
		if (self < 0) self.error("Negative numbers cannot be prime")
		if (self == 1) return false
		return (2..(self.div(2) + 1)).any({ i => self % i == 0 }).negate()
	}

	/**
	 * Executes the given action n times (n = self)
	 *
	 * Self must be a positive integer value.
	 *
	 * Example:
	 * 		4.times({ i => console.println(i) }) ==> Answers 
	 * 			1
	 * 			2
	 * 			3
	 * 			4
	 */
	method times(action) {
		self.coerceToInteger()
		if (self < 0) self.error("times requires a positive integer number")
		(1..self).forEach(action)
	}

	/** Allows users to define a positive number with 1 or +1 */
	method plus() = self	
}

/**
 * Strings are constant; their values cannot be changed after they are created.
 *
 * @author jfernandes
 * @noInstantiate
 */
class String {
	/** Answers the number of elements */
	method length() native
	
	/** 
	 * Answers the char value at the specified index. An index ranges from 0 to length() - 1. 
	 * The first char value of the sequence is at index 0, the next at index 1, and so on, as for array indexing.
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
	 * Tests if this string starts with the specified prefix. It is case sensitive.
	 *
	 * Examples:
	 * 		"mother".startsWith("moth")  ==> Answers true
	 *      "mother".startsWith("Moth")  ==> Answers false
	 */ 
	method startsWith(other) native
	
	/** Tests if this string ends with the specified suffix. It is case sensitive.
	 * @see startsWith
	 */
	method endsWith(other) native
	
	/** 
	 * Answers the index within this string of the first occurrence of the specified character.
	 * If character is not present, Answers -1
	 * 
	 * Examples:
	 * 		"pototo".indexOf("o")  ==> Answers 1
	 * 		"unpredictable".indexOf("o")  ==> Answers -1 		
	 */
	method indexOf(other) native
	
	/**
	 * Answers the index within this string of the last occurrence of the specified character.
	 * If character is not present, Answers -1
	 *
	 * Examples:
	 * 		"pototo".lastIndexOf("o")  ==> Answers 5
	 * 		"unpredictable".lastIndexOf("o")  ==> Answers -1 		
	 */
	method lastIndexOf(other) native
	
	/** Converts all of the characters in this String to lower case */
	method toLowerCase() native
	
	/** Converts all of the characters in this String to upper case */
	method toUpperCase() native
	
	/** 
	 * Answers a string whose value is this string, with any leading and trailing whitespace removed
	 * 
	 * Example:
	 * 		"   emptySpace  ".trim()  ==> "emptySpace"
	 */
	method trim() native
	
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
	method isEmpty() {
		return self.size() == 0
	}

	/** 
	 * Compares this String to another String, ignoring case considerations.
	 *
	 * Example:
	 *		"WoRD".equalsIgnoreCase("Word")  ==> Answers true
	 */
	method equalsIgnoreCase(aString) {
		return self.toUpperCase() == aString.toUpperCase()
	}
	
	/**
	 * Answers a substring of this string beginning from an inclusive index.
	 * Parameter index must be a positive integer value.
	 *
	 * Examples:
	 * 		"substitute".substring(6)  ==> Answers "tute", because second "t" is in position 6
	 * 		"effect".substring(0)      ==> Answers "effect", has no effect at all
	 */
	method substring(index) native
	
	/**
	 * Answers a substring of this string beginning from an inclusive index up to another inclusive index
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
	 * 		"this,could,be,a,list".split(",")   ==> Answers ["this", "could", "be", "a", "list"]
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
	 * Answers a string resulting from replacing all occurrences of expression in this string with replacement
	 *
	 * Example:
	 *		 "stupid is what stupid does".replace("stupid", "genius") ==> Answers "genius is what genius does"
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
	
	/** Compares this string to the specified object. The result is true if and only if the
	 * argument is not null and is a String object that represents the same sequence of characters as this object.
	 */
	override method ==(other) native
	
	/** A synonym for length */
	method size() = self.length()
	
	/** Takes first n characters of this string */
	method take(n) = self.substring(0, n.min(self.size()))
	
	/** Answers a new string dropping first n characters of this string */
	method drop(n) = self.substring(n.min(self.size()), self.size())
	
	/** Splits this strings into several words */
	method words() = self.split(" ")
	
	/** Changes the first letter of every word to upper case in this string */
	method capitalize() {
		const capitalizedPhrase = self.words().fold("", { words, word => words + word.take(1).toUpperCase() + word.drop(1).toLowerCase() + " " })
		return capitalizedPhrase.take(capitalizedPhrase.size() - 1)
	}
 	
}

/**
 * Represents a Boolean value (true or false)
 *
 * @author jfernandes
 * @noinstantiate
 */
class Boolean {

	/** Answers the result of applying the logical AND operator to the specified boolean operands self and other */
	method and(other) native
	/** A synonym for and operation */
	method &&(other) native
	
	/** Answers the result of applying the logical OR operator to the specified boolean operands self and other */
	method or(other) native
	/** A synonym for or operation */
	method ||(other) native
	
	/** Answers a String object representing this Boolean's value. */
	override method toString() native
	
	/** @private */
	override method toSmartString(alreadyShown) native
	
	/** Compares this string to the specified object. The result is true if and only if the
	 * argument is not null and represents same value (true or false)
	 */
	override method ==(other) native
	
	/** NOT logical operation */
	method negate() native
}

/**
 * Represents a finite arithmetic progression of integer numbers with optional step
 * If start = 1, end = 8, Range will represent [1, 2, 3, 4, 5, 6, 7, 8]
 * If start = 1, end = 8, step = 3, Range will represent [1, 4, 7]
 *
 * @author jfernandes
 * @since 1.3
 */
class Range {
	const start
	const end
	var step
	
	/**
	  * Instantiates a Range. Both _start and _end must be integer values.
	  */
	constructor(_start, _end) {
		_start.coerceToInteger()
		_end.coerceToInteger()
		start = _start
		end = _end
		if (_start > _end) { 
			step = -1 
		} else {
			step = 1
		}  
	}
	
	method step(_step) { step = _step }

	/** 
	 * Iterates over a Range from start to end, based on step
	 */
	method forEach(closure) native
	
	/**
	 * Answers a new collection that contains the result of transforming each of self collection's elements
	 * using a given closure.
	 * The condition is a closure argument that takes an integer and Answers an object.
	 * @returns another list
	 * Example:
	 *      (1..10).map({ n => n * 2}) ==> Answers [2, 4, 6, 8, 10, 12, 14, 16, 18, 20] 
	 */
	method map(closure) {
		const l = []
		self.forEach{e=> l.add(closure.apply(e)) }
		return l
	}
	
	/** @private */
	method asList() {
		return self.map({ elem => return elem })
	}
	
	/** Answers whether this range contains no elements */
	method isEmpty() = self.size() == 0

	/** @see List#fold(seed, foldClosure) */
	method fold(seed, foldClosure) { return self.asList().fold(seed, foldClosure) }
	
	/** Answers the number of elements */
	method size() { return end - start + 1 }
	
	/** @see List#any(closure) */
	method any(closure) { return self.asList().any(closure) }
	
	/** @see List#all(closure) */
	method all(closure) { return self.asList().all(closure) }
	
	/** @see List#filter(closure) */
	method filter(closure) { return self.asList().filter(closure) }
	
	/** @see List#min() */
	method min() { return self.asList().min() }
	
	/** @see List#max() */
	method max() { return self.asList().max() }
	
	/**
	 * Answers a random integer contained in the range
	 */		
	method anyOne() native
	
	/** Tests whether a number e is contained in the range */
	method contains(e) { return self.asList().contains(e) }
	
	/** @see List#sum() */
	method sum() { return self.asList().sum() }
	
	/**
	 * Sums all elements that match the boolean closure 
	 *
	 * Example:
	 * 		(1..9).sum({ i => if (i.even()) i else 0 }) ==> Answers 20
	 */
	method sum(closure) { return self.asList().sum(closure) }
	
	/**
	 * Counts how many elements match the boolean closure
	 *
	 * Example:
	 * 		(1..9).count({ i => i.even() }) ==> Answers 4 (2, 4, 6 and 8 are even)
	 */
	method count(closure) { return self.asList().count(closure) }
	
	/** @see List#find(closure) */
	method find(closure) { return self.asList().find(closure) }
	
	/** @see List#findOrElse(predicate, continuation)	 */
	method findOrElse(closure, continuation) { return self.asList().findOrElse(closure, continuation) }
	
	/** @see List#findOrDefault(predicate, value) */
	method findOrDefault(predicate, value) { return self.asList().findOrDefault(predicate, value) }
	
	/** @see List#sortBy */
	method sortedBy(closure) { return self.asList().sortedBy(closure) }
	
	/** @private */
	override method internalToSmartString(alreadyShown) = start.toString() + ".." + end.toString()
}

/**
 * 
 * Represents an executable piece of code. You can create a closure, assign it to a reference,
 * evaluate it many times, send it as parameter to another object, and many useful things.
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

/**
 *
 * Represents a Date (without time). A Date is immutable, once created you can not change it.
 *
 * @since 1.4.5
 */	
class Date {

	/**
	  * Default constructor instantiates the current day 
	  */
	constructor()
	
	/**
	 * Constructor: you should pass the day, month and year (integer values only).
	 */
	constructor(_day, _month, _year) { self.initialize(_day, _month, _year) }
	
	override method toString() = self.toSmartString(false) 
	
	/** Two dates are equals if they represent the same date */
	override method ==(_aDate) native
	
	/** Answers a copy of this Date with the specified number of days added. 
	  * Parameter must be an integer value.
	  */
	method plusDays(_days) native
	
	/** Answers a copy of this Date with the specified number of months added. 
	  * Parameter must be an integer value.
	  */
	method plusMonths(_months) native
	
	/** Answers a copy of this Date with the specified number of years added. 
	  * Parameter must be an integer value.
	  */
	method plusYears(_years) native
	
	/** Checks if the year is a leap year, like 2000, 2004, 2008, 2012, 2016... */
	method isLeapYear() native
	
	/** @private */
	method initialize(_day, _month, _year) native
	
	/** Answers the day number of the Date */
	method day() native
	
	/** Answers the day of week of the Date, where
	 * 1 = MONDAY
	 * 2 = TUESDAY
	 * 3 = WEDNESDAY
	 * ...
	 * 7 = SUNDAY
	 */
	method dayOfWeek() native
	
	/** Answers the month number of the Date */
	method month() native
	
	/** Answers the year number of the Date */
	method year() native
	
	/** 
	 * Answers the difference in days between two dates, in absolute values.
	 * 
	 * Examples:
	 * 		new Date().plusDays(4) - new Date() ==> Answers 4
	 *		new Date() - new Date().plusDays(2) ==> Answers 2
	 */
	method -(_aDate) native
	
	/** 
	 * Answers a copy of this date with the specified number of days subtracted.
	 * For example, 2009-01-01 minus one day would result in 2008-12-31.
	 * This instance is immutable and unaffected by this method call.
	 * Parameter must be an integer value.
	 */
	method minusDays(_days) native
	
	/** 
	 * Answers a copy of this date with the specified number of months subtracted.
	 * Parameter must be an integer value.
	 */
	method minusMonths(_months) native
	
	/** Answers a copy of this date with the specified number of years subtracted.
	  * Parameter must be an integer value.
	  */
	method minusYears(_years) native
	
	method <(_aDate) native
	method >(_aDate) native
	method <=(_aDate) { 
		return (self < _aDate) || (self.equals(_aDate))
	}
	method >=(_aDate) { 
		return (self > _aDate) || (self.equals(_aDate)) 
	}
	
	/** Answers whether self is between two dates (both inclusive comparison) */
	method between(_startDate, _endDate) { 
		return (self >= _startDate) && (self <= _endDate) 
	}

	/** Shows nicely an internal representation of a date **/
	override method toSmartString(alreadyShown) =
		"a Date[day = " + self.day() + ", month = " + self.month() + ", year = " + self.year() + "]"
}
