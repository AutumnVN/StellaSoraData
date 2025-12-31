local CookieGamePanel = class("CookieGamePanel", BasePanel)
CookieGamePanel._bIsMainPanel = true
CookieGamePanel._tbDefine = {
	{
		sPrefabPath = "Play_Cookie_400004/CookieGamePanel.prefab",
		sCtrlName = "Game.UI.Play_Cookie_400004.CookieGameCtrl"
	}
}
function CookieGamePanel:Awake()
end
function CookieGamePanel:OnEnable()
end
function CookieGamePanel:OnAfterEnter()
end
function CookieGamePanel:OnDisable()
end
function CookieGamePanel:OnDestroy()
end
function CookieGamePanel:OnRelease()
end
return CookieGamePanel
