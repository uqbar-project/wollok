package com.uqbar.vainilla.sound;

import java.nio.ShortBuffer;
import javax.sound.sampled.AudioFormat;

public class MonoSound extends Sound {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public MonoSound(byte[] input, AudioFormat inputFormat) {
		super(input, inputFormat);
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	protected int collectableSamples(int inputLength) {
		return inputLength;
	}

	@Override
	protected int renderSamples(float[] buffer, float vol, int offset, int length) {
		int i = 0;
		int j = 0;

		for(; i + offset < length; i += 1, j += 2) {
			buffer[j] += this.getSamples()[i + offset] * vol;
			buffer[j + 1] += this.getSamples()[i + offset] * vol;
		}

		return i; // cuantos se copiaron
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	protected void collectSamples(float[] buffer, ShortBuffer samples, int samplesLength, float increment) {
		for(int i = 0; i < buffer.length; i++) {
			int sampleIndex = (int) (i * increment);

			if(sampleIndex >= samplesLength - this.getFormat().getChannels()) {
				break;
			}

			buffer[i] = toFloatSample(samples.get(sampleIndex));

			sampleIndex += increment;
		}
	}
}
