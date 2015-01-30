package com.uqbar.vainilla.sound;

public class SoundPlay {

	private Sound sound;
	private float volume;
	private int writtenSamples;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public SoundPlay(Sound sound, float volume) throws Exception {
		this.setSound(sound);
		this.setVolume(volume);
		this.setWrittenSamples(0);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public boolean writeSamples(int samplesToWrite, float[] buffer) {
		float[] samples = this.sound.getSamples();
		float vol = this.volume;

		// TODO: SACAR EL getFormat() de ahí
		int remainingSamples = Math.min(samples.length, this.writtenSamples + samplesToWrite
				* this.sound.getFormat().getChannels() / SoundPlayer.CHANNELS);

		int i = this.sound.renderSamples(buffer, vol, this.writtenSamples, remainingSamples);

		this.writtenSamples += i;

		return this.writtenSamples >= samples.length;
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected Sound getSound() {
		return this.sound;
	}

	protected void setSound(Sound sound) {
		this.sound = sound;
	}

	protected int getWrittenSamples() {
		return this.writtenSamples;
	}

	public void setWrittenSamples(int writtenSamples) {
		this.writtenSamples = writtenSamples;
	}

	protected float getVolume() {
		return this.volume;
	}

	protected void setVolume(float volume) {
		this.volume = volume;
	}
}