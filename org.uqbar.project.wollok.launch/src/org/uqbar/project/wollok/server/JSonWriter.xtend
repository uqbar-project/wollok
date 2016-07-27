package org.uqbar.project.wollok.server

import com.google.gson.stream.JsonWriter
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class JSonWriter {
	@Accessors
	JsonWriter writer

	new(JsonWriter writer) {
		this.writer = writer
	}

	def object(String name, (JSonWriter)=>void contents) {
		writer.name(name)
		writer.beginObject
		try {
			this => contents
		} finally {
			writer.endObject
		}
	}

	def value(String name, Object value) {
		writer.name(name).value(value?.toString)
	}

	def array(String name, (JSonWriter)=>void contents) {
		writer.name(name)
		writer.beginArray
		try {
			this => contents
		} finally {
			writer.endArray
		}
	}

	def <T> array(String name, List<T> elements, (JSonWriter, T)=>void elementWriter) {
		array(name) [
			elements.forEach[element | elementWriter.apply(this, element)]
		]								
	}

	def array(String name, Object[] values) { 
		array(name, values) [ it, each | writer.value(each.toString)]
   }
	
	/**
	 * This method should only be used in an array or at top level 
	 */
	def object((JSonWriter)=>void contents) {
		writer.beginObject
		try {
			this => contents
		} finally {
			writer.endObject
		}
	}
}
