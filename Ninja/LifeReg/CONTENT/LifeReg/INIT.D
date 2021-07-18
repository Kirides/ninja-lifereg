const string NINJA_LIFEREG_VERSION = "LifeReg v1.2.0";

const string NINJA_LIFEREG_INI = "NINJA_LIFEREG";
const string NINJA_LIFEREG_INI_TICKRATE = "TICKRATE";
const string NINJA_LIFEREG_INI_PERMILLE = "PERMILLE";
const string NINJA_LIFEREG_INI_ALLOW_INFIGHT = "INFIGHT";
const string NINJA_LIFEREG_INI_IN_FIGHT_PERCENT = "IN_FIGHT_PERCENT";

const int Ninja_LifeReg_TickRate = 0;
const int Ninja_LifeReg_Permille = 0;
const int Ninja_LifeReg_Permille_InFight = 0;
const int Ninja_LifeReg_SumMenge = 0;
const int Ninja_LifeReg_AllowInFight = 0;

/// This function is based on mud-freak's work in [Autosave Patch](https://forum.worldofplayers.de/forum/threads/1560461-Patch-Autosave).
func int Ninja_LifeReg_IsInFight() {
    /*
        Not in fight or during threat
        oHERO_STATUS_STD = 0 // Default
        oHERO_STATUS_THR = 1 // Threatened
        oHERO_STATUS_FGT = 2 // In Fight
     */
    const int oCZoneMusic__s_herostatus_G1 =  9299208; //0x8DE508
    const int oCZoneMusic__s_herostatus_G2 = 10111520; //0x9A4A20
    if (MEM_ReadInt(MEMINT_SwitchG1G2(oCZoneMusic__s_herostatus_G1, oCZoneMusic__s_herostatus_G2))) {
        return 1;
    };
    return 0;
};

func void Ninja_LifeReg_Regeneration() {
	// Only when allowed
	const int isInFight = 0; isInFight = Ninja_LifeReg_IsInFight();
	if (!Ninja_LifeReg_AllowInFight) {
		if (isInFight) { return; };
	};

	if (hero.attribute[ATR_HITPOINTS] < hero.attribute[ATR_HITPOINTS_MAX] && (hero.attribute[ATR_HITPOINTS] != 0)) {
		var int heroHpMax; heroHpMax = mkf(hero.attribute[ATR_HITPOINTS_MAX]);
		var int menge;
		if (isInFight && Ninja_LifeReg_Permille_InFight) {
			menge = mulf(heroHpMax, Ninja_LifeReg_Permille_InFight);
		} else {
			menge = mulf(heroHpMax, Ninja_LifeReg_Permille);
		};
		Ninja_LifeReg_SumMenge = addf(Ninja_LifeReg_SumMenge, menge);

		menge = truncf(Ninja_LifeReg_SumMenge);
		if (menge < 1) { return; };

		Npc_ChangeAttribute(hero, ATR_HITPOINTS, menge);
		Ninja_LifeReg_SumMenge = subf(Ninja_LifeReg_SumMenge, mkf(menge));
	};
};

func string Ninja_LifeReg_GothOpt(var string section, var string option, var string default) {
	if (!MEM_GothOptExists(section, option)) {
		MEM_SetGothOpt(section, option, default);
		return default;
	};
	var string opt; opt = MEM_GetGothOpt(section, option);
	return opt;
};

/// Reads information from INI and sets some constants for use in this patch.
func void Ninja_LifeReg_ApplyINI() {
	var string ini_tickrate; ini_tickrate = Ninja_LifeReg_GothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_TICKRATE, "1000");
	var string ini_permille; ini_permille = Ninja_LifeReg_GothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_PERMILLE, "3");
	var string ini_inFight;  ini_inFight  = Ninja_LifeReg_GothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_ALLOW_INFIGHT, "0");
	var string ini_InFightPercent; ini_InFightPercent = Ninja_LifeReg_GothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_IN_FIGHT_PERCENT, "0");
		
	MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": TICKRATE FROM INI = "), ini_tickrate));
	MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": PERMILLE FROM INI = "), ini_permille));
	MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": INFIGHT FROM INI = "), ini_inFight));
	MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": IN_FIGHT_PERCENT FROM INI = "), ini_InFightPercent));
	
	Ninja_LifeReg_TickRate = STR_ToInt(ini_tickrate);
	Ninja_LifeReg_Permille = STR_ToInt(ini_permille);
	Ninja_LifeReg_AllowInFight = STR_ToInt(ini_inFight);

	Ninja_LifeReg_Permille_InFight = STR_ToInt(ini_InFightPercent);
	if (Ninja_LifeReg_Permille_InFight >= 100) {
		// This combo allows for full regeneration in fight
		Ninja_LifeReg_AllowInFight = 1;
		Ninja_LifeReg_Permille_InFight = 0;

		MEM_SetGothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_IN_FIGHT_PERCENT, "100");
	} else if (Ninja_LifeReg_Permille_InFight <= 0) {
		MEM_SetGothOpt(NINJA_LIFEREG_INI, NINJA_LIFEREG_INI_IN_FIGHT_PERCENT, "0");
		Ninja_LifeReg_Permille_InFight = 0;
		Ninja_LifeReg_AllowInFight = 0;
	};

	Ninja_LifeReg_Permille = divf(mkf(Ninja_LifeReg_Permille), mkf(1000));
	if (Ninja_LifeReg_Permille_InFight) {
		Ninja_LifeReg_Permille_InFight = mulf(Ninja_LifeReg_Permille, divf(mkf(Ninja_LifeReg_Permille_InFight), mkf(100)));
	};
	Ninja_LifeReg_SumMenge = FLOATNULL;
};

func void Ninja_LifeReg_SetupRegeneration(var int tickRate) {
    var int hndl;
    if (!hndl) {
        FF_Remove(Ninja_LifeReg_Regeneration); // Remove from previous versions of LifeReg
        FF_ApplyExtGT(Ninja_LifeReg_Regeneration, tickRate, -1);
        hndl = nextHandle;
		MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": " ), "FrameFunction installed"));	
    } else {
        var FFItem ff; ff = get(hndl);
        ff.delay = tickRate;
        ff.next = TimerGT() + ff.delay;
		MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": " ), "FrameFunction updated"));	
    };
};

/// Start/update FrameFunction 
/// ____
/// `on every initialization!`
func void Ninja_LifeReg_Init_Internal() {
	// Initialize Ikarus
	MEM_InitAll();
	Lego_MergeFlags(LeGo_FrameFunctions);

	MEM_Info(ConcatStrings(ConcatStrings("Initialize ", NINJA_LIFEREG_VERSION), "."));
	
	const int once = 1;
	if (once) {
		MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": " ), "Applying Gothic.INI."));
		Ninja_LifeReg_ApplyINI();
		MEM_Info(ConcatStrings(ConcatStrings(NINJA_LIFEREG_VERSION, ": " ), "Gothic.INI applied"));	
		once = 0;
	};

	Ninja_LifeReg_SetupRegeneration(Ninja_LifeReg_TickRate);
	Ninja_LifeReg_SumMenge = FLOATNULL;
    MEM_Info(ConcatStrings(NINJA_LIFEREG_VERSION, " was initialized successfully."));
};

