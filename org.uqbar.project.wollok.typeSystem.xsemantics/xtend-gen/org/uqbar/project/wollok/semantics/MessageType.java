package org.uqbar.project.wollok.semantics;

import java.util.List;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class MessageType {
  /* @Property
   */private String name;
  
  /* @Property
   */private List<WollokType> parameterTypes;
  
  private WollokType returnType;
  
  public MessageType(final String name, final List<WollokType> parameterTypes, final WollokType returnType) {
    this.name = name;
    this.parameterTypes = parameterTypes;
    this.returnType = returnType;
  }
  
  public boolean equals(final Object obj) {
    Object _xifexpression = null;
    if ((obj instanceof MessageType)) {
      _xifexpression = this.isSubtypeof(((MessageType)obj));
    } else {
      _xifexpression = Boolean.valueOf(false);
    }
    return (_xifexpression).ObjectValue();
  }
  
  public String toString() {
    throw new Error("Unresolved compilation problems:"
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved."
      + "\nThe method join is undefined for the type MessageType"
      + "\n!= cannot be resolved."
      + "\n!= cannot be resolved."
      + "\n+ cannot be resolved."
      + "\n+ cannot be resolved"
      + "\n+ cannot be resolved"
      + "\n&& cannot be resolved");
  }
  
  /**
   * tells whether this message type can be considered polymorphic
   * with the given message.
   * No matter if parameter types are exactly the same type.
   * But each param type should be "compatible" with the given's.
   * For example
   * 
   *  train(Dog d)  isSubtypeof   train(Animal a)
   * 
   *  train(Dog d)  isSubtypeof     < itself >
   * 
   *  learn(Trick t, Master m)   isSubtypeof    learn(MoveTailTrick t, GoodMaster m)
   */
  public Object isSubtypeof(final MessageType obj) {
    throw new Error("Unresolved compilation problems:"
      + "\n== cannot be resolved."
      + "\n== cannot be resolved."
      + "\n== cannot be resolved."
      + "\nThe method forall is undefined for the type MessageType"
      + "\n&& cannot be resolved"
      + "\n&& cannot be resolved"
      + "\n|| cannot be resolved"
      + "\nacceptAssignment cannot be resolved");
  }
}
