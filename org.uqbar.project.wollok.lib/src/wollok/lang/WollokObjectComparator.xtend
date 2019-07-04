package wollok.lang

import java.util.Comparator
import java.util.Map
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject

class WollokObjectComparator implements Comparator<WollokObject> {
	Map<WollokObject, String> stringRepresentation
	
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	new(Map<WollokObject,String> stringRepresentation) {
		this.stringRepresentation = stringRepresentation
	}
	
	override compare(WollokObject o1, WollokObject o2) {
		return (stringRepresentation.get(o2) ?: "").compareTo(stringRepresentation.get(o1) ?: "")

/*
 * Alternativas
 * 
 * 
1) usar hashCode. Ventaja: rapidísimo, desventaja: no toma en cuenta equals (para String y Date funcionarían mal)
2) usar toString cacheado. Ventaja: mejor performance (2,5 seg en lugar de 7 para 100 elementos), respeta enteros, strings, fechas y en general todos los objetos que se representan igual. Desventaja: no toma en cuenta el equals (dos objetos que se imprimen igual podrían no ser iguales), si se modifica algún atributo que cambie la representación no te enterás.
3) si el objeto no tiene redefinido el equals, usar hashCode y cachear el equals que se haga. Ventaja: en teoría mejor performance (habría que probarlo), usa el equals solo para los que tiene que usarlo. Desventaja: si el objeto cambia algún atributo que depende del equals, tendrías que enterarte de alguna manera. Ponerle un estado de última modificación?
equals o ==

Quiénes redefinen el equals de Object:
1) Exception (no me calienta) ==> tener una colección de excepciones?
2) String
3) Date
4) Set y List (set de listas...) ==> otro caso border
5) Boolean (solo hay dos booleanos, no hay problema)
* 
 * 
 */

//		return o1?.hashCode.compareTo(o2?.hashCode)
 
//		if (o1.wollokEquals(o2)) {
//			return 0
//		}
//		try {
//			if (o1.wollokGreaterThan(o2)) {
//				return 1
//			}
//			return -1
//		} catch (RuntimeException e) {
//			return o1?.hashCode.compareTo(o2?.hashCode)
//		}
	}
	
}