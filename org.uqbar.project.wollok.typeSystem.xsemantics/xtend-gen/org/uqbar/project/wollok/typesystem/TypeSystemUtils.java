package org.uqbar.project.wollok.typesystem;

import java.util.Collections;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.uqbar.project.wollok.semantics.AnyType;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.BooleanType;
import org.uqbar.project.wollok.semantics.IntType;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.typesystem.TypeSystem;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WParameter;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TypeSystemUtils {
  public static String functionType(final WMethodDeclaration m, @Extension final TypeSystem ts) {
    EList<WParameter> _parameters = m.getParameters();
    final Function1<WParameter, String> _function = new Function1<WParameter, String>() {
      public String apply(final WParameter it) {
        WollokType _type = ts.type(it);
        String _name = null;
        if (_type!=null) {
          _name=_type.getName();
        }
        return _name;
      }
    };
    List<String> _map = ListExtensions.<WParameter, String>map(_parameters, _function);
    String _join = IterableExtensions.join(_map, ", ");
    String _plus = ("(" + _join);
    String _plus_1 = (_plus + ") => ");
    WollokType _type = ts.type(m);
    String _name = null;
    if (_type!=null) {
      _name=_type.getName();
    }
    return (_plus_1 + _name);
  }
  
  public static Pair<? extends List<? extends BasicType>, ? extends BasicType> typeOfOperation(final String op) {
    Pair<? extends List<? extends BasicType>, ? extends BasicType> _xifexpression = null;
    boolean _contains = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("&&", "||")).contains(op);
    if (_contains) {
      _xifexpression = Pair.<List<AnyType>, BooleanType>of(Collections.<AnyType>unmodifiableList(CollectionLiterals.<AnyType>newArrayList(WollokType.WAny, WollokType.WAny)), WollokType.WBoolean);
    } else {
      Pair<? extends List<? extends BasicType>, ? extends BasicType> _xifexpression_1 = null;
      boolean _contains_1 = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("==", "!=", "===", "<", "<=", ">", ">=")).contains(op);
      if (_contains_1) {
        _xifexpression_1 = Pair.<List<AnyType>, BooleanType>of(Collections.<AnyType>unmodifiableList(CollectionLiterals.<AnyType>newArrayList(WollokType.WAny, WollokType.WAny)), WollokType.WBoolean);
      } else {
        _xifexpression_1 = Pair.<List<IntType>, IntType>of(Collections.<IntType>unmodifiableList(CollectionLiterals.<IntType>newArrayList(WollokType.WInt, WollokType.WInt)), WollokType.WInt);
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
}
