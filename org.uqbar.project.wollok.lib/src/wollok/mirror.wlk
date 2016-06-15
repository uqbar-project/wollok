	class InstanceVariableMirror {
		const target
		const name
		constructor(_target, _name) { target = _target ; name = _name }
		method name() = name
		method value() = target.resolve(name)
		
		method valueToSmartString(alreadyShown) {
			const v = self.value()
			return if (v == null) "null" else v.toSmartString(alreadyShown)
		}

		method toString() = name + "=" + self.value()
	}
