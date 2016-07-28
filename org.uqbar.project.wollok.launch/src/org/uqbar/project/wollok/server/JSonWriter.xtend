package org.uqbar.project.wollok.server

import com.google.gson.Gson
import com.google.gson.stream.JsonWriter
import java.io.InputStream
import java.io.InputStreamReader
import java.io.Writer
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * An improvement over Gson writer interface
 * 
 * @author npasserini 
 */
class JSonWriter {
	static extension Gson = new Gson

	static def writeJson(Writer writer, (JSonWriter)=>void contents) {
		val gson = writer.newJsonWriter
		try {
			new JSonWriter(gson) => contents				
		}
		finally {
			gson.close
		}
	} 
		
	/**
	 * GSon requires a Reader to produce a Json, but a request has an input stream, so handle the conversion.
	 * TODO: This could require smarter character encoding handling.
	 */
	static def <T> T fromJson(InputStream input, Class<T> resultType) {
		new InputStreamReader(input).fromJson(resultType)
	}

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
