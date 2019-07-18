class InstanceVariableMirror {
	const target
	const property name
	
	method value() = target.resolve(name)
	
	method valueToSmartString(alreadyShown) {
		const v = self.value()
		return if (v == null) "null" else v.toSmartString(alreadyShown)
	}

	override method toString() = name + "=" + self.value()
}
