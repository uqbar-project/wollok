package com.uqbar.vainilla.appearances;


import java.awt.Canvas;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.util.Arrays;
import java.util.List;

import com.uqbar.vainilla.GameComponent;

public class Label implements Appearance {
	private Font font;
	private Color color;
	private List<String> textLines;
	private boolean dropShadow = false;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public Label(Font font, Color color, String text) {
		this(font, color, text, false);
	}
	
	public Label(Font font, Color color, String text, boolean dropShadow) {
		this(font, color);
		this.setText(text);
		this.dropShadow = dropShadow;
	}

	public Label(Font font, Color color, String... textLines) {
		this(font, color, Arrays.asList(textLines));
	}

	protected Label(Font font, Color color, List<String> textLines) {
		this.setFont(font);
		this.setColor(color);
		this.setTextLines(textLines);
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	public double getWidth() {
		double answer = 0;
		FontMetrics metrics = new Canvas().getFontMetrics(this.getFont());

		for(String line : this.getTextLines()) {
			answer = Math.max(answer, metrics.stringWidth(line));
		}

		return answer;
	}

	@Override
	public double getHeight() {
		return this.getLinesCount() * 1.05 * this.getLineHeight();
	}

	@Override
	@SuppressWarnings("unchecked")
	public Appearance copy() {
		return new Label(this.getFont(), this.getColor(), this.getTextLines());
	}

	protected int getLinesCount() {
		return this.getTextLines().size();
	}

	protected double getLineHeight() {
		return this.getFont().getSize2D();
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void setText(String text) {
		this.setTextLines(Arrays.asList(text.split("\n")));
	}

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void update(double delta) {
	}

	@Override
	public void render(GameComponent<?> component, Graphics2D graphics) {
		graphics.setFont(this.getFont());
		graphics.setColor(this.getColor());

		this.getTextLines().get(0);

		for(int index = 0; index < this.getTextLines().size(); index++) {
			// shadow
			if (dropShadow) {
				graphics.setColor(Color.DARK_GRAY);
				graphics.drawString(this.getTextLines().get(index), //
						(int) component.getX() + 2, //
						(int) (component.getY() + 3 + this.getLineHeight() * (index + 1)) //
						);
				graphics.setColor(this.getColor());
			}
			
			// text
			graphics.drawString(this.getTextLines().get(index), //
			(int) component.getX(), //
			(int) (component.getY() + this.getLineHeight() * (index + 1)) //
				);
		}
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public Font getFont() {
		return this.font;
	}

	public void setFont(Font font) {
		this.font = font;
	}

	public Color getColor() {
		return this.color;
	}

	public void setColor(Color color) {
		this.color = color;
	}

	protected List<String> getTextLines() {
		return this.textLines;
	}

	protected void setTextLines(List<String> textLines) {
		this.textLines = textLines;
	}
}