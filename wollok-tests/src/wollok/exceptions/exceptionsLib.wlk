class A {
	method m0() { throw new MyException("my exception message") }
	method m1() { this.m2() }
	method m2() { this.m3() }
	method m3() { this.m4() }
	method m4() {
		try  
			this.m5()
		catch e : MyException
			throw new Exception("Opps, error on m5()", e)
	}
	method m5() { 
		throw new MyException("Error sarasa")
	}
}

class MyException inherits wollok.lang.Exception {
	new(message) = super(message)
}
