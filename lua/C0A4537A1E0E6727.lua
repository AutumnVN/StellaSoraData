local GuideGroup_303 = class("GuideGroup_303")
local mapEventConfig = {}
local groupId = 303
local totalStep = 3
local current = 1
function GuideGroup_303:Init(parent, runStep)
	self:BindEvent()
	self.parent = parent
	current = 1
	local funName = "Step_" .. current
	local func = handler(self, self[funName])
	func()
end
function GuideGroup_303:BindEvent()
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Add(nEventId, self, callback)
		end
	end
end
function GuideGroup_303:UnBindEvent()
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Remove(nEventId, self, callback)
		end
	end
end
function GuideGroup_303:SendGuideStep(step)
	self.parent:SendGuideStep(groupId, step)
end
function GuideGroup_303:Clear()
	self.runGuide = false
	self:UnBindEvent()
	self.parent = nil
end
function GuideGroup_303:Step_1()
	self.msg = {
		BindIcon = "PenguinCardPanel/----SafeAreaRoot----/---Prepare---/--Info--/imgScoreBg",
		Deviation = {-170, -30},
		Size = {350, 140},
		Head = "Icon/Head/head_11101",
		Desc = "Guide_4_1",
		DescDeviation = {-700, -240},
		Type = GameEnum.guidetype.Introductory
	}
	self.parent:ActiveHide(true)
	current = 1
	self.parent:PlayTypeMask(self.msg)
end
function GuideGroup_303:Step_2()
	self.msg = {
		BindIcon = "PenguinCardPanel/----SafeAreaRoot----/---Prepare---/--Info--/imgTurnBg",
		Deviation = {0, 0},
		Head = "Icon/Head/head_11101",
		Desc = "Guide_4_1",
		DescDeviation = {0, -230},
		Type = GameEnum.guidetype.Introductory
	}
	self.parent:ActiveHide(true)
	current = 2
	self.parent:PlayTypeMask(self.msg)
end
function GuideGroup_303:Step_3()
	self.msg = {
		BindIcon = "PenguinCardPanel/----SafeAreaRoot----/---Prepare---/--Upgrade--",
		Deviation = {0, 0},
		Head = "Icon/Head/head_11101",
		Desc = "Guide_4_1",
		DescDeviation = {700, -350},
		Type = GameEnum.guidetype.Introductory
	}
	self.parent:ActiveHide(true)
	current = 3
	self.parent:PlayTypeMask(self.msg)
end
function GuideGroup_303:FinishCurrentStep()
	self.msg = nil
	self.openPanelId = nil
	self.waitAinEnd = nil
	self.runGuide = false
	self.waitAnimTime = 0
	if current == 1 then
	elseif current == totalStep then
		self:SendGuideStep(-1)
		self.parent:ClearCurGuide(true)
		return
	end
	local funName = "Step_" .. current + 1
	local func = handler(self, self[funName])
	func()
end
return GuideGroup_303
