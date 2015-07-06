package org.uqbar.project.wollok.typesystem.constraints;

import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable;

@SuppressWarnings("all")
public class TypeVariablesFactory {
  public static TypeVariable sealed(final WollokType type) {
    TypeVariable _typeVariable = new TypeVariable();
    final Procedure1<TypeVariable> _function = new Procedure1<TypeVariable>() {
      public void apply(final TypeVariable it) {
        it.addMinimalType(type);
        it.setSealed(Boolean.valueOf(true));
      }
    };
    return ObjectExtensions.<TypeVariable>operator_doubleArrow(_typeVariable, _function);
  }
}
