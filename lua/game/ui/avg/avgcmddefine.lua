local E = require("Game.UI.Avg.AvgCmdEnum")
local P = require("Game.UI.Avg.AvgCmdParamOptionDefine")
local ST, BB, BT, CG, PM, GD, DP = E.ConfigType.ST, E.ConfigType.BB, E.ConfigType.BT, E.ConfigType.CG, E.ConfigType.PM, E.ConfigType.GD, E.ConfigType.DP
local stage, character, talk, phone, bubble, choice, audio, etc = E.Category.stage, E.Category.character, E.Category.talk, E.Category.phone, E.Category.bubble, E.Category.choice, E.Category.audio, E.Category.etc
local blue, gray, green, pink, purpel, white, yellow, cyan = E.BgColor.blue, E.BgColor.gray, E.BgColor.green, E.BgColor.pink, E.BgColor.purpel, E.BgColor.white, E.BgColor.yellow, E.BgColor.cyan
local bol, num, str = E.ParamType.bol, E.ParamType.num, E.ParamType.str
local ddIdx, ddVal, iptStr, iptNum, idChar, idContact, idRes = E.ParamInputType.ddIdx, E.ParamInputType.ddVal, E.ParamInputType.iptStr, E.ParamInputType.iptNum, E.ParamInputType.idChar, E.ParamInputType.idContact, E.ParamInputType.idRes
local AvgCmdDefine = {
	SetBg = {
		allow = {ST, CG},
		category = stage,
		color = gray,
		name = "\229\136\135\230\141\162\232\131\140\230\153\175",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				str,
				"",
				idRes,
				"BgCgFgResName",
				"\230\150\176\229\155\190\229\144\141\229\173\151"
			},
			{
				str,
				"",
				idRes,
				"BgEffectResName",
				"\230\151\167\229\155\190\230\183\161\229\135\186\230\149\136\230\158\156\229\155\190"
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				str,
				"",
				ddVal,
				"TransKeys",
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.BgFg,
				nil
			}
		}
	},
	CtrlBg = {
		allow = {ST, CG},
		category = stage,
		color = gray,
		name = "\230\142\167\229\136\182\232\131\140\230\153\175",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\129\176\230\128\129"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\233\128\143\230\152\142"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\152\142\230\154\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\168\161\231\179\138"
			},
			{
				str,
				"",
				ddVal,
				"BgShakeTypeKeys",
				nil
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.BgFg,
				nil
			}
		}
	},
	SetStage = {
		allow = {ST, CG},
		category = stage,
		color = blue,
		name = "\232\174\190\231\189\174\232\136\158\229\143\176",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.SubStages,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.SubStageInOutAnim,
				nil
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	CtrlStage = {
		allow = {ST, CG},
		category = stage,
		color = blue,
		name = "\230\142\167\229\136\182\232\136\158\229\143\176",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\129\176\230\128\129"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\152\142\230\154\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\168\161\231\179\138"
			},
			{
				str,
				"",
				ddVal,
				"BgShakeTypeKeys",
				nil
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetFx = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = stage,
		color = gray,
		name = "\232\136\158\229\143\176\231\137\185\230\149\136",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				str,
				"",
				idRes,
				"FxNames",
				"\231\137\185\230\149\136\232\181\132\230\186\144\229\144\141"
			},
			{
				num,
				0,
				ddIdx,
				P.NewDel,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.FxPos,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				bol,
				true,
				ddIdx,
				P.OnOffPP_,
				nil
			}
		}
	},
	SetFrontObj = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = stage,
		color = gray,
		name = "\229\137\141\230\153\175\231\137\169\228\187\182",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.NewDel,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.Mask_,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\155\190\231\137\135\229\144\141\229\173\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetFilm = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = stage,
		color = gray,
		name = "\231\148\181\229\189\177\230\168\161\229\188\143",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.InOut,
				nil
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetTrans = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = stage,
		color = gray,
		name = "\232\189\172\229\156\186",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Trans,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.TransStyle,
				nil
			},
			{
				str,
				"",
				idRes,
				"BgEffectResName",
				"\232\189\172\229\156\186\230\149\136\230\158\156\229\155\190"
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				bol,
				false,
				ddIdx,
				P.ClrChar,
				nil
			},
			{
				bol,
				false,
				ddIdx,
				P.ClrTalk,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				str,
				"",
				ddVal,
				"TransKeys",
				nil
			}
		}
	},
	SetHeartBeat = {
		allow = {ST, CG},
		category = stage,
		color = gray,
		name = "\229\143\141\232\137\178\229\191\131\232\183\179",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\228\184\173\229\191\131\231\130\185Y"
			},
			{
				num,
				0.75,
				nil,
				nil,
				nil
			}
		}
	},
	SetPP = {
		allow = {ST, CG},
		category = stage,
		color = gray,
		name = "\229\136\134\233\149\156\229\144\142\230\156\159",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.SubStages,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.OnOffPP,
				nil
			}
		}
	},
	SetPPGlobal = {
		allow = {ST, CG},
		category = stage,
		color = gray,
		name = "\229\133\168\229\177\128\229\186\148\231\148\168\229\144\142\230\156\159",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.PPApplyAll,
				nil
			}
		}
	},
	SetChar = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\232\174\190\231\189\174\232\167\146\232\137\178",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.InOut,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.Stages,
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharEnterExitKeys",
				nil
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\171\153\228\189\141\233\161\186\229\186\143"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\129\176\230\128\129"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\152\142\230\154\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\233\128\143\230\152\142"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\168\161\231\179\138"
			}
		}
	},
	CtrlChar = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\230\142\167\229\136\182\232\167\146\232\137\178",
		preview = true,
		param = {
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\171\153\228\189\141\233\161\186\229\186\143"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\129\176\230\128\129"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\152\142\230\154\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\233\128\143\230\152\142"
			},
			{
				str,
				"",
				ddVal,
				"CharShakeTypeKeys",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharFadeEft",
				nil
			},
			{
				str,
				"",
				ddVal,
				P.Eases,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.CharRot,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"Z\232\189\180\232\189\172\232\167\146"
			},
			{
				bol,
				false,
				ddIdx,
				P.ExitWileDone,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\168\161\231\179\138"
			}
		}
	},
	PlayCharAnim = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\232\167\146\232\137\178\229\138\168\231\148\187",
		preview = true,
		param = {
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\138\168\231\148\187\229\144\141"
			},
			{
				bol,
				false,
				ddIdx,
				P.ExitWileDone,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetCharHead = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\232\174\190\231\189\174\229\164\180\229\131\143\230\161\134",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.InOut,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.CharHeadFramePos,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.CharHeadFrameBg,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\129\176\230\128\129"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\152\142\230\154\151"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\233\128\143\230\152\142"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\230\168\161\231\179\138"
			}
		}
	},
	CtrlCharHead = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\230\142\167\229\136\182\229\164\180\229\131\143\230\161\134",
		preview = true,
		param = {
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.CharHeadFrameBg,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetL2D = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\232\174\190\231\189\174L2D",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.NewDel,
				nil
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	CtrlL2D = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = character,
		color = purpel,
		name = "\230\142\167\229\136\182L2D",
		preview = false,
		param = {
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\138\168\231\148\187\229\144\141"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\146\232\137\178\232\175\173\233\159\179"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetTalk = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = talk,
		color = green,
		name = "\229\175\185\232\175\157",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.TalkType,
				nil
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			},
			{
				num,
				1,
				ddIdx,
				P.ClrPageType,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\146\232\137\178\232\175\173\233\159\179"
			},
			{
				bol,
				false,
				ddIdx,
				P.WaitAudioDone,
				nil
			}
		}
	},
	SetTalkShake = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = talk,
		color = green,
		name = "\230\138\150\229\138\168\229\175\185\232\175\157\230\161\134",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.TalkFrameType,
				nil
			},
			{
				str,
				"",
				ddVal,
				"BgShakeTypeKeys",
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetGoOn = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = talk,
		color = green,
		name = "\231\187\173\230\146\173\229\175\185\232\175\157",
		preview = false,
		param = {}
	},
	SetMainRoleTalk = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = talk,
		color = green,
		name = "\228\184\187\232\167\146\232\175\180\230\131\179-\230\142\167\229\136\182\229\164\180\229\131\143",
		preview = true,
		param = {
			{
				num,
				0,
				ddIdx,
				P.MainRoleHead,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.Mask,
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_1",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharShakeTypeKeys",
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				true,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetPhone = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\229\138\168\231\148\187",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.PhoneAnim,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.ClrHistoryMsg,
				nil
			},
			{
				str,
				"",
				idContact,
				"AvgContacts",
				nil
			}
		}
	},
	SetPhoneMsg = {
		allow = {
			ST,
			BT,
			CG,
			PM,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\230\182\136\230\129\175",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.MsgType,
				nil
			},
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			},
			{
				str,
				"",
				ddIdx,
				P.PicEmoji,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\146\232\137\178\232\175\173\233\159\179"
			},
			{
				bol,
				false,
				ddIdx,
				P.WaitAudioDone,
				nil
			}
		}
	},
	SetPhoneThinking = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\230\128\157\232\128\131",
		preview = false,
		param = {
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			}
		}
	},
	SetPhoneMsgChoiceBegin = {
		allow = {
			ST,
			BT,
			CG,
			PM,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\233\128\137\233\161\185\229\188\128\229\167\139",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185 A \231\154\132\229\134\133\229\174\185..."
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185 B \231\154\132\229\134\133\229\174\185..."
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185 C \231\154\132\229\134\133\229\174\185..."
			}
		}
	},
	SetPhoneMsgChoiceEnd = {
		allow = {
			ST,
			BT,
			CG,
			PM,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\233\128\137\233\161\185\231\187\147\230\157\159",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetPhoneMsgChoiceJumpTo = {
		allow = {
			ST,
			BT,
			CG,
			PM,
			GD
		},
		category = phone,
		color = cyan,
		name = "\230\137\139\230\156\186\233\128\137\233\161\185\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\233\128\137\233\161\185\231\180\162\229\188\149"
			}
		}
	},
	SetBubbleUIType = {
		allow = {BB},
		category = bubble,
		color = green,
		name = "\230\176\148\230\179\161\230\160\183\229\188\143",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.BubbleType,
				nil
			}
		}
	},
	SetBubble = {
		allow = {BB},
		category = bubble,
		color = green,
		name = "\230\176\148\230\179\161\229\175\185\232\175\157",
		preview = false,
		param = {
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			},
			{
				num,
				0,
				ddIdx,
				P.LR,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\146\232\137\178\232\175\173\233\159\179\229\144\141"
			}
		}
	},
	SetChoiceBegin = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\233\128\137\233\161\185\229\188\128\229\167\139",
		preview = true,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				ddIdx,
				P.Mask_,
				nil
			},
			{
				{
					num,
					0,
					ddIdx,
					P.ChoiceVisible,
					nil
				},
				{
					num,
					0,
					ddIdx,
					P.ChoiceVisible,
					nil
				},
				{
					num,
					0,
					ddIdx,
					P.ChoiceVisible,
					nil
				},
				{
					num,
					0,
					ddIdx,
					P.ChoiceVisible,
					nil
				}
			},
			{
				{
					str,
					"",
					iptStr,
					nil,
					"\233\128\137\233\161\185 A \231\154\132\229\134\133\229\174\185..."
				},
				{
					str,
					"",
					iptStr,
					nil,
					"\233\128\137\233\161\185 B \231\154\132\229\134\133\229\174\185..."
				},
				{
					str,
					"",
					iptStr,
					nil,
					"\233\128\137\233\161\185 C \231\154\132\229\134\133\229\174\185..."
				},
				{
					str,
					"",
					iptStr,
					nil,
					"\233\128\137\233\161\185 D \231\154\132\229\134\133\229\174\185..."
				}
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceSide,
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceRole,
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			}
		}
	},
	SetChoiceJumpTo = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\233\128\137\233\161\185\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\233\128\137\233\161\185\231\180\162\229\188\149"
			}
		}
	},
	SetChoiceRollback = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\233\128\137\233\161\185\232\191\148\229\155\158",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceRet,
				nil
			}
		}
	},
	SetChoiceRollover = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\233\128\137\233\161\185\232\183\179\229\135\186",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetChoiceEnd = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\233\128\137\233\161\185\231\187\147\230\157\159",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetMajorChoice = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\232\183\175\231\186\191\233\128\137\233\161\185",
		preview = true,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185A\229\155\190\230\160\135"
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceBG,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"A\230\160\135\233\162\152"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"A\230\143\143\232\191\176"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\163\233\148\129\230\157\161\228\187\182Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\129\230\141\174Id"
			},
			{
				num,
				0,
				ddIdx,
				P.ForceMajorDisable,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185B\229\155\190\230\160\135"
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceBG,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"B\230\160\135\233\162\152"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"B\230\143\143\232\191\176"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\163\233\148\129\230\157\161\228\187\182Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\129\230\141\174Id"
			},
			{
				num,
				0,
				ddIdx,
				P.ForceMajorDisable,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\128\137\233\161\185C\229\155\190\230\160\135"
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceBG,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"C\230\160\135\233\162\152"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"C\230\143\143\232\191\176"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\167\163\233\148\129\230\157\161\228\187\182Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\129\230\141\174Id"
			},
			{
				num,
				0,
				ddIdx,
				P.ForceMajorDisable,
				nil
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\173\233\159\179\232\181\132\230\186\144"
			}
		}
	},
	SetMajorChoiceJumpTo = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\232\183\175\231\186\191\233\128\137\233\161\185\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\233\128\137\233\161\185\231\180\162\229\188\149"
			}
		}
	},
	SetMajorChoiceRollover = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\232\183\175\231\186\191\233\128\137\233\161\185\232\183\179\229\135\186",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetMajorChoiceEnd = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\232\183\175\231\186\191\233\128\137\233\161\185\231\187\147\230\157\159",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetPersonalityChoice = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\230\128\167\230\160\188\233\128\137\233\161\185",
		preview = true,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\229\128\141\231\142\135\231\179\187\230\149\176"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\231\155\180\232\167\137\233\128\137\233\161\185\231\154\132\232\161\140\228\184\186\230\150\135\229\173\151"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\136\134\230\158\144\233\128\137\233\161\185\231\154\132\232\161\140\228\184\186\230\150\135\229\173\151"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\183\183\230\178\140\233\128\137\233\161\185\231\154\132\232\161\140\228\184\186\230\150\135\229\173\151"
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				str,
				"",
				ddVal,
				"CharEmoji",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\180\232\175\157\229\134\133\229\174\185"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\232\175\173\233\159\179\232\181\132\230\186\144"
			}
		}
	},
	SetPersonalityChoiceJumpTo = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\230\128\167\230\160\188\233\128\137\233\161\185\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\233\128\137\233\161\185\231\180\162\229\188\149"
			}
		}
	},
	SetPersonalityChoiceRollover = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\230\128\167\230\160\188\233\128\137\233\161\185\232\183\179\229\135\186",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetPersonalityChoiceEnd = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\230\128\167\230\160\188\233\128\137\233\161\185\231\187\147\230\157\159",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\231\187\132Id"
			}
		}
	},
	IfTrue = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\229\166\130\230\158\156",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"'\229\166\130\230\158\156'\230\140\135\228\187\164\231\154\132\231\187\132Id"
			},
			{
				num,
				0,
				ddIdx,
				P.ChoiceMP,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\188\148\229\135\186\233\133\141\231\189\174AvgId"
			},
			{
				num,
				0,
				iptNum,
				nil,
				"\233\128\137\233\161\185\231\154\132\231\187\132Id"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\156\128\232\191\145\228\184\128\230\172\161\233\128\137\230\139\169"
			}
		}
	},
	EndIf = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = choice,
		color = yellow,
		name = "\231\187\147\230\157\159\229\166\130\230\158\156",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"'\229\166\130\230\158\156'\230\140\135\228\187\164\231\154\132\231\187\132Id"
			}
		}
	},
	SetAudio = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = audio,
		color = pink,
		name = "\233\159\179\230\149\136",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.Audio,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\233\159\179\230\149\136\229\144\141"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				false,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetBGM = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = audio,
		color = pink,
		name = "BGM",
		preview = false,
		param = {
			{
				num,
				0,
				ddIdx,
				P.BGM_Play,
				nil
			},
			{
				str,
				"",
				ddVal,
				"BgmVol",
				nil
			},
			{
				num,
				0,
				ddIdx,
				P.BGM_Track,
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"BGM"
			},
			{
				str,
				"",
				ddVal,
				P.BgmFadeTime,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				false,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetSceneHeading = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\230\151\182\233\151\180\229\156\176\231\130\185",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\230\151\182\233\151\180"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\156\136\228\187\189"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\151\165\230\156\159"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\228\184\187\232\166\129\229\156\176\231\130\185"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\172\161\232\166\129\229\156\176\231\130\185"
			}
		}
	},
	Wait = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\231\173\137\229\190\133",
		preview = false,
		param = {
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			}
		}
	},
	Jump = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				num,
				0,
				iptNum,
				nil,
				"\232\183\179\232\189\172\232\135\179id"
			}
		}
	},
	Clear = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\230\184\133\229\156\186",
		preview = false,
		param = {
			{
				bol,
				false,
				ddIdx,
				P.ClrChar,
				nil
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\128\151\230\151\182"
			},
			{
				bol,
				false,
				ddIdx,
				P.ClrTalk,
				nil
			},
			{
				bol,
				false,
				ddIdx,
				P.Wait,
				nil
			}
		}
	},
	SetGroupId = {
		allow = {
			BB,
			PM,
			DP
		},
		category = bubble,
		color = green,
		name = "\230\176\148\230\179\161\231\187\132",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\231\187\132Id"
			}
		}
	},
	SetIntro = {
		allow = {
			ST,
			BT,
			CG
		},
		category = etc,
		color = gray,
		name = "\232\174\190\231\189\174\230\162\151\230\166\130",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\229\155\190\230\160\135\232\181\132\230\186\144\229\144\141"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\160\135\233\162\152\239\188\154\231\172\172\228\184\128\232\175\157"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\144\141\229\173\151\239\188\154\233\130\130\233\128\133"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\230\162\151\230\166\130\229\134\133\229\174\185"
			}
		}
	},
	JUMP_AVG_ID = {
		allow = {
			ST,
			BT,
			CG
		},
		category = etc,
		color = gray,
		name = "AVG ID\232\183\179\232\189\172",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\232\183\179\232\189\172\232\135\179 AVG Id"
			},
			{
				num,
				1,
				iptNum,
				nil,
				"\232\183\179\232\189\172\232\135\179\230\140\135\228\187\164 Id"
			}
		}
	},
	NewCharIntro = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\230\150\176\232\167\146\231\153\187\229\156\186",
		preview = false,
		param = {
			{
				str,
				"",
				idChar,
				"AvgCharacter",
				nil
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\229\144\141\229\173\151"
			},
			{
				str,
				"",
				iptStr,
				nil,
				"\231\167\176\229\143\183"
			},
			{
				str,
				"",
				ddVal,
				"CharPose_0",
				nil
			},
			{
				str,
				"002",
				iptStr,
				nil,
				"\232\132\184"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185X"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\229\157\144\230\160\135\231\130\185Y"
			},
			{
				num,
				nil,
				iptNum,
				nil,
				"\231\188\169\230\148\190"
			},
			{
				num,
				0,
				ddIdx,
				P.NewCharAnim,
				nil
			}
		}
	},
	Comment = {
		allow = {
			ST,
			BT,
			CG,
			GD
		},
		category = etc,
		color = gray,
		name = "\229\164\135\230\179\168",
		preview = false,
		param = {
			{
				str,
				"",
				iptStr,
				nil,
				"\229\164\135\230\179\168\229\134\133\229\174\185"
			}
		}
	},
	End = {
		allow = {
			ST,
			BB,
			BT,
			CG,
			PM,
			GD
		},
		category = etc,
		color = gray,
		name = "<color=red>\231\187\147\230\157\159</color>",
		preview = false
	}
}
local bLog = false
local num_Params, num_ddIdx, num_ddVal, num_iptStr, num_iptNum, num_idChar, num_idContact, num_idRes, sCmdName = 0, 0, 0, 0, 0, 0, 0, 0
for k, v in pairs(AvgCmdDefine) do
	local tbParam = v.param
	if tbParam ~= nil then
		local n = #tbParam
		if num_Params < n then
			sCmdName = k
			num_Params = n
		end
		local n_ddIdx, n_ddVal, n_iptStr, n_iptNum, n_idChar, n_idContact, n_idRes = 0, 0, 0, 0, 0, 0, 0
		for ii, vv in ipairs(tbParam) do
			if vv[3] == ddIdx then
				n_ddIdx = n_ddIdx + 1
				if num_ddIdx < n_ddIdx then
					num_ddIdx = n_ddIdx
				end
			elseif vv[3] == ddVal then
				n_ddVal = n_ddVal + 1
				if num_ddVal < n_ddVal then
					num_ddVal = n_ddVal
				end
			elseif vv[3] == iptStr then
				n_iptStr = n_iptStr + 1
				if num_iptStr < n_iptStr then
					num_iptStr = n_iptStr
				end
			elseif vv[3] == iptNum then
				n_iptNum = n_iptNum + 1
				if num_iptNum < n_iptNum then
					num_iptNum = n_iptNum
				end
			elseif vv[3] == idChar then
				n_idChar = n_idChar + 1
				if num_idChar < n_idChar then
					num_idChar = n_idChar
				end
			elseif vv[3] == idContact then
				n_idContact = n_idContact + 1
				if num_idContact < n_idContact then
					num_idContact = n_idContact
				end
			elseif vv[3] == idRes then
				n_idRes = n_idRes + 1
				if num_idRes < n_idRes then
					num_idRes = n_idRes
				end
			end
			if #vv > 5 and bLog == true then
				print("\230\140\135\228\187\164\229\143\130\230\149\176\231\154\132\230\143\143\232\191\176\232\182\133\232\191\1354\233\161\185 " .. k .. " " .. ii)
			end
		end
	end
end
if bLog == true then
	print(string.format("\230\137\128\230\156\137\230\140\135\228\187\164\228\184\173\239\188\140\229\143\130\230\149\176\230\156\128\229\164\154\231\154\132\230\140\135\228\187\164\230\152\175\239\188\154%s\239\188\140\229\143\130\230\149\176\230\156\137\239\188\154%s\228\184\170", sCmdName, num_Params))
	print("ddIdx \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_ddIdx))
	print("ddVal \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_ddVal))
	print("iptStr \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_iptStr))
	print("iptNum \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_iptNum))
	print("idChar \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_idChar))
	print("idRes \231\177\187\229\143\130\230\149\176\229\156\168\228\184\128\228\184\170\230\140\135\228\187\164\228\184\173\230\156\128\229\164\154\229\135\186\231\142\176\228\184\170\230\149\176\239\188\154" .. tostring(num_idRes))
end
return AvgCmdDefine, {
	num_ddIdx,
	num_ddVal,
	num_iptStr,
	num_iptNum,
	num_idChar,
	num_idContact,
	num_idRes
}
