package exceptionsLib {
	class A {
		method m1() {
			throw new MyException()
		}
	}
	
	
	class MyException extends wollok.lang.Exception {
	}
}