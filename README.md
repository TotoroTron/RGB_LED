# FPGA-32x32-RGB-LED-Matrix
Personal project: VHDL code to drive a 32x32 RGB LED matrix with 24-bit color, ~60 frames per second, and simple gamma correction on a Xilinx FPGA

Photos and videos of the final product on hardware: https://imgur.com/a/1KAUMys

Future Work: Currently, animation frames are stored without compression in the embedded BRAMs. The Arty Z7-20 only has 630 KB in BRAM. Since we are using 24-bit color, and since each frame is 32x32 pixels, each frame will require 3.072 KB (32*32*24 = 24576 b = 3072 B). This means we can only store an animation with a maximum of about 200 frames (630/3.072 = 205), which, if played at 60fps (frame rate can be adjusted), is less than 3.5 seconds of animation. Instead of using embedded BRAM, it is probably worthwhile to figure out how to interface with the external SD card slot on the back of the FPGA board. This will allow for the storage of longer or multiple animations. Another consideration could be the inclusion of compression and decompression functionality, which will probably involve the Zynq microprocessor.
