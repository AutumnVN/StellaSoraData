local GameCameraStackManager = CS.GameCameraStackManager.Instance
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local BubbleVoiceManager = require("Game.Actor2D.BubbleVoiceManager")
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
local StarTowerShopCtrl = class("StarTowerShopCtrl", BaseCtrl)
local _, GrayColor = ColorUtility.TryParseHtmlString("#94aac0")
StarTowerShopCtrl._mapNodeConfig = {
	t_fullscreen_blur_blue = {},
	aniBlur = {
		sNodeName = "t_fullscreen_blur_blue",
		sComponentName = "Animator"
	},
	rawImgActor2D = {
		sNodeName = "----Actor2D----",
		sComponentName = "RawImage"
	},
	trActor2D_PNG = {
		sNodeName = "----Actor2D_PNG----",
		sComponentName = "Transform"
	},
	btnActor = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Actor"
	},
	safeAreaRoot = {
		sNodeName = "----SafeAreaRoot----"
	},
	srGoodsList = {
		sComponentName = "LoopScrollView"
	},
	srBgList = {
		sComponentName = "LoopScrollView"
	},
	trGoodsList = {
		sNodeName = "srGoodsList",
		sComponentName = "Transform"
	},
	ButtonBack = {
		sComponentName = "NaviButton",
		callback = "OnBtn_CloseShop"
	},
	btnBag = {
		sComponentName = "NaviButton",
		callback = "OnBtn_Depot"
	},
	goBuyPanel = {},
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Shop_TitleBuy"
	},
	txtPriceCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "Shop_UnitPrice"
	},
	aniBuyPanel = {
		sNodeName = "goBuyPanelAnimRoot",
		sComponentName = "Animator"
	},
	txtGoodsName = {sComponentName = "TMP_Text"},
	imgGoodsTalentBg = {sComponentName = "Image"},
	txtDesc = {sComponentName = "TMP_Text"},
	imgBuyDiscount = {},
	txtBuyDiscount = {
		sComponentName = "TMP_Text",
		sLanguageId = "Shop_Discount"
	},
	imgGoodsIcon = {sComponentName = "Image"},
	imgGoodsCharIcon = {sComponentName = "Image"},
	imgCharEdgeGoods = {},
	imgTickets = {sComponentName = "Image"},
	goBubble = {},
	txtBuy = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "FixedRoguelike_ShopBuy"
	},
	txtCurResume = {sComponentName = "TMP_Text"},
	goOrigin = {},
	txtOrigin = {sComponentName = "TMP_Text"},
	ButtonClose = {
		sComponentName = "UIButton",
		callback = "OnBtn_CloseBuy"
	},
	ButtonConfirm = {
		sComponentName = "NaviButton",
		callback = "OnBtn_Confirm",
		sAction = "Confirm"
	},
	btnShortcutClose = {
		sComponentName = "NaviButton",
		callback = "OnBtn_CloseBuy"
	},
	sv = {
		sComponentName = "GamepadScroll"
	},
	TMPLink = {
		sNodeName = "txtDesc",
		sComponentName = "TMPHyperLink",
		callback = "OnLinkClick_Word"
	},
	btnBlur = {
		sNodeName = "snapshot",
		sComponentName = "Button",
		callback = "OnBtn_CloseBuy"
	},
	imgCoin = {sComponentName = "Image"},
	txtCoinCount = {sComponentName = "TMP_Text"},
	RollButton = {},
	goRollCoin = {},
	btnRoll = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Roll"
	},
	imgRollBtn = {sComponentName = "Image"},
	imgRollCostIcon = {sComponentName = "Image"},
	txtRollCostCount = {sComponentName = "TMP_Text"},
	txtRemainRoll = {sComponentName = "TMP_Text"},
	ActionBar = {
		sCtrlName = "Game.UI.ActionBar.ActionBarCtrl"
	},
	goNoteHint = {},
	TMPNoteHintTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "STShop_OutfitNoteHintTitle"
	},
	TMPOutfitSkillInfoTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "STShop_OutfitSkillInfoTitle"
	},
	TMPNoteHintCount = {sComponentName = "TMP_Text"},
	imgIconNoteHint = {sComponentName = "Image"},
	imgOutfitSkillBg = {},
	lstOutfitSkillInfo = {
		sComponentName = "LoopScrollView"
	}
}
StarTowerShopCtrl._mapEventConfig = {
	OpenFixedRoguelikeShopBuyPanel = "OnEvent_OpenBuy",
	GamepadUIChange = "OnEvent_GamepadUIChange",
	StarTowerShoopSelectGoods = "OnEvent_SelectGoods",
	GamepadUIReopen = "OnEvent_Reopen",
	RefreshStarTowerCoin = "OnEvent_RefreshCoin",
	[EventId.ShowBubbleVoiceText] = "OnEvent_ShowBubbleVoiceText"
}
function StarTowerShopCtrl:Refresh()
	self._mapNode.RollButton:SetActive(self.mapRoll and self.mapRoll.CanReRoll)
	local nCount = #self.tbGoods
	if nCount < 5 then
		nCount = 5
	end
	self._mapNode.srGoodsList:Init(nCount, self, self.OnGridRefresh)
	local nBgCount = math.ceil(nCount / 4)
	self._mapNode.srBgList:Init(nBgCount, self, self.OnGridRefresh_Bg)
	NovaAPI.SetScrollRectVertical(self._mapNode.srBgList, false)
	self:SelectGoods()
	self:RefreshCoin()
	self:RefreshActionBar()
end
function StarTowerShopCtrl:RefreshActionBar()
	local tbConfig = {}
	if self.mapRoll and self.mapRoll.CanReRoll then
		tbConfig = {
			{
				sAction = "Roll",
				sLang = "ActionBar_Reroll"
			},
			{
				sAction = "Depot",
				sLang = "ActionBar_Depot"
			},
			{
				sAction = "Back",
				sLang = "ActionBar_Back"
			},
			{
				sAction = "Confirm",
				sLang = "ActionBar_Check"
			}
		}
	else
		tbConfig = {
			{
				sAction = "Depot",
				sLang = "ActionBar_Depot"
			},
			{
				sAction = "Back",
				sLang = "ActionBar_Back"
			},
			{
				sAction = "Confirm",
				sLang = "ActionBar_Check"
			}
		}
	end
	self._mapNode.ActionBar:InitActionBar(tbConfig)
end
function StarTowerShopCtrl:RefreshCoin()
	NovaAPI.SetTMPText(self._mapNode.txtCoinCount, self:ThousandsNumber(self.nCoin))
	if not self.mapRoll or not self.mapRoll.CanReRoll then
		return
	end
	local bAble = self.mapRoll.ReRollTimes > 0
	NovaAPI.SetImageColor(self._mapNode.imgRollBtn, bAble and Blue_Normal or GrayColor)
	NovaAPI.SetTMPText(self._mapNode.txtRemainRoll, orderedFormat(ConfigTable.GetUIText("StarTower_Select_RemainRoll"), self.mapRoll.ReRollTimes))
	self:SetSprite_Coin(self._mapNode.imgRollCostIcon, AllEnum.CoinItemId.FixedRogCurrency)
	NovaAPI.SetTMPText(self._mapNode.txtRollCostCount, self.mapRoll.ReRollPrice)
	NovaAPI.SetTMPColor(self._mapNode.txtRollCostCount, self.nCoin < self.mapRoll.ReRollPrice and Red_Unable or Blue_Normal)
	self._mapNode.goRollCoin:SetActive(bAble)
	local white = Color(1, 1, 1)
	local gray = Color(1, 1, 1, 0.6)
	local trRoot = self._mapNode.btnRoll.gameObject:GetComponent("Transform"):Find("AnimRoot")
	if trRoot then
		local Xbox = trRoot:Find("Xbox")
		if Xbox then
			local icon = Xbox:Find("imgAction")
			if icon then
				NovaAPI.SetImageColor(icon:GetComponent("Image"), bAble and white or gray)
			end
		end
		local PS = trRoot:Find("PS")
		if PS then
			local icon = PS:Find("imgAction")
			if icon then
				NovaAPI.SetImageColor(icon:GetComponent("Image"), bAble and white or gray)
			end
		end
	end
end
function StarTowerShopCtrl:PlayEnterShopNPCVoice()
	PlayerData.Voice:StopCharVoice()
	local mapCurCfg = ConfigTable.GetData("StarTower", self.nStarTowerId)
	if nil == mapCurCfg then
		return
	end
	local nFloorNum = 0
	for i = 1, #mapCurCfg.FloorNum do
		nFloorNum = nFloorNum + mapCurCfg.FloorNum[i]
	end
	if self.nCurLevel == nFloorNum then
		self.nCurVoiceId = PlayerData.Voice:PlayCharVoice("final", self.nNPCId, nil, true)
		return
	end
	local sVoiceKey = ""
	local tbPool = {"greet_npc"}
	if mapCurCfg.GroupId == 1 then
		table.insert(tbPool, "Tower_typeA")
	elseif mapCurCfg.GroupId == 2 then
		table.insert(tbPool, "Tower_typeB")
	elseif mapCurCfg.GroupId == 3 then
		table.insert(tbPool, "Tower_typeC")
	end
	if nil ~= self.tbGoods then
		for p, v in pairs(self.tbGoods) do
			if 0 < v.nDiscount then
				table.insert(tbPool, "onsale")
				break
			end
		end
	end
	sVoiceKey = tbPool[math.random(1, #tbPool)]
	if sVoiceKey ~= "" then
		self.nCurVoiceId = PlayerData.Voice:PlayCharVoice(sVoiceKey, self.nNPCId, nil, true)
	end
end
function StarTowerShopCtrl:OnGridRefresh_Bg(goGrid, gridIndex)
end
function StarTowerShopCtrl:OnGridRefresh(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local mapGoods = self.tbGoods[nIndex]
	if not self.mapGoodCtrl then
		self.mapGoodCtrl = {}
	end
	if self.mapGoodCtrl[goGrid] == nil then
		self.mapGoodCtrl[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.StarTower.StarTowerShop.StarTowerShopGridCtrl")
	end
	self.mapGoodCtrl[goGrid]:RefreshGrid(mapGoods, self.nCoin)
end
function StarTowerShopCtrl:Clear()
	self.tbGoods = nil
	self.tbGoodsList = nil
	self.tbBuyGridList = nil
end
function StarTowerShopCtrl:OpenBuyPanel(bOpen, mapGoods, bUnable, bQuit)
	if not bOpen then
		if bQuit then
			self._mapNode.t_fullscreen_blur_blue:SetActive(false)
			self._mapNode.goBuyPanel:SetActive(false)
			GamepadUIManager.DisableGamepadUI("BuyPanel")
		else
			self._mapNode.aniBuyPanel:Play("t_window_04_t_out")
			self._mapNode.aniBlur:SetTrigger("tOut")
			self:AddTimer(1, 0.2, function()
				self._mapNode.t_fullscreen_blur_blue:SetActive(false)
				self._mapNode.goBuyPanel:SetActive(false)
				GamepadUIManager.DisableGamepadUI("BuyPanel")
				self:SelectGoods()
			end, true, true, true)
			EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
		end
		return
	end
	GamepadUIManager.EnableGamepadUI("BuyPanel", self.tbGoodsGamepadUINode)
	WwiseAudioMgr:PlaySound("ui_roguelike_shop_scan")
	self._mapNode.t_fullscreen_blur_blue:SetActive(true)
	self._mapNode.goBuyPanel:SetActive(true)
	self._mapNode.aniBuyPanel:Play("t_window_04_t_in")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
	local mapGoodCfgData = ConfigTable.GetData("StarTowerShopGoods", mapGoods.Idx)
	if mapGoodCfgData == nil then
		printError("StarTowerShopGoods Missing" .. mapGoods.Idx)
		return
	end
	local nItemTid
	if mapGoods.nType == 2 then
		nItemTid = mapGoods.nGoodsId
	else
		nItemTid = mapGoodCfgData.ShowItem
	end
	local mapItem = ConfigTable.GetData_Item(nItemTid)
	if mapItem == nil then
		return
	end
	self:SetPngSprite(self._mapNode.imgTickets, ConfigTable.GetData_Item(AllEnum.CoinItemId.FixedRogCurrency).Icon)
	self:SetPngSprite(self._mapNode.imgGoodsIcon, mapItem.Icon)
	local sPath = AllEnum.FrameType_New.Item .. AllEnum.FrameColor_New[mapItem.Rarity]
	self._mapNode.imgGoodsTalentBg.gameObject:SetActive(false)
	if mapGoods.nCharId ~= nil and mapGoods.nCharId > 0 then
		local nCharSkinId = PlayerData.Char:GetCharSkinId(mapGoods.nCharId)
		self:SetPngSprite(self._mapNode.imgGoodsCharIcon, ConfigTable.GetData_CharacterSkin(nCharSkinId).Icon, AllEnum.CharHeadIconSurfix.S)
		self._mapNode.imgGoodsCharIcon.gameObject:SetActive(true)
		self._mapNode.imgCharEdgeGoods.gameObject:SetActive(true)
	else
		self._mapNode.imgGoodsCharIcon.gameObject:SetActive(false)
		self._mapNode.imgCharEdgeGoods.gameObject:SetActive(false)
	end
	NovaAPI.SetTMPText(self._mapNode.txtDesc, mapItem.Desc)
	NovaAPI.SetTMPText(self._mapNode.txtGoodsName, mapItem.Title)
	NovaAPI.SetTMPText(self._mapNode.txtCurResume, 0 < mapGoods.nDiscount and mapGoods.nDiscount or mapGoods.Price)
	self.mapBuy = {
		nSid = mapGoods.nSid,
		sName = mapItem.Title,
		sValue = "",
		sDesc = mapItem.Desc
	}
	self._mapNode.imgBuyDiscount:SetActive(0 < mapGoods.nDiscount)
	self._mapNode.goOrigin:SetActive(0 < mapGoods.nDiscount)
	if 0 < mapGoods.nDiscount then
		NovaAPI.SetTMPText(self._mapNode.txtOrigin, mapGoods.Price)
	end
	if mapGoods.nType == 2 then
		self:SetNoteInfo(mapGoods.nGoodsId)
	else
		self._mapNode.imgOutfitSkillBg:SetActive(false)
		self._mapNode.goNoteHint:SetActive(false)
	end
end
function StarTowerShopCtrl:OpenShop(tbGoodsList, nCoin)
	if tbGoodsList == nil then
		printError("\229\149\134\229\147\129\230\149\176\230\141\174\228\184\186\231\169\186")
		return
	end
	self._mapNode.safeAreaRoot:SetActive(true)
	self._mapNode.RollButton:SetActive(false)
	WwiseAudioMgr:PlaySound("ui_roguelike_shopPanel_enter")
	WwiseAudioMgr:PlaySound("ui_roguelike_shop_window")
	self.tbGoods = self:SortGoods(tbGoodsList)
	self.nCoin = nCoin
	self:Refresh()
end
function StarTowerShopCtrl:SortGoods(tbGoodsList)
	local tbTypeSort = {
		[1] = 1,
		[2] = 2,
		[3] = 4,
		[4] = 3
	}
	local func_sort = function(a, b)
		if tbTypeSort[a.nType] ~= tbTypeSort[b.nType] then
			return tbTypeSort[a.nType] < tbTypeSort[b.nType]
		elseif a.nDiscount ~= b.nDiscount then
			return a.nDiscount > b.nDiscount
		else
			return a.nSid < b.nSid
		end
	end
	table.sort(tbGoodsList, func_sort)
	return tbGoodsList
end
function StarTowerShopCtrl:OpenPanel()
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		local tbGoodsList = tbParam[1]
		self.nCoin = tbParam[2]
		self.BuyCallback = tbParam[3]
		self.nCaseId = tbParam[4]
		self.mapRoll = tbParam[5]
		self.tbOutfitId = tbParam[6]
		self.mapNoteCount = tbParam[7]
		self.nStarTowerId = tbParam[8]
		self.nCurLevel = tbParam[9]
		self:OpenShop(tbGoodsList, self.nCoin)
	end
	CS.GameCameraStackManager.Instance:CloseMainCamera(0.1)
	local bUseL2D = LocalSettingData.mapData.UseLive2D
	self._mapNode.rawImgActor2D.transform.localScale = bUseL2D == true and Vector3.one or Vector3.zero
	self._mapNode.trActor2D_PNG.localScale = bUseL2D == true and Vector3.zero or Vector3.one
	if bUseL2D == true then
		Actor2DManager.SetBoardNPC2D(self:GetPanelId(), self._mapNode.rawImgActor2D, self.nNPCId)
	else
		Actor2DManager.SetBoardNPC2D_PNG(self._mapNode.trActor2D_PNG, self:GetPanelId(), self.nNPCId)
	end
	self:PlayEnterShopNPCVoice()
end
function StarTowerShopCtrl:OnEvent_AvgVoiceEnd(nDuration)
end
function StarTowerShopCtrl:OnEvent_ShowBubbleVoiceText(nCharId, nId)
	local mapVoDirectoryData = ConfigTable.GetData("VoDirectory", nId)
	if mapVoDirectoryData == nil then
		printError("VoDirectory\230\156\170\230\137\190\229\136\176\230\149\176\230\141\174id:" .. nId)
		return
	end
	BubbleVoiceManager.PlayFixedBubbleAnim(self._mapNode.goBubble, mapVoDirectoryData.voResource)
end
function StarTowerShopCtrl:Awake()
	self.mapGoodCtrl = nil
	self:Clear()
	self._mapNode.safeAreaRoot:SetActive(false)
	self:SetSprite_Coin(self._mapNode.imgCoin, AllEnum.CoinItemId.FixedRogCurrency)
	self.nNPCId = 9133
	self.nCurVoiceId = 0
	self.tbShopGamepadUINode = {
		[1] = {
			mapNode = self._mapNode.btnBag,
			sComponentName = "NaviButton"
		},
		[2] = {
			mapNode = self._mapNode.ButtonBack,
			sComponentName = "NaviButton"
		},
		[3] = {
			mapNode = self._mapNode.btnRoll,
			sComponentName = "NaviButton"
		}
	}
	self.tbGoodsGamepadUINode = {
		[1] = {
			mapNode = self._mapNode.btnShortcutClose,
			sComponentName = "NaviButton"
		},
		[2] = {
			mapNode = self._mapNode.ButtonConfirm,
			sComponentName = "NaviButton",
			sAction = "Confirm"
		},
		[3] = {
			mapNode = self._mapNode.sv,
			sComponentName = "GamepadScroll",
			sAction = "Scroll"
		}
	}
end
function StarTowerShopCtrl:OnEnable()
	NovaAPI.SetL2DTimeState(true)
	PanelManager.InputDisable()
	EventManager.Hit("StarTowerSetButtonEnable", false, false)
	self:AddTimer(1, 0.1, "OpenPanel", true, true, true)
	GamepadUIManager.EnableGamepadUI("StarTowerShopCtrl", self.tbShopGamepadUINode)
	PlayerData.Voice:StartBoardFreeTimer(self.nNPCId)
	EventManager.Add(EventId.AvgVoiceEnd, self, self.OnEvent_AvgVoiceEnd)
end
function StarTowerShopCtrl:OnDisable()
	if self.mapGoodCtrl then
		for nInstanceId, objCtrl in pairs(self.mapGoodCtrl) do
			self:UnbindCtrlByNode(objCtrl)
			self.mapGoodCtrl[nInstanceId] = nil
		end
		self.mapGoodCtrl = {}
	end
	CS.GameCameraStackManager.Instance:OpenMainCamera()
	Actor2DManager.UnsetBoardNPC2D()
	BubbleVoiceManager.StopBubbleAnim()
	PlayerData.Voice:ClearTimer()
	EventManager.Remove(EventId.AvgVoiceEnd, self, self.OnEvent_AvgVoiceEnd)
end
function StarTowerShopCtrl:OnDestroy()
	self.mapGoodCtrl = nil
	self:Clear()
end
function StarTowerShopCtrl:OnBtn_CloseShop()
	PanelManager.InputEnable()
	NovaAPI.SetL2DTimeState(false)
	EventManager.Hit("StarTowerSetButtonEnable", true, true)
	GamepadUIManager.DisableGamepadUI("StarTowerShopCtrl")
	self:Clear()
	EventManager.Hit("CloseFRShopPanel")
	EventManager.Hit("ReplayShopRoomBGM")
	EventManager.Hit(EventId.ClosePanel, PanelId.StarTowerShop)
	PlayerData.Voice:StopCharVoice()
	local tbPool = {
		"leave",
		"posterchat_npc"
	}
	if 0 < #tbPool then
		PlayerData.Voice:PlayCharVoice(tbPool[math.random(1, #tbPool)], self.nNPCId, nil, true)
	end
end
function StarTowerShopCtrl:OnEvent_OpenBuy(mapGoods, bUnable)
	self:OpenBuyPanel(true, mapGoods, bUnable)
end
function StarTowerShopCtrl:OnEvent_CloseStarTowerDepot()
	if self.bOpenDepot then
		self.bOpenDepot = false
		CS.GameCameraStackManager.Instance:CloseMainCamera(0.1)
		self.gameObject:SetActive(true)
		self:SelectGoods()
	end
end
function StarTowerShopCtrl:OnBtn_CloseBuy()
	self:OpenBuyPanel(false)
end
function StarTowerShopCtrl:OnBtn_Confirm()
	local callback = function(nCoin)
		self:OpenBuyPanel(false, nil, nil, true)
		for _, mapGoods in pairs(self.tbGoods) do
			if mapGoods.nSid == self.mapBuy.nSid then
				mapGoods.bSoldOut = true
			end
		end
		self.nCoin = nCoin
		self:Refresh()
		self.nCurVoiceId = PlayerData.Voice:PlayCharVoice("thank_npc", self.nNPCId, nil, true)
	end
	if self.BuyCallback ~= nil and type(self.BuyCallback) == "function" then
		if type(self.nCaseId) == "table" then
			printError("\230\152\159\229\161\148\229\149\134\229\186\151\232\180\173\228\185\176\230\151\182\239\188\140caseId \229\143\152\230\136\144table\228\186\134\239\188\140\228\187\150\231\154\132\229\134\133\229\174\185\230\152\175\239\188\154")
			local function printTableHelper(t, indent)
				indent = indent or 0
				for k, v in pairs(t) do
					local formatting = string.rep(" ", indent) .. tostring(k) .. ": "
					if type(v) == "table" then
						printError(formatting)
						printTableHelper(v, indent + 4)
					else
						printError(formatting .. tostring(v))
					end
				end
			end
			printTableHelper(self.nCaseId, 0)
		end
		self.BuyCallback(self.nCaseId, self.mapBuy.nSid, callback)
	end
end
function StarTowerShopCtrl:OnBtn_UnableConfirm()
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("FIXEDROGUE_00"))
end
function StarTowerShopCtrl:OnBtn_Depot()
	self.bOpenDepot = true
	CS.GameCameraStackManager.Instance:OpenMainCamera()
	self.gameObject:SetActive(false)
	EventManager.Hit(EventId.StarTowerDepot, AllEnum.StarTowerDepotTog.Potential)
end
function StarTowerShopCtrl:OnBtnClick_Roll()
	if self.mapRoll.ReRollTimes <= 0 then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("StarTower_ReRoll_NotEnoughCount"))
		return
	end
	if self.nCoin < self.mapRoll.ReRollPrice then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("StarTower_ReRoll_NotEnoughCoin"))
		return
	end
	local callback = function(nCoin, tbGoodsList, mapRoll)
		self.nCoin = nCoin
		self.tbGoods = self:SortGoods(tbGoodsList)
		self.mapRoll = mapRoll
		self:Refresh()
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			bPositive = true,
			sContent = ConfigTable.GetUIText("StarTower_Shop_ReRollSuccess")
		})
	end
	if self.BuyCallback ~= nil and type(self.BuyCallback) == "function" then
		self.BuyCallback(self.nCaseId, nil, callback, true)
	end
end
function StarTowerShopCtrl:OnLinkClick_Word(link, sWordId)
	UTILS.ClickWordLink(link, sWordId)
end
function StarTowerShopCtrl:OnBtnClick_Actor(btn)
	self.nCurVoiceId = PlayerData.Voice:PlayBoardNPCClickVoice(self.nNPCId)
end
function StarTowerShopCtrl:OnEvent_SelectGoods(nIndex)
	self.nSelectIdx = nIndex
end
function StarTowerShopCtrl:OnEvent_RefreshCoin(nCoin)
	self.nCoin = nCoin
	self:Refresh()
end
function StarTowerShopCtrl:OnEvent_GamepadUIChange(sName, nBeforeType, nAfterType)
	if sName ~= "StarTowerShopCtrl" then
		return
	end
	local bNeedSelect = nBeforeType == AllEnum.GamepadUIType.Other and nAfterType ~= AllEnum.GamepadUIType.Mouse or nBeforeType == AllEnum.GamepadUIType.Mouse and nAfterType ~= AllEnum.GamepadUIType.Other
	if bNeedSelect then
		self:SelectGoods()
	else
		GamepadUIManager.ClearSelectedUI()
	end
end
function StarTowerShopCtrl:OnEvent_Reopen(sName)
	if sName == "StarTowerShopCtrl" then
		if self.bOpenDepot then
			self:OnEvent_CloseStarTowerDepot()
		else
			self:SelectGoods()
		end
	end
end
function StarTowerShopCtrl:SelectGoods()
	local nShowIndex = self._mapNode.srGoodsList:GetFirsetGridIndex()
	if not self.nSelectIdx then
		self.nSelectIdx = nShowIndex
	end
	local goSelect = self._mapNode.trGoodsList:Find("ViewPort/Content/" .. self.nSelectIdx)
	if goSelect then
		GamepadUIManager.SetSelectedUI(goSelect:Find("ButtonBuy").gameObject)
		self.mapGoodCtrl[goSelect.gameObject]:SetSelect(true)
	else
		goSelect = self._mapNode.trGoodsList:Find("ViewPort/Content/" .. nShowIndex)
		if goSelect then
			GamepadUIManager.SetSelectedUI(goSelect:Find("ButtonBuy").gameObject)
			self.mapGoodCtrl[goSelect.gameObject]:SetSelect(true)
		end
	end
end
function StarTowerShopCtrl:SetNoteInfo(nNoteId)
	local nCurCount = self.mapNoteCount[nNoteId] == nil and 0 or self.mapNoteCount[nNoteId]
	local tbOutfitId = {}
	for i = 1, 3 do
		if self.tbOutfitId[i] ~= 0 then
			table.insert(tbOutfitId, self.tbOutfitId[i])
		end
	end
	local tbSkill = PlayerData.Disc:GetDiscSkillByNote(tbOutfitId, self.mapNoteCount, nNoteId)
	local bShowInfo = false
	local nMaxNote = 0
	self.tbShowInfo = {}
	for _, mapData in ipairs(tbSkill) do
		local tbNoteInfo = {}
		local bCurrShow = false
		for nTid, nCount in pairs(mapData.tbNote) do
			table.insert(tbNoteInfo, {nTid, nCount})
			if nTid == nNoteId then
				nMaxNote = math.max(nMaxNote, nCount)
				if nCurCount < nMaxNote then
					bShowInfo = true
					bCurrShow = true
				end
			end
		end
		local sort = function(a, b)
			if a[1] == nNoteId or b[1] == nNoteId then
				return a[1] == nNoteId
			end
			return a[1] > b[1]
		end
		if bCurrShow then
			table.sort(tbNoteInfo, sort)
			table.insert(self.tbShowInfo, {
				nId = mapData.nId,
				tbNote = tbNoteInfo
			})
		end
	end
	if bShowInfo == true then
		self._mapNode.goNoteHint:SetActive(true)
		if nCurCount >= nMaxNote then
			NovaAPI.SetTMPText(self._mapNode.TMPNoteHintCount, string.format("%d/%d", nCurCount, nMaxNote))
		else
			NovaAPI.SetTMPText(self._mapNode.TMPNoteHintCount, string.format("<color=#08d3d4>%d</color>/%d", nCurCount, nMaxNote))
		end
		local mapNote = ConfigTable.GetData("SubNoteSkill", nNoteId)
		if mapNote ~= nil then
			self:SetPngSprite(self._mapNode.imgIconNoteHint, mapNote.Icon .. AllEnum.DiscSkillIconSurfix.Small)
		end
	else
		self._mapNode.goNoteHint:SetActive(false)
	end
	if 0 < #self.tbShowInfo then
		self._mapNode.imgOutfitSkillBg:SetActive(true)
		self._mapNode.lstOutfitSkillInfo:Init(#self.tbShowInfo, self, self.OnDiscSkillInfoGridRefresh)
	else
		self._mapNode.imgOutfitSkillBg:SetActive(false)
	end
end
function StarTowerShopCtrl:OnDiscSkillInfoGridRefresh(goGrid, nIdx)
	local mapSkill = self.tbShowInfo[nIdx + 1]
	local tbNoteCount = {}
	local tbimgIconCount = {}
	local TMPSkillTitle = goGrid.transform:Find("btnGrid/AnimRoot/TMPSkillTitle"):GetComponent("TMP_Text")
	local imgIcon = goGrid.transform:Find("btnGrid/AnimRoot/imgIconBg/imgIcon"):GetComponent("Image")
	local imgIconBg = goGrid.transform:Find("btnGrid/AnimRoot/imgIconBg"):GetComponent("Image")
	tbNoteCount[1] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount1"):GetComponent("TMP_Text")
	tbNoteCount[2] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount2"):GetComponent("TMP_Text")
	tbNoteCount[3] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount3"):GetComponent("TMP_Text")
	tbimgIconCount[1] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount1/imgIconCount1"):GetComponent("Image")
	tbimgIconCount[2] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount2/imgIconCount2"):GetComponent("Image")
	tbimgIconCount[3] = goGrid.transform:Find("btnGrid/AnimRoot/TMPNoteCount3/imgIconCount3"):GetComponent("Image")
	local mapSkillCfg = ConfigTable.GetData("SecondarySkill", mapSkill.nId)
	if mapSkillCfg == nil then
		goGrid:SetActive(false)
		return
	else
		goGrid:SetActive(true)
	end
	NovaAPI.SetTMPText(TMPSkillTitle, mapSkillCfg.Name)
	self:SetPngSprite(imgIcon, mapSkillCfg.Icon .. AllEnum.DiscSkillIconSurfix.Small)
	self:SetPngSprite(imgIconBg, mapSkillCfg.IconBg .. AllEnum.DiscSkillIconSurfix.Small)
	for i = 1, 3 do
		if mapSkill.tbNote[i] ~= nil then
			tbNoteCount[i].gameObject:SetActive(true)
			tbimgIconCount[i].gameObject:SetActive(true)
			local mapNote = ConfigTable.GetData("SubNoteSkill", mapSkill.tbNote[i][1])
			if mapNote ~= nil then
				self:SetPngSprite(tbimgIconCount[i], mapNote.Icon .. AllEnum.DiscSkillIconSurfix.Small)
			end
			local nCurCount = self.mapNoteCount[mapSkill.tbNote[i][1]] == nil and 0 or self.mapNoteCount[mapSkill.tbNote[i][1]]
			if nCurCount >= mapSkill.tbNote[i][2] then
				NovaAPI.SetTMPText(tbNoteCount[i], string.format("%d/%d", nCurCount, mapSkill.tbNote[i][2]))
			else
				NovaAPI.SetTMPText(tbNoteCount[i], string.format("<color=#08d3d4>%d</color>/%d", nCurCount, mapSkill.tbNote[i][2]))
			end
		else
			tbNoteCount[i].gameObject:SetActive(false)
			tbimgIconCount[i].gameObject:SetActive(false)
		end
	end
end
return StarTowerShopCtrl
