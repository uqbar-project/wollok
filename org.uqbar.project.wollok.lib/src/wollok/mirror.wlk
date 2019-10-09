class InstanceVariableMirror {
  const target
  const property name
  
  method value() = target.resolve(name)
  
  method valueToSmartString(alreadyShown) {
    const value = self.value()
    return if (value == null) "null" else value.toSmartString(alreadyShown)
  }

  override method toString() = name + "=" + self.value()
}
