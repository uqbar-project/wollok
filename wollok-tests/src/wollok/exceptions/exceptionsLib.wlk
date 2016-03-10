class A {
	method m0() { throw new MyException("my exception message") }
	method m1() { self.m2() }
	method m2() { self.m3() }
	method m3() { self.m4() }
	method m4() {
		try  
			self.m5()
		catch e : MyException
			throw new Exception("Opps, error on m5()", e)
	}
	method m5() { 
		throw new MyException("Error sarasa")
	}
}

class MyException inherits wollok.lang.Exception {
	constructor(message) = super(message)
}
