package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

// TO DO: Redo the menu creation system for not being as dumb
class RPGLoadingSaveState extends MusicBeatState
{

	var options:Array<String> = ['Save 1', 'Save 2', 'Save 3'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpBorder:FlxTypedGroup<FlxSprite>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var saveFile = 0;

	public static function saveData1() {
		FlxG.save.data.area1 = RPGState.area;
		FlxG.save.data.areaName1 = RPGState.areaName;
		FlxG.save.data.BFX1 = RPGState.bfLocationX;
		FlxG.save.data.BFY1 = RPGState.bfLocationY;
		FlxG.save.data.DB1 = RPGState.didBlooky;
		FlxG.save.data.DD1 = RPGState.didDummy;
		FlxG.save.data.DFl1 = RPGState.didFlowey;
		FlxG.save.data.TF1 = RPGState.followToriel;
		FlxG.save.data.DT1 = RPGState.didToriel;
		FlxG.save.data.Spares1 = RPGState.spares;
		FlxG.save.data.Fights1 = RPGState.fights;
		FlxG.save.data.Ruins1 = RPGState.RuinsCompleted;
	}
	
	public static function loadData1() {
		RPGState.area = FlxG.save.data.area1;
		RPGState.areaName = FlxG.save.data.areaName1;
		RPGState.bfLocationX = FlxG.save.data.BFX1;
		RPGState.bfLocationY = FlxG.save.data.BFY1;
		RPGState.didBlooky = FlxG.save.data.DB1;
		RPGState.didDummy = FlxG.save.data.DD1;
		RPGState.didFlowey = FlxG.save.data.DFl1;
		RPGState.followToriel= FlxG.save.data.TF1;
		RPGState.didToriel = FlxG.save.data.DT1;
		RPGState.spares = FlxG.save.data.Spares1;
		RPGState.fights = FlxG.save.data.Fights1;
		RPGState.RuinsCompleted = FlxG.save.data.Ruins1;
		
	}

	public static function saveData2() {
		FlxG.save.data.area2 = RPGState.area;
		FlxG.save.data.areaName2 = RPGState.areaName;
		FlxG.save.data.BFX2 = RPGState.bfLocationX;
		FlxG.save.data.BFY2 = RPGState.bfLocationY;
		FlxG.save.data.DD2 = RPGState.didDummy;
		FlxG.save.data.DB2 = RPGState.didBlooky;
		FlxG.save.data.DFl2 = RPGState.didFlowey;
		FlxG.save.data.TF2 = RPGState.followToriel;
		FlxG.save.data.DT2 = RPGState.didToriel;
		FlxG.save.data.Spares2 = RPGState.spares;
		FlxG.save.data.Fights2 = RPGState.fights;
		FlxG.save.data.Ruins2 = RPGState.RuinsCompleted;
		FlxG.save.flush();
	}
	public static function loadData2() {
		RPGState.area = FlxG.save.data.area2;
		RPGState.areaName = FlxG.save.data.areaName2;
		RPGState.bfLocationX = FlxG.save.data.BFX2;
		RPGState.bfLocationY = FlxG.save.data.BFY2;
		RPGState.didDummy = FlxG.save.data.DD2;
		RPGState.didBlooky = FlxG.save.data.DB2;
		RPGState.didFlowey = FlxG.save.data.DFl2;
		RPGState.followToriel= FlxG.save.data.TF2;
		RPGState.didToriel = FlxG.save.data.DT2;
		RPGState.spares = FlxG.save.data.Spares2;
		RPGState.fights = FlxG.save.data.Fights2;
		RPGState.RuinsCompleted = FlxG.save.data.Ruins2;
		
	}

	public static function saveData3() {
		FlxG.save.data.area3 = RPGState.area;
		FlxG.save.data.areaName3 = RPGState.areaName;
		FlxG.save.data.BFX3 = RPGState.bfLocationX;
		FlxG.save.data.BFY3 = RPGState.bfLocationY;
		FlxG.save.data.DD3 = RPGState.didDummy;
		FlxG.save.data.DB3 = RPGState.didBlooky;
		FlxG.save.data.DFl3 = RPGState.didFlowey;
		FlxG.save.data.TF3 = RPGState.followToriel;
		FlxG.save.data.DT3 = RPGState.didToriel;
		FlxG.save.data.Spares3 = RPGState.spares;
		FlxG.save.data.Fights3 = RPGState.fights;
		FlxG.save.data.Ruins3 = RPGState.RuinsCompleted;
		FlxG.save.flush();
	}
	public static function loadData3() {
		RPGState.area = FlxG.save.data.area3;
		RPGState.areaName = FlxG.save.data.areaName3;
		RPGState.bfLocationX = FlxG.save.data.BFX3;
		RPGState.didDummy = FlxG.save.data.DD3;
		RPGState.bfLocationY = FlxG.save.data.BFY3;
		RPGState.didBlooky = FlxG.save.data.DB3;
		RPGState.didFlowey = FlxG.save.data.DFl3;
		RPGState.followToriel= FlxG.save.data.TF3;
		RPGState.didToriel = FlxG.save.data.DT3;
		RPGState.spares = FlxG.save.data.Spares3;
		RPGState.fights = FlxG.save.data.Fights3;
		RPGState.RuinsCompleted = FlxG.save.data.Ruins3;
	}

	public static function reset1(){
		FlxG.save.data.area1 = "Ruins1";
		FlxG.save.data.areaName1 = "The Beginning";
		FlxG.save.data.BFX1 = 1121;
		FlxG.save.data.BFY1 = 1080;
		FlxG.save.data.DB1 = false;
		FlxG.save.data.DD1 = false;
		FlxG.save.data.DFl1 = false;
		FlxG.save.data.TF1 = false;
		FlxG.save.data.DT1 = false;
		FlxG.save.data.Spares1 = 0;
		FlxG.save.data.Fights1 = 0;
		FlxG.save.data.Ruins1 = false;
		FlxG.save.flush();
	}

	public static function reset2(){
		FlxG.save.data.area2 = "Ruins1";
		FlxG.save.data.areaName2 = "The Beginning";
		FlxG.save.data.BFX2 = 1121;
		FlxG.save.data.BFY2 = 1080;
		FlxG.save.data.DD2 = false;
		FlxG.save.data.DB2 = false;
		FlxG.save.data.DFl2 = false;
		FlxG.save.data.TF2 = false;
		FlxG.save.data.DT2 = false;
		FlxG.save.data.Spares2 = 0;
		FlxG.save.data.Fights2 = 0;
		FlxG.save.data.Ruins2 = false;
		FlxG.save.flush();
	}

	public static function reset3(){
		FlxG.save.data.area3 = "Ruins1";
		FlxG.save.data.areaName3 = "The Beginning";
		FlxG.save.data.BFX3 = 1121;
		FlxG.save.data.BFY3 = 1080;
		FlxG.save.data.DD3 = false;
		FlxG.save.data.DB3 = false;
		FlxG.save.data.DFl3 = false;
		FlxG.save.data.TF3 = false;
		FlxG.save.data.DT3 = false;
		FlxG.save.data.Spares3 = 0;
		FlxG.save.data.Fights3 = 0;
		FlxG.save.data.Ruins3 = false;
		FlxG.save.flush();
	}

	public function setDefaultSaves() {
		trace("DidDefaults!");
		if (FlxG.save.data.area1 == null)
		{
			reset1();
		}
		if (FlxG.save.data.area2 == null)
		{
			reset2();
		}
		if (FlxG.save.data.area3 == null)
		{
			reset3();
		}
	}


	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.2));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);
		FlxG.sound.playMusic(Paths.music('menuMusic'), 1);

		grpOptions = new FlxTypedGroup<Alphabet>();
		grpBorder = new FlxTypedGroup<FlxSprite>();
		setDefaultSaves();

		for (i in 0...options.length)
		{
			var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('resetBorder'));
			border.screenCenter();
			border.setGraphicSize(Std.int(border.width*1.4));
			border.y += (180 * (i - (options.length / 2))) + 50;
			grpBorder.add(border);

			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (180 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
		add(grpBorder);
		add(grpOptions);
		changeSelection();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}


		if (controls.ACCEPT) {
			for (item in grpOptions.members) {
				item.alpha = 0;
			}
			for (item in grpBorder.members) {
				item.alpha = 0;
			}

			switch(options[curSelected]) {
				case 'Save 1':
					openSubState(new LoadSubState());
					RPGLoadingSaveState.saveFile = 1;

				case 'Save 2':
					openSubState(new LoadSubState());
					RPGLoadingSaveState.saveFile = 2;

				case 'Save 3':
					openSubState(new LoadSubState());
					RPGLoadingSaveState.saveFile = 3;
			}

		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpBorder.members) {
			item.alpha = 1;
		}
		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}
}





class LoadSubState extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	public var switched:Bool = false;
	static var options:Array<String> = [
		'LOAD',
		'RESET'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var showCharacter:Character = null;
	private var descText:FlxText;

	public function new()
	{
		super();
		// avoids lagspikes while scrolling through menus!
		switched = true;
		showCharacter = new Character(840, 170, 'bf', true);
		showCharacter.setGraphicSize(Std.int(showCharacter.width * 0.8));
		showCharacter.updateHitbox();
		showCharacter.dance();
		add(showCharacter);
		showCharacter.visible = false;

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var isCentered:Bool = false;
			var optionText:Alphabet = new Alphabet(0, (30 * i), options[i], true, false, 0.05, .7);
			

			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			} else {
				optionText.x += 50;
				optionText.forceX = 300;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				var valueText:AttachedText = new AttachedText('', optionText.width);
				valueText.sprTracker = optionText;
				grpTexts.add(valueText);
				textNumber.push(i);
			}
		}

		descText = new FlxText(50, 500, 1180, "", 32);
		descText.screenCenter();
		descText.setFormat(Paths.font("undertale.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.ORANGE);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		changeSelection();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (nextAccept == 1)
		{
			changeSelection();
		}
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK) {
			grpOptions.forEachAlive(function(spr:Alphabet) {
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText) {
				spr.alpha = 0;
			});
			if(showCharacter != null) {
				showCharacter.alpha = 0;
			}
			descText.alpha = 0;
			RPGLoadingSaveState.saveFile = 0;
			switched = false;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}


		if (controls.ACCEPT && nextAccept <= 0) {
			if(switched)
			{
			for (item in grpOptions.members) {
				item.alpha = 0;
			}
			switch(options[curSelected]) {
				case 'LOAD':
					RPGState.saveIndex = RPGLoadingSaveState.saveFile;
					switch (RPGLoadingSaveState.saveFile)
					{
						case 1:
							RPGLoadingSaveState.loadData1();
						case 2:
							RPGLoadingSaveState.loadData2();
						case 3:
							RPGLoadingSaveState.loadData3();
					}
					FlxG.sound.music.stop();
					RPGState.triggerMusic = true;
					MusicBeatState.switchState(new RPGState());
				case 'RESET':
					switch (RPGLoadingSaveState.saveFile)
					{
						case 1:
							RPGLoadingSaveState.reset1();
						case 2:
							RPGLoadingSaveState.reset2();
						case 3:
							RPGLoadingSaveState.reset3();
					}
					changeSelection();
			}
			}
		}



		if(showCharacter != null && showCharacter.animation.curAnim.finished) {
			showCharacter.dance();
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
		{
			curSelected = options.length - 1;
		}
		if (curSelected >= options.length)
		{
			curSelected = 0;
		}


		var daText:String = "...";
		if (RPGLoadingSaveState.saveFile == 1)
		{
			daText = 'Area: ' + FlxG.save.data.areaName1 + '\n' + 'Spares: ' + FlxG.save.data.Spares1 + '\n' + 'Fights: ' + FlxG.save.data.Fights1;
		}
		if (RPGLoadingSaveState.saveFile == 2)
		{
			daText = 'Area: ' + FlxG.save.data.areaName2 + '\n' + 'Spares: ' + FlxG.save.data.Spares2 + '\n' + 'Fights: ' + FlxG.save.data.Fights2;
		}
		if (RPGLoadingSaveState.saveFile == 3)
		{
			daText = 'Area: ' + FlxG.save.data.areaName3 + '\n' + 'Spares: ' + FlxG.save.data.Spares3 + '\n' + 'Fights: ' + FlxG.save.data.Fights3;
		}

		
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

		}
		for (text in grpOptions.members) {
			text.alpha = 0.5;
			if(grpOptions.members.indexOf(text) == curSelected) {
				text.alpha = 1;
			}
			
		}

		showCharacter.visible = (options[curSelected] == 'Anti-Aliasing');
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}


