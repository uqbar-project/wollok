package org.uqbar.project.wollok.typesystem.substitutions;

import com.google.common.base.Objects;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;
import org.uqbar.project.wollok.typesystem.substitutions.TypeCheck;

/**
 * Checks that two types are the same.
 * 		a == b
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SameTypeCheck implements TypeCheck {
  public void check(final WollokType a, final WollokType b) {
    boolean _notEquals = (!Objects.equal(a, b));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("ERROR: expected <<");
      _builder.append(a, "");
      _builder.append(">> but found <<");
      _builder.append(b, "");
      _builder.append(">>");
      throw new TypeExpectationFailedException(_builder.toString());
    }
  }
  
  public String getOperandString() {
    return "==";
  }
}
