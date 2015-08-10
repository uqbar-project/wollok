package org.uqbar.project.wollok.semantics;

import it.xsemantics.runtime.RuleEnvironment;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.IteratorExtensions;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class StructuralType extends MinimalEObjectImpl.Container implements WollokType {
  private List<MessageType> messages;
  
  public StructuralType(final Iterator<MessageType> messagesTypes) {
    List<MessageType> _list = IteratorExtensions.<MessageType>toList(messagesTypes);
    this.messages = _list;
  }
  
  public String getName() {
    String _join = IterableExtensions.join(this.messages, " ; ");
    String _plus = ("{ " + _join);
    return (_plus + " }");
  }
  
  public Iterable<MessageType> getAllMessages() {
    return this.messages;
  }
  
  public void acceptAssignment(final WollokType other) {
    final Function1<MessageType, Boolean> _function = new Function1<MessageType, Boolean>() {
      public Boolean apply(final MessageType m) {
        boolean _understandsMessage = other.understandsMessage(m);
        return Boolean.valueOf((!_understandsMessage));
      }
    };
    final Iterable<MessageType> notSupported = IterableExtensions.<MessageType>filter(this.messages, _function);
    int _size = IterableExtensions.size(notSupported);
    boolean _greaterThan = (_size > 0);
    if (_greaterThan) {
      throw new TypeSystemException(((("Incompatible type. Type «" + other) + "» does not complaint the following messages: ") + notSupported));
    }
  }
  
  public WollokType refine(final WollokType previous, final RuleEnvironment g) {
    return this.doRefine(previous, g);
  }
  
  protected StructuralType _doRefine(final StructuralType previouslyInferred, final RuleEnvironment g) {
    StructuralType _xblockexpression = null;
    {
      final Function1<MessageType, Boolean> _function = new Function1<MessageType, Boolean>() {
        public Boolean apply(final MessageType m) {
          return Boolean.valueOf(previouslyInferred.understandsMessage(m));
        }
      };
      final Iterable<MessageType> intersection = IterableExtensions.<MessageType>filter(this.messages, _function);
      Iterator<MessageType> _iterator = intersection.iterator();
      _xblockexpression = new StructuralType(_iterator);
    }
    return _xblockexpression;
  }
  
  protected StructuralType _doRefine(final WollokType previouslyInferred, final RuleEnvironment g) {
    throw new TypeSystemException("Incompatible types");
  }
  
  public boolean understandsMessage(final MessageType message) {
    final Function1<MessageType, Boolean> _function = new Function1<MessageType, Boolean>() {
      public Boolean apply(final MessageType it) {
        return Boolean.valueOf(message.isSubtypeof(it));
      }
    };
    return IterableExtensions.<MessageType>exists(this.messages, _function);
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final RuleEnvironment g) {
    return WollokType.WAny;
  }
  
  public String toString() {
    return this.getName();
  }
  
  public StructuralType doRefine(final WollokType previouslyInferred, final RuleEnvironment g) {
    if (previouslyInferred instanceof StructuralType) {
      return _doRefine((StructuralType)previouslyInferred, g);
    } else if (previouslyInferred != null) {
      return _doRefine(previouslyInferred, g);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(previouslyInferred, g).toString());
    }
  }
}
