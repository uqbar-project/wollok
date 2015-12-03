package org.uqbar.project.wollok.typesystem.bindings;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.bindings.TypedNode;

/**
 * Expect the given type to be the same or
 * a supertype of the other.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SuperTypeExpectation implements TypeExpectation {
  private TypedNode from;
  
  private TypedNode to;
  
  public SuperTypeExpectation(final TypedNode from, final TypedNode to) {
    this.from = from;
    this.to = to;
  }
  
  public void check(final WollokType actualType) throws TypeExpectationFailedException {
    try {
      WollokType _type = this.from.getType();
      WollokType _type_1 = this.to.getType();
      _type.acceptAssignment(_type_1);
    } catch (final Throwable _t) {
      if (_t instanceof TypeSystemException) {
        final TypeSystemException e = (TypeSystemException)_t;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Expecting super type of <<");
        WollokType _type_2 = this.to.getType();
        _builder.append(_type_2, "");
        _builder.append(">> but found <<");
        WollokType _type_3 = this.from.getType();
        _builder.append(_type_3, "");
        _builder.append(">> which is not");
        throw new TypeExpectationFailedException(_builder.toString());
      } else {COMPILE ERROR : 'org.eclipse.xtext.xbase.lib.Exceptions' could not be found on the classpath!
      }
    }
  }
}
