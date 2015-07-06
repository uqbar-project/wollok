package org.uqbar.project.wollok.semantics;

import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class AnyType extends BasicType implements WollokType {
  public AnyType() {
    super("Any");
  }
  
  public void acceptAssignment(final WollokType other) {
  }
  
  public boolean understandsMessage(final MessageType message) {
    return true;
  }
}
