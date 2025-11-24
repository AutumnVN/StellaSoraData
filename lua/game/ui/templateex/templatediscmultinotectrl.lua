local TemplateDiscMultiNoteCtrl = class("TemplateDiscMultiNoteCtrl", BaseCtrl)
TemplateDiscMultiNoteCtrl._mapNodeConfig = {
	imgNoteBg = {nCount = 2, sComponentName = "Image"},
	NoteMask = {},
	imgNoteIcon = {nCount = 2, sComponentName = "Image"},
	txtNoteCount = {sComponentName = "TMP_Text"},
	cgNoteCount = {
		sNodeName = "txtNoteCount",
		sComponentName = "CanvasGroup"
	},
	cgNoteIcon = {
		sNodeName = "goNoteIcon",
		sComponentName = "CanvasGroup"
	}
}
TemplateDiscMultiNoteCtrl._mapEventConfig = {}
function TemplateDiscMultiNoteCtrl:SetNoteItem(tbNoteId, nCount, bLock)
	if next(tbNoteId) == nil then
		return
	end
	if #tbNoteId == 1 then
		self._mapNode.NoteMask:SetActive(false)
		self._mapNode.imgNoteIcon[2].gameObject:SetActive(false)
		local noteConfig = ConfigTable.GetData("Note", tbNoteId[1])
		if noteConfig ~= nil then
			local _, _color = ColorUtility.TryParseHtmlString(noteConfig.Color)
			NovaAPI.SetTMPColor(self._mapNode.txtNoteCount, _color)
		end
	else
		self._mapNode.NoteMask:SetActive(true)
		self._mapNode.imgNoteIcon[2].gameObject:SetActive(true)
		local _, _color = ColorUtility.TryParseHtmlString("#264278")
		NovaAPI.SetTMPColor(self._mapNode.txtNoteCount, _color)
	end
	table.sort(tbNoteId)
	for i, nNoteId in ipairs(tbNoteId) do
		if 2 < i then
			printError("\230\183\183\232\137\178\233\159\179\231\172\166\231\167\141\231\177\187\233\133\141\229\135\186\232\182\133\232\191\1352\228\184\170")
			break
		end
		local noteConfig = ConfigTable.GetData("Note", nNoteId)
		if noteConfig ~= nil then
			self:SetPngSprite(self._mapNode.imgNoteBg[i], noteConfig.Style4)
			self:SetPngSprite(self._mapNode.imgNoteIcon[i], noteConfig.Style7)
		end
	end
	NovaAPI.SetTMPText(self._mapNode.txtNoteCount, nCount)
	if bLock then
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgNoteCount, 0.4)
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgNoteIcon, 0.4)
	else
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgNoteCount, 1)
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgNoteIcon, 1)
	end
end
return TemplateDiscMultiNoteCtrl
