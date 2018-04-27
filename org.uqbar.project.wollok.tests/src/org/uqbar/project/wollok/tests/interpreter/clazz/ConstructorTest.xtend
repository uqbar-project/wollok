package org.uqbar.project.wollok.tests.interpreter.clazz

import org.junit.Assert
import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * All tests for constructors functionality in terms of runtime execution.
 * For static validations see the X_PECT test.
 * This tests
 * - having multiple constructors
 * - constructor delegation: to this or super
 * - automatic delegation for no-args constructors
 * 
 * @author jfernandes
 * @author dodain
 * 
 */
class ConstructorTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void defaultConstructorHappyPath() {
		'''
		class Point {
			var x
			var y
		}
		program t {
			const p1 = new Point()
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void defaultConstructorCalledWith1Argument() {
		try {
			'''
			class Point {
				var x
				var y
			}
			program t {
				const p2 = new Point(1)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals("Wrong number of arguments. Should be new Point()", message)
		}
	}

	@Test
	def void defaultConstructorCalledWith2Arguments() {
		try {
			'''
			class Point {
				var x
				var y
			}
			program t {
				const p2 = new Point(1, 2)
				console.println(p2)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new Point(1, 2)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals("Wrong number of arguments. Should be new Point()", message)
		}
	}

	@Test
	def void oneArgumentConstructorHappyPath() {
		'''
		class Ave {
			var energia
			constructor(_energia) { energia = _energia }
		}
		program t {
			const pepita = new Ave(100)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void oneArgumentConstructorCalledWithNoArguments() {
		try {
			'''
			class Ave {
				var energia
				constructor(_energia) { energia = _energia }
			}
			program t {
				const pepita = new Ave()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new Ave()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals("Wrong number of arguments. Should be new Ave(_energia)", message)
		}
	}

	@Test
	def void oneArgumentConstructorCalledWith2Arguments() {
		try {
			'''
			class Ave {
				var energia
				constructor(_energia) { energia = _energia }
			}
			program t {
				const pepita = new Ave(10, "pepita")
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new Ave(10, \"pepita\")")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals("Wrong number of arguments. Should be new Ave(_energia)", message)
		}
	}
	
	@Test
	def void singleSimpleConstructor() {
		'''
		class C {
			var a = 10
			const b
			var c
			
			constructor(anA, aB, aC) {
				a = anA
				b = aB
				c = aC
			}
			method getA() { return a }
			method getB() { return b }
			method getC() { return c }
		}
		program t {
			const c = new C (1,2,3)
			assert.equals(1, c.getA())
			assert.equals(2, c.getB())
			assert.equals(3, c.getC())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void multipleConstructors() {
		'''
		class Point {
			var x
			var y
			
			constructor () { x = 20 ; y = 20 }
			
			constructor(ax, ay) {
				x = ax
				y = ay
			}
			method getX() { return x }
			method getY() { return y }
		}
		program t {
			const p1 = new Point(1,2)
			assert.equals(1, p1.getX())
			assert.equals(2, p1.getY())

			const p2 = new Point()
			assert.equals(20, p2.getX())
			assert.equals(20, p2.getY())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void wrongNumberOfArgsInConstructorCall() {
		try {
			#['''
			class Point {
				var x
				var y
				
				constructor(ax, ay) { x = ax ; y = ay }
			}
			program t {
				const p1 = new Point()
			}
			'''].interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new Point()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new Point(ax, ay)", message)
		}
	}
	
	@Test
	def void constructorDelegationToSelf() {
		'''
			class Point {
				var x
				var y
				constructor(ax, ay) { x = ax ; y = ay }
				
				constructor() = self(10,15) {
				}
				
				method getX() { return x }
				method getY() { return y }
			}
			program t {
				const p = new Point()
				assert.equals(10, p.getX())
				assert.equals(15, p.getY())
			}
			'''.interpretPropagatingErrors
	}
	
	@Test
	def void constructorDelegationToSelfWithoutBody() {
		'''
			class Point {
				var x
				var y
				constructor(ax, ay) { x = ax ; y = ay }
				
				constructor() = self(10,15)
				
				method getX() { return x }
				method getY() { return y }
			}
			program t {
				const p = new Point()
				console.println(p)
				assert.equals(10, p.getX())
				assert.equals(15, p.getY())
			}
			'''.interpretPropagatingErrors
	}
	
	@Test
	def void constructorDelegationToSuper() {
		'''
			class SuperClass {
				var superX
				constructor(a) { superX = a }
				
				method getSuperX() { return superX }
			}
			class SubClass inherits SuperClass { 
				constructor(n) = super(n + 1) {}
			}
			program t {
				const o = new SubClass(20)
				assert.equals(21, o.getSuperX())
			}
			'''.interpretPropagatingErrors
	}
	@Test
	def void emptyConstructorDelegationToSuper() {
		'''
			class SuperClass {
				var superX
				constructor(){}
				method getSuperX() { return superX }
				method setSuperX(value) { superX = value }
			}
			class SubClass inherits SuperClass { 
				var anotherVariable
				constructor(n) = super() {
					anotherVariable = n
				}
				method getAnotherVariable() = anotherVariable
			}
			program t {
				const o = new SubClass(20)
				assert.equals(20, o.getAnotherVariable())
			}
			'''.interpretPropagatingErrors
	}

	@Test
	def void defaultConstructorDelegationToSuper() {
		'''
			class SuperClass {
				var superX
				
				method getSuperX() { return superX }
				method setSuperX(value) { superX = value }
			}
			class SubClass inherits SuperClass { 
				var anotherVariable
				constructor(n) {
					anotherVariable = n
				}
				method getAnotherVariable() = anotherVariable
			}
			program t {
				const o = new SubClass(20)
				assert.equals(20, o.getAnotherVariable())
			}
			'''.interpretPropagatingErrors
	}
		
	@Test
	def void twoLevelsDelegationToSuper() {
		'''
			class A {
				var x
				constructor(a) { x = a }
				
				method getX() { return x }
			}
			class B inherits A { 
				constructor(n) = super(n + 1) {}
			}
			class C inherits B {
				constructor(l) = super(l * 2) {}
			}
			program t {
				const o = new C(20)
				assert.equals(41, o.getX())
			}
			'''.interpretPropagatingErrors
	}
	
	@Test
	def void mixedSelfAndSuperDelegation() {
		'''
			class A {
				var x
				var y
				constructor(p) = self(p.getX(), p.getY()) {}
				constructor(_x,_y) { x = _x ; y = _y }
				
				method getX() { return x }
				method getY() { return y }
			}
			class B inherits A { 
				constructor(p) = super(p + 10) {}
			}
			class C inherits B {
				constructor(_x, _y) = self(new Point(_x, _y)) {}
				constructor(p) = super(p) {}
			}
			class Point {
				var x
				var y
				constructor(_x,_y) { x = _x ; y = _y }
				method +(delta) {
					x += delta
					y += delta
					return self
				}
				method getX() { return x }
				method getY() { return y }
			}
			
			program t {
				const o = new C(10, 20)
				assert.equals(20, o.getX())
				assert.equals(30, o.getY())
			}
			'''.interpretPropagatingErrors
	}
	
	// ***********************
	// ** automatic calls
	// ***********************
	
	@Test
	def void emptyConstructorInSuperClassMustBeAutomaticallyCalled() {
		'''
			class SuperClass {
				var superX
				constructor() { superX = 20 }
				
				method getSuperX() { return superX }
			}
			class SubClass inherits SuperClass { }
			program t {
				const o = new SubClass()
				assert.equals(20, o.getSuperX())
			}
			'''.interpretPropagatingErrors
	}
	
	@Test
	def void emptyConstructorInSuperClassMustBeAutomaticallyCalledBeforeCallingSubclassEmptyConstructor() {
		'''
			class SuperClass {
				var superX
				var otherX
				constructor() { 
					superX = 20
					otherX = 30
				}
				
				method getSuperX() { return superX }
				method getOtherX() { return otherX }
				method setSuperX(a) { superX = a }
			}
			class SubClass inherits SuperClass {
				var subX
				constructor() {
					subX = 10
					self.setSuperX(self.getSuperX() + 20) // 20 + 20
				}
				method getSubX() { return subX }
			}
			program t {
				const o = new SubClass()
				assert.equals(10, o.getSubX())
				assert.equals(40, o.getSuperX())
				assert.equals(30, o.getOtherX())
			}
			'''.interpretPropagatingErrors
	}
	
	@Test
	def void emptyConstructorAutoCalledMixingImplicitConstructorInHierarchy() {
		'''
			class A {
				var x
				constructor() { x = 20 }
				
				method getX() { return x }
			}
			class B inherits A {
			}
			class C inherits B {
				var c1
				constructor() {
					c1 = 10
				}
				method getC1() { return c1 }
			}
			class D inherits C {}
			program t {
				const o = new D()
				assert.equals(20, o.getX())
				assert.equals(10, o.getC1())
			}
			'''.interpretPropagatingErrors
	}

	@Test
	def void defaultConstructorInheritedFromObject() {
		'''
		class A {
		}
		class B inherits A {
		}
		class C inherits B {
		}
		program t {
			const a = new A()
			const b = new B()
			const c = new C()
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void inheritedOneArgumentConstructorInheritedFromSuperclass() {
		'''
		class A {
		}
		class B inherits A {
			var x
			constructor(_x) { x = _x }
			method x() = x
		}
		class C inherits B {
		}
		program t {
			const a = new A()
			const b = new B(1)
			assert.equals(1, b.x())
			const c = new C(1)
			assert.equals(1, c.x())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void inheritedOneArgumentConstructorInheritedFromSuperclassCallingNoArgumentFails1() {
		try {
			
			'''
			class A {
			}
			class B inherits A {
				var x
				constructor(_x) { x = _x }
				method x() = x
			}
			class C inherits B {
			}
			program t {
				const b = new B()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new B()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new B(_x)", message)
		}
	}

	@Test
	def void inheritedOneArgumentConstructorInheritedFromSuperclassCallingNoArgumentFails2() {
		try {
			
			'''
			class A {
			}
			class B inherits A {
				var x
				constructor(_x) { x = _x }
				method x() = x
			}
			class C inherits B {
			}
			program t {
				const c = new C()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new C()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new C(_x)", message)
		}
	}

	@Test
	def void inheritedOneArgumentConstructorInheritedFromSuperclassCallingNoArgumentFails3() {
		try {
			
			'''
			class A {
				constructor(_a, _b) { }
			}
			class B inherits A {
				var x
				constructor(_x) { x = _x }
				method x() = x
			}
			class C inherits B {
			}
			program t {
				const c = new C(1, 2)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new C(1, 2)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new C(_x)", message)
		}
	}

	@Test
	def void inheritedConstructorsHappyPath() {
		'''
		class A {
			var a
			constructor(_a) { a = _a }
			method a() = a
		}
		class B inherits A {
			var x
			constructor(_y, _x) { x = _x ; a = _y }
			method x() = x
		}
		class C inherits B {
			constructor() { a = 2 ; x = 3 }
		}
		program t {
			const a = new A(1)
			assert.equals(1, a.a())
			const b = new B(5, 6)
			assert.equals(5, b.a())
			assert.equals(6, b.x())
			const c = new C()
			assert.equals(2, c.a())
			assert.equals(3, c.x())
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}

	@Test
	def void inheritedConstructorsBadConstructorCallsFromA1() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const a = new A()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new A()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new A(_a)", message)
		}
	}

	@Test
	def void inheritedConstructorsBadConstructorCallsFromA2() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const a = new A(1, 2)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new A(1, 2)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new A(_a)", message)
		}
	}

	@Test
	def void inheritedConstructorsBadConstructorCallsFromB1() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const b = new B()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new B()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new B(_y, _x)", message)
		}
	}

	@Test
	def void inheritedConstructorsBadConstructorCallsFromB2() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const b = new B(1)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new B(1)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new B(_y, _x)", message)
		}
	}
	
	@Test
	def void inheritedConstructorsBadConstructorCallsFromC1() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const c = new C(1)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new C(1)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new C()", message)
		}			
	}
	
	@Test
	def void inheritedConstructorsBadConstructorCallsFromC2() {
		try {
			'''
			class A {
				var a
				constructor(_a) { a = _a }
				method a() = a
			}
			class B inherits A {
				var x
				constructor(_y, _x) { x = _x ; a = _y }
				method x() = x
			}
			class C inherits B {
				constructor() { a = 2 ; x = 3 }
			}
			program t {
				const c = new C(1, 7)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new C(1, 7)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			assertEquals("Wrong number of arguments. Should be new C()", message)
		}
	}
	
	/** ****************************************************************** 
	 * 
	 * TESTS BASED ON REAL-WORLD EXAMPLES. THEY HAVE SEVERAL DEFINITIONS
	 * OF ELEMENTS , SO THEY COMPLEMENT PREVIOUS TESTS.
	 * 
	 * ******************************************************************
	 * */
	@Test
	def void issue1288() {
		'''
		class Arma {
			const mm
			
			constructor(_mm) {
				mm = _mm
			}
		}
		
		class Unidad {
			var nombre = "Peloton"
		}
		
		class UnidadArmada inherits Unidad {
			var arma
			
			constructor(unArma) {
				arma = unArma
			}
		}
		
		object armeria {
			method arco() = new Arma(25)
		}
		class Arquero inherits UnidadArmada {
			constructor() = super(armeria.arco())
		}
		program prueba {
			console.println(new Arquero())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void multipleInheritanceForConstructors() {
		try {
			'''
			class Musico {
				var habilidadBase
				var grupo = ''
				const albumes = #{}
				constructor() { }
				constructor ( _habilidadBase) {
					habilidadBase = _habilidadBase
				}
			}
			
			class MusicoConRoles inherits Musico {
				var rolInterpretador
				var rolCobrador
				constructor ( _habilidadBase, _rolInterpretador, _rolCobrador) = super ( _habilidadBase) {
					rolInterpretador = _rolInterpretador
					rolCobrador = _rolCobrador
				}
				method internalInterpretaBien(cancion) = rolInterpretador.interpretaBien(cancion)
				method cobra(presentacion) = rolCobrador.cobra(presentacion)
			}
			
			class VocalistaPopular inherits MusicoConRoles {
				method esSolista() = true
				method habilidadExtra() = if (self.esSolista()) 0 else -20
			}
			
			program prueba {
				new VocalistaPopular()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new VocalistaPopular()")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals("Wrong number of arguments. Should be new VocalistaPopular(_habilidadBase, _rolInterpretador, _rolCobrador)", message)
		}
	}
	
	@Test
	def void multipleInheritanceForConstructors2() {
		try {
			'''
			class Musico {
				var habilidadBase
				var grupo = ''
				const albumes = #{}
				constructor() { }
				constructor ( _habilidadBase) {
					habilidadBase = _habilidadBase
				}
			}
			
			class MusicoConRoles inherits Musico {
				var rolInterpretador
				var rolCobrador
				constructor ( _habilidadBase, _rolInterpretador, _rolCobrador) = super ( _habilidadBase) {
					rolInterpretador = _rolInterpretador
					rolCobrador = _rolCobrador
				}
				method internalInterpretaBien(cancion) = rolInterpretador.interpretaBien(cancion)
				method cobra(presentacion) = rolCobrador.cobra(presentacion)
			}
			
			class VocalistaPopular inherits MusicoConRoles {
				method esSolista() = true
				method habilidadExtra() = if (self.esSolista()) 0 else -20
			}
			
			program prueba {
				new VocalistaPopular(2)
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			Assert.fail("Should have thrown an error in new VocalistaPopular(2)")
		} catch (WollokProgramExceptionWrapper e) {
			val message = e.wollokException.instanceVariables.get("message").toString
			Assert.assertEquals(message, "Wrong number of arguments. Should be new VocalistaPopular(_habilidadBase, _rolInterpretador, _rolCobrador)")
		}
	}
	
	@Test
	def void multipleInheritanceForConstructors3() {
		'''
		class Musico {
			var habilidadBase
			var grupo = ''
			const albumes = #{}
			constructor() { }
			constructor ( _habilidadBase) {
				habilidadBase = _habilidadBase
			}
		}
		
		class MusicoConRoles inherits Musico {
			var rolInterpretador
			var rolCobrador
			constructor ( _habilidadBase, _rolInterpretador, _rolCobrador) = super ( _habilidadBase) {
				rolInterpretador = _rolInterpretador
				rolCobrador = _rolCobrador
			}
			method internalInterpretaBien(cancion) = rolInterpretador.interpretaBien(cancion)
			method cobra(presentacion) = rolCobrador.cobra(presentacion)
		}
		
		class VocalistaPopular inherits MusicoConRoles {
			method esSolista() = true
			method habilidadExtra() = if (self.esSolista()) 0 else -20
		}
		
		program prueba {
			new VocalistaPopular(30, null, null)
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}
	
	@Test
	def void multipleInheritanceForConstructors4() {
		'''
		class Musico {
			var habilidadBase
			var grupo = ''
			const albumes = #{}
			constructor() { }
			constructor ( _habilidadBase) {
				habilidadBase = _habilidadBase
			}
		}
		
		class MusicoConRoles inherits Musico {
			var rolInterpretador
			var rolCobrador
			method internalInterpretaBien(cancion) = rolInterpretador.interpretaBien(cancion)
			method cobra(presentacion) = rolCobrador.cobra(presentacion)
		}
		
		class VocalistaPopular inherits MusicoConRoles {
			method esSolista() = true
			method habilidadExtra() = if (self.esSolista()) 0 else -20
		}
		
		program prueba {
			new VocalistaPopular(100)
			new VocalistaPopular()
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}

	@Test
	def void namedParametersWithNumbers() {
		'''
		class Point {
			var x
			var y
		}
		program t {
			console.println(new Point(x = 1, y = 2))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void namedParametersWithLiterals() {
		'''
		object chayanne {
			method nombre() = "Chayanne"
		}
		class Presentacion {
			var fecha
			var property cantante
			var property localidades
		}
		program t {
			const presentacion = new Presentacion(fecha = new Date(), cantante = chayanne, localidades = [100, 50, 200])
			console.println(presentacion)
			assert.equals(chayanne, presentacion.cantante())
			assert.equals(350, presentacion.localidades().sum())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void namedParametersWithInheritance() {
		'''
		object chayanne {
			method nombre() = "Chayanne"
		}
		object lunaPark {}
		class Evento {
			var fecha
		}
		class EventoLocalizado inherits Evento {
			var lugar
			method lugar() = lugar
		}
		class Presentacion inherits EventoLocalizado {
			var property cantante
			var property localidades
		}
		program t {
			const presentacion = new Presentacion(
				lugar = lunaPark,
				fecha = new Date(),
				cantante = chayanne,
				localidades = [100, 50, 200]
			)
			console.println(presentacion)
			assert.equals(chayanne, presentacion.cantante())
			assert.equals(350, presentacion.localidades().sum())
			assert.equals(presentacion.lugar(), lunaPark)
		}
		'''.interpretPropagatingErrors
	}
}
