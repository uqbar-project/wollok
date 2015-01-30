package com.uqbar.vainilla.sound;

import java.nio.ShortBuffer;
import javax.sound.sampled.AudioFormat;

public class StereoSound extends Sound {

	private static final int CHANNELS = 2;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	protected StereoSound(byte[] input, AudioFormat inputFormat) {
		super(input, inputFormat);
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	protected int collectableSamples(int inputLength) {
		return inputLength % CHANNELS != 0 ? inputLength - inputLength % CHANNELS : inputLength;
	}

	@Override
	protected int renderSamples(float[] buffer, float vol, int offset, int length) {
		int i = 0;
		int j = 0;

		for(; i + offset < length; i += 2, j += 2) {
			buffer[j] += this.getSamples()[i + offset] * vol;
			buffer[j + 1] += this.getSamples()[i + offset + 1] * vol;
		}

		return i;
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	protected void collectSamples(float[] buffer, ShortBuffer samples, int samplesLength, float increment) {
		for(int i = 0; i < buffer.length; i++) {
			int sampleIndex = (int) (i * increment);

			int leftSampleIndex = sampleIndex * 2;

			if(leftSampleIndex >= samplesLength - this.getFormat().getChannels()) {
				break;
			}

			buffer[i++] = toFloatSample(samples.get(leftSampleIndex));
			buffer[i] = toFloatSample(samples.get(leftSampleIndex + 1));

			sampleIndex += increment;
		}
	}
}
