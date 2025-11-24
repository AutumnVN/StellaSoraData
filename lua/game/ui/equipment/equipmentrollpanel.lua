local EquipmentRollPanel = class("EquipmentRollPanel", BasePanel)
EquipmentRollPanel._tbDefine = {
	{
		sPrefabPath = "Equipment/EquipmentRollPanel.prefab",
		sCtrlName = "Game.UI.Equipment.EquipmentRollCtrl"
	}
}
function EquipmentRollPanel:Awake()
end
function EquipmentRollPanel:OnEnable()
end
function EquipmentRollPanel:OnAfterEnter()
end
function EquipmentRollPanel:OnDisable()
end
function EquipmentRollPanel:OnDestroy()
end
function EquipmentRollPanel:OnRelease()
end
return EquipmentRollPanel
