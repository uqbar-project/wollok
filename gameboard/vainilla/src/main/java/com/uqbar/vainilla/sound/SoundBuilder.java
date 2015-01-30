package com.uqbar.vainilla.sound;

import static javax.sound.sampled.AudioSystem.getAudioInputStream;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;

public class SoundBuilder {

	// ****************************************************************
	// ** STATICS
	// ****************************************************************

	// Returns a signed, 16 bytes little-endian equivalent for the input
	protected static AudioFormat toNormalizedReadableFormat(AudioFormat inputFormat) {
		return new AudioFormat(
			SoundPlayer.ENCODING,
			inputFormat.getSampleRate(),
			SoundPlayer.SAMPLE_SIZE_IN_BYTES * 8,
			inputFormat.getChannels(),
			inputFormat.getChannels() * SoundPlayer.SAMPLE_SIZE_IN_BYTES,
			inputFormat.getSampleRate(),
			false //
		);
	}

	protected static byte[] readInput(AudioInputStream input) {
		ByteArrayOutputStream inputContent = new ByteArrayOutputStream();
		byte[] buffer = new byte[10240];

		try {
			int readed;
			while((readed = input.read(buffer)) != -1) {
				inputContent.write(buffer, 0, readed);
			}
		}
		catch(Exception e) {
			throw new RuntimeException(e);
		}

		return inputContent.toByteArray();
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public static Sound buildSound(String path) {
		return buildSound(SoundBuilder.class.getResourceAsStream(path));
	}

	public static Sound buildSound(InputStream inputStream) {
		try {
			AudioInputStream input = getAudioInputStream(new BufferedInputStream(inputStream));
			AudioFormat inputFormat = toNormalizedReadableFormat(input.getFormat());
			AudioInputStream normalizedInput = getAudioInputStream(inputFormat, input);

			Sound answer = inputFormat.getChannels() == 1
				? new MonoSound(readInput(normalizedInput), inputFormat)
				: new StereoSound(readInput(normalizedInput), inputFormat);

			normalizedInput.close();

			return answer;
		}
		catch(Exception e) {
			throw new RuntimeException(e);
		}
	}
}