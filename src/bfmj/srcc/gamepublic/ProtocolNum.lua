--
-- Author: Chen
-- Date: 2017-11-17 17:29:25
-- Brief: 
--

local protocolNum = gg.protocolNum

if not protocolNum then
    return
end

--// 接收协议
Enum({
    "SC_MAHJ_OP_REQ_P",
    "SC_MAHJ_OP_P",
    "SC_MAHJ_DRAWN_P",
    "SC_MAHJ_TITE_UP_P",
    "SC_MAHJ_DICE_P",
    "SC_MAHJ_RESULT_P",
    "SC_MAHJ_BAO_P",
    "SC_MAHJ_INITDATA_P",
    "SC_BET_P",       
    "SC_MAHJ_CHANGE_P",
    "SC_MAHJ_FIX_P",
    "SC_MAHJ_FIX_ACK_P",
    "SC_MAHJ_CALC_RESULT_P",
    "SC_MAHJ_GAMEOVER_P",
    "SC_MAHJ_HU_RESULT_P",
    "SC_MAHJ_HU_TYPE_P",
    "SC_MAHJ_FIX_END_P",
    "SC_MAHJ_CHANGE_END_P",
    "SC_MAHJ_OPERATE_DATA_ACK_P",
    "SC_MAHJ_CHANGE_TILE_P",
    "SC_MAHJ_FIX_MOVE_P",
    "SC_MAHJ_ANYRAIN_P",
    "SC_MAHJ_SHOOT_P"
}, protocolNum.PROTOCOL_GAMESERVER, protocolNum)


--// 发送协议
Enum({
    "CS_MAHJ_OP_ACK_P",
    "CS_MAHJ_CHANGE_REQ_P",
    "CS_MAHJ_FIX_REQ_P",
    "CS_MAHJ_OPERATE_DATA_REQ_P",
    "CS_GETINITDATA_REQ_P"
}, protocolNum.PROTOCOL_GAMECLIENT, protocolNum)
