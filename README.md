# Image to sound converter for iOS

The app is a simple iPhone iOS Application inspired by [this video].

The user may select any image from the gallery to be converted. First, the chosen picture is resized and filtered to be square and black-and-white. That is done concurrently, using NSOperations.

Then, for each pixel on the new image a waveform is generated. The total waveform, i.e the sum of all pixels' waveforms, represents the generated sound. Again, that is a concurrent NSOperation.

A pixel's waveform depends on two factors - its coordinates and brightness. First, an *n*-th degree [hilbert curve] is used to map the pixels' normalized coordinates (on a unit square) to a floating-point number in range [0; 1]. That coefficient is used to select a frequency from a predefined range. The amplitude is simply the brightness of the pixel. The waveform of a pixel is simply a sine wave with the aforementioned frequency and amplitude. 

I have used a third-party library, [AudioKit], to display the generated waveform and play the sound. All code was written in Swift 2.3.

[this video]: https://www.youtube.com/watch?v=DuiryHHTrjU
[hilbert curve]: https://en.wikipedia.org/wiki/Hilbert_curve
[AudioKit]: http://audiokit.io/