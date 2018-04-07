package org.uqbar.project.wollok.typesystem

class WollokTypeExtension {
	def static dispatch isAny(AnyType any) { true }
	def static dispatch isAny(WollokType type) { false }
}