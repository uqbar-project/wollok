package org.uqbar.project.wollok.ui.console.highlight

import java.util.ArrayList
import java.util.List
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.graphics.GlyphMetrics

import static org.uqbar.project.wollok.ui.console.highlight.AnsiCommands.*

/**
 * A LineStyleListener that interprets ansi codes
 * and provides the styles based on that standard (font style and colors).
 * 
 * @author jfernandes
 */
class WollokAnsiColorLineStyleListener implements LineStyleListener {
	var lastAttributes = new WollokConsoleAttributes
    var currentAttributes = new WollokConsoleAttributes
    public static val Character ESCAPE_SGR = 'm'

    int lastRangeEnd = 0
	
	override lineGetStyle(LineStyleEvent event) {
		if (event === null || event.lineText === null || event.lineText.length() == 0)
            return

        val currentPalette = WollokConsolePreferenceUtils.getString(WollokConsolePreferenceConstants.PREF_COLOR_PALETTE)
        WollokConsoleColorPalette.setPalette(currentPalette)
        var StyleRange defStyle

        if (event.styles !== null && event.styles.length > 0) {
            defStyle = event.styles.get(0).clone as StyleRange
            if (defStyle.background === null)
                defStyle.background = WollokConsolePreferenceUtils.getDebugConsoleBgColor
        }
        else {
            defStyle = new StyleRange(1, lastRangeEnd, 0.toColor, 15.toColor, SWT.NORMAL)
        }

        lastRangeEnd = 0
        val ranges = new ArrayList<StyleRange>
        var currentText = event.lineText
        val matcher = AnsiUtils.pattern.matcher(currentText)
        while (matcher.find) {
            val start = matcher.start
            val end = matcher.end

            var theEscape = currentText.substring(start + 2, end - 1)
            var code = currentText.charAt(end - 1)
            if (code == ESCAPE_SGR) {
                // Select Graphic Rendition (SGR) escape sequence
                var nCommands = new ArrayList<Integer>
                for (String cmd : theEscape.split(";")) {
                    var nCmd = tryParseInteger(cmd)
                    if (nCmd != -1)
                        nCommands.add(nCmd)
                }
                if (nCommands.empty)
                    nCommands.add(0)
                
                interpretCommand(nCommands)
            }

            if (lastRangeEnd != start)
                addRange(ranges, event.lineOffset + lastRangeEnd, start - lastRangeEnd, defStyle, false)
            lastAttributes = currentAttributes.clone

            addRange(ranges, event.lineOffset + start, end - start, defStyle, true)
        }
        if (lastRangeEnd != currentText.length)
            addRange(ranges, event.lineOffset + lastRangeEnd, currentText.length - lastRangeEnd, defStyle, false)
        
        lastAttributes = currentAttributes.clone

        if (!ranges.empty)
            event.styles = ranges
	}
	
	def void addRange(List<StyleRange> ranges, int start, int length, StyleRange defStyle, boolean isCode) {
        val range = new StyleRange(start, length, defStyle.foreground, null)
        range.underline = defStyle.underline
        WollokConsoleAttributes.updateRangeStyle(range, lastAttributes)
        if (isCode) {
            val showEscapeCodes = WollokConsolePreferenceUtils.getBoolean(WollokConsolePreferenceConstants.PREF_SHOW_ESCAPES)
            if (showEscapeCodes)
                range.font = new Font(null, "Monospaced", 6, SWT.NORMAL)
            else
                range.metrics = new GlyphMetrics(0, 0, 0)
        }
        ranges.add(range)
        lastRangeEnd += range.length
    }
    
    def tryParseInteger(String text) {
		try
			if ("" == text)
				-1
			else
				Integer.parseInt(text)
        catch (NumberFormatException e)
			-1
    }
    
    def interpretCommand(List<Integer> nCommands) {
        val iter = nCommands.iterator
        while (iter.hasNext) {
            val nCmd = iter.next
            switch (nCmd) {
                case COMMAND_ATTR_RESET:             currentAttributes.reset
                case COMMAND_ATTR_INTENSITY_BRIGHT:  currentAttributes.bold = true
                case COMMAND_ATTR_INTENSITY_FAINT:   currentAttributes.bold = false
                case COMMAND_ATTR_INTENSITY_NORMAL:  currentAttributes.bold = false

                case COMMAND_ATTR_ITALIC:            currentAttributes.italic = true
                case COMMAND_ATTR_ITALIC_OFF:        currentAttributes.italic = false

                case COMMAND_ATTR_UNDERLINE:         currentAttributes.underline = SWT.UNDERLINE_SINGLE
                case COMMAND_ATTR_UNDERLINE_DOUBLE:  currentAttributes.underline = SWT.UNDERLINE_DOUBLE
                case COMMAND_ATTR_UNDERLINE_OFF:     currentAttributes.underline = WollokConsoleAttributes.UNDERLINE_NONE

                case COMMAND_ATTR_CROSSOUT_ON:       currentAttributes.strike = true
                case COMMAND_ATTR_CROSSOUT_OFF:      currentAttributes.strike = false

                case COMMAND_ATTR_NEGATIVE_ON:       currentAttributes.invert = true
                case COMMAND_ATTR_NEGATIVE_OFF:      currentAttributes.invert = false

                case COMMAND_ATTR_CONCEAL_ON:        currentAttributes.conceal = true
                case COMMAND_ATTR_CONCEAL_OFF:       currentAttributes.conceal = false

                case COMMAND_ATTR_FRAMED_ON:         currentAttributes.framed = true
                case COMMAND_ATTR_FRAMED_OFF:        currentAttributes.framed = false

                case COMMAND_COLOR_FOREGROUND_RESET: currentAttributes.currentFgColor = null
                case COMMAND_COLOR_BACKGROUND_RESET: currentAttributes.currentBgColor = null

                case COMMAND_256COLOR_FOREGROUND, case COMMAND_256COLOR_BACKGROUND  :  {// {esc}[48;5;{color}m 
                    var nMustBe5 = if (iter.hasNext) iter.next else -1
                    if (nMustBe5 == 5) { // 256 colors
                        var color = if (iter.hasNext) iter.next else -1
                        if (color >= 0 && color < 256)
                            if (nCmd == COMMAND_256COLOR_FOREGROUND)
                                currentAttributes.currentFgColor = color
                            else
                                currentAttributes.currentBgColor = color
                    }
				}
                case -1: return // do nothing
                
                default : {
                    if (nCmd.foregroundColor)
                        currentAttributes.currentFgColor = nCmd - COMMAND_COLOR_FOREGROUND_FIRST
                    else if (nCmd.backgroundColor)
                        currentAttributes.currentBgColor = nCmd - COMMAND_COLOR_BACKGROUND_FIRST
                    else if (nCmd.isHiForegroundColor)
                        currentAttributes.currentFgColor = nCmd - COMMAND_HICOLOR_FOREGROUND_FIRST + COMMAND_COLOR_INTENSITY_DELTA
                    else if (nCmd.isHiBackgroundColor)
                        currentAttributes.currentBgColor = nCmd - COMMAND_HICOLOR_BACKGROUND_FIRST + COMMAND_COLOR_INTENSITY_DELTA
               }
            }
        }
    }
	
	def isForegroundColor(Integer it) { between(COMMAND_COLOR_FOREGROUND_FIRST, COMMAND_COLOR_FOREGROUND_LAST) }
	def isBackgroundColor(Integer it) { between(COMMAND_COLOR_BACKGROUND_FIRST, COMMAND_COLOR_BACKGROUND_LAST) }
	def isHiForegroundColor(Integer it) { between(COMMAND_HICOLOR_FOREGROUND_FIRST, COMMAND_HICOLOR_FOREGROUND_LAST) }
	def isHiBackgroundColor(Integer it) { between(COMMAND_HICOLOR_BACKGROUND_FIRST, COMMAND_HICOLOR_BACKGROUND_LAST) }
	def between(Integer i, int a, int b) { i >= a && i <= b }
    
    def toColor(Integer i) {new Color(null, WollokConsoleColorPalette.getColor(i)) }
	
}