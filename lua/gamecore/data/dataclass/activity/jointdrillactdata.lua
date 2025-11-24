local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local JointDrillActData = class("JointDrillActData", ActivityDataBase)
function JointDrillActData:Init()
	self.nStatus = 0
	self.jointDrillActCfg = nil
	self:InitConfig()
end
function JointDrillActData:InitConfig()
	local mapActCfg = ConfigTable.GetData("JointDrillControl", self.nActId)
	if nil == mapActCfg then
		return
	end
	self.jointDrillActCfg = mapActCfg
end
function JointDrillActData:GetJointDrillActCfg()
	return self.jointDrillActCfg
end
function JointDrillActData:RefreshJointDrillActData(msgData)
	PlayerData.JointDrill:CacheJointDrillData(self.nActId, msgData)
end
function JointDrillActData:GetActOpenTime()
	return self.nOpenTime
end
function JointDrillActData:GetActCloseTime()
	return self.nEndTime
end
function JointDrillActData:GetChallengeStartTime()
	if self.jointDrillActCfg ~= nil then
		return self.nOpenTime + self.jointDrillActCfg.DrillStartTime
	end
end
function JointDrillActData:GetChallengeEndTime()
	if self.jointDrillActCfg ~= nil then
		return self.nOpenTime + self.jointDrillActCfg.DrillStartTime + self.jointDrillActCfg.DrillDurationTime
	end
end
return JointDrillActData
