package org.uqbar.project.wollok.typesystem.bindings;

import com.google.common.base.Objects;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectation;
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException;

/**
 * Expect the exact given type.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ExactTypeExpectation implements TypeExpectation {
  private WollokType expectedType;
  
  public ExactTypeExpectation(final WollokType expected) {
    this.expectedType = expected;
  }
  
  public void check(final WollokType actualType) {
    boolean _notEquals = (!Objects.equal(this.expectedType, actualType));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("ERROR: expected <<");
      _builder.append(this.expectedType, "");
      _builder.append(">> but found <<");
      _builder.append(actualType, "");
      _builder.append(">>");
      throw new TypeExpectationFailedException(_builder.toString());
    }
  }
}
