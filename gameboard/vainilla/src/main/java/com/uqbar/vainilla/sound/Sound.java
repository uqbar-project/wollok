package com.uqbar.vainilla.sound;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.ShortBuffer;
import javax.sound.sampled.AudioFormat;

public abstract class Sound {

	private float[] samples;
	private AudioFormat format;

	// ****************************************************************
	// ** STATICS
	// ****************************************************************

	protected static float toFloatSample(short value) {
		return value / (float) Short.MAX_VALUE;
	}

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	protected Sound() {
	}

	public Sound(byte[] input, AudioFormat inputFormat) {
		this.setFormat(SoundPlayer.INSTANCE.normalizeFormat(inputFormat));
		this.setSamples(this.resample(input, inputFormat));

	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	protected float[] resample(byte[] originalSamples, AudioFormat originalFormat) {
		int samplesLength = originalSamples.length / Short.SIZE * Byte.SIZE;
		ShortBuffer samplesBuffer = ByteBuffer.wrap(originalSamples).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer();

		int resamplesLength = (int) (samplesLength * SoundPlayer.SAMPLE_RATE / originalFormat.getSampleRate());
		float[] answer = new float[this.collectableSamples(resamplesLength)];

		if(originalFormat.getSampleRate() == SoundPlayer.SAMPLE_RATE) {
			for(int i = 0; i < answer.length; i++ ) {
				answer[i] = toFloatSample(samplesBuffer.get(i));
			}
		}
		else {
			this.collectSamples(answer, samplesBuffer, samplesLength, originalFormat.getSampleRate() / SoundPlayer.SAMPLE_RATE);
		}

		return answer;
	}

	protected abstract int collectableSamples(int inputLength);

	protected abstract void collectSamples(float[] buffer, ShortBuffer samples, int samplesLength, float increment);

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void play() {
		this.play(1);
	}

	public void play(float volume) {
		SoundPlayer.INSTANCE.enqueueSound(this, volume);
	}

	protected abstract int renderSamples(float[] buffer, float vol, int offset, int length);

	// ACCESSORS
	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected float[] getSamples() {
		return this.samples;
	}

	protected void setSamples(float[] samples) {
		this.samples = samples;
	}

	protected AudioFormat getFormat() {
		return this.format;
	}

	protected void setFormat(AudioFormat format) {
		this.format = format;
	}
}