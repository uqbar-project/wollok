package org.uqbar.project.wollok.typesystem.substitutions;

import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;

/**
 * a >= b
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SuperTypeCheck implements TypeCheck {
  public void check(final WollokType a, final WollokType b) {
    try {
      a.acceptAssignment(b);
    } catch (final Throwable _t) {
      if (_t instanceof TypeSystemException) {
        final TypeSystemException e = (TypeSystemException)_t;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Expecting super type of <<");
        _builder.append(a, "");
        _builder.append(">> but found <<");
        _builder.append(b, "");
        _builder.append(">> which is not");
        throw new TypeExpectationFailedException(_builder.toString());
      } else {COMPILE ERROR : 'org.eclipse.xtext.xbase.lib.Exceptions' could not be found on the classpath!
      }
    }
  }
  
  public String getOperandString() {
    return "superTypeOf";
  }
}
