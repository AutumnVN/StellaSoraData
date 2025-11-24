local BdConvertBuildPanel = class("BdConvertBuildPanel", BasePanel)
BdConvertBuildPanel._bIsMainPanel = true
BdConvertBuildPanel._bAddToBackHistory = true
BdConvertBuildPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
BdConvertBuildPanel._sUIResRootPath = "UI_Activity/"
BdConvertBuildPanel._tbDefine = {
	{
		sPrefabPath = "_500001/BdConvertBuildPanel.prefab",
		sCtrlName = "Game.UI.Activity.BdConvert._500001.BdConvertBuildCtrl"
	}
}
function BdConvertBuildPanel:Awake()
end
function BdConvertBuildPanel:OnEnable()
end
function BdConvertBuildPanel:OnAfterEnter()
end
function BdConvertBuildPanel:OnDisable()
end
function BdConvertBuildPanel:OnDestroy()
end
function BdConvertBuildPanel:OnRelease()
end
return BdConvertBuildPanel
