package org.uqbar.project.wollok.launch.io

import java.io.BufferedReader
import java.io.PrintWriter

/**
 * A link with other process.
 * Has input and out to read an write back.
 * 
 * @author jfernandes
 */
class CommunicationChannel {
	@Property BufferedReader in
	@Property PrintWriter out
	
	new(BufferedReader in, PrintWriter out) {
		this.in = in
		this.out = out
	}
	
	def close() {
		in.close
		out.close
	}
	
}