package org.uqbar.project.wollok.typesystem.constraints.variables

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

enum EffectStatus {
	Change,
	Nothing,
	Exception,
	Undefined
}

class EffectStatusExtensions {
	static def join(EffectStatus s1, EffectStatus s2) {
		if (s1 == Change || s2 == Change) return Change
		if (s1 == Undefined) s2 else s1
	}
}
