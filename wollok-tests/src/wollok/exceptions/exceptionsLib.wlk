class A {
	method m1() {
		this.m2()
	}
	
	method m2() {
		this.m3()
	}
	
	method m3() {
		this.m4()
	}
	
	method m4() {
		this.m5()
	}
	
	method m5() {
		throw new MyException("Error sarasa")
	}
}


class MyException inherits wollok.lang.Exception {
	
	new(message) = super(message)
}
