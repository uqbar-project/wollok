 package lib {
	object console {
		method println(obj) native
		method readLine() native
		method readInt() native
	}
	
	object tester{
		method assert(value) native
		method assertEquals(expected, actual) native
	}
	
	
	class WObject {
		method identity() native
		
		method ==(other) {
			return this === other
		}
		
		method ->(other) {
			return new Pair(this, other)
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
	
	
}