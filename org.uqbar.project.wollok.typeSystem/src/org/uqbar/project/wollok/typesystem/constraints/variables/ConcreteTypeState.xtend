package org.uqbar.project.wollok.typesystem.constraints.variables

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

enum ConcreteTypeState {
	Pending,
	Ready,
	Error,
	Postponed,
	Cancel
}

class ConcreteTypeStateExtensions {
	static def join(ConcreteTypeState s1, ConcreteTypeState s2) {
		if (s1 == Ready) s2 else s1
	}
}
