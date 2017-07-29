package org.uqbar.project.wollok.interpreter.api

import java.util.Stack
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

interface XThread {
	def Stack<XStackFrame> getStack()
}