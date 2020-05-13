import hxp.*;

class Benchmarks extends hxp.Script
{
	public function new()
	{
		super();

		run("testing with Vector:");
		run("testing with Array:", ["-D", "PixelMatrixUseArray"]);
		run("testing with UInt32Array:", ["-D", "PixelMatrixUseUInt32Array"]);
		run("testing with Bytes:", ["-D", "PixelMatrixUseBytes"]);
    }

	function run(desc, args = null)
	{
		Log.info(desc);

		var arguments = [ "benchmarks.hxml" ];
		if (args != null) arguments = arguments.concat(args);
				
		System.runCommand("", "haxe", arguments);

		var outputDir = "Export/benchmarks";

		Log.info("------------------- Node -------------------------------------");
		System.runCommand(outputDir, "node", ["benchmarks.js"]);

		Log.info("------------------- CPP --------------------------------------");
		System.runCommand(outputDir, ((System.hostPlatform != WINDOWS) ? "./" : "") + "Benchmarks", []);

		Log.info("------------------- Neko -------------------------------------");
		System.runCommand(outputDir, "neko", [ "benchmarks.n" ]);
	}
}