local CookieQuestPanel = class("CookieQuestPanel", BasePanel)
CookieQuestPanel._bIsMainPanel = true
CookieQuestPanel._tbDefine = {
	{
		sPrefabPath = "Play_Cookie_400006/CookieQuestPanel.prefab",
		sCtrlName = "Game.UI.Play_Cookie_400006.CookieQuestCtrl"
	}
}
function CookieQuestPanel:Awake()
end
function CookieQuestPanel:OnEnable()
end
function CookieQuestPanel:OnAfterEnter()
end
function CookieQuestPanel:OnDisable()
end
function CookieQuestPanel:OnDestroy()
end
function CookieQuestPanel:OnRelease()
end
return CookieQuestPanel
