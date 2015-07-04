package org.uqbar.project.wollok.semantics;

import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.WollokType;

@SuppressWarnings("all")
public class VoidType extends BasicType implements WollokType {
  public VoidType() {
    super("Void");
  }
}
