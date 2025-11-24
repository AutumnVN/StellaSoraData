local DatingCtrl = class("DatingCtrl", BaseCtrl)
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResTypeAny = GameResourceLoader.ResType.Any
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local Path = require("path")
local typeof = typeof
local Offset = CS.Actor2DOffsetData
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local TimerManager = require("GameCore.Timer.TimerManager")
local BubbleVoiceManager = require("Game.Actor2D.BubbleVoiceManager")
DatingCtrl._mapNodeConfig = {
	animRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	imgBgRT = {
		sNodeName = "----Actor2D----",
		sComponentName = "RawImage"
	},
	rtImgBgRT = {
		sNodeName = "----Actor2D----",
		sComponentName = "RectTransform"
	},
	rtOffScreenRoot = {
		sNodeName = "----Actor2D_Node----",
		sComponentName = "Transform"
	},
	trCamera = {
		sNodeName = "OffScreen3DCamera",
		sComponentName = "Camera"
	},
	bgLandmark = {
		sComponentName = "SpriteRenderer"
	},
	trCharacter = {sNodeName = "animator", sComponentName = "Transform"},
	trPanelOffsetL2D = {
		sNodeName = "panel_offset",
		sComponentName = "Transform"
	},
	trActorOffsetL2d = {
		sNodeName = "actor_offset",
		sComponentName = "Transform"
	},
	trL2D = {sNodeName = "L2D", sComponentName = "Transform"},
	trPng = {sNodeName = "PNG", sComponentName = "Transform"},
	spr_body = {
		sNodeName = "sp_body",
		sComponentName = "SpriteRenderer"
	},
	spr_face = {
		sNodeName = "sp_face",
		sComponentName = "SpriteRenderer"
	},
	trEmojiRoot = {
		sNodeName = "----emoji----",
		sComponentName = "Transform"
	},
	cvEmojiRoot = {
		sNodeName = "----emoji----",
		sComponentName = "Canvas"
	},
	trEmoji = {sNodeName = "emoji_root", sComponentName = "Transform"},
	txtLandmark = {sComponentName = "TMP_Text"},
	imgTimeBg1 = {},
	goEvent = {
		sCtrlName = "Game.UI.Phone.Dating.DatingEventCtrl"
	},
	goSendGift = {
		sCtrlName = "Game.UI.Phone.Dating.DatingGiftCtrl"
	},
	goBubble = {},
	animBubble = {sNodeName = "goBubble", sComponentName = "Animator"},
	txtBubble = {sComponentName = "TMP_Text"},
	imgAffinityBg = {},
	txtAffinityCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "Phone_Gift_Affinity"
	},
	txtAffinityValue = {sComponentName = "TMP_Text"},
	imgMsgDetail = {
		sNodeName = "imgMsgDetail",
		sComponentName = "Image"
	},
	txtNotice = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Book_Close_Tip"
	},
	aniMsgDetail = {
		sNodeName = "rtImgMsgDetail",
		sComponentName = "Animator"
	},
	btnSnapShot = {
		sNodeName = "snapshot",
		sComponentName = "Button",
		callback = "OnBtnClick_HideImgMsg"
	}
}
DatingCtrl._mapEventConfig = {
	DatingEventAction = "OnEvent_DatingEventAction",
	DatingSendGift = "OnEvent_DatingSendGift",
	DatingEventFinish = "OnEvent_DatingEventFinish",
	DatingSendGiftFinish = "OnEvent_DatingSendGiftFinish",
	CloseDatingPanel = "OnEvent_CloseDatingPanel",
	[EventId.AvgVoiceDuration] = "OnEvent_AvgVoiceDuration",
	DatingOptionSelected = "OnEvent_DatingOptionSelected",
	DatingShowImgMsg = "OnBtnClick_DatingShowImgMsg"
}
local type_event = 1
local type_gift = 2
function DatingCtrl:CreateRT()
end
function DatingCtrl:ReleaseRT()
end
function DatingCtrl:GetOffsetData(sOffset)
	local objOffset = self:LoadAsset(sOffset, typeof(Offset))
	local nPanelId = self:GetOffsetPanelId()
	if nil == objOffset then
		printError(string.format("\231\186\166\228\188\154\230\181\129\231\168\139\231\149\140\233\157\162 \229\138\160\232\189\189\229\129\143\231\167\187\230\149\176\230\141\174\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129panelId = %s, \229\138\160\232\189\189\232\183\175\229\190\132[%s]", nPanelId, sOffset))
		return Vector3.zero, Vector3.one
	end
	local nX, nY = 0, 0
	local s, x, y = objOffset:GetOffsetData(nPanelId, indexOfPose("a"), true, nX, nY)
	local vPos = Vector3(x, y, 0)
	local vScale = Vector3(s, s, 1)
	return vPos, vScale
end
function DatingCtrl:GetOffsetPanelId()
	local nShowPanelId = self:GetPanelId()
	local tbConfig = Actor2DManager.GetMapPanelConfig(nShowPanelId)
	if nil ~= tbConfig and tbConfig.nReuse > 0 then
		nShowPanelId = tbConfig.nReuse
	end
	return nShowPanelId
end
function DatingCtrl:CheckUseL2D()
	local bL2D = false
	local tbConfig = Actor2DManager.GetMapPanelConfig(self:GetPanelId())
	if nil ~= tbConfig then
		bL2D = tbConfig.bL2D and LocalSettingData.mapData.UseLive2D
	end
	return bL2D
end
function DatingCtrl:GetName(sPortrait, sFace)
	local sFileFullName = Path.basename(sPortrait)
	local sFileExtName = Path.extension(sPortrait)
	local sFileName = string.gsub(sFileFullName, sFileExtName, "")
	sFileName = string.gsub(sFileName, "_a", "")
	local sBodyName = string.format("%s_%s", sFileName, "001")
	local sFaceName = string.format("%s_%s", sFileName, sFace)
	return sBodyName, sFaceName
end
function DatingCtrl:SetCharacterPng(nSkinId)
	local bSetSuccess, nT, nAnimLength, tbRenderer = Actor2DManager.SetActor2DWithRender(self._panel._nPanelId, self._mapNode.imgBgRT, self._panel.nCharId, nSkinId, nil, self._mapNode.rtOffScreenRoot)
end
function DatingCtrl:SetCharacterL2D(nSkinId)
	if nil ~= self.goL2D then
		if self.goL2D.nSkinId == nSkinId then
			return
		end
		self.goL2D.tbRenderer.trL2DIns.gameObject:SetActive(false)
	end
	local skinCfgData = ConfigTable.GetData_CharacterSkin(nSkinId)
	local bSetSuccess, nT, nAnimLength, tbRenderer = Actor2DManager.SetActor2DWithRender(self._panel._nPanelId, self._mapNode.imgBgRT, self._panel.nCharId, nSkinId, nil, self._mapNode.rtOffScreenRoot)
	if bSetSuccess then
		self.goL2D = {}
		self.goL2D.nSkinId = nSkinId
		self.goL2D.tbRenderer = tbRenderer
	end
	NovaAPI.SetSpriteRendererSprite(self._mapNode.bgRight, self:LoadAsset(skinCfgData.Bg .. ".png", typeof(Sprite)))
end
function DatingCtrl:SetCharacter()
	local mapChar = ConfigTable.GetData_Character(self._panel.nCharId)
	if mapChar == nil then
		return
	end
	local nSkinId = mapChar.DefaultSkinId
	local bL2D = self:CheckUseL2D()
	local nType = AllEnum.Actor2DType.Normal
	if bL2D then
		self:SetCharacterL2D(nSkinId, nType)
	else
		self:SetCharacterPng(nSkinId, nType)
	end
	self._mapNode.trL2D.gameObject:SetActive(bL2D)
	self._mapNode.trPng.gameObject:SetActive(not bL2D)
	local skinCfgData = ConfigTable.GetData_CharacterSkin(nSkinId)
	local vPos, vScale = self:GetOffsetData(skinCfgData.Offset)
	self._mapNode.trActorOffsetL2d.localPosition = vPos
	self._mapNode.trActorOffsetL2d.localScale = vScale
	local nShowPanelId = self:GetPanelId()
	local tbPanelOffsetData = Actor2DManager.GetMapPanelConfig(nShowPanelId)
	local x, y, s = 0, 0, 1
	if tbPanelOffsetData ~= nil then
		if 0 < tbPanelOffsetData.nReuse then
			x = tbPanelOffsetData.v3PanelOffset.x
			y = tbPanelOffsetData.v3PanelOffset.y
			s = tbPanelOffsetData.v3PanelOffset.z
		end
		if s <= 0 then
			s = 1
		end
	end
	self._mapNode.trPanelOffsetL2D.localPosition = Vector3(x, y, 0)
	self._mapNode.trPanelOffsetL2D.localScale = Vector3(s, s, 1)
end
function DatingCtrl:SetLandmarkBg()
	local mapCfg = ConfigTable.GetData("DatingLandmark", self._panel.nLandmark)
	if mapCfg ~= nil then
		local sPath = string.format("ImageAvg/AvgBg/%s.png", mapCfg.Bg)
		NovaAPI.SetSpriteRendererSprite(self._mapNode.bgLandmark, self:LoadAsset(sPath, typeof(Sprite)))
	end
end
local mapCharEmoji = {}
local tbCharEmoji = {}
local nLayerIndex = 0
local timerEmoji
local LoadPresetEmoji = function()
	local sPath = "Game.UI.Avg.AvgPreset"
	local AvgPreset = require(sPath)
	for _, v in ipairs(AvgPreset.CharEmoji) do
		local sEmojiName = v[3]
		local sEmojiSound = v[4] or ""
		local bIsLoop = v[5] or false
		mapCharEmoji[sEmojiName] = sEmojiSound
		table.insert(tbCharEmoji, sEmojiName)
	end
	package.loaded[sPath] = nil
	AvgPreset = nil
	nLayerIndex = CS.UnityEngine.LayerMask.NameToLayer("Cam_Layer_4")
end
function DatingCtrl:SetEmoji(sEmoji)
	local mapCharCfg = ConfigTable.GetData_Character(self._panel.nCharId)
	if mapCharCfg == nil then
		return
	end
	local nSkinId = mapCharCfg.DefaultSkinId
	local sFullPath = string.format("Actor2D/Character/%s/%s.asset", nSkinId, nSkinId)
	local objOffset = self:LoadAsset(sFullPath, typeof(Offset))
	if objOffset == nil then
		return
	end
	local sPose = "a"
	local nX, nY = 0, 0
	local s, x, y = objOffset:GetEmojiData(self:GetOffsetPanelId(), indexOfPose(sPose), table.indexof(tbCharEmoji, sEmoji), nX, nY)
	local v3OffsetPos = Vector3(x, y, 0)
	local v3OffsetScale = Vector3(s, math.abs(s), 1)
	if timerEmoji ~= nil then
		timerEmoji:Cancel(true)
	end
	local sEmojiFullPath = string.format("UI/Avg/AnimEmoji/%s.prefab", sEmoji)
	local goEmojiIns = self:CreatePrefabInstance(sEmojiFullPath, self._mapNode.trEmoji)
	goEmojiIns.transform:SetLayerRecursively(nLayerIndex)
	local animator = goEmojiIns:GetComponent("Animator")
	if animator ~= nil then
		animator:SetTrigger("tIn")
	end
	self._mapNode.trEmoji.anchoredPosition3D = v3OffsetPos
	self._mapNode.trEmoji.localScale = v3OffsetScale
	local sEmojiSoundName = mapCharEmoji[sEmoji]
	if sEmojiSoundName ~= nil then
		CS.WwiseAudioManager.Instance:PlaySound(sEmojiSoundName)
	end
	timerEmoji = TimerManager.Add(1, 3, Actor2DManager, function()
		destroy(goEmojiIns)
		timerEmoji = nil
	end, true, true, true, nil)
end
function DatingCtrl:SetBubble(sContent, nDuration)
	if sContent == nil or sContent == "" then
		return
	end
	self._mapNode.goBubble.gameObject:SetActive(true)
	self._mapNode.animBubble:SetTrigger("tIn")
	sContent = string.gsub(sContent, "==RT==", "\n")
	sContent = string.gsub(sContent, "==PLAYER_NAME==", PlayerData.Base:GetPlayerNickName())
	NovaAPI.SetTMPText(self._mapNode.txtBubble, sContent)
	nDuration = nDuration == nil and 2 or nDuration
	self:AddTimer(1, nDuration, function()
		self._mapNode.animBubble:SetTrigger("tOut")
	end, true, true, true, nil)
end
function DatingCtrl:LoadEventConfig(tbEventId)
	local tbTempEvent = {}
	for _, v in ipairs(tbEventId) do
		local mapEventCfg
		if v.nType == GameEnum.DatingEventType.BranchA or v.nType == GameEnum.DatingEventType.BranchB then
			mapEventCfg = ConfigTable.GetData("DatingBranch", v.nId)
			if nil ~= mapEventCfg then
				local tbOptions = {}
				for k, nOptId in pairs(self.tbBranchOptionIds) do
					if mapEventCfg["Option" .. nOptId] ~= "" then
						table.insert(tbOptions, {
							nOptId = nOptId,
							sOpt = mapEventCfg["Option" .. nOptId]
						})
					end
				end
				local data = {nId = v, tbOptions = tbOptions}
				table.insert(self.tbAllEvent, data)
				table.insert(tbTempEvent, data)
			end
		elseif v.nType == GameEnum.DatingEventType.BeforeBranch or v.nType == GameEnum.DatingEventType.AfterBranch or v.nType == GameEnum.DatingEventType.Landmark then
			mapEventCfg = ConfigTable.GetData("DatingLandmarkEvent", v.nId)
		elseif v.nType == GameEnum.DatingEventType.LimitedLandmark or v.nType == GameEnum.DatingEventType.Regular then
			mapEventCfg = ConfigTable.GetData("DatingCharacterEvent", v.nId)
		elseif v.nType == GameEnum.DatingEventType.Start or v.nType == GameEnum.DatingEventType.End then
			mapEventCfg = ConfigTable.GetData("DatingStartEndEvent", v.nId)
		end
		if mapEventCfg ~= nil and v.nType ~= GameEnum.DatingEventType.BranchA and v.nType ~= GameEnum.DatingEventType.BranchB then
			local nEventAffinity = ConfigTable.GetConfigNumber("Dating_Event_Base_Affinity") + mapEventCfg.Affinity
			local bSpecial = false
			local sCG = ""
			if mapEventCfg.DatingEventType == GameEnum.DatingEventType.LimitedLandmark then
				if mapEventCfg.CG ~= nil then
					sCG = mapEventCfg.CG
				end
				local param = mapEventCfg.DatingEventParams
				if #param == 2 and tonumber(param[1]) == self._panel.nCharId and tonumber(param[2]) == self._panel.nLandmark then
					bSpecial = true
				end
			end
			local nMaxDescCount = 0
			for i = 3, 1, -1 do
				if mapEventCfg["Desc" .. i] ~= "" then
					nMaxDescCount = i
					break
				end
			end
			for i = 1, 3 do
				if mapEventCfg["Desc" .. i] ~= "" then
					local bLast = i == nMaxDescCount
					local nAffinity = nEventAffinity
					local data = {
						nEventId = v,
						bSpecial = bSpecial,
						sDesc = mapEventCfg["Desc" .. i],
						bLast = bLast,
						nAffinity = nAffinity,
						sResponse = mapEventCfg.Response
					}
					table.insert(self.tbAllEvent, data)
					table.insert(tbTempEvent, data)
				end
			end
			if sCG ~= "" then
				self.tbAllEvent[#self.tbAllEvent].sCG = sCG
				tbTempEvent[#tbTempEvent].sCG = sCG
			end
		end
	end
	return tbTempEvent
end
function DatingCtrl:ClosePanel()
	local func = function()
		EventManager.Hit(EventId.ClosePanel, PanelId.Dating)
	end
	EventManager.Hit(EventId.SetTransition, 11, func)
end
function DatingCtrl:ShowReward()
	UTILS.OpenReceiveByDisplayItem(self.msgData.Show, self.msgData.Change, function()
		local nCharId = self._panel.nCharId
		if self.msgData.Info ~= nil then
			local nLastLevel = self.curAffinityInfo.Level
			local nLastExp = self.curAffinityInfo.Exp
			local mapDelay = {
				nCharId = nCharId,
				nCurLevel = self.msgData.Info.AffinityLevel,
				nLastLevel = nLastLevel,
				nCurExp = self.msgData.Info.AffinityExp,
				nLastExp = nLastExp
			}
			PlayerData.Dating:SetCharFavourLevelUpDelay(mapDelay)
		end
		self:ClosePanel()
	end, 0, AllEnum.ReceivePropsTitle.Dating)
end
function DatingCtrl:Awake()
	self.nPanelType = 0
	self._mapNode.goBubble.gameObject:SetActive(false)
	self._mapNode.imgTimeBg1.gameObject:SetActive(false)
	LoadPresetEmoji()
end
function DatingCtrl:FadeIn()
	EventManager.Hit(EventId.SetTransition)
end
function DatingCtrl:OnEnable()
	self.nOptionSelected = 0
	self.nTotalValue = 0
	self:CreateRT()
	if nil == self.uiRoot then
		self.uiRoot = PanelManager.GetUIRoot(self._panel._sSortingLayerName)
	end
	if nil ~= self.uiRoot then
		self._mapNode.rtOffScreenRoot:SetParent(self.uiRoot)
		self._mapNode.rtOffScreenRoot.localScale = Vector3.one
		self._mapNode.trEmojiRoot.localPosition = Vector3.zero
		self._mapNode.trEmojiRoot.localScale = Vector3(0.01, 0.01, 0.01)
		NovaAPI.SetCanvasWorldCamera(self._mapNode.cvEmojiRoot, self._mapNode.OffScreen3DCamera)
	end
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self._panel.nLandmark = tbParam[1]
		self._panel.nCharId = tbParam[2]
		local tbEventId = tbParam[3]
		self.tbEventId = {
			{
				nId = tbEventId,
				nType = GameEnum.DatingEventType.BeforeBranch
			}
		}
		self.curAffinityInfo = tbParam[4]
		self.tbBranchOptionIds = tbParam[5]
		self.tbReward = tbParam[6]
		self.bFirstOption = true
		local nStartId = PlayerData.Dating:GetCharStartEventId(self._panel.nCharId)
		if nStartId ~= nil then
			table.insert(self.tbEventId, 1, {
				nId = nStartId,
				nType = GameEnum.DatingEventType.Start
			})
		end
		local nBranchAId = PlayerData.Dating:GetCharBranchEventId(self._panel.nCharId, true)
		if nBranchAId ~= 0 then
			table.insert(self.tbEventId, {
				nId = nBranchAId,
				nType = GameEnum.DatingEventType.BranchA
			})
		end
		NovaAPI.SetTMPText(self._mapNode.txtAffinityValue, 0)
		self:SetLandmarkBg()
		self:SetCharacter()
		self:StartShowEvent()
	end
end
function DatingCtrl:OnDisable()
	self._mapNode.rtOffScreenRoot:SetParent(self.gameObject.transform)
	if self.goL2D ~= nil and self.goL2D.tbRenderer ~= nil then
		Actor2DManager.UnSetActor2DWithRender(self.goL2D.tbRenderer)
	end
	if self.charVoiceTimer ~= nil then
		self.charVoiceTimer:Cancel()
		self.charVoiceTimer = nil
	end
	BubbleVoiceManager.StopBubbleAnim(true)
end
function DatingCtrl:OnDestroy()
end
function DatingCtrl:OnEvent_DatingEventAction(nCurIndex, sResponse, nAffinity)
	self.nCurIndex = nCurIndex
	if sResponse ~= nil then
		local sType = sResponse
		local mapCharResponseCfg = CacheTable.GetData("_DatingCharResponse", self._panel.nCharId)
		if mapCharResponseCfg == nil then
			printError(string.format("\232\167\146\232\137\178%s\230\178\161\230\156\137\233\133\141\231\189\174Response", self._panel.nCharId))
			return
		end
		local cfgData = mapCharResponseCfg[sType]
		if cfgData ~= nil then
			PlayerData.Voice:PlayCharVoice(cfgData.VoiceKey, self._panel.nCharId)
			if self.goL2D ~= nil then
				Actor2DManager.PlayL2DAnim(self.goL2D.tbRenderer.trL2DIns.transform, cfgData.Action, false, true)
			end
			self:SetEmoji(cfgData.BubbleEmoji)
			self:SetBubble(cfgData.Words)
		end
		local twValue = DOTween.To(function()
			return self.nTotalValue
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtAffinityValue, self:ThousandsNumber(math.floor(v)))
		end, self.nTotalValue + nAffinity, 0.5)
		local _cb = function()
			self.nTotalValue = self.nTotalValue + nAffinity
		end
		twValue.onComplete = dotween_callback_handler(self, _cb)
	end
end
function DatingCtrl:OnEvent_DatingSendGift()
	self.nPanelType = type_gift
	self._mapNode.animRoot:Play("DatingPanel_Gift_in")
	self:AddTimer(1, 0.1, function()
		self._mapNode.goEvent.gameObject:SetActive(false)
		self._mapNode.goSendGift.gameObject:SetActive(true)
		self._mapNode.imgTimeBg1.gameObject:SetActive(true)
	end, true, true, true)
	self._mapNode.goSendGift:RefreshSendGift()
end
function DatingCtrl:OnEvent_DatingEventFinish()
	self._mapNode.animRoot:Play("DatingPanel_end")
	if self.nCurIndex == #self.tbAllEvent then
		return
	end
	local nAddValue = 0
	for i = self.nCurIndex + 1, #self.tbAllEvent do
		if self.tbAllEvent[i].bLast then
			nAddValue = nAddValue + self.tbAllEvent[i].nAffinity
		end
	end
	local twValue = DOTween.To(function()
		return self.nTotalValue
	end, function(v)
		NovaAPI.SetTMPText(self._mapNode.txtAffinityValue, self:ThousandsNumber(math.floor(v)))
	end, self.nTotalValue + nAddValue, 0.5)
	local _cb = function()
		self.nTotalValue = self.nTotalValue + nAddValue
	end
	twValue.onComplete = dotween_callback_handler(self, _cb)
	self.nCurIndex = #self.tbAllEvent
end
function DatingCtrl:OnEvent_DatingSendGiftFinish(sVoiceKey, msgData)
	self.msgData = msgData
	self.bPlayCharVoice = false
	self.nGiftVoiceId = PlayerData.Voice:PlayCharVoice(sVoiceKey, self._panel.nCharId)
	self.charVoiceTimer = self:AddTimer(1, 0.5, function()
		if not self.bPlayCharVoice then
			self:ShowReward()
		end
		self.charVoiceTimer = nil
	end, true, true, true)
end
function DatingCtrl:OnEvent_CloseDatingPanel()
	local nCharId = self._panel.nCharId
	self:ClosePanel()
	local nLastLevel = self.curAffinityInfo.Level
	local mapCharAffinity = ConfigTable.GetData("CharAffinityTemplate", nCharId)
	if mapCharAffinity == nil then
		return
	end
	local templateId = mapCharAffinity.TemplateId
	local nMaxAffinityLevel = PlayerData.Char:GetMaxAffinityLevel(templateId)
	if nLastLevel < nMaxAffinityLevel then
		local nLastExp = self.curAffinityInfo.Exp
		local curData = PlayerData.Char:GetCharAffinityData(nCharId)
		local mapDelay = {
			nCharId = nCharId,
			nCurLevel = curData.Level,
			nLastLevel = nLastLevel,
			nCurExp = curData.Exp,
			nLastExp = nLastExp
		}
		PlayerData.Dating:SetCharFavourLevelUpDelay(mapDelay)
	end
end
function DatingCtrl:OnEvent_AvgVoiceDuration(nDuration)
	if self.nGiftVoiceId ~= nil then
		local mapVoiceCfg = ConfigTable.GetData("VoDirectory", self.nGiftVoiceId)
		if mapVoiceCfg == nil then
			return
		end
		self.bPlayCharVoice = true
		if self.goL2D ~= nil then
			Actor2DManager.PlayL2DAnim(self.goL2D.tbRenderer.trL2DIns.transform, mapVoiceCfg.motion, false, true)
		end
		self._mapNode.goBubble.gameObject:SetActive(true)
		BubbleVoiceManager.PlayFixedBubbleAnim(self._mapNode.goBubble, mapVoiceCfg.voResource)
		if nDuration ~= nil and 0 < nDuration then
			self:AddTimer(1, nDuration, function()
				self:ShowReward()
			end, true, true, true)
			EventManager.Hit(EventId.TemporaryBlockInput, nDuration)
		else
			self:ShowReward()
		end
	end
end
function DatingCtrl:OnBtnClick_DatingShowImgMsg(iconPath)
	self:SetPngSprite(self._mapNode.imgMsgDetail, iconPath)
	NovaAPI.SetImageNativeSize(self._mapNode.imgMsgDetail)
	self._mapNode.aniMsgDetail:Play("showMsg")
end
function DatingCtrl:OnBtnClick_HideImgMsg()
	self._mapNode.aniMsgDetail:Play("hideMsg")
end
function DatingCtrl:StartShowEvent()
	self.nPanelType = type_event
	local mapLandmarkCfg = ConfigTable.GetData("DatingLandmark", self._panel.nLandmark)
	if mapLandmarkCfg ~= nil then
		NovaAPI.SetTMPText(self._mapNode.txtLandmark, mapLandmarkCfg.Name)
	end
	self._mapNode.goEvent.gameObject:SetActive(true)
	self._mapNode.goSendGift.gameObject:SetActive(false)
	self.tbAllEvent = {}
	self.tbAllEvent = self:LoadEventConfig(self.tbEventId)
	self.nCurIndex = 0
	self._mapNode.goEvent:SetEventList(self.tbAllEvent, self.tbEventId)
end
function DatingCtrl:OnEvent_DatingOptionSelected(nOptionIndex)
	local callback = function(_, msgData)
		local tbNewEvents = {}
		if self.bFirstOption then
			self.bFirstOption = false
			for k, v in pairs(msgData.LandmarkEventIds) do
				table.insert(tbNewEvents, {
					nId = v,
					nType = GameEnum.DatingEventType.Landmark
				})
			end
			table.sort(tbNewEvents, function(a, b)
				local cfgDataA = ConfigTable.GetData("DatingLandmarkEvent", a.nId)
				local cfgDataB = ConfigTable.GetData("DatingLandmarkEvent", b.nId)
				if cfgDataA ~= nil and cfgDataB ~= nil then
					return cfgDataA.SortTag < cfgDataB.SortTag
				end
			end)
			local nBranchBId = PlayerData.Dating:GetCharBranchEventId(self._panel.nCharId, false)
			if nBranchBId ~= 0 then
				table.insert(tbNewEvents, {
					nId = nBranchBId,
					nType = GameEnum.DatingEventType.BranchA
				})
			end
			self.tbBranchOptionIds = msgData.BranchBOptionIds
		else
			table.insert(tbNewEvents, {
				nId = msgData.CharacterEventId,
				nType = GameEnum.DatingEventType.LimitedLandmark
			})
			table.insert(tbNewEvents, {
				nId = msgData.AfterBranchId,
				nType = GameEnum.DatingEventType.AfterBranch
			})
			local nEndId = PlayerData.Dating:GetCharEndEventId(self._panel.nCharId)
			if nEndId ~= nil then
				table.insert(tbNewEvents, {
					nId = nEndId,
					nType = GameEnum.DatingEventType.End
				})
			end
			PlayerData.Dating:RefreshLimitedEventList(self._panel.nCharId, {
				msgData.CharacterEventId
			})
			PlayerData.Char:ChangeCharAffinityValue(msgData.Info)
			if msgData.Change ~= nil then
				local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(msgData.Change)
				HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
			end
		end
		local tbTempEvent = self:LoadEventConfig(tbNewEvents)
		self._mapNode.goEvent:AddEvent(tbTempEvent, tbNewEvents)
	end
	if nOptionIndex == 0 then
		nOptionIndex = self.tbBranchOptionIds[1]
	end
	local nNetMsgId = self.bFirstOption and NetMsgId.Id.char_dating_branch_a_select_req or NetMsgId.Id.char_dating_branch_b_select_req
	HttpNetHandler.SendMsg(nNetMsgId, {OptionId = nOptionIndex}, nil, callback)
end
return DatingCtrl
