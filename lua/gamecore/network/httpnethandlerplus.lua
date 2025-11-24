local HttpNetHandlerPlus = {}
function HttpNetHandlerPlus.char_gem_generate_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.char_gem_refresh_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.ChangeInfo)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.char_gem_replace_attribute_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_update_gem_lock_status_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_use_preset_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_rename_preset_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gem_equip_gem_succeed_ack(mapMsgData)
end
function HttpNetHandlerPlus.char_gems_import_notify(mapMsgData)
	PlayerData.Equipment:CacheEquipmentDataForChar(mapMsgData)
end
function HttpNetHandlerPlus.char_gems_export_notify(mapMsgData)
	CS.UnityEngine.GUIUtility.systemCopyBuffer = mapMsgData.Value
end
function HttpNetHandlerPlus.char_gem_instance_apply_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.disc_all_limit_break_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.order_paid_notify(mapMsgData)
	PlayerData.Mall:ProcessOrderPaidNotify(mapMsgData)
end
function HttpNetHandlerPlus.order_revoke_notify(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.order_collected_notify(mapMsgData)
	PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.MessageBox, ConfigTable.GetUIText("Order_Collected_Notify"))
end
function HttpNetHandlerPlus.activity_shop_purchase_succeed_ack(mapMsgData)
	if not mapMsgData.IsRefresh then
		local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
		HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
	end
end
function HttpNetHandlerPlus.energy_extract_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.gacha_guarantee_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.vampire_survivor_talent_node_notify(mapData)
	PlayerData.VampireSurvivor:CacheTalentData(mapData)
end
function HttpNetHandlerPlus.gacha_newbie_obtain_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
	PlayerData.Item:CacheFragmentsOverflow(nil, mapMsgData)
end
function HttpNetHandlerPlus.gacha_newbie_spin_failed_ack(mapMsgData)
	EventManager.Hit("GachaProcessStart", false)
end
function HttpNetHandlerPlus.gacha_spin_failed_ack(mapMsgData)
	EventManager.Hit("GachaProcessStart", false)
end
function HttpNetHandlerPlus.activity_story_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.activity_task_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.activity_task_group_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.player_head_icon_change_notify(mapMsgData)
	PlayerData.Base:ChangePlayerHeadId(mapMsgData.Set)
	PlayerData.HeadData:DelHeadId(mapMsgData.Del)
end
function HttpNetHandlerPlus.activity_mining_enter_layer_notify(mapMsgData)
	EventManager.Hit("Mining_UpdateLevelData", mapMsgData)
end
function HttpNetHandlerPlus.activity_mining_grids_error_notify(mapMsgData)
	EventManager.Hit("Mining_Error")
end
function HttpNetHandlerPlus.activity_cookie_settle_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.tutorial_level_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.story_set_info_succeed_ack(mapMsgData)
	PlayerData.StorySet:CacheStorySetData(mapMsgData)
end
function HttpNetHandlerPlus.story_set_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.story_set_state_notify(mapMsgData)
	PlayerData.StorySet:UnlockNewChapter(mapMsgData.Value)
end
function HttpNetHandlerPlus.vampire_survivor_new_season_notify(mapMsgData)
	PlayerData.VampireSurvivor:OnNotifyRefresh(mapMsgData.Value)
end
function HttpNetHandlerPlus.battle_pass_common_fail(mapMsgData)
	EventManager.Hit("BattlePassNeedRefresh")
end
function HttpNetHandlerPlus.activity_levels_settle_failed_ack()
	EventManager.Hit("ActivityLevelSettle_Failed")
end
function HttpNetHandlerPlus.joint_drill_game_over_failed_ack(mapMsgData)
	if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112701 then
		EventManager.Hit("JointDrillChallengeFinishError")
	end
end
function HttpNetHandlerPlus.joint_drill_sync_failed_ack(mapMsgData)
	if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
		EventManager.Hit("JointDrillChallengeFinishError")
	end
end
function HttpNetHandlerPlus.joint_drill_give_up_failed_ack(mapMsgData)
	if mapMsgData ~= nil and mapMsgData.Code ~= nil and mapMsgData.Code == 112704 then
		EventManager.Hit("JointDrillChallengeFinishError")
	end
end
function HttpNetHandlerPlus.build_convert_submit_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.build_convert_group_reward_receive_succeed_ack(mapMsgData)
	local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
	HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
end
function HttpNetHandlerPlus.item_expired_change_notify(mapMsgData)
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Item_Change_Expired_Tips"))
end
return HttpNetHandlerPlus
