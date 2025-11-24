local BattleResultMaskCtrl = class("BattleResultMaskCtrl", BaseCtrl)
BattleResultMaskCtrl._mapNodeConfig = {
	animRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	}
}
BattleResultMaskCtrl._mapEventConfig = {
	SettlementPerformLoadFinish = "OnEvent_LoadFinish"
}
function BattleResultMaskCtrl:Awake()
end
function BattleResultMaskCtrl:OnEnable()
end
function BattleResultMaskCtrl:OnDisable()
end
function BattleResultMaskCtrl:OnDestroy()
end
function BattleResultMaskCtrl:OnEvent_LoadFinish()
	self._mapNode.animRoot:Play("BattleResultMaskPanel_victory_out")
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForSeconds(0.5))
		EventManager.Hit(EventId.ClosePanel, PanelId.BattleResultMask)
		EventManager.Hit("OpenBattleResultPanel")
	end
	cs_coroutine.start(wait)
end
return BattleResultMaskCtrl
