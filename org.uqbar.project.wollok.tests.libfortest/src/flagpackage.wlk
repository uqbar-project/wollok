class Flag {
	
	
	method value() native
	method value(_value) native
	
	method logicAnd(_other) {
		self.value(self.value() and _other.value());
	}

	method logicOr(_other) {
		self.value(self.value() or _other.value());
	}

	method off() {
		self.value(false)
	}
	
	method on() {
		self.value(true)
	}
	
}