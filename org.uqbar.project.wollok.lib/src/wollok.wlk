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
		method printStackTrace() native	
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
		method getKey() { this.getX() }
		method getValue() { this.getY() }
	}
	
	class Collection {
		method max(closure) = this.absolute(closure, [a,b | a > b])
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
		
		method addAll(elements) { elements.forEach[e| this.add(e) ] }
		
		method isEmpty() = this.size() == 0
				
		method forEach(closure) { this.fold(null, [ acc, e | closure.apply(e) ]) }
		method forAll(predicate) = this.fold(true, [ acc, e | if (!acc) acc else predicate.apply(e) ])
		method exists(predicate) = this.fold(false, [ acc, e | if (acc) acc else predicate.apply(e) ])
		method detect(predicate) = this.fold(null, [ acc, e | if (acc == null && predicate.apply(e)) e else acc ])
		method count(predicate) = this.fold(0, [ acc, e | if (predicate.apply(e)) acc++ else acc  ])
		method sum(closure) = this.fold(0, [ acc, e | acc + closure.apply(e) ])
		
		method map(closure) = this.fold(this.newInstance(), [ acc, e |
			 acc.add(closure.apply(e))
			 acc
		])
		
		method filter(closure) = this.fold(this.newInstance(), [ acc, e |
			 if (closure.apply(e))
			 	acc.add(e)
			 acc
		])
				
		method contains(e) = this.exists[one | e == one ]
		
		override method internalToSmartString(alreadyShown) {
			return this.toStringPrefix() + this.map[e| e.toSmartString(alreadyShown) ].join(', ') + this.toStringSufix()
		}
		
		method toStringPrefix()
		method toStringSufix()
		
		method newInstance()
	}

	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */	
	class Set extends Collection {
	
		override method newInstance() = new Set()
		override method toStringPrefix() = "#{"
		override method toStringSufix() = "}"
		
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
	class List extends Collection {

		method get(index) native
		
		override method newInstance() = new List()
		
		method any() {
			if (this.isEmpty()) 
				throw new Exception() //("Illegal operation 'any' on empty collection")
			else 
				return this.get(this.randomBetween(0, this.size()))
		}
		
		override method toStringPrefix() = "#["
		override method toStringSufix() = "]"
		
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
	class Integer extends Number {
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
		
		method ..(end) native
		
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
	class Double extends Number {
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
