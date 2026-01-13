local LocalData = require("GameCore.Data.LocalData")
local ChapterLineCtrl = class("ChapterLineCtrl", BaseCtrl)
local AvgData = PlayerData.Avg
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
ChapterLineCtrl._mapNodeConfig = {
	tranContent = {
		sNodeName = "Content",
		sComponentName = "RectTransform"
	},
	scrollRect = {
		sNodeName = "Scroll View",
		sComponentName = "ScrollRect"
	},
	imgMask = {
		sNodeName = "ImgMask",
		sComponentName = "RectTransform"
	},
	goImgMaskRoot = {}
}
ChapterLineCtrl._mapEventConfig = {
	Story_RewardClosed = "OnEvent_Story_RewardClosed",
	Story_Done = "OnEvent_Story_Done"
}
local UnlockConditionPriority = {
	[1] = "MustStoryIds",
	[2] = "OneofStoryIds",
	[3] = "MustEvIds",
	[4] = "OneofEvIds",
	[5] = "WorldLevel",
	[6] = "MustAchievementIds",
	[7] = "TimeUnlock"
}
function ChapterLineCtrl:Awake()
	self.bCanClick = true
	local callback = function()
		self.bHasAchievementData = true
	end
	PlayerData.Achievement:SendAchievementInfoReq(callback)
	local tbParam = self:GetPanelParam()
	self.curChapter = tbParam[1]
	self.curTimeStamp = 0
	self.tbImgFocusNode = {}
	self.tbLockedPlayedAnim = {}
	self.lineAnimTime = 0.14
	self.tbBranchGrid = {}
	self.tbLockedBranchGrid = {}
	self.bFocusNotReadNode = true
	self:CacheCurChapterConfig()
	self:CacheChapterBranchNode()
	self:Refresh()
	self:AddTimer(1, 0.5, function()
		if self.bNeedPlayUnlockAnim or self.bNeedPlayBranchAnim then
			if self.bNeedPlayBranchAnim then
				self.curShouldPlayDepth = self.tbNeedPlayUnlockAnimGird[1].depth
			end
			self:DoPlayUnlockAnim(self.curShouldPlayDepth)
		end
	end, true, true, true)
end
function ChapterLineCtrl:RefreshFocusNode()
	self.tbFocusNode = {}
	self.bFocusLastNode = false
	local tbNewNodes = AvgData:CheckNewStory(self.curChapter)
	for k, v in pairs(tbNewNodes) do
		if v == true then
			table.insert(self.tbFocusNode, k)
		end
	end
	if #self.tbFocusNode == 0 then
		local firstNode = self._mapNode.tranContent:GetChild(1):Find("goGrid"):GetChild(0)
		local avgId = firstNode.name
		local storyConfig = AvgData:GetStoryCfgData(avgId)
		if not AvgData:IsStoryReaded(storyConfig.Id) then
			table.insert(self.tbFocusNode, storyConfig.Id)
		else
			self.bFocusLastNode = true
			table.insert(self.tbFocusNode, AvgData:GetRecentStoryId(self.curChapter))
		end
	end
	self.bNeedPlayUnlockAnim = false
	self.bNeedPlayBranchAnim = false
	for k, v in ipairs(self.tbFocusNode) do
		local storyConfig = ConfigTable.GetData_Story(v)
		local bHasPlayedAnim = LocalData.GetPlayerLocalData("MainlineUnlock_" .. v)
		if bHasPlayedAnim == nil or tonumber(bHasPlayedAnim) == 0 then
			if storyConfig.IsBranch == true then
				self.bNeedPlayBranchAnim = true
				break
			end
			self.bNeedPlayUnlockAnim = true
			break
		end
		local avgId = storyConfig.StoryId
		if 0 < table.indexof(self.tbLockedBranchGrid, avgId) and self.tbBranch[avgId] ~= nil then
			for _, branchGrid in ipairs(self.tbBranch[avgId]) do
				local bUnlock = AvgData:IsUnlock(branchGrid.ConditionId, branchGrid.StoryId)
				if bUnlock then
					self.bNeedPlayBranchAnim = true
					break
				end
			end
		end
	end
end
function ChapterLineCtrl:Refresh()
	self._mapNode.goImgMaskRoot.transform:SetParent(self._mapNode.tranContent)
	self._mapNode.goImgMaskRoot.transform:SetAsFirstSibling()
	self:RefreshFocusNode()
	self.tbGridList = {}
	self.tbTimeStampList = {}
	self.tbDepthLockCount = {}
	self.maxUnlockDepth = 1
	self.maxStoryDepth = 1
	for i = 1, self._mapNode.tranContent.childCount - 1 do
		local gridRoot = self._mapNode.tranContent:GetChild(i):Find("goGrid")
		local goTimeStamp = self._mapNode.tranContent:GetChild(i):Find("goTimeStamp")
		self.tbDepthLockCount[i] = {
			Node = self._mapNode.tranContent:GetChild(i),
			ChildCount = gridRoot.childCount,
			DisableCount = 0
		}
		for j = 1, gridRoot.childCount do
			local goGrid = gridRoot:GetChild(j - 1)
			local avgId = goGrid.name
			table.insert(self.tbGridList, {
				avgId = avgId,
				grid = goGrid,
				depth = i
			})
			local storyConfig = AvgData:GetStoryCfgData(avgId)
			local bUnlock = AvgData:IsUnlock(storyConfig.ConditionId, storyConfig.StoryId)
			if i > self.maxStoryDepth then
				self.maxStoryDepth = i
			end
			if bUnlock and i > self.maxUnlockDepth then
				self.maxUnlockDepth = i
			end
		end
		table.insert(self.tbTimeStampList, goTimeStamp)
	end
	table.sort(self.tbGridList, function(a, b)
		return a.depth < b.depth
	end)
	self:RefreshUnlockAnimList()
	for k, v in ipairs(self.tbGridList) do
		self:RefreshGrid(v.grid, v.depth)
	end
	for i = 1, #self.tbTimeStampList do
		self:RefreshTimeStamp(self.tbTimeStampList[i], i)
	end
	self:AddTimer(1, 0.1, function()
		self._mapNode.scrollRect.horizontalNormalizedPosition = (self.curTimeStamp - 1) * 250
	end, true, true, true)
	CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._mapNode.tranContent)
	if 0 > self.curTimeStamp - 1 then
		self._mapNode.imgMask.gameObject:SetActive(false)
	else
		self._mapNode.imgMask.gameObject:SetActive(true)
		local node = self._mapNode.tranContent:Find(tostring(self.curTimeStamp))
		local layout = self._mapNode.tranContent:GetComponent("HorizontalLayoutGroup")
		local pos = node.localPosition.x - layout.padding.left
		self._mapNode.imgMask.anchoredPosition = Vector2(pos, -6)
	end
end
function ChapterLineCtrl:RefreshGrid(goGrid, gridDepth)
	local avgId = goGrid.name
	local storyConfig = AvgData:GetStoryCfgData(avgId)
	local bUnlock = AvgData:IsUnlock(storyConfig.ConditionId, avgId)
	local goLeftBorder = goGrid:Find("goLeftBorder")
	local bAllLock = 1 < gridDepth and true or false
	for i = 1, #storyConfig.ParentStoryId do
		local parentConfig = AvgData:GetStoryCfgData(storyConfig.ParentStoryId[i])
		local parentUnlock = AvgData:IsUnlock(parentConfig.ConditionId, parentConfig.StoryId)
		if parentUnlock then
			bAllLock = false
		end
	end
	if bAllLock then
		self.tbDepthLockCount[gridDepth].DisableCount = self.tbDepthLockCount[gridDepth].DisableCount + 1
	end
	self.tbDepthLockCount[gridDepth].Node.gameObject:SetActive(self.tbDepthLockCount[gridDepth].DisableCount < self.tbDepthLockCount[gridDepth].ChildCount)
	local allParentDepthLock = true
	if self.tbDepthLockCount[gridDepth - 1] ~= nil and self.tbDepthLockCount[gridDepth - 1] ~= nil then
		allParentDepthLock = self.tbDepthLockCount[gridDepth - 1].DisableCount == self.tbDepthLockCount[gridDepth - 1].ChildCount
	end
	local bNeedPlayUnlockAnim = false
	for k, v in ipairs(self.tbNeedPlayUnlockAnimGird) do
		if v.avgId == avgId then
			bNeedPlayUnlockAnim = true
			break
		end
	end
	local bPlayedLockAnim = table.indexof(self.tbLockedPlayedAnim, avgId) > 0
	goGrid.gameObject:SetActive((not bAllLock or not allParentDepthLock) and not bNeedPlayUnlockAnim or bPlayedLockAnim)
	local bReaded = AvgData:IsStoryReaded(storyConfig.Id)
	local btnEnter = goGrid:Find("btnEnter"):GetComponent("UIButton")
	local NormalRoot = btnEnter.transform:Find("AnimRoot/NormalRoot")
	local BattleRoot = btnEnter.transform:Find("AnimRoot/BattleRoot")
	local BranchRoot = goGrid:Find("BranchRoot")
	local LockRoot = btnEnter.transform:Find("AnimRoot/LockRoot")
	local imgClue = goGrid:Find("imgClue")
	local lineContinue = goGrid:Find("lineContinue")
	local goRightBorder = goGrid:Find("goRightBorder")
	local txtUnlock = LockRoot:Find("txtUnlock"):GetComponent("TMP_Text")
	local cgComp = storyConfig.IsBattle and NormalRoot:GetComponent("CanvasGroup") or BattleRoot:GetComponent("CanvasGroup")
	NovaAPI.SetCanvasGroupAlpha(cgComp, bUnlock and 1 or 0.5)
	LockRoot.gameObject:SetActive(not bUnlock or bPlayedLockAnim)
	imgClue.gameObject:SetActive(storyConfig.HasEvidence and bUnlock and not bReaded)
	local bShowLineContinue = not bUnlock and gridDepth > self.maxUnlockDepth
	lineContinue.gameObject:SetActive(bShowLineContinue)
	local rootTrans = storyConfig.IsBattle and BattleRoot or NormalRoot
	rootTrans.gameObject:SetActive(bUnlock)
	local imgFocus = rootTrans:Find("imgFocus")
	local RedDot = rootTrans:Find("RedDot")
	local bFocus = 0 < table.indexof(self.tbFocusNode, storyConfig.Id) and (not bReaded or self.bFocusLastNode)
	imgFocus.gameObject:SetActive(bFocus and not bPlayedLockAnim)
	RedDot.gameObject:SetActive(bFocus and not bReaded and not bPlayedLockAnim)
	if self.tbBranch[avgId] ~= nil then
		for k, v in ipairs(self.tbBranch[avgId]) do
			if 0 < table.indexof(self.tbFocusNode, v.Id) then
				bFocus = true
				break
			end
		end
	end
	if bFocus then
		local nodeTimeStampIndex = tonumber(goGrid.transform.parent.parent.name)
		if nodeTimeStampIndex > self.curTimeStamp then
			if self.tbImgFocusNode[self.curTimeStamp] ~= nil then
				for k, v in ipairs(self.tbImgFocusNode[self.curTimeStamp]) do
					v.gameObject:SetActive(false)
				end
			end
			self.curTimeStamp = nodeTimeStampIndex
		end
		if self.tbImgFocusNode[self.curTimeStamp] == nil then
			self.tbImgFocusNode[self.curTimeStamp] = {}
		end
		table.insert(self.tbImgFocusNode[self.curTimeStamp], imgFocus)
	end
	if bUnlock then
		local goReaded = rootTrans:Find("goReaded")
		local goNotRead = rootTrans:Find("goNotRead")
		local txtNotRead = goNotRead:Find("txtNotRead"):GetComponent("TMP_Text")
		local txtLevelName = goReaded:Find("txtLevelName"):GetComponent("TMP_Text")
		local txtLevelIndex = goReaded:Find("txtLevelIndex"):GetComponent("TMP_Text")
		local txtNewUnlock = goNotRead:Find("txtNewUnlock"):GetComponent("TMP_Text")
		goReaded.gameObject:SetActive(bReaded)
		goNotRead.gameObject:SetActive(not bReaded)
		NovaAPI.SetTMPText(txtNotRead, storyConfig.Index)
		NovaAPI.SetTMPText(txtLevelName, storyConfig.Title)
		NovaAPI.SetTMPText(txtLevelIndex, storyConfig.Index)
		NovaAPI.SetTMPText(txtNewUnlock, ConfigTable.GetUIText("Story_NewStory_Unlock"))
		if not storyConfig.IsBattle then
			local imgClueReaded = goReaded:Find("imgClueReaded")
			imgClueReaded.gameObject:SetActive(storyConfig.HasEvidence)
		end
		self:PlayUnlockAnim(rootTrans, "Empty")
	end
	NovaAPI.SetTMPText(txtUnlock, ConfigTable.GetUIText("Story_Unkown_Chapter"))
	for i = 1, goRightBorder.childCount do
		goRightBorder:GetChild(i - 1).gameObject:SetActive(not bShowLineContinue)
	end
	if self.tbBranch[avgId] ~= nil then
		if bNeedPlayUnlockAnim == false and 0 < table.indexof(self.tbLockedBranchGrid, avgId) then
			bNeedPlayUnlockAnim = true
		end
		self:RefreshBranchGrid(BranchRoot, avgId, gridDepth, bNeedPlayUnlockAnim)
	end
	btnEnter.onClick:RemoveAllListeners()
	btnEnter.onClick:AddListener(function()
		self:OnClickGrid(avgId)
	end)
end
function ChapterLineCtrl:RefreshBranchGrid(root, avgId, depth, isNeedPlayUnlockAnim)
	local branchIds = {}
	local forEachLine_Story = function(mapLineData)
		for k, v in pairs(mapLineData.ParentStoryId) do
			if v == avgId and mapLineData.IsBranch == true then
				table.insert(branchIds, mapLineData.StoryId)
			end
		end
	end
	ForEachTableLine(DataTable.Story, forEachLine_Story)
	local index = 1
	local bHasUnlockBranch = false
	for k, v in ipairs(self.tbBranch[avgId]) do
		local bUnlock = AvgData:IsUnlock(v.ConditionId, v.StoryId)
		local bReaded = AvgData:IsStoryReaded(v.Id)
		local branchGrid = root:Find("BranchGrid_" .. k)
		local storyConfig = AvgData:GetStoryCfgData(branchIds[index])
		if bUnlock then
			bHasUnlockBranch = true
		end
		table.insert(self.tbLockedBranchGrid, avgId)
		if bUnlock and table.indexof(self.tbLockedBranchGrid, avgId) > 0 then
			table.removebyvalue(self.tbLockedBranchGrid, avgId)
		end
		if isNeedPlayUnlockAnim and bUnlock then
			if not bReaded then
				root.gameObject:SetActive(false)
			end
			table.insert(self.tbNeedPlayUnlockAnimGird, {
				grid = root,
				avgId = storyConfig.StoryId,
				depth = depth,
				index = index,
				totalCount = #self.tbBranch[avgId]
			})
		end
		if branchGrid ~= nil then
			local goUnlock = branchGrid:Find("AnimRoot/goUnlock")
			local goLock = branchGrid:Find("AnimRoot/goLock")
			local goLevelIndex = branchGrid:Find("AnimRoot/goUnlock/txtLevelIndex")
			local txtLevelIndex = goLevelIndex:GetComponent("TMP_Text")
			local txtLevelName = txtLevelIndex.transform:Find("txtLevelName"):GetComponent("TMP_Text")
			local cgLevelIndex = goLevelIndex:GetComponent("CanvasGroup")
			local imgNewUnlockBg = branchGrid:Find("AnimRoot/goUnlock/imgNewUnlockBg")
			local imgNewUnlock = branchGrid:Find("AnimRoot/goUnlock/imgNewUnlock")
			NovaAPI.SetCanvasGroupAlpha(cgLevelIndex, 1)
			NovaAPI.SetTMPText(txtLevelIndex, storyConfig.Index)
			goUnlock.gameObject:SetActive(bUnlock)
			goLock.gameObject:SetActive(not bUnlock)
			txtLevelIndex.gameObject:SetActive(bUnlock)
			if bReaded then
				NovaAPI.SetTMPText(txtLevelName, storyConfig.Title)
			else
				NovaAPI.SetTMPText(txtLevelName, ConfigTable.GetUIText("Story_NewEnd_Unlock"))
			end
			if #self.tbBranch[avgId] == 1 then
			end
			local imgLockBg = branchGrid:Find("AnimRoot/goLock/imgBranchGridBgLock")
			imgLockBg.gameObject:SetActive(not bUnlock)
			local txtUnlock = branchGrid:Find("AnimRoot/goUnlock/txtUnlock"):GetComponent("TMP_Text")
			txtUnlock.gameObject:SetActive(false)
			NovaAPI.SetTMPText(txtUnlock, ConfigTable.GetUIText("Story_Unkown_End"))
			local imgLock = branchGrid:Find("AnimRoot/goLock/imgLock")
			imgLock.gameObject:SetActive(not bUnlock)
			local RedDot = branchGrid:Find("AnimRoot/RedDot")
			local bNew = 0 < table.indexof(self.tbFocusNode, v.Id) and not bReaded
			RedDot.gameObject:SetActive(bNew)
			imgNewUnlock.gameObject:SetActive(bNew)
			imgNewUnlockBg.gameObject:SetActive(bNew)
			local btnEnter = branchGrid:GetComponent("UIButton")
			btnEnter.onClick:RemoveAllListeners()
			btnEnter.onClick:AddListener(function()
				self:OnClickGrid(v.StoryId)
			end)
		end
		index = index + 1
	end
	root.gameObject:SetActive(bHasUnlockBranch)
end
function ChapterLineCtrl:RefreshTimeStamp(goTimeStamp, index)
	local timeStampName
	local nId = self.curChapter * 100 + index
	local config = ConfigTable.GetData("StoryChapterTimeStamp", nId)
	if config == nil then
		return
	end
	timeStampName = config.TimeStamp
	if timeStampName == nil then
		goTimeStamp.gameObject:SetActive(false)
		return
	end
	local tranTimeStamp = goTimeStamp:GetChild(0)
	local imgFocus = tranTimeStamp:Find("imgFocus")
	imgFocus.gameObject:SetActive(index == self.curTimeStamp)
	local imgBg = tranTimeStamp:Find("imgBg")
	imgBg.gameObject:SetActive(index ~= self.curTimeStamp)
	local txtTimeTitle = tranTimeStamp:Find("imgFocus/txtTimeTitle"):GetComponent("TMP_Text")
	local imgStage = txtTimeTitle.transform:Find("imgStage")
	imgStage.gameObject:SetActive(index == self.curTimeStamp)
	if index > self.maxUnlockDepth and 0 < self.curTimeStamp then
		timeStampName = ConfigTable.GetUIText("No_Arrived_Future")
	end
	NovaAPI.SetTMPText(txtTimeTitle, timeStampName)
	local txtTimeTitle = tranTimeStamp:Find("imgBg/txtTimeTitle"):GetComponent("TMP_Text")
	NovaAPI.SetTMPText(txtTimeTitle, timeStampName)
end
function ChapterLineCtrl:RefreshUnlockAnimList()
	self.tbNeedPlayUnlockAnimGird = {}
	self.curShouldPlayDepth = 9999
	if not self.bNeedPlayUnlockAnim and not self.bNeedPlayBranchAnim then
		return
	end
	local cachedGird = {}
	for k, v in ipairs(self.tbGridList) do
		local storyConfig = AvgData:GetStoryCfgData(v.avgId)
		if table.indexof(self.tbFocusNode, storyConfig.Id) > 0 then
			local bHasPlayedAnim = LocalData.GetPlayerLocalData("MainlineUnlock_" .. storyConfig.Id)
			if (bHasPlayedAnim == nil or bHasPlayedAnim == 0) and cachedGird[v.avgId] == nil then
				table.insert(self.tbNeedPlayUnlockAnimGird, v)
				cachedGird[v.avgId] = v
				if self.curShouldPlayDepth > v.depth then
					self.curShouldPlayDepth = v.depth
				end
			end
		else
			for _, parentNode in pairs(storyConfig.ParentStoryId) do
				if cachedGird[parentNode] ~= nil then
					local parentStoryConfig = AvgData:GetStoryCfgData(parentNode)
					local bHasPlayedAnim = LocalData.GetPlayerLocalData("MainlineUnlock_" .. storyConfig.Id)
					local parentUnlock = AvgData:IsUnlock(parentStoryConfig.ConditionId, parentStoryConfig.StoryId)
					if cachedGird[v.avgId] == nil and (bHasPlayedAnim == nil or bHasPlayedAnim == 0) and parentUnlock then
						table.insert(self.tbNeedPlayUnlockAnimGird, v)
						cachedGird[v.avgId] = v
						if self.curShouldPlayDepth > v.depth then
							self.curShouldPlayDepth = v.depth
						end
					end
				elseif table.indexof(self.tbFocusNode, parentNode) > 0 then
					local parentStoryConfig = AvgData:GetStoryCfgData(parentNode)
					local bHasPlayedAnim = LocalData.GetPlayerLocalData("MainlineUnlock_" .. parentStoryConfig.Id)
					if bHasPlayedAnim == nil or bHasPlayedAnim == 0 then
						bHasPlayedAnim = LocalData.GetPlayerLocalData("MainlineUnlock_" .. storyConfig.Id)
						if cachedGird[v.avgId] == nil and (bHasPlayedAnim == nil or bHasPlayedAnim == 0) then
							table.insert(self.tbNeedPlayUnlockAnimGird, v)
							cachedGird[v.avgId] = v
							if self.curShouldPlayDepth > v.depth then
								self.curShouldPlayDepth = v.depth
							end
						end
					end
				end
			end
		end
	end
end
function ChapterLineCtrl:DoPlayUnlockAnim(depth)
	local nodes = {}
	for _, node in ipairs(self.tbNeedPlayUnlockAnimGird) do
		if node.depth == depth then
			table.insert(nodes, node)
		end
	end
	for _, node in pairs(nodes) do
		self:PlayGridUnlockAnim(node, depth)
	end
end
function ChapterLineCtrl:PlayGridUnlockAnim(nodeInfo, depth)
	local storyConfig = AvgData:GetStoryCfgData(nodeInfo.avgId)
	if storyConfig.IsBranch then
		nodeInfo.grid.gameObject:SetActive(true)
		self:PlayBranchNodeUnlockAnim(nodeInfo, depth)
	else
		self:PlayNormalNodeUnlockAnim(nodeInfo, depth)
	end
end
function ChapterLineCtrl:PlayNormalNodeUnlockAnim(nodeInfo, depth)
	local grid = nodeInfo.grid.transform
	local storyConfig = AvgData:GetStoryCfgData(nodeInfo.avgId)
	local imgLeftPoint_1 = grid:Find("imgLeftPoint_1")
	local imgRightPoint_1 = grid:Find("imgRightPoint_1")
	local goLeftBorder = grid:Find("goLeftBorder")
	local goRightBorder = grid:Find("goRightBorder")
	local allLine = {}
	for i = 0, goLeftBorder.transform.childCount - 1 do
		table.insert(allLine, goLeftBorder.transform:GetChild(i))
	end
	grid.gameObject:SetActive(true)
	local bLeftActived = imgLeftPoint_1.gameObject.activeInHierarchy
	local bRightActived = imgRightPoint_1.gameObject.activeInHierarchy
	local goLineContinue = grid:Find("lineContinue")
	imgRightPoint_1.gameObject:SetActive(false)
	imgLeftPoint_1.gameObject:SetActive(false)
	goLineContinue.gameObject:SetActive(false)
	local bUnlock = AvgData:IsUnlock(storyConfig.ConditionId, storyConfig.StoryId)
	local batteleNode = grid:Find("btnEnter/AnimRoot/BattleRoot")
	local normalNode = grid:Find("btnEnter/AnimRoot/NormalRoot")
	local lockNode = grid:Find("btnEnter/AnimRoot/LockRoot")
	batteleNode.gameObject:SetActive(false)
	normalNode.gameObject:SetActive(false)
	lockNode.gameObject:SetActive(false)
	local rootNode
	local bNewUnlock = 0 < table.indexof(self.tbLockedPlayedAnim, nodeInfo.avgId)
	if bNewUnlock then
		lockNode.gameObject:SetActive(true)
		table.removebyvalue(self.tbLockedPlayedAnim, nodeInfo.avgId)
	end
	if bUnlock then
		rootNode = storyConfig.IsBattle == true and batteleNode or normalNode
	else
		rootNode = lockNode
		table.insert(self.tbLockedPlayedAnim, nodeInfo.avgId)
	end
	local PlayLineAnimTime = 0.01
	if 0 < #allLine and not bNewUnlock then
		PlayLineAnimTime = self.lineAnimTime
		for k, v in ipairs(allLine) do
			self:PlayLineAnim(v)
		end
		self:AddTimer(1, self.lineAnimTime, function()
			imgLeftPoint_1.gameObject:SetActive(bLeftActived)
		end, true, true, true)
	elseif bNewUnlock then
		imgLeftPoint_1.gameObject:SetActive(bLeftActived)
	end
	local DoAfterAnim = function(time)
		self:AddTimer(1, time, function()
			imgRightPoint_1.gameObject:SetActive(bRightActived)
			if not bUnlock then
				if bRightActived then
					goLineContinue.gameObject:SetActive(true)
					self:PlayLineAnim(goLineContinue)
				end
			else
				local imgFocus = rootNode:Find("imgFocus")
				local bReaded = AvgData:IsStoryReaded(storyConfig.Id)
				local RedDot = rootNode:Find("RedDot")
				local bFocus = table.indexof(self.tbFocusNode, storyConfig.Id) > 0 and (not bReaded or self.bFocusLastNode)
				imgFocus.gameObject:SetActive(bFocus)
				RedDot.gameObject:SetActive(bFocus and not bReaded)
				self:DoPlayUnlockAnim(depth + 1)
			end
		end, true, true, true)
	end
	self:AddTimer(1, PlayLineAnimTime, function()
		lockNode.gameObject:SetActive(false)
		rootNode.gameObject:SetActive(true)
		local animName = bUnlock and "BattleRoot_in" or "LockRoot_in"
		if bUnlock then
			LocalData.SetPlayerLocalData("MainlineUnlock_" .. storyConfig.Id, 1)
			CS.WwiseAudioManager.Instance:PostEvent("ui_mainline_level")
		end
		local animTime = self:PlayUnlockAnim(rootNode, animName)
		DoAfterAnim(animTime)
	end, true, true, true)
end
function ChapterLineCtrl:PlayBranchNodeUnlockAnim(nodeInfo, depth)
	if nodeInfo.totalCount > 1 then
		self:PlayUnlockAnim(nodeInfo.grid, "BranchRoot_in3")
	else
		self:PlayUnlockAnim(nodeInfo.grid, "BranchRoot_in" .. nodeInfo.index)
	end
	WwiseAudioMgr:PostEvent("ui_mainline_newending")
	local storyConfig = AvgData:GetStoryCfgData(nodeInfo.avgId)
	LocalData.SetPlayerLocalData("MainlineUnlock_" .. storyConfig.Id, 1)
end
function ChapterLineCtrl:PlayUnlockAnim(go, animName)
	local animator = go:GetComponent("Animator")
	animator.enabled = true
	animator:Play(animName)
	local nAnimLength = NovaAPI.GetAnimClipLength(animator, {animName})
	return nAnimLength
end
function ChapterLineCtrl:PlayLineAnim(goLine)
	local lineRect = goLine:GetComponent("RectTransform")
	if lineRect.pivot.x > 0 then
		lineRect.pivot = Vector2(0, 0.5)
		local Pos = lineRect.localPosition
		local angle = math.rad(lineRect.localEulerAngles.z)
		lineRect.localPosition = Vector3(Pos.x - lineRect.rect.width * math.cos(angle), Pos.y - lineRect.rect.width * math.sin(angle), Pos.z)
	end
	lineRect.localScale = Vector3(0, 1, 1)
	lineRect:DOScaleX(1, self.lineAnimTime)
end
function ChapterLineCtrl:OnClickGrid(avgId)
	if self.bCanClick == false then
		return
	end
	local storyConfig = AvgData:GetStoryCfgData(avgId)
	local bUnlock, tbResult = AvgData:IsUnlock(storyConfig.ConditionId, avgId)
	if not bUnlock then
		WwiseAudioMgr:PostEvent("ui_systerm_locked")
		if tbResult ~= nil then
			local lockTxt = ""
			for i = 1, #tbResult do
				local value = tbResult[i]
				if value[1] == false then
					if UnlockConditionPriority[i] == "MustStoryIds" then
						do
							local tbStoryIds = value[2]
							for k, v in pairs(tbStoryIds) do
								if v == false then
									local storyData = ConfigTable.GetData_Story(AvgData.CFG_Story[k])
									lockTxt = orderedFormat(ConfigTable.GetUIText("Story_UnlockPreId") or "", storyData.Title)
									break
								end
							end
						end
						break
					end
					if UnlockConditionPriority[i] == "OneofStoryIds" then
						do
							local tbStoryIds = value[2]
							for k, v in pairs(tbStoryIds) do
								if v == false then
									local storyData = ConfigTable.GetData_Story(AvgData.CFG_Story[k])
									lockTxt = orderedFormat(ConfigTable.GetUIText("Story_UnlockPreId") or "", storyData.Title)
									break
								end
							end
						end
						break
					end
					if UnlockConditionPriority[i] == "MustEvIds" then
						lockTxt = ConfigTable.GetUIText("Story_UnlockClueCondition")
						break
					end
					if UnlockConditionPriority[i] == "OneofEvIds" then
						lockTxt = ConfigTable.GetUIText("Story_UnlockClueCondition")
						break
					end
					if UnlockConditionPriority[i] == "WorldLevel" then
						do
							local level = value[2]
							lockTxt = orderedFormat(ConfigTable.GetUIText("Story_UnlockWorldLv") or "", level)
						end
						break
					end
					if UnlockConditionPriority[i] == "MustAchievementIds" then
						if self.bHasAchievementData == true then
							local tbAchievementList = value[2]
							for k, v in pairs(tbAchievementList) do
								if v == false then
									local achievementId = k
									local achievement = ConfigTable.GetData("Achievement", achievementId)
									lockTxt = orderedFormat(ConfigTable.GetUIText("Story_UnlockAchievement") or "", achievement.Title) .. "\n" .. "(" .. achievement.Desc .. ")"
									break
								end
							end
						end
						break
					end
					if UnlockConditionPriority[i] == "TimeUnlock" then
						local curTime = CS.ClientManager.Instance.serverTimeStamp
						local openTime = value[2]
						local remainTime = openTime - curTime
						if remainTime <= 60 then
							do
								local sec = math.floor(remainTime)
								lockTxt = orderedFormat(ConfigTable.GetUIText("Mainline_Open_Time_Sec") or "", sec)
							end
							break
						end
						if 60 < remainTime and remainTime <= 3600 then
							do
								local min = math.floor(remainTime / 60)
								local sec = math.floor(remainTime - min * 60)
								if sec == 0 then
									min = min - 1
									sec = 60
								end
								lockTxt = orderedFormat(ConfigTable.GetUIText("Mainline_Open_Time_Min") or "", min, sec)
							end
							break
						end
						if 3600 < remainTime and remainTime <= 86400 then
							do
								local hour = math.floor(remainTime / 3600)
								local min = math.floor((remainTime - hour * 3600) / 60)
								if min == 0 then
									hour = hour - 1
									min = 60
								end
								lockTxt = orderedFormat(ConfigTable.GetUIText("Mainline_Open_Time_Hour") or "", hour, min)
							end
							break
						end
						if 86400 < remainTime then
							local day = math.floor(remainTime / 86400)
							local hour = math.floor((remainTime - day * 86400) / 3600)
							if hour == 0 then
								day = day - 1
								hour = 24
							end
							lockTxt = orderedFormat(ConfigTable.GetUIText("Mainline_Open_Time_Day") or "", day, hour)
						end
					end
					break
				end
			end
			local msg = {
				nType = AllEnum.MessageBox.Alert,
				sContent = lockTxt
			}
			EventManager.Hit(EventId.OpenMessageBox, msg)
		end
		return
	end
	WwiseAudioMgr:PostEvent("ui_common_menu3")
	local nRecentStoryId = AvgData:GetRecentStoryId(self.curChapter)
	local recentStoryAvgId = ConfigTable.GetData_Story(nRecentStoryId).StoryId
	local findCount = 0
	local recentStoryDepth = 0
	local curDepth = 0
	for k, v in ipairs(self.tbGridList) do
		local gridName = v.grid.name
		if gridName == avgId then
			findCount = findCount + 1
			curDepth = v.depth
		end
		if gridName == recentStoryAvgId then
			findCount = findCount + 1
			recentStoryDepth = v.depth
		end
		if findCount == 2 then
			break
		end
	end
	self.curChosenStory = avgId
	EventManager.Hit(EventId.ChoseMainlineStory, avgId, curDepth >= recentStoryDepth)
end
function ChapterLineCtrl:OnEvent_Story_RewardClosed()
	if self.bNeedPlayUnlockAnim or self.bNeedPlayBranchAnim then
		if self.bNeedPlayBranchAnim then
			self.curShouldPlayDepth = self.tbNeedPlayUnlockAnimGird[1].depth
		end
		self:DoPlayUnlockAnim(self.curShouldPlayDepth)
	end
end
function ChapterLineCtrl:OnEvent_Story_Done(bHasReward)
	if not bHasReward and (self.bNeedPlayUnlockAnim or self.bNeedPlayBranchAnim) then
		if self.bNeedPlayBranchAnim then
			self.curShouldPlayDepth = self.tbNeedPlayUnlockAnimGird[1].depth
		end
		self:AddTimer(1, 1.5, function()
			self:DoPlayUnlockAnim(self.curShouldPlayDepth)
		end, true, true, true)
	end
end
function ChapterLineCtrl:CacheCurChapterConfig()
	self.tbChapterStoryNumIds = AvgData:GetChapterStoryNumIds(self.curChapter)
end
function ChapterLineCtrl:CacheChapterBranchNode()
	self.tbBranch = {}
	for i, v in ipairs(self.tbChapterStoryNumIds) do
		local data = ConfigTable.GetData_Story(v)
		if data.IsBranch then
			if self.tbBranch[data.ParentStoryId[1]] == nil then
				self.tbBranch[data.ParentStoryId[1]] = {}
			end
			table.insert(self.tbBranch[data.ParentStoryId[1]], data)
		end
	end
end
function ChapterLineCtrl:IsAllStoryCompleted()
	for k, v in ipairs(self.tbGridList) do
		if self.maxStoryDepth == v.depth and self.curChosenStory == v.grid.name then
			local avgId = v.grid.name
			local nStoryId = AvgData.CFG_Story[avgId]
			return AvgData:IsStoryReaded(nStoryId)
		end
	end
	return false
end
function ChapterLineCtrl:ForbidClick()
	self.bCanClick = false
	self:AddTimer(1, 1.5, function()
		self.bCanClick = true
	end, true, true, true)
end
return ChapterLineCtrl
