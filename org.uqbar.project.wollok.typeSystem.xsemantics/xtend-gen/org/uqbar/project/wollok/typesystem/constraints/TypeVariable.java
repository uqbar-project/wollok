package org.uqbar.project.wollok.typesystem.constraints;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Pure;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokType;

@SuppressWarnings("all")
public class TypeVariable {
  public enum ConcreteTypeState {
    Pending,
    
    Ready;
  }
  
  private Map<WollokType, TypeVariable.ConcreteTypeState> minimalConcreteTypes = CollectionLiterals.<WollokType, TypeVariable.ConcreteTypeState>newHashMap();
  
  @Property
  private Boolean _sealed = Boolean.valueOf(false);
  
  public WollokType type() {
    WollokType _xifexpression = null;
    int _size = this.minimalConcreteTypes.size();
    boolean _equals = (_size == 1);
    if (_equals) {
      Set<WollokType> _keySet = this.minimalConcreteTypes.keySet();
      Iterator<WollokType> _iterator = _keySet.iterator();
      _xifexpression = _iterator.next();
    } else {
      throw new TypeSystemException("Cannot determine the type of an expression");
    }
    return _xifexpression;
  }
  
  public TypeVariable.ConcreteTypeState addMinimalType(final WollokType type) {
    return this.minimalConcreteTypes.put(type, TypeVariable.ConcreteTypeState.Pending);
  }
  
  @Pure
  public Boolean getSealed() {
    return this._sealed;
  }
  
  public void setSealed(final Boolean sealed) {
    this._sealed = sealed;
  }
}
