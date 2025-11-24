local GachaCtrl = class("GachaCtrl", BaseCtrl)
local LocalData = require("GameCore.Data.LocalData")
local newDayTime = UTILS.GetDayRefreshTimeOffset()
local WwiseManger = CS.WwiseAudioManager
local coverScript = {
	[GameEnum.gachaStorageType.CharacterCardPool] = "Game.UI.GachaEx.GachaCover.GachaCoverCtrl_PermanentCharUp",
	[GameEnum.gachaStorageType.DiscCardPool] = "Game.UI.GachaEx.GachaCover.GachaCoverCtrl_PermanentDiscUp",
	[GameEnum.gachaStorageType.CharacterUpCardPool] = "Game.UI.GachaEx.GachaCover.GachaCoverCtrl_CharUp",
	[GameEnum.gachaStorageType.DiscUpCardPool] = "Game.UI.GachaEx.GachaCover.GachaCoverCtrl_DiscUp",
	[GameEnum.gachaStorageType.BeginnerCardPool] = "Game.UI.GachaEx.GachaCover.GachaCoverCtrl_NewBie"
}
GachaCtrl._mapNodeConfig = {
	coverRoot = {
		sNodeName = "----BGRoot----",
		sComponentName = "Transform"
	},
	PoolContent = {sComponentName = "Transform"},
	PoolTabTemplete = {},
	btn_GachaOne = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_One"
	},
	btn_GachaTen = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Ten"
	},
	txtBtnpoolDetail = {
		sComponentName = "TMP_Text",
		sLanguageId = "Recruit_info"
	},
	txtBtnpoolHistory = {
		sComponentName = "TMP_Text",
		sLanguageId = "GachaHistory_Guarantee"
	},
	txtBtnshop = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_Tog_Exchange"
	},
	txt_NewBieJump = {
		sComponentName = "TMP_Text",
		sLanguageId = "Gacha_NewBieRecord"
	},
	txt_NewBieCount = {sComponentName = "TMP_Text"},
	TMP_gachaNewBieTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Gacha_NewBieSummonTitle"
	},
	TMP_gachaNewBieCost = {
		sComponentName = "TMP_Text",
		sLanguageId = "Gacha_NewBieSummonCost"
	},
	TMP_gachaOneTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Recruit_one"
	},
	TMP_gachaTenTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Recruit_ten"
	},
	TMP_GachaTimes = {sComponentName = "TMP_Text"},
	imgItemOne = {sComponentName = "Image"},
	imgItemTen = {sComponentName = "Image"},
	imgNewBieItemTen = {sComponentName = "Image"},
	TMP_gachaOneCost = {sComponentName = "TMP_Text"},
	TMP_gachaTenCost = {sComponentName = "TMP_Text"},
	imgBtnTip = {sComponentName = "Image"},
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	btn_poolDetail = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_GachaDetail"
	},
	btn_poolHistory = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_GachaHistory"
	},
	btn_shop = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_shop"
	},
	btn_NewBieJump = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_NewBieJump"
	},
	btn_NewBieJumpRecord = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_NewBieJumpRecord"
	},
	rootAnim = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	GachaOpenDoor = {},
	GachaShow = {
		sCtrlName = "Game.UI.GachaEx.GachaShowCtrl"
	},
	GachaShowResult = {
		sCtrlName = "Game.UI.GachaEx.GachaShowResultCtrl"
	},
	GachaInfo = {
		sNodeName = "----PoolInfo---- ",
		sCtrlName = "Game.UI.GachaEx.GachaInfoCtrl"
	},
	GachaHistory = {
		sNodeName = "----GachaHistory----",
		sCtrlName = "Game.UI.GachaEx.GachaHistotyCtrl"
	},
	GachaProb = {
		sNodeName = "----ProbInfo----",
		sCtrlName = "Game.UI.GachaEx.GachaProbInfoCtrl"
	},
	GachaNewBieShowRecord = {
		sNodeName = "GachaNewBieShowRecord",
		sCtrlName = "Game.UI.GachaEx.GachaNewBieShowRecordCtrl"
	},
	GachaNewBieShowResult = {
		sNodeName = "GachaNewBieShowResult",
		sCtrlName = "Game.UI.GachaEx.GachaNewBieShowResultCtrl"
	},
	GachaNewBieSaveRecord = {
		sNodeName = "GachaNewBieSaveRecord",
		sCtrlName = "Game.UI.GachaEx.GachaNewBieSaveRecordCtrl"
	},
	GachaNewBieReplaceResult = {
		sNodeName = "GachaNewBieReplaceResult",
		sCtrlName = "Game.UI.GachaEx.GachaNewBieReplaceResultCtrl"
	},
	GachaNewBieObtainResult = {
		sNodeName = "GachaNewBieObtainResult",
		sCtrlName = "Game.UI.GachaEx.GachaNewBieObtainResultCtrl"
	}
}
GachaCtrl._mapEventConfig = {
	GachaPoolDetail = "OnEvent_GachaPoolDetail",
	GachaOpenPoolInfo = "OnBtnClick_GachaDetail",
	GachaOpenProbInfo = "OnBtnClick_ProbDetail",
	GachaNewbieSpin = "OnEvent_GachaNewbieSpin",
	GachaNewbieRecord = "OnEvent_GachaNewbieRecord",
	GachaNewbieObtainRecord = "OnEvent_GachaNewbieObtainRecord",
	GachaNewbieSaveRecord = "OnEvent_GachaNewbieSaveRecord",
	GachaNewbieReplaceRecord = "OnEvent_GachaNewbieReplaceRecord",
	GachaNewbieReplaceRecordOver = "OnEvent_GachaNewbieReplaceRecordOver",
	GachaNewbieObtainRecordOver = "OnEvent_GachaNewbieObtainRecordOver",
	GachaProcessStart = "OnEvent_GachaProcessStart"
}
function GachaCtrl:Awake()
	self.bGachaProcess = false
end
function GachaCtrl:FadeIn()
end
function GachaCtrl:FadeOut()
end
function GachaCtrl:OnEnable()
	self._mapMaxAcquireReward = {}
	local forEachAcquireReward = function(mapData)
		if self._mapMaxAcquireReward[mapData.itemStype] == nil then
			self._mapMaxAcquireReward[mapData.itemStype] = {}
		end
		if self._mapMaxAcquireReward[mapData.itemStype][mapData.itemRarity] == nil then
			self._mapMaxAcquireReward[mapData.itemStype][mapData.itemRarity] = mapData.AcquireTimes
		end
		if mapData.AcquireTimes > self._mapMaxAcquireReward[mapData.itemStype][mapData.itemRarity] then
			self._mapMaxAcquireReward[mapData.itemStype][mapData.itemRarity] = mapData.AcquireTimes
		end
	end
	ForEachTableLine(DataTable.AcquireReward, forEachAcquireReward)
	self.nTopBarId = self._mapNode.TopBar.gameObject:GetInstanceID()
	self.curPoolId = 0
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self.curPoolId = tbParam[1]
	end
	if self._panel.nCurPool ~= nil and self._panel.nCurPool ~= 0 then
		self.curPoolId = self._panel.nCurPool
		self._panel.nCurPool = 0
	end
	self.mapCover = {}
	local callback = function()
		local wait = function()
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
			self:RefreshAll()
		end
		cs_coroutine.start(wait)
		EventManager.Hit("Guide_GachaOpen")
	end
	self._mapNode.TMP_GachaTimes.gameObject:SetActive(false)
	local newbie_callback = function()
		PlayerData.Gacha:GetGachaInfomation(callback)
	end
	PlayerData.Gacha:GetGachaNewbieInfomation(newbie_callback)
	self._mapNode.GachaNewBieShowRecord.gameObject:SetActive(false)
	self._mapNode.GachaNewBieShowResult.gameObject:SetActive(false)
	self._mapNode.GachaNewBieSaveRecord.gameObject:SetActive(false)
	self._mapNode.GachaNewBieReplaceResult.gameObject:SetActive(false)
	self._mapNode.GachaNewBieObtainResult.gameObject:SetActive(false)
end
function GachaCtrl:OnDisable()
	for _, mapCtrl in pairs(self.mapCover) do
		self:UnbindCtrlByNode(mapCtrl)
	end
	self._panel.nCurPool = self.curPoolId
	self.mapCover = nil
	self.mapTab = nil
	delChildren(self._mapNode.coverRoot)
	delChildren(self._mapNode.PoolContent)
	CS.WwiseAudioManager.Instance:PostEvent("ui_recuit_cover_all_stop")
end
function GachaCtrl:OnDestroy()
end
function GachaCtrl:OnRelease()
end
function GachaCtrl:RefreshAll()
	self.tbOpenedPool = PlayerData.Gacha:GetOpenedPool()
	self:LoadCover()
	self:RefreshTab()
	if type(self.curPoolId) ~= "number" or self.curPoolId <= 0 or table.indexof(self.tbOpenedPool, self.curPoolId) < 1 then
		self.curPoolId = self.tbOpenedPool[1]
	end
	self:SetTabSelect(self.curPoolId, true)
	self:RefreshInfo()
	EventManager.Hit(EventId.SetTransition)
	if self.mapCover[self.curPoolId] ~= nil then
		self.mapCover[self.curPoolId].gameObject:SetActive(true)
		local gachaData = ConfigTable.GetData("Gacha", self.curPoolId)
		if gachaData ~= nil then
			CS.WwiseAudioManager.Instance:PostEvent(gachaData.Voice)
		end
	end
	self._mapNode.rootAnim:Play("GachaPanel_in")
	if self.mapCover[self.curPoolId] then
		self.mapCover[self.curPoolId]:PlayInAnim()
		self.mapCover[self.curPoolId]:EnableCover()
	end
end
function GachaCtrl:RefreshTab()
	self.mapTab = {}
	delChildren(self._mapNode.PoolContent)
	if #self.tbOpenedPool < 1 then
		printError("\230\178\161\230\156\137\229\188\128\229\144\175\231\154\132\229\141\161\230\177\160")
		return
	end
	local comp = function(a, b)
		local mapGachaA = ConfigTable.GetData("Gacha", a)
		local mapGachaB = ConfigTable.GetData("Gacha", b)
		return mapGachaA.Sort < mapGachaB.Sort
	end
	table.sort(self.tbOpenedPool, comp)
	for _, nGachaId in ipairs(self.tbOpenedPool) do
		local mapGacha = ConfigTable.GetData("Gacha", nGachaId)
		local goTab = instantiate(self._mapNode.PoolTabTemplete, self._mapNode.PoolContent)
		goTab.transform.localScale = Vector3.one
		self.mapTab[nGachaId] = goTab
		local compBtn = goTab:GetComponent("UIButton")
		local func_Handler = ui_handler(self, self.OnBtnClick_Tab, compBtn, nGachaId)
		compBtn.onClick:AddListener(func_Handler)
		local imgIconTab = goTab.transform:Find("AnimRoot/imgTab"):GetComponent("Image")
		self:SetPngSprite(imgIconTab, mapGacha.Icon)
		goTab.transform:Find("AnimRoot/imgChoose").gameObject:SetActive(false)
	end
end
function GachaCtrl:RefreshInfo()
	if self.curPoolId == nil or self.curPoolId == 0 then
		return
	end
	local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGacha == nil then
		return
	end
	self.isNewBie = mapGacha.StorageId == GameEnum.gachaStorageType.BeginnerCardPool
	self._mapNode.btn_NewBieJump.gameObject:SetActive(self.isNewBie)
	self._mapNode.btn_NewBieJumpRecord.gameObject:SetActive(self.isNewBie)
	self._mapNode.btn_GachaOne.gameObject:SetActive(not self.isNewBie)
	self._mapNode.btn_GachaTen.gameObject:SetActive(not self.isNewBie)
	self._mapNode.btn_poolHistory.gameObject:SetActive(not self.isNewBie)
	self._mapNode.btn_shop.gameObject:SetActive(not self.isNewBie)
	if self.isNewBie then
		local newbie = ConfigTable.GetData("GachaNewbie", self.curPoolId)
		local newbieData = PlayerData.Gacha:GetGachaNewbieData(self.curPoolId)
		local c = 0
		if newbieData ~= nil then
			c = #newbieData.Cards
		end
		if newbie ~= nil then
			NovaAPI.SetTMPText(self._mapNode.txt_NewBieCount, tostring(c) .. "/" .. tostring(newbie.SaveCount))
		end
	end
	self:RefreshCoin(mapGacha)
	self:RefreshCover()
	self._mapNode.GachaInfo:Refresh(self.curPoolId)
	self._mapNode.GachaProb:Refresh(self.curPoolId)
end
function GachaCtrl:RefreshCoin(mapGacha)
	if mapGacha == nil then
		return
	end
	local mapGachaStorage = ConfigTable.GetData("GachaStorage", mapGacha.StorageId)
	if mapGachaStorage == nil then
		return
	end
	if self.isNewBie then
		return
	end
	local rapidjson = require("rapidjson")
	if type(mapGachaStorage.OncePreferred) == "string" then
		local tbOne = rapidjson.decode(mapGachaStorage.OncePreferred)
		if tbOne ~= nil then
			mapGachaStorage.OncePreferred = tbOne
		else
			mapGachaStorage.OncePreferred = {}
			printError("\229\141\149\230\138\189\230\182\136\232\128\151\233\133\141\231\189\174\233\148\153\232\175\175\239\188\154" .. self.curPoolId)
			return
		end
	end
	if type(mapGachaStorage.TenTimesPreferred) == "string" then
		local tbTen = rapidjson.decode(mapGachaStorage.TenTimesPreferred)
		if tbTen ~= nil then
			mapGachaStorage.TenTimesPreferred = tbTen
		else
			mapGachaStorage.TenTimesPreferred = {}
			printError("\229\141\129\232\191\158\230\182\136\232\128\151\233\133\141\231\189\174\233\148\153\232\175\175\239\188\154" .. self.curPoolId)
			return
		end
	end
	if #mapGachaStorage.OncePreferred > 0 then
		for nIdx, mapCost in ipairs(mapGachaStorage.OncePreferred) do
			local f = pairs(mapCost)
			local sTid, nCount = f(mapCost)
			local nTid = tonumber(sTid)
			local nCurCount = PlayerData.Item:GetItemCountByID(nTid)
			if nCount <= nCurCount then
				NovaAPI.SetTMPText(self._mapNode.TMP_gachaOneCost, nCount)
				local mapItemCfgData = ConfigTable.GetData_Item(nTid)
				self:SetPngSprite(self._mapNode.imgItemOne, mapItemCfgData.Icon2)
				NovaAPI.SetImageNativeSize(self._mapNode.imgItemOne)
				break
			end
			if nIdx == #mapGachaStorage.OncePreferred then
				NovaAPI.SetTMPText(self._mapNode.TMP_gachaOneCost, mapGachaStorage.DefaultQty)
				local mapItemCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
				self:SetPngSprite(self._mapNode.imgItemOne, mapItemCfgData.Icon2)
				NovaAPI.SetImageNativeSize(self._mapNode.imgItemOne)
			end
		end
	else
		NovaAPI.SetTMPText(self._mapNode.TMP_gachaOneCost, mapGachaStorage.DefaultQty)
		local mapItemCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
		if mapItemCfgData ~= nil then
			self:SetPngSprite(self._mapNode.imgItemOne, mapItemCfgData.Icon2)
			NovaAPI.SetImageNativeSize(self._mapNode.imgItemOne)
		end
	end
	if #mapGachaStorage.TenTimesPreferred > 0 then
		for nIdx, mapCost in ipairs(mapGachaStorage.TenTimesPreferred) do
			local f = pairs(mapCost)
			local sTid, nCount = f(mapCost)
			local nTid = tonumber(sTid)
			local nCurCount = PlayerData.Item:GetItemCountByID(nTid)
			if nCount <= nCurCount then
				NovaAPI.SetTMPText(self._mapNode.TMP_gachaTenCost, nCount)
				local mapItemCfgData = ConfigTable.GetData_Item(nTid)
				self:SetPngSprite(self._mapNode.imgItemTen, mapItemCfgData.Icon2)
				NovaAPI.SetImageNativeSize(self._mapNode.imgItemTen)
				break
			end
			if nIdx == #mapGachaStorage.TenTimesPreferred then
				NovaAPI.SetTMPText(self._mapNode.TMP_gachaTenCost, mapGachaStorage.DefaultQty * 10)
				local mapItemCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
				self:SetPngSprite(self._mapNode.imgItemTen, mapItemCfgData.Icon2)
				NovaAPI.SetImageNativeSize(self._mapNode.imgItemTen)
			end
		end
	else
		NovaAPI.SetTMPText(self._mapNode.TMP_gachaTenCost, mapGachaStorage.DefaultQty * 10)
		local mapItemCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
		self:SetPngSprite(self._mapNode.imgItemTen, mapItemCfgData.Icon2)
		NovaAPI.SetImageNativeSize(self._mapNode.imgItemTen)
	end
end
function GachaCtrl:RefreshCover()
	for nPoolId, mapCoverCtrl in pairs(self.mapCover) do
		mapCoverCtrl:SetCover(nPoolId)
	end
end
function GachaCtrl:LoadCover()
	self.mapCover = {}
	for _, nPoolId in ipairs(self.tbOpenedPool) do
		local mapGacha = ConfigTable.GetData("Gacha", nPoolId)
		if mapGacha ~= nil then
			print(string.format("UI_GachaCover/%s/%s.prefab", mapGacha.Image, mapGacha.Image))
			local coverPrefab = self:LoadAsset(string.format("UI_GachaCover/%s/%s.prefab", mapGacha.Image, mapGacha.Image))
			local goCover = instantiate(coverPrefab, self._mapNode.coverRoot)
			goCover:SetActive(false)
			local sScript = "Game.UI.GachaEx.GachaCoverCtrl"
			if coverScript[mapGacha.StorageId] ~= nil then
				sScript = coverScript[mapGacha.StorageId]
			end
			local goCtrl = self:BindCtrlByNode(goCover, sScript)
			self.mapCover[nPoolId] = goCtrl
			self.mapCover[nPoolId]:SetCover(nPoolId)
		end
	end
end
function GachaCtrl:SetTabSelect(nGachaId, bSelect)
	if nGachaId == nil then
		return
	end
	local gachaData = ConfigTable.GetData("Gacha", nGachaId)
	local mapStorage = ConfigTable.GetData("GachaType", gachaData.GachaType)
	self._mapNode.TopBar:CreateCoin(mapStorage.CoinItem)
	self.tbCurTabCoin = mapStorage.CoinItem
	local go = self.mapTab[nGachaId]
	if go ~= nil then
		go.transform:Find("AnimRoot/imgChoose").gameObject:SetActive(bSelect)
	end
	self._mapNode.btn_NewBieJump.gameObject:SetActive(gachaData.StorageId == GameEnum.gachaStorageType.BeginnerCardPool)
	self._mapNode.btn_shop.gameObject:SetActive(gachaData.StorageId == GameEnum.gachaStorageType.BeginnerCardPool)
end
function GachaCtrl:SetCoverOpen(nGachaId, bOpen)
	if nGachaId == nil then
		return
	end
	local go = self.mapCover[nGachaId].gameObject
	if go ~= nil then
		go:SetActive(bOpen)
		if bOpen then
			local gachaData = ConfigTable.GetData("Gacha", nGachaId)
			if gachaData ~= nil then
				CS.WwiseAudioManager.Instance:PostEvent(gachaData.Voice)
			end
		end
	end
end
function GachaCtrl:GachaOneExchangeCoin(mapGacha)
	local ConfirmPanel = function(sTip, confirmCallback, againKey)
		if againKey ~= nil then
			local TipsTime = LocalData.GetPlayerLocalData(againKey)
			local _tipDay = 0
			if TipsTime ~= nil then
				_tipDay = tonumber(TipsTime)
			end
			local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
			local fixedTimeStamp = curTimeStamp - newDayTime * 3600
			local nYear = tonumber(os.date("!%Y", fixedTimeStamp))
			local nMonth = tonumber(os.date("!%m", fixedTimeStamp))
			local nDay = tonumber(os.date("!%d", fixedTimeStamp))
			local nowD = nYear * 366 + nMonth * 31 + nDay
			if nowD == _tipDay then
				confirmCallback()
				return
			end
		end
		local isSelectAgain = false
		local func_confirm = function()
			if againKey ~= nil and isSelectAgain then
				local _curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
				local _fixedTimeStamp = _curTimeStamp - newDayTime * 3600
				local _nYear = tonumber(os.date("!%Y", _fixedTimeStamp))
				local _nMonth = tonumber(os.date("!%m", _fixedTimeStamp))
				local _nDay = tonumber(os.date("!%d", _fixedTimeStamp))
				local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
				LocalData.SetPlayerLocalData(againKey, tostring(_nowD))
			end
			confirmCallback()
		end
		local againCallback = function(isSelect)
			isSelectAgain = isSelect
		end
		local cancelCallback = function()
			EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
		end
		local msg = {
			nType = AllEnum.MessageBox.Confirm,
			sContent = sTip,
			callbackConfirm = func_confirm,
			callbackCancel = cancelCallback,
			callbackAgain = againKey ~= nil and againCallback or nil
		}
		EventManager.Hit(EventId.OpenMessageBox, msg)
		EventManager.Hit("TopRes", true, self.nTopBarId, {
			AllEnum.CoinItemId.Jade,
			AllEnum.CoinItemId.STONE
		})
	end
	local GachaCallback = function(mapData)
		self:GetGachaItem(mapData, mapGacha.StorageId)
		self:RefreshCoin(mapGacha)
	end
	local mapGachaStorage = ConfigTable.GetData("GachaStorage", mapGacha.StorageId)
	if mapGachaStorage == nil then
		return
	end
	local nDefaultCount = PlayerData.Item:GetItemCountByID(mapGachaStorage.DefaultId)
	if nDefaultCount >= mapGachaStorage.DefaultQty then
		PlayerData.Gacha:SendGachaReq(self.curPoolId, 1, GachaCallback)
	elseif mapGachaStorage.CostId > 0 then
		local nCostCount = PlayerData.Item:GetItemCountByID(mapGachaStorage.CostId)
		local confirmCallback = function()
			EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
			if nCostCount >= mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty - nDefaultCount) then
				PlayerData.Gacha:SendGachaReq(self.curPoolId, 1, GachaCallback)
			elseif mapGachaStorage.CostId == AllEnum.CoinItemId.Jade then
				local nNeedCount = mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty - nDefaultCount)
				local nJadeCount = PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.Jade)
				nNeedCount = nNeedCount - nJadeCount
				local mapCostCfgData = ConfigTable.GetData_Item(AllEnum.CoinItemId.STONE)
				local mapJadeCfgData = ConfigTable.GetData_Item(AllEnum.CoinItemId.Jade)
				local sTips1 = orderedFormat(ConfigTable.GetUIText("Recruit_ExchangeGemZero"), mapJadeCfgData.Id, nNeedCount, mapCostCfgData.Id)
				local confirmCallbackStone = function()
					EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
					local nCurStoneCount = PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.STONE)
					nCurStoneCount = nCurStoneCount + PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.FREESTONE)
					if nCurStoneCount >= nNeedCount then
						PlayerData.Coin:SendGemConvertReqReq(nNeedCount, nil)
					else
						local sTips2 = orderedFormat(ConfigTable.GetUIText("Recruit_Charge") or "", mapCostCfgData.Id)
						local confirmCallbackExchange = function()
							EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
							EventManager.Hit(EventId.OpenPanel, PanelId.Mall, AllEnum.MallToggle.Gem)
						end
						ConfirmPanel(sTips2, confirmCallbackExchange)
					end
				end
				ConfirmPanel(sTips1, confirmCallbackStone)
			else
				EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("NotEnoughItem"))
			end
		end
		local nNeedCount = mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty - nDefaultCount)
		local mapCostCfgData = ConfigTable.GetData_Item(mapGachaStorage.CostId)
		local mapDefaultCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
		local sTips
		if 0 < nDefaultCount then
			sTips = orderedFormat(ConfigTable.GetUIText("Recruit_ExchangeGem"), nDefaultCount, mapDefaultCfgData.Id, nNeedCount, mapCostCfgData.Id, mapGachaStorage.DefaultQty - nDefaultCount, mapDefaultCfgData.Id)
		else
			sTips = orderedFormat(ConfigTable.GetUIText("Recruit_Exchange"), nNeedCount, mapCostCfgData.Id, mapGachaStorage.DefaultQty - nDefaultCount, mapDefaultCfgData.Id)
		end
		ConfirmPanel(sTips, confirmCallback, "GachaShowTicketExchange")
	else
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("NotEnoughItem"))
	end
end
function GachaCtrl:GachaTenExchangeCoin(mapGacha)
	local ConfirmPanel = function(sTip, confirmCallback, againKey)
		if againKey ~= nil then
			local TipsTime = LocalData.GetPlayerLocalData(againKey)
			local _tipDay = 0
			if TipsTime ~= nil then
				_tipDay = tonumber(TipsTime)
			end
			local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
			local fixedTimeStamp = curTimeStamp - newDayTime * 3600
			local nYear = tonumber(os.date("!%Y", fixedTimeStamp))
			local nMonth = tonumber(os.date("!%m", fixedTimeStamp))
			local nDay = tonumber(os.date("!%d", fixedTimeStamp))
			local nowD = nYear * 366 + nMonth * 31 + nDay
			if nowD == _tipDay then
				confirmCallback()
				return
			end
		end
		local isSelectAgain = false
		local func_confirm = function()
			if againKey ~= nil and isSelectAgain then
				local _curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
				local _fixedTimeStamp = _curTimeStamp - newDayTime * 3600
				local _nYear = tonumber(os.date("!%Y", _fixedTimeStamp))
				local _nMonth = tonumber(os.date("!%m", _fixedTimeStamp))
				local _nDay = tonumber(os.date("!%d", _fixedTimeStamp))
				local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
				LocalData.SetPlayerLocalData(againKey, tostring(_nowD))
			end
			confirmCallback()
		end
		local againCallback = function(isSelect)
			isSelectAgain = isSelect
		end
		local cancelCallback = function()
			EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
		end
		local msg = {
			nType = AllEnum.MessageBox.Confirm,
			sContent = sTip,
			callbackConfirm = func_confirm,
			callbackCancel = cancelCallback,
			callbackAgain = againKey ~= nil and againCallback or nil
		}
		EventManager.Hit(EventId.OpenMessageBox, msg)
		EventManager.Hit("TopRes", true, self.nTopBarId, {
			AllEnum.CoinItemId.Jade,
			AllEnum.CoinItemId.STONE
		})
	end
	local bGetFirstTenReward = PlayerData.Gacha:GetRecvFirstTenReward(self.curPoolId)
	local GachaCallback = function(mapData)
		self:GetGachaItem(mapData, mapGacha.StorageId, bGetFirstTenReward)
		self:RefreshCoin(mapGacha)
	end
	local mapGachaStorage = ConfigTable.GetData("GachaStorage", mapGacha.StorageId)
	if mapGachaStorage == nil then
		return
	end
	local nDefaultCount = PlayerData.Item:GetItemCountByID(mapGachaStorage.DefaultId)
	if nDefaultCount >= mapGachaStorage.DefaultQty * 10 then
		PlayerData.Gacha:SendGachaReq(self.curPoolId, 2, GachaCallback)
	elseif mapGachaStorage.CostId > 0 then
		local nCostCount = PlayerData.Item:GetItemCountByID(mapGachaStorage.CostId)
		local confirmCallback = function()
			EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
			if nCostCount >= mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty * 10 - nDefaultCount) then
				PlayerData.Gacha:SendGachaReq(self.curPoolId, 2, GachaCallback)
			elseif mapGachaStorage.CostId == AllEnum.CoinItemId.Jade then
				local nNeedCount = mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty * 10 - nDefaultCount)
				local nJadeCount = PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.Jade)
				nNeedCount = nNeedCount - nJadeCount
				local mapCostCfgData = ConfigTable.GetData_Item(AllEnum.CoinItemId.STONE)
				local mapJadeCfgData = ConfigTable.GetData_Item(AllEnum.CoinItemId.Jade)
				local sTips1 = orderedFormat(ConfigTable.GetUIText("Recruit_ExchangeGemZero"), mapJadeCfgData.Id, nNeedCount, mapCostCfgData.Id)
				local confirmCallbackStone = function()
					EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
					local nCurStoneCount = PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.STONE)
					nCurStoneCount = nCurStoneCount + PlayerData.Item:GetItemCountByID(AllEnum.CoinItemId.FREESTONE)
					if nCurStoneCount >= nNeedCount then
						PlayerData.Coin:SendGemConvertReqReq(nNeedCount, nil)
					else
						local sTips2 = orderedFormat(ConfigTable.GetUIText("Recruit_Charge") or "", mapCostCfgData.Id)
						local confirmCallbackExchange = function()
							EventManager.Hit("TopRes", false, self.nTopBarId, self.tbCurTabCoin)
							EventManager.Hit(EventId.OpenPanel, PanelId.Mall, AllEnum.MallToggle.Gem)
						end
						ConfirmPanel(sTips2, confirmCallbackExchange)
					end
				end
				ConfirmPanel(sTips1, confirmCallbackStone)
			else
				EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("NotEnoughItem"))
			end
		end
		local nNeedCount = mapGachaStorage.CostQty * (mapGachaStorage.DefaultQty * 10 - nDefaultCount)
		local mapCostCfgData = ConfigTable.GetData_Item(mapGachaStorage.CostId)
		local mapDefaultCfgData = ConfigTable.GetData_Item(mapGachaStorage.DefaultId)
		local sTips
		if 0 < nDefaultCount then
			sTips = orderedFormat(ConfigTable.GetUIText("Recruit_ExchangeGem"), nDefaultCount, mapDefaultCfgData.Id, nNeedCount, mapCostCfgData.Id, mapGachaStorage.DefaultQty * 10 - nDefaultCount, mapDefaultCfgData.Id)
		else
			sTips = orderedFormat(ConfigTable.GetUIText("Recruit_Exchange"), nNeedCount, mapCostCfgData.Id, mapGachaStorage.DefaultQty * 10 - nDefaultCount, mapDefaultCfgData.Id)
		end
		ConfirmPanel(sTips, confirmCallback, "GachaShowTicketExchange")
	else
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("NotEnoughItem"))
	end
end
function GachaCtrl:OnBtnClick_Tab(goBtn, nGachaId)
	CS.WwiseAudioManager.Instance:PostEvent("ui_recuit_cover_all_stop")
	if self.curPoolId == nGachaId then
		return
	end
	self:SetTabSelect(self.curPoolId, false)
	self:SetTabSelect(nGachaId, true)
	self:SetCoverOpen(self.curPoolId, false)
	self:SetCoverOpen(nGachaId, true)
	self.curPoolId = nGachaId
	self:RefreshInfo()
	self.mapCover[self.curPoolId]:PlayInAnim()
end
function GachaCtrl:OnBtnClick_One()
	if self.bGachaProcess then
		return
	end
	CS.WwiseAudioManager.Instance:PostEvent("ui_recuit_cover_all_stop")
	local GachaCallback = function(mapData)
		local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
		if mapGacha == nil then
			return
		end
		self:RefreshCoin(mapGacha)
		self:GetGachaItem(mapData, mapGacha.StorageId)
	end
	if self.curPoolId == nil or self.curPoolId == 0 then
		return
	end
	local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGacha == nil then
		return
	end
	local mapGachaStorage = ConfigTable.GetData("GachaStorage", mapGacha.StorageId)
	if mapGachaStorage == nil then
		return
	end
	local rapidjson = require("rapidjson")
	if type(mapGachaStorage.OncePreferred) == "string" then
		local tbOne = rapidjson.decode(mapGachaStorage.OncePreferred)
		if tbOne ~= nil then
			mapGachaStorage.OncePreferred = tbOne
		else
			mapGachaStorage.OncePreferred = {}
			printError("\229\141\149\230\138\189\230\182\136\232\128\151\233\133\141\231\189\174\233\148\153\232\175\175\239\188\154" .. self.curPoolId)
			return
		end
	end
	if 0 < #mapGachaStorage.OncePreferred then
		for nIdx, mapCost in ipairs(mapGachaStorage.OncePreferred) do
			local f = pairs(mapCost)
			local sTid, nCount = f(mapCost)
			local nTid = tonumber(sTid)
			local nCurCount = PlayerData.Item:GetItemCountByID(nTid)
			if nCount <= nCurCount then
				PlayerData.Gacha:SendGachaReq(self.curPoolId, 1, GachaCallback)
				break
			end
			if nIdx == #mapGachaStorage.OncePreferred then
				self:GachaOneExchangeCoin(mapGacha)
			end
		end
	else
		self:GachaOneExchangeCoin(mapGacha)
	end
end
function GachaCtrl:OnBtnClick_Ten()
	if self.bGachaProcess then
		return
	end
	if self.curPoolId == nil or self.curPoolId == 0 then
		return
	end
	local bGetFirstTenReward = PlayerData.Gacha:GetRecvFirstTenReward(self.curPoolId)
	local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGacha == nil then
		return
	end
	CS.WwiseAudioManager.Instance:PostEvent("ui_recuit_cover_all_stop")
	local GachaCallback = function(mapData)
		local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
		if mapGacha == nil then
			return
		end
		self:RefreshCoin(mapGacha)
		self:GetGachaItem(mapData, mapGacha.StorageId, bGetFirstTenReward)
	end
	local mapGachaStorage = ConfigTable.GetData("GachaStorage", mapGacha.StorageId)
	if mapGachaStorage == nil then
		return
	end
	local rapidjson = require("rapidjson")
	if type(mapGachaStorage.TenTimesPreferred) == "string" then
		local tbTen = rapidjson.decode(mapGachaStorage.TenTimesPreferred)
		if tbTen ~= nil then
			mapGachaStorage.TenTimesPreferred = tbTen
		else
			mapGachaStorage.TenTimesPreferred = {}
			printError("\229\141\149\230\138\189\230\182\136\232\128\151\233\133\141\231\189\174\233\148\153\232\175\175\239\188\154" .. self.curPoolId)
			return
		end
	end
	if 0 < #mapGachaStorage.TenTimesPreferred then
		for nIdx, mapCost in ipairs(mapGachaStorage.TenTimesPreferred) do
			local f = pairs(mapCost)
			local sTid, nCount = f(mapCost)
			local nTid = tonumber(sTid)
			local nCurCount = PlayerData.Item:GetItemCountByID(nTid)
			if nCount <= nCurCount then
				PlayerData.Gacha:SendGachaReq(self.curPoolId, 2, GachaCallback)
				break
			end
			if nIdx == #mapGachaStorage.TenTimesPreferred then
				self:GachaTenExchangeCoin(mapGacha)
			end
		end
	else
		self:GachaTenExchangeCoin(mapGacha)
	end
end
function GachaCtrl:OnBtnClick_GachaDetail()
	self._mapNode.GachaProb.gameObject:SetActive(false)
	self._mapNode.GachaInfo:OpenInfo()
end
function GachaCtrl:OnBtnClick_ProbDetail()
	self._mapNode.GachaInfo.gameObject:SetActive(false)
	self._mapNode.GachaProb:OpenInfo()
end
function GachaCtrl:OnBtnClick_GachaHistory()
	local mapGacha = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGacha ~= nil then
		local GetDataCallback = function(tbData)
			self._mapNode.GachaHistory:OpenPanel(mapGacha.StorageId, self.curPoolId)
		end
		PlayerData.Gacha:GetGachaHistory(mapGacha.StorageId, GetDataCallback)
	end
end
function GachaCtrl:OnBtnClick_shop()
	EventManager.Hit(EventId.OpenPanel, PanelId.Mall, AllEnum.MallToggle.Shop)
end
function GachaCtrl:OnEvent_GachaPoolDetail(nIdx)
end
function GachaCtrl:GetGachaItem(mapData, nStorageId, bGetFirstTenReward)
	local tbReward = {}
	local mapRewardItem = {}
	local rare = 3
	local tbGiveItems = {}
	local nStorage = 0
	local mapGachaData = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGachaData ~= nil then
		nStorage = mapGachaData.StorageId
		local mapStorage = ConfigTable.GetData("GachaStorage", nStorage)
		if mapStorage ~= nil then
			local sGiveItem = mapStorage.GiveItems
			local mapDecodeItems = decodeJson(sGiveItem)
			for nTid, nCount in pairs(mapDecodeItems) do
				table.insert(tbGiveItems, {
					Tid = tonumber(nTid),
					Qty = tonumber(nCount)
				})
			end
		end
	end
	local mapChangeInfo = UTILS.DecodeChangeInfo(mapData.Change)
	local tbAcquire = mapChangeInfo["proto.Acquire"]
	if tbAcquire ~= nil then
		tbAcquire = tbAcquire[1]
	end
	if tbAcquire == nil then
		tbAcquire = {}
	end
	local GetRewardItem = function(nIdx, nTid)
		local ret = {}
		local nNumber = 0
		for _, mapAcq in ipairs(tbAcquire.List) do
			if mapAcq.Tid == nTid then
				nNumber = mapAcq.Begin
			end
		end
		for i = 1, nIdx do
			if mapData.Cards[i].Card.Tid == nTid then
				nNumber = nNumber + 1
			end
		end
		local mapItemCfgData = ConfigTable.GetData_Item(nTid)
		if mapItemCfgData == nil then
			return ret
		end
		local nMaxCount = self._mapMaxAcquireReward[mapItemCfgData.Stype][mapItemCfgData.Rarity]
		if nMaxCount == nil then
			nMaxCount = 1
		end
		nNumber = math.min(nMaxCount, nNumber)
		local nId = mapItemCfgData.Stype * 1000 + mapItemCfgData.Rarity * 100 + nNumber
		local mapCfg = ConfigTable.GetData("AcquireReward", nId)
		if not mapCfg or mapCfg.ItemNum == 0 then
			return ret
		end
		table.insert(ret, {
			Tid = mapCfg.ItemId,
			Qty = mapCfg.ItemNum
		})
		return ret
	end
	for nIdx, v in ipairs(mapData.Cards) do
		local tbAcReward = GetRewardItem(nIdx, v.Card.Tid)
		for _, mapReward in ipairs(tbAcReward) do
			table.insert(v.Rewards, mapReward)
		end
		table.insert(tbReward, {
			id = v.Card.Tid,
			count = v.Card.Qty,
			rewardItem = v.Rewards,
			bNew = v.Card.bNew,
			exItem = tbGiveItems
		})
		local mapItem = ConfigTable.GetData_Item(v.Card.Tid)
		if mapItem ~= nil and rare > mapItem.Rarity then
			rare = mapItem.Rarity
		end
		if v.Rewards ~= nil and #v.Rewards > 0 then
			for _, mapItem in ipairs(v.Rewards) do
				if mapRewardItem[mapItem.Tid] == nil then
					mapRewardItem[mapItem.Tid] = 0
				end
				mapRewardItem[mapItem.Tid] = mapRewardItem[mapItem.Tid] + mapItem.Qty
			end
		end
	end
	local OnGachaDragOpenDoor = function()
		WwiseManger.Instance:PostEvent("music_recruit_rarity_3s")
	end
	local function OnShowFinish()
		EventManager.Remove("GaChaShowVideoEnd", self, OnShowFinish)
		EventManager.Remove("GachaDragOpenDoor", self, OnGachaDragOpenDoor)
		self.bGachaProcess = false
		if nStorage == GameEnum.gachaStorageType.DiscCardPool or nStorage == GameEnum.gachaStorageType.DiscUpCardPool then
			WwiseManger.Instance:SetState("recruit_rarity", "diskR")
		else
			WwiseManger.Instance:SetState("recruit_rarity", "R")
		end
		self:RefreshCover()
		self._mapNode.GachaShow:ShowResults(tbReward, tbGiveItems)
		PlayerData.SideBanner:TryOpenSideBanner()
	end
	local function OnShowItemEnd()
		EventManager.Remove("GachaShowItemEnd", self, OnShowItemEnd)
		if #mapData.Cards < 10 then
			CS.WwiseAudioManager.Instance:SetState("recruit_rarity", "None")
			PlayerData.Item:TryOpenFragmentsOverflow(function()
				PlayerData.Phone:CheckNewChat()
			end)
			return
		end
		self._mapNode.GachaShowResult.gameObject:SetActive(true)
		for _, mapItem in ipairs(tbGiveItems) do
			mapItem.Qty = mapItem.Qty * #tbReward
			if bGetFirstTenReward ~= nil and not bGetFirstTenReward and mapGachaData ~= nil then
				local nTimes = mapGachaData.FirstTenShow == 0 and 1 or mapGachaData.FirstTenShow
				mapItem.Qty = mapItem.Qty * nTimes
			end
		end
		self._mapNode.GachaShowResult:ShowResult(tbReward, mapRewardItem, tbGiveItems)
	end
	EventManager.Add("GachaDragOpenDoor", self, OnGachaDragOpenDoor)
	EventManager.Add("GaChaShowVideoEnd", self, OnShowFinish)
	EventManager.Add("GachaShowItemEnd", self, OnShowItemEnd)
	if not self:CheckGachaVideoRes() then
		OnShowFinish()
	else
		WwiseManger.Instance:SetState("recruit_rarity", "transition")
		if nStorage == GameEnum.gachaStorageType.DiscCardPool or nStorage == GameEnum.gachaStorageType.DiscUpCardPool then
			NovaAPI.PlayGachaDisc(self._mapNode.GachaOpenDoor, #mapData.Cards, rare)
		else
			NovaAPI.PlayGachaOpenDoor(self._mapNode.GachaOpenDoor, rare)
		end
	end
end
function GachaCtrl:CheckGachaVideoRes()
	local ProVideoManager = CS.ProVideoManager
	local File = CS.System.IO.File
	local path = ProVideoManager.GetVideoResourcePath("Gacha_001.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_002_loop.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_003.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_003_r.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_003_r_1.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_car_001.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("Gacha_car_001_r.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc_10_g.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc_10_r.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc_10_r_1.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc_g.mp4")
	if not File.Exists(path) then
		return false
	end
	path = ProVideoManager.GetVideoResourcePath("gacha_disc_r.mp4")
	if not File.Exists(path) then
		return false
	end
	return true
end
function GachaCtrl:OnEvent_GachaProcessStart(bStart)
	self.bGachaProcess = bStart
end
function GachaCtrl:GetGachaNewbieItem(mapData)
	local tbReward = {}
	local rare = 3
	local CheckNew = function(nTid)
		local mapItemCfgData = ConfigTable.GetData_Item(nTid)
		if mapItemCfgData == nil then
			return false
		end
		if mapItemCfgData.Type == GameEnum.itemType.Char then
			local mapChar = PlayerData.Char:GetCharDataByTid(nTid)
			return mapChar == nil
		elseif mapItemCfgData.Type == GameEnum.itemType.Disc then
			local mapDisc = PlayerData.Disc:GetDiscById(nTid)
			return mapDisc == nil
		else
			return false
		end
	end
	local curItem = {}
	for _, v in ipairs(mapData.Cards) do
		local mapItem = ConfigTable.GetData_Item(v)
		local bForceJump = mapItem == nil or mapItem.Rarity ~= GameEnum.itemRarity.SSR
		table.insert(tbReward, {
			id = v,
			count = 1,
			rewardItem = {},
			bForceJump = bForceJump,
			bNew = CheckNew(v) and 1 > table.indexof(curItem, v),
			exItem = {}
		})
		local mapItem = ConfigTable.GetData_Item(v)
		if mapItem ~= nil and rare > mapItem.Rarity then
			rare = mapItem.Rarity
		end
		table.insert(curItem, v)
	end
	local OnGachaDragOpenDoor = function()
		WwiseManger.Instance:PostEvent("music_recruit_rarity_3s")
	end
	local function OnShowFinish()
		EventManager.Remove("GaChaShowVideoEnd", self, OnShowFinish)
		EventManager.Remove("GachaDragOpenDoor", self, OnGachaDragOpenDoor)
		self.bGachaProcess = false
		self:RefreshCover()
		self._mapNode.GachaShow:ShowResults(tbReward, {})
		PlayerData.SideBanner:TryOpenSideBanner()
	end
	local function OnShowItemEnd()
		EventManager.Remove("GachaShowItemEnd", self, OnShowItemEnd)
		WwiseManger.Instance:SetState("recruit_rarity", "R")
		if #mapData.Cards < 10 then
			CS.WwiseAudioManager.Instance:SetState("recruit_rarity", "None")
			PlayerData.Item:TryOpenFragmentsOverflow(function()
				PlayerData.Phone:CheckNewChat()
			end)
			return
		end
		self._mapNode.GachaNewBieShowResult.gameObject:SetActive(true)
		self._mapNode.GachaNewBieShowResult:ShowResult(tbReward, self.curPoolId)
	end
	EventManager.Add("GachaDragOpenDoor", self, OnGachaDragOpenDoor)
	EventManager.Add("GaChaShowVideoEnd", self, OnShowFinish)
	EventManager.Add("GachaShowItemEnd", self, OnShowItemEnd)
	if not self:CheckGachaVideoRes() then
		OnShowFinish()
	else
		WwiseManger.Instance:SetState("recruit_rarity", "transition")
		NovaAPI.PlayGachaOpenDoor(self._mapNode.GachaOpenDoor, rare)
	end
end
function GachaCtrl:OnEvent_GachaNewbieSpin()
	self:OnBtnClick_NewBieJump()
end
function GachaCtrl:OnEvent_GachaNewbieRecord()
	self:OnBtnClick_NewBieJumpRecord()
end
function GachaCtrl:OnEvent_GachaNewbieObtainRecord(idx, items)
	self._mapNode.GachaNewBieObtainResult:SetItems(self.curPoolId, idx, items)
	self._mapNode.GachaNewBieObtainResult.gameObject:SetActive(true)
end
function GachaCtrl:OnEvent_GachaNewbieSaveRecord()
	local newbie = ConfigTable.GetData("GachaNewbie", self.curPoolId)
	if newbie == nil then
		return
	end
	local newbieData = PlayerData.Gacha:GetGachaNewbieData(self.curPoolId)
	if newbieData == nil then
		return
	end
	if #newbieData.Temp == 0 then
		return
	end
	if #newbieData.Cards < newbie.SaveCount then
		local GachaCallback = function(mapData)
			self:RefreshInfo()
			self._mapNode.GachaNewBieShowResult:RefreshInfo()
			EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Gacha_NewBieSaveTip"))
		end
		PlayerData.Gacha:SendGachaNewbieSaveReq(self.curPoolId, 0, GachaCallback)
		return
	end
	self._mapNode.GachaNewBieSaveRecord:SetItems(self.curPoolId)
	self._mapNode.GachaNewBieSaveRecord.gameObject:SetActive(true)
end
function GachaCtrl:OnEvent_GachaNewbieReplaceRecord(idx)
	self._mapNode.GachaNewBieReplaceResult:SetItems(self.curPoolId, idx)
	self._mapNode.GachaNewBieReplaceResult.gameObject:SetActive(true)
end
function GachaCtrl:OnEvent_GachaNewbieReplaceRecordOver()
	self:RefreshInfo()
	self._mapNode.GachaNewBieShowResult:RefreshInfo()
	self._mapNode.GachaNewBieReplaceResult.gameObject:SetActive(false)
	self._mapNode.GachaNewBieSaveRecord.gameObject:SetActive(false)
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Gacha_NewBieSaveTip"))
end
function GachaCtrl:OnEvent_GachaNewbieObtainRecordOver(changes, items, tbNew)
	local tbReward = {}
	local mapRewardItem = {}
	local rare = 3
	local tbGiveItems = {}
	if tbNew == nil then
		tbNew = {}
	end
	local mapGachaData = ConfigTable.GetData("Gacha", self.curPoolId)
	if mapGachaData ~= nil then
		local nStorage = mapGachaData.StorageId
		local mapStorage = ConfigTable.GetData("GachaStorage", nStorage)
		if mapStorage ~= nil then
			local sGiveItem = mapStorage.GiveItems
			local mapDecodeItems = decodeJson(sGiveItem)
			for nTid, nCount in pairs(mapDecodeItems) do
				table.insert(tbGiveItems, {
					Tid = tonumber(nTid),
					Qty = tonumber(nCount)
				})
			end
		end
	end
	local mapChangeInfo = UTILS.DecodeChangeInfo(changes)
	local tbAcquire = mapChangeInfo["proto.Acquire"]
	if tbAcquire ~= nil then
		tbAcquire = tbAcquire[1]
	end
	if tbAcquire == nil then
		tbAcquire = {}
	end
	local GetRewardItem = function(nIdx, nTid)
		local ret = {}
		local nNumber = 0
		for _, mapAcq in ipairs(tbAcquire.List) do
			if mapAcq.Tid == nTid then
				nNumber = mapAcq.Begin
			end
		end
		for i = 1, nIdx do
			if items[i] == nTid then
				nNumber = nNumber + 1
			end
		end
		local mapItemCfgData = ConfigTable.GetData_Item(nTid)
		if mapItemCfgData == nil then
			return ret
		end
		local nMaxCount = self._mapMaxAcquireReward[mapItemCfgData.Stype][mapItemCfgData.Rarity]
		if nMaxCount == nil then
			nMaxCount = 1
		end
		nNumber = math.min(nMaxCount, nNumber)
		local nId = mapItemCfgData.Stype * 1000 + mapItemCfgData.Rarity * 100 + nNumber
		local mapCfg = ConfigTable.GetData("AcquireReward", nId)
		if not mapCfg or mapCfg.ItemNum == 0 then
			return ret
		end
		table.insert(ret, {
			Tid = mapCfg.ItemId,
			Qty = mapCfg.ItemNum
		})
		return ret
	end
	for nIdx, v in ipairs(items) do
		local tbAcReward = GetRewardItem(nIdx, v)
		local rewards = {}
		for _, mapReward in ipairs(tbAcReward) do
			table.insert(rewards, mapReward)
		end
		table.insert(tbReward, {
			id = v,
			count = 1,
			rewardItem = rewards,
			bNew = tbNew[nIdx] or false,
			exItem = tbGiveItems
		})
		local mapItem = ConfigTable.GetData_Item(v)
		if mapItem ~= nil and rare > mapItem.Rarity then
			rare = mapItem.Rarity
		end
		if rewards ~= nil and 0 < #rewards then
			for _, mapItem in ipairs(rewards) do
				if mapRewardItem[mapItem.Tid] == nil then
					mapRewardItem[mapItem.Tid] = 0
				end
				mapRewardItem[mapItem.Tid] = mapRewardItem[mapItem.Tid] + mapItem.Qty
			end
		end
	end
	local function OnShowItemEnd()
		EventManager.Remove("GachaShowItemEnd", self, OnShowItemEnd)
		if #items < 10 then
			CS.WwiseAudioManager.Instance:SetState("recruit_rarity", "None")
			PlayerData.Item:TryOpenFragmentsOverflow(function()
				PlayerData.Phone:CheckNewChat()
			end)
			return
		end
		self._mapNode.GachaShowResult.gameObject:SetActive(true)
		for _, mapItem in ipairs(tbGiveItems) do
			mapItem.Qty = mapItem.Qty * #tbReward
		end
		self._mapNode.GachaShowResult:ShowResult(tbReward, mapRewardItem, tbGiveItems)
		self:RefreshAll()
	end
	EventManager.Add("GachaShowItemEnd", self, OnShowItemEnd)
	self._mapNode.GachaNewBieObtainResult.gameObject:SetActive(false)
	self._mapNode.GachaNewBieShowRecord.gameObject:SetActive(false)
	self._mapNode.GachaNewBieShowResult.gameObject:SetActive(false)
	self:RefreshCover()
	self._mapNode.GachaShow:ShowResults(tbReward, tbGiveItems)
	PlayerData.SideBanner:TryOpenSideBanner()
end
function GachaCtrl:OnBtnClick_NewBieJump()
	if self.bGachaProcess then
		return
	end
	local GachaCallback = function(mapData)
		self:GetGachaNewbieItem(mapData)
		self:RefreshInfo()
		self:RefreshCover()
		self._mapNode.GachaNewBieShowResult:RefreshInfo()
	end
	local newbieData = PlayerData.Gacha:GetGachaNewbieData(self.curPoolId)
	if newbieData == nil then
		return
	end
	local newbie = ConfigTable.GetData("GachaNewbie", self.curPoolId)
	if newbie == nil then
		return
	end
	if newbieData.Times < newbie.SpinCount then
		PlayerData.Gacha:SendGachaNewbieReq(self.curPoolId, GachaCallback)
	else
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Gacha_NewBieSummonLimit"))
	end
end
function GachaCtrl:OnBtnClick_NewBieJumpRecord()
	local newbieData = PlayerData.Gacha:GetGachaNewbieData(self.curPoolId)
	if newbieData ~= nil then
		if #newbieData.Cards == 0 and #newbieData.Temp == 0 then
			EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Gacha_NewBieNoRecordTip"))
		else
			self._mapNode.GachaNewBieShowRecord:SetPoolId(self.curPoolId)
			self._mapNode.GachaNewBieShowRecord.gameObject:SetActive(true)
		end
	else
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Gacha_NewBieNoRecordTip"))
	end
end
return GachaCtrl
