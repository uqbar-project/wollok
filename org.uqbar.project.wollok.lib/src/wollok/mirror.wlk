class InstanceVariableMirror {
	const target
	const property name
	
	constructor(_target, _name) { target = _target ; name = _name }

	method value() = target.resolve(name)
	
	method valueToSmartString(alreadyShown) {
		const v = self.value()
		return if (v == null) "null" else v.toSmartString(alreadyShown)
	}

	override method toString() = name + "=" + self.value()
}
