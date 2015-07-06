package org.uqbar.project.wollok.semantics;

import com.google.common.base.Objects;
import java.util.Collection;
import java.util.List;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class MessageType {
  @Property
  private String _name;
  
  @Property
  private List<WollokType> _parameterTypes;
  
  private WollokType returnType;
  
  public MessageType(final String name, final List<WollokType> parameterTypes, final WollokType returnType) {
    this.setName(name);
    this.setParameterTypes(parameterTypes);
    this.returnType = returnType;
  }
  
  public boolean equals(final Object obj) {
    boolean _xifexpression = false;
    if ((obj instanceof MessageType)) {
      _xifexpression = this.isSubtypeof(((MessageType)obj));
    } else {
      _xifexpression = false;
    }
    return _xifexpression;
  }
  
  public String toString() {
    String _name = this.getName();
    String _xifexpression = null;
    List<WollokType> _parameterTypes = this.getParameterTypes();
    boolean _isEmpty = _parameterTypes.isEmpty();
    if (_isEmpty) {
      _xifexpression = "";
    } else {
      List<WollokType> _parameterTypes_1 = this.getParameterTypes();
      String _join = IterableExtensions.join(_parameterTypes_1, ",");
      String _plus = ("(" + _join);
      String _plus_1 = (_plus + ")");
      String _xifexpression_1 = null;
      boolean _and = false;
      boolean _notEquals = (!Objects.equal(this.returnType, null));
      if (!_notEquals) {
        _and = false;
      } else {
        boolean _notEquals_1 = (!Objects.equal(this.returnType, WollokType.WVoid));
        _and = _notEquals_1;
      }
      if (_and) {
        _xifexpression_1 = (" : " + this.returnType);
      } else {
        _xifexpression_1 = "";
      }
      _xifexpression = (_plus_1 + _xifexpression_1);
    }
    return (_name + _xifexpression);
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
  public boolean isSubtypeof(final MessageType obj) {
    boolean _and = false;
    boolean _and_1 = false;
    String _name = this.getName();
    String _name_1 = obj.getName();
    boolean _equals = Objects.equal(_name, _name_1);
    if (!_equals) {
      _and_1 = false;
    } else {
      List<WollokType> _parameterTypes = this.getParameterTypes();
      int _size = _parameterTypes.size();
      List<WollokType> _parameterTypes_1 = obj.getParameterTypes();
      int _size_1 = _parameterTypes_1.size();
      boolean _equals_1 = (_size == _size_1);
      _and_1 = _equals_1;
    }
    if (!_and_1) {
      _and = false;
    } else {
      boolean _or = false;
      List<WollokType> _parameterTypes_2 = this.getParameterTypes();
      int _size_2 = _parameterTypes_2.size();
      boolean _equals_2 = (_size_2 == 0);
      if (_equals_2) {
        _or = true;
      } else {
        List<WollokType> _parameterTypes_3 = this.getParameterTypes();
        List<WollokType> _parameterTypes_4 = obj.getParameterTypes();
        final Function2<WollokType, WollokType, Boolean> _function = new Function2<WollokType, WollokType, Boolean>() {
          public Boolean apply(final WollokType mineT, final WollokType otherT) {
            boolean _xtrycatchfinallyexpression = false;
            try {
              boolean _xblockexpression = false;
              {
                otherT.acceptAssignment(mineT);
                _xblockexpression = true;
              }
              _xtrycatchfinallyexpression = _xblockexpression;
            } catch (final Throwable _t) {
              if (_t instanceof TypeSystemException) {
                final TypeSystemException e = (TypeSystemException)_t;
                _xtrycatchfinallyexpression = false;
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
            return Boolean.valueOf(_xtrycatchfinallyexpression);
          }
        };
        Collection<Boolean> _zip = XTendUtilExtensions.<WollokType, WollokType, Boolean>zip(_parameterTypes_3, _parameterTypes_4, _function);
        final Function1<Boolean, Boolean> _function_1 = new Function1<Boolean, Boolean>() {
          public Boolean apply(final Boolean it) {
            return it;
          }
        };
        boolean _forall = IterableExtensions.<Boolean>forall(_zip, _function_1);
        _or = _forall;
      }
      _and = _or;
    }
    return _and;
  }
  
  @Pure
  public String getName() {
    return this._name;
  }
  
  public void setName(final String name) {
    this._name = name;
  }
  
  @Pure
  public List<WollokType> getParameterTypes() {
    return this._parameterTypes;
  }
  
  public void setParameterTypes(final List<WollokType> parameterTypes) {
    this._parameterTypes = parameterTypes;
  }
}
