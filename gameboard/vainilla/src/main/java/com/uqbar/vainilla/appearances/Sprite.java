package com.uqbar.vainilla.appearances;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import com.uqbar.vainilla.exceptions.GameException;

@SuppressWarnings("unchecked")
public class Sprite extends SimpleAppearance<Sprite> {

	private BufferedImage image;

	// ****************************************************************
	// ** STATIC
	// ****************************************************************

	public static Sprite fromImage(String imageFileName) {
		BufferedImage image;

		try {
			image = ImageIO.read(Sprite.class.getResource(imageFileName));
		}
		catch(Exception e) {
			throw new GameException("The resource '" + imageFileName + "' was not found");
		}

		return new Sprite(image);
	}

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public Sprite(BufferedImage image) {
		this.setImage(image);
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	public double getWidth() {
		return this.getImage().getWidth();
	}

	@Override
	public double getHeight() {
		return this.getImage().getHeight();
	}

	protected BufferedImage getTransformedImage(AffineTransform transformation) {
		AffineTransformOp transformOperation = new AffineTransformOp(transformation, AffineTransformOp.TYPE_BICUBIC);

		return transformOperation.filter(this.getImage(), new BufferedImage(
			(int) (this.getImage().getWidth() * Math.abs(transformation.getScaleX())),
			(int) (this.getImage().getHeight() * Math.abs(transformation.getScaleY())),
			this.getImage().getType()
			));
	}

	// ****************************************************************
	// ** TRANSFORMATIONS
	// ****************************************************************

	@Override
	public Sprite scale(double scaleX, double scaleY) {
		return new Sprite(this.getTransformedImage(AffineTransform.getScaleInstance(scaleX, scaleY)));
	}

	public Sprite rotate(double radians) {
		BufferedImage newImage = new BufferedImage((int) this.getWidth(), (int) this.getHeight(), this.getImage().getType());

		Graphics2D graphics = newImage.createGraphics();
		graphics.rotate(radians, this.getWidth() / 2, this.getHeight() / 2);
		graphics.drawImage(this.getImage(), null, 0, 0);
		graphics.dispose();

		return new Sprite(newImage);
	}

	// ****************************************************************
	// ** FLIPING
	// ****************************************************************

	public Sprite flipHorizontally() {
		AffineTransform transformation = new AffineTransform();
		transformation.translate(this.getImage().getWidth(), 0);
		transformation.scale(-1, 1);

		return new Sprite(this.getTransformedImage(transformation));
	}

	public Sprite flipVertically() {
		AffineTransform transformation = new AffineTransform();
		transformation.translate(0, this.getImage().getHeight());
		transformation.scale(1, -1);

		return new Sprite(this.getTransformedImage(transformation));
	}

	// ****************************************************************
	// ** CROPPING
	// ****************************************************************

	public Sprite crop(int width, int height) {
		return this.crop(0, 0, width, height);
	}

	public Sprite crop(int x, int y, int width, int height) {
		return new Sprite(this.getImage().getSubimage(x, y, width, height));
	}

	// ****************************************************************
	// ** REPEATING
	// ****************************************************************

	public Sprite repeat(double horizontalRepetitions, double verticalRepetitions) {
		double horizontalIterations = Math.ceil(horizontalRepetitions);
		double verticalIterations = Math.ceil(verticalRepetitions);
		BufferedImage newImage = new BufferedImage( //
			(int) (this.getWidth() * horizontalRepetitions), //
			(int) (this.getHeight() * verticalRepetitions), //
			this.getImage().getType() //
		);
		Graphics2D graphics = newImage.createGraphics();

		for(int i = 0; i < horizontalIterations; i++ ) {
			for(int j = 0; j < verticalIterations; j++ ) {
				graphics.drawImage(this.getImage(), i * (int) this.getWidth(), j * (int) this.getHeight(), null);
			}
		}

		graphics.dispose();

		return new Sprite(newImage);
	}

	public Sprite repeatHorizontally(double repetitions) {
		return this.repeat(repetitions, 1);
	}

	public Sprite repeatVertically(double repetitions) {
		return this.repeat(1, repetitions);
	}

	public Sprite repeatHorizontallyToCover(double width) {
		return this.repeatHorizontally(width / this.getWidth());
	}

	public Sprite repeatVerticallyToCover(double height) {
		return this.repeatVertically(height / this.getHeight());
	}

	public Sprite repeatToCover(double width, double height) {
		return this.repeat(width / this.getWidth(), height / this.getHeight());
	}

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void update(double delta) {
	}

	@Override
	protected void doRenderAt(int x, int y, Graphics2D graphics) {
		graphics.drawImage(this.getImage(), x, y, null);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected BufferedImage getImage() {
		return this.image;
	}

	protected void setImage(BufferedImage currentImage) {
		this.image = currentImage;
	}
}