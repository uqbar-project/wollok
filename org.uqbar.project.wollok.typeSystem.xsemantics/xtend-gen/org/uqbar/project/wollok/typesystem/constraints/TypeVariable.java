package org.uqbar.project.wollok.typesystem.constraints;

import java.util.Map;
import org.uqbar.project.wollok.semantics.WollokType;

@SuppressWarnings("all")
public class TypeVariable {
  public enum ConcreteTypeState {
    Pending,
    
    Ready;
  }
  
  private Map<WollokType, TypeVariable.ConcreteTypeState> minimalConcreteTypes /* Skipped initializer because of errors */;
  
  /* @Property
   */private Boolean sealed = Boolean.valueOf(false);
  
  public WollokType type() {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved.");
  }
  
  public TypeVariable.ConcreteTypeState addMinimalType(final WollokType type) {
    return this.minimalConcreteTypes.put(type, TypeVariable.ConcreteTypeState.Pending);
  }
}
