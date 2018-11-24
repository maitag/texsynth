package texsynth;

class ImageTransition {

	public static function render(pixelType:PixelType, input1:PixelData, input2:PixelData,
																transZoneSize:Int = 10,
	                              neighborsX:Int = 2, neighborsY:Int = 2,  neighborsOutside:Bool = false,
								  							passes:Int = 3, merged:Bool = true):PixelData {

		var pixelMath = new PixelMath(pixelType);


    //output.randomizeAlpha(); // TODO: FIX THIS FUNCTION

		//var ixStart:Int = (neighborsOutside) ? 0 : neighborsX;
		//var iyStart:Int = (neighborsOutside) ? 0 : neighborsY;

		var best = new Vec2<Int>(0, 0);

		var bestd:Float;
		var tempd:Float;

		if (input1.height!=input2.height)  throw('input images do not have the same height');
		var output = new PixelData(input1.width + input2.width + transZoneSize, input1.width);
		var pixellocinOutput = new PixelLocationMap(output.width, output.height); // Pixelloc output -> Pixelloc input
		var curloc    = new Vec2<Int>(0, 0);
		var candidate = new Vec2<Int>(0, 0);
		var curneigh  = new Vec2<Int>(0, 0);


		//randomize transZone
		for (x in input1.width...input1.width + transZoneSize)
			for (y in 0...output.height)
				output.setPixel(x, y, Pixel.random());
		//copy input1 and input2 into output
		for (x in 0...input1.width)
			for (y in 0...output.height)
				output.setPixel(x, y, input1.getPixel(x, y));
		for (x in input1.width + transZoneSize ... input1.width + transZoneSize+ input2.width)
			for (y in 0...output.height)
				output.setPixel(x, y, input2.getPixel(x - input1.width - transZoneSize, y));

		for (y in 0...output.height) {
			for (x in 0...output.width) {
				if(Std.random(2)==0){
					candidate.x = Std.random(input1.width - 2 * neighborsX) + neighborsX;
				}
				else{
					candidate.x = Std.random(input2.width - 2 * neighborsX) + neighborsX + input1.width + transZoneSize;
				}
				candidate.y = Std.random(output.height - 2* neighborsY) + neighborsY;
				curloc.set(x, y);
				pixellocinOutput.setLocInOutput(curloc, candidate);
			}
		}

    for (pass in 0...passes) {
		// for every pixel in output image
  		for (y in 0...output.height) {
  			trace('render line $y'); // TODO: onProgress callback here (for worker)
  			curloc.y = y;
  			for (x in input1.width...input1.width + transZoneSize) {
  				curloc.x = x;
  				bestd = 9007199254740992;

  				for (cx in (0-neighborsX)...neighborsX+1) {
  					for (cy in (0-neighborsY)...neighborsY + 1) {
  						tempd = 0;
  						curneigh.set(curloc.x - cx, curloc.y - cy);
  						candidate = pixellocinOutput.getLocInOutput(curneigh);
  						candidate.set(candidate.x + cx, candidate.y + cy);
  						if (candidate.x >= output.width - neighborsX  || candidate.x <= neighborsX ||
  							  candidate.y >= output.height - neighborsY || candidate.y <= neighborsY) {
									if(Std.random(2)==0){
										candidate.x = Std.random(input1.width - 2 * neighborsX) + neighborsX;
									}
									else{
										candidate.x = Std.random(input2.width - 2 * neighborsX) + neighborsX + input1.width + transZoneSize;
									}
  								candidate.y = Std.random(output.height - 2 * neighborsY) + neighborsY;
  						}
  						for (nx in (0-neighborsX)...neighborsX+1)
  							for (ny in (0-neighborsX)...neighborsY + 1)
  								tempd += pixelMath.absErrorNorm2(output.getPixel(candidate.x - nx, candidate.y - ny), output.getPixelSeamless(x - nx, y - ny));
							if (tempd < bestd) {
  							bestd = tempd;
  							best.set(candidate.x, candidate.y);
  						}
  					}
  				}
  				output.setPixel(x, y, output.getPixel(best.x, best.y));
  				candidate.set(best.x, best.y);
  				pixellocinOutput.setLocInOutput(curloc, candidate);
  			}
  		}
    }
		var finaloutput:PixelData;
		if (merged==true){
			finaloutput=output;
		}
		else{
			finaloutput=new PixelData(transZoneSize, input1.width);
			for (x in 0...transZoneSize)
				for (y in 0...output.height)
					finaloutput.setPixel(x, y, output.getPixel(input1.width + x, y));
		}

	return finaloutput;
	}

}
