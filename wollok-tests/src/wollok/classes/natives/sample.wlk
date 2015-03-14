package wollok.classes.natives {

	class MyNative {
		method aNativeMethod() native
		
		method uppercased() {
			this.aNativeMethod().toUpperCase()
		} 
	}

}