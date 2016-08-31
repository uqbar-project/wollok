package org.uqbar.project.wollok.ui.console.editor

import java.util.List
import java.util.Map
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.FontData

/**
 * Abstracts a style applied to a WollokReplStyledText
 */
class WollokStyle {
	int startOffset
	int length
	
	// Map
	// key = line
	// value = list of Style Ranges applied to this line
	val Map<Integer, List<StyleRange>> styles = newHashMap
	
	// Internal buffer of every line selected
	val Map<Integer, String> lines = newHashMap
	
	val WollokReplStyledText widget
	val FontData fontData
	
	new(WollokReplStyledText _widget) {
		widget = _widget
		fontData = _widget.getFont().fontData.get(0)
	}

	def applyStyle(int line, List<StyleRange> _styles) {
		val styleAdapted = adaptOffset(line, _styles)
		val content = widget.content
		lines.put(line, content.getLine(line))
		styles.put(line, styleAdapted)
	}
	
	/**
	 * Adapts offsets relative to selected line 
	 */	
	private def List<StyleRange> adaptOffset(int line, List<StyleRange> ranges) {
		val offset = widget.getOffsetAtLine(line)
		ranges.map [ styleRange | 
			val newStart = styleRange.start - offset
			new StyleRange(newStart, styleRange.length, styleRange.foreground, styleRange.background, styleRange.fontStyle)
		]
	}
	
	/**
	 * Adjust boundary offsets (min and max) based on selected characters
	 */
	def List<StyleRange> getStylesSelected(int lineNumber) {
		// if lines are not in boundary just return them
		if (lineNumber > lineStart && lineNumber < lineEnd) {
			return styles.get(lineNumber)
		}
		
		var List<StyleRange> newStyles = styles.get(lineNumber)
		// First line
		if (lineNumber == lineStart) {
			val oldLineStart = widget.getOffsetAtLine(lineNumber)
			val newStartOffset = startOffset - oldLineStart
			newStyles = newStyles.filter [ style | style.end > newStartOffset ].toList
			if (!newStyles.isEmpty) {
				newStyles.head => [
					val diffOffset = newStartOffset - it.start
					it.start = it.start + diffOffset
					it.length = it.length - diffOffset
				]
			}
		}
		
		// Last line
		if (lineNumber == lineEnd) {
			val endLine = widget.getLine(lineEnd)
			var oldLength = endLine.length
			val diffLength = (widget.getOffsetAtLine(lineEnd) + oldLength) - endOffset
			val newLength = oldLength - diffLength
			newStyles = newStyles.filter [ style | style.start < newLength ].toList
			if (!newStyles.isEmpty) {
				val stylesEnd = styles.get(lineEnd)
				// This is because newline characters causes style to overflow line length
				val stylesTotalLength = stylesEnd.fold(0) [acum, style | acum + style.length ]
				val adjustLength = stylesTotalLength - oldLength
				var totalLengthOut = styles.get(lineEnd)
					.filter [ style | style.start >= newLength ]
					.toList
					.fold(0) [ acum, style | acum + style.length ]
				
				newStyles.last.length += Math.max(0, (totalLengthOut - adjustLength) - diffLength) 
			}
		}
		
		newStyles
	}
	
	def endOffset() {
		startOffset + length
	}
	
	def getEnd(StyleRange style) {
		style.start + style.length
	}
	
	override toString() {
		"WollokStyle: " + styles.toString
	}
	
	def getStylesAtLine(int lineNumber) {
		adjustStylesRange(getStylesSelected(lineNumber))
	}
	
	def adjustStylesRange(List<StyleRange> ranges) {
		var rangesSortedByStart = ranges.sortBy [ start ]
		// Style ranges often collide among each others!!
		for (var int i = 1; i < rangesSortedByStart.length; i++) { 
			val currentRange = rangesSortedByStart.get(i)
			val sameRanges = rangesSortedByStart.filter [ range | range != currentRange && range.start == currentRange.start ]
			if (!sameRanges.isEmpty) {
				// Shift all ranges to set bold/normal font & colors
				val allRanges = #[currentRange] + sameRanges 
				
				/**
				val sameRangesSorted = allRanges.sortBy [ length ]
				var shiftedStart = currentRange.start
				var totalShift = 0
				for (var j = 0; j < sameRangesSorted.length; j++) {
					val currentSameRange = sameRangesSorted.get(j)
					currentSameRange.start = shiftedStart
					currentSameRange.length -= totalShift
					totalShift += currentSameRange.length
					shiftedStart += currentSameRange.length
				}
				*/
				
				val maxLength = allRanges.maxBy [ length ].length
				var totalLength = 0
				for (var j = allRanges.length - 1; j >= 0; j--) {
					val currentSameRange = allRanges.get(j)
					currentSameRange.start += totalLength
					val newLength = currentSameRange.length - totalLength
					currentSameRange.length = Math.max(0, newLength)
					totalLength += currentSameRange.length
					totalLength = Math.min(totalLength, maxLength)
				}
				
			}
		}
		
		// first, style range overflow next range!!
		rangesSortedByStart = rangesSortedByStart.sortBy [ start ]
		for (var int i = 0; i < rangesSortedByStart.length - 1; i++) {
			val currentRange = rangesSortedByStart.get(i)
			val nextRange = rangesSortedByStart.get(i+1)
			if (currentRange.start + currentRange.length > nextRange.start) {
				currentRange.length = Math.min(0, nextRange.start - currentRange.start)
			}
		}
		rangesSortedByStart
	}

	def getLine(Integer line) {
		lines.get(line) ?: ""
	}

	def allStyles() {
		styles.values.flatten
	}
	
	def allColors() {
		allStyles
 			.filter [ style | style.foreground != null ]
 			.map [ style | style.foreground ]
 			.toSet  // remove duplicates
 			.toList // get an order
	}
	
	def adjustBoundaryOffsets(int _startOffset, int _length) {
		startOffset = _startOffset
		length = _length
	}

	def getLineStart() {
		if (startOffset > 0) {
			widget.getLineAtOffset(startOffset)
		} else {
			0
		}
	}
	
	def getLineEnd() {
		val endOffset = startOffset + length
		if (endOffset == 0) {
			lines.size
		} else {
			widget.getLineAtOffset(endOffset)
		} 
	}

	def getDefaultFont() {
		fontData.name
	}		
}
