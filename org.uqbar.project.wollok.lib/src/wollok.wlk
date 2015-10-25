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
	class WObject {
		method identity() native
		
		method ==(other) {
			return this === other
		}
		
		method ->(other) {
			return new Pair(this, other)
		}
		
		method randomBetween(start, end) native
		
		method toString() { return "anObject" }
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
	
	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */
	class WList {
		
		method fold(initialValue, closure) native
		method add(element) native
		method remove(element) native
		method size() native
		method get(index) native
		method clear() native
		method join(separator) native
		
		// non-native methods
		
		method newInstance() = new WList()
		
		method isEmpty() = this.size() == 0
				
		method forEach(closure) { this.fold(null, [ acc, e | closure.apply(e) ]) }
		method forAll(predicate) = this.fold(true, [ acc, e | if (!acc) acc else predicate.apply(e) ])
		method exists(predicate) = this.fold(false, [ acc, e | if (acc) acc else predicate.apply(e) ])
		
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
		
		method any() {
			if (this.isEmpty()) 
				throw new Exception() //("Illegal operation 'any' on empty collection")
			else 
				return this.get(this.randomBetween(0, this.size()))
		}
		
		override method toString() = "#[" + this.join(",") + "]"
		
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
