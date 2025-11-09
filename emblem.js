const { writeFileSync } = require('fs');
const CHARGEMSLOTCONTROL = require('./EN/bin/CharGemSlotControl.json');
const CHARGEMATTRTYPE = require('./EN/bin/CharGemAttrType.json');
const CHARGEMATTRGROUP = require('./EN/bin/CharGemAttrGroup.json');
const CHARGEMATTRVALUE = require('./EN/bin/CharGemAttrValue.json');

const MAP = {
    '无': 'NONE',
    '攻击力': 'ATK',
    '防御力': 'DEF',
    '生命上限': 'MAXHP',
    '命中': 'HITRATE',
    '回避': 'EVD',
    '暴击': 'CRITRATE',
    '暴击抵抗': 'CRITRESIST',
    '暴击伤害': 'CRITDMG',
    '防御穿透': 'PENETRATE',
    '无视防御': 'DEF_IGNORE',
    '水系抗性': 'WATER_RES',
    '火系抗性': 'FIRE_RES',
    '地系抗性': 'SOIL_RES',
    '风系抗性': 'AIR_RES',
    '光系抗性': 'LIGHT_RES',
    '暗系抗性': 'DARK_RES',
    '水系伤害': 'WATER_DMG',
    '火系伤害': 'FIRE_DMG',
    '地系伤害': 'SOIL_DMG',
    '风系伤害': 'AIR_DMG',
    '光系伤害': 'LIGHT_DMG',
    '暗系伤害': 'DARK_DMG',
    '水系穿透': 'WATER_PEN',
    '火系穿透': 'FIRE_PEN',
    '地系穿透': 'SOIL_PEN',
    '风系穿透': 'AIR_PEN',
    '光系穿透': 'LIGHT_PEN',
    '暗系穿透': 'DARK_PEN',
    '无视水系伤害': 'WATER_DMG_IGNORE',
    '无视火系伤害': 'FIRE_DMG_IGNORE',
    '无视地系伤害': 'SOIL_DMG_IGNORE',
    '无视风系伤害': 'AIR_DMG_IGNORE',
    '无视光系伤害': 'LIGHT_DMG_IGNORE',
    '无视暗系伤害': 'DARK_DMG_IGNORE',
    '受到水系伤害': 'WATER_DMG_RECEIVED',
    '受到火系伤害': 'FIRE_DMG_RECEIVED',
    '受到地系伤害': 'SOIL_DMG_RECEIVED',
    '受到风系伤害': 'AIR_DMG_RECEIVED',
    '受到光系伤害': 'LIGHT_DMG_RECEIVED',
    '受到暗系伤害': 'DARK_DMG_RECEIVED',
    '重量': 'WEIGHT',
    '最大韧性': 'TOUGHNESS_MAX',
    '破韧效率': 'TOUGHNESS_DAMAGE_ADJUST',
    '护盾上限': 'SHIELD_MAX',
    '移动速度': 'MOVESPEED',
    '攻击速度': 'ATKSPD_P',
    '强度': 'INTENSITY',
    '造成伤害': 'GENDMG',
    '伤害值': 'DMGPLUS',
    '最终伤害': 'FINALDMG',
    '最终伤害值': 'FINALDMGPLUS',
    '受到所有伤害': 'GENDMGRCD',
    '受到伤害': 'DMGPLUSRCD',
    '弱点压制': 'SUPPRESS',
    '普攻伤害': 'NORMALDMG',
    '技能伤害': 'SKILLDMG',
    '绝招伤害': 'ULTRADMG',
    '其他伤害': 'OTHERDMG',
    '受到普攻伤害': 'RCDNORMALDMG',
    '受到技能伤害': 'RCDSKILLDMG',
    '受到绝招伤害': 'RCDULTRADMG',
    '受到其他伤害': 'RCDOTHERDMG',
    '印记伤害': 'MARKDMG',
    '受到印记伤害': 'RCDMARKDMG',
    '仆从伤害': 'SUMMONDMG',
    '受到仆从伤害': 'RCDSUMMONDMG',
    '衍射物伤害': 'PROJECTILEDMG',
    '受到衍生物伤害': 'RCDPROJECTILEDMG',
    '普攻暴击': 'NORMALCRITRATE',
    '技能暴击': 'SKILLCRITRATE',
    '绝招暴击': 'ULTRACRITRATE',
    '印记暴击': 'MARKCRITRATE',
    '仆从暴击': 'SUMMONCRITRATE',
    '衍生物暴击': 'PROJECTILECRITRATE',
    '其他暴击': 'OTHERCRITRATE',
    '普攻暴击伤害': 'NORMALCRITPOWER',
    '技能暴击伤害': 'SKILLCRITPOWER',
    '绝招暴击伤害': 'ULTRACRITPOWER',
    '印记暴击伤害': 'MARKCRITPOWER',
    '仆从暴击伤害': 'SUMMONCRITPOWER',
    '衍生物暴击伤害': 'PROJECTILECRITPOWER',
    '其他暴击伤害': 'OTHERCRITPOWER',
    '能量上限': 'ENERGY_MAX',
    '技能强度': 'SKILL_INTENSITY',
    '破韧专属易伤': 'TOUGHNESS_BROKEN_DMG',
    '护盾强效': 'ADD_SHIELD_STRENGTHEN',
    '受护盾效率': 'BE_ADD_SHIELD_STRENGTHEN',
    '支援能量获取效率': 'ADD_ENERGY',
    '主控能量获取效率': 'FRONT_ADD_ENERGY',
    '吸血鬼掉落物吸附距离修正': 'ADSORPTION_CHANGE',
    '普通攻击等级提升': 'NormalAtk',
    '技能等级提升': 'Skill',
    '支援技能等级提升': 'AssistSkill',
    '必杀等级提升': 'Ultimate',
    '5号潜能提升': 'Potential5',
    '6号潜能提升': 'Potential6',
    '7号潜能提升': 'Potential7',
    '8号潜能提升': 'Potential8',
    '9号潜能提升': 'Potential9',
    '10号潜能提升': 'Potential10',
    '11号潜能提升': 'Potential11',
    '12号潜能提升': 'Potential12',
    '13号潜能提升': 'Potential13',
    '25号潜能提升': 'Potential25',
    '26号潜能提升': 'Potential26',
    '27号潜能提升': 'Potential27',
    '28号潜能提升': 'Potential28',
    '29号潜能提升': 'Potential29',
    '30号潜能提升': 'Potential30',
    '31号潜能提升': 'Potential31',
    '32号潜能提升': 'Potential32',
    '33号潜能提升': 'Potential33',
    '41号潜能提升': 'Potential41',
    '42号潜能提升': 'Potential42',
    '43号潜能提升': 'Potential43',
}

const emblem = {};

for (const id in CHARGEMSLOTCONTROL) {
    emblem[`lv${CHARGEMSLOTCONTROL[id].UnlockLevel}`] = {
        attrGroup: CHARGEMSLOTCONTROL[id].AttrGroupId.map(gid => {
            const group = Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === gid);
            return {
                groupId: group.GroupId,
                weight: group.Weight ? group.Weight / 100 + '%' : undefined,
                uniqueAttrNumWeight: group.UniqueAttrNumWeight ? Object.fromEntries(Object.entries(JSON.parse(group.UniqueAttrNumWeight)).map(([k, v]) => [k, v / 100 + '%'])) : undefined,
                attr: Object.values(CHARGEMATTRTYPE).filter(t => t.GroupId === gid).map(t => ({
                    attrType: MAP[t.AttrType] || t.AttrType,
                    attrTypeId: Object.values(CHARGEMATTRVALUE).find(a => a.TypeId === t.Id).AttrTypeFirstSubtype,
                    value: Object.values(CHARGEMATTRVALUE).filter(a => a.TypeId === t.Id).map(a => ({
                        value: a.Value.includes('.') ? iHateFloatingPointNumber(a.Value, '*', 100) + '%' : a.Value,
                        rarity: a.Rarity,
                    })),
                })),
            };
        }),
        uniqueAttrGroup: CHARGEMSLOTCONTROL[id].UniqueAttrGroupId ? (() => {
            const group = Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === CHARGEMSLOTCONTROL[id].UniqueAttrGroupId);
            return {
                groupId: group.GroupId,
                weight: group.Weight ? group.Weight / 100 + '%' : undefined,
                uniqueAttrNumWeight: group.UniqueAttrNumWeight ? Object.fromEntries(Object.entries(JSON.parse(group.UniqueAttrNumWeight)).map(([k, v]) => [k, v / 100 + '%'])) : undefined,
                attr: Object.values(CHARGEMATTRTYPE).filter(t => t.GroupId === CHARGEMSLOTCONTROL[id].UniqueAttrGroupId).map(t => ({
                    attrType: MAP[t.AttrType] || t.AttrType,
                    attrTypeId: Object.values(CHARGEMATTRVALUE).find(a => a.TypeId === t.Id).AttrTypeFirstSubtype,
                    value: Object.values(CHARGEMATTRVALUE).filter(a => a.TypeId === t.Id).map(a => ({
                        value: a.Value.includes('.') ? iHateFloatingPointNumber(a.Value, '*', 100) + '%' : a.Value,
                        rarity: a.Rarity,
                    })),
                })),
            };
        })() : undefined,
    }
}

// for (const id in CHARGEMATTRTYPE) {

//     emblem[id] = {
//         attrType: MAP[CHARGEMATTRTYPE[id].AttrType] || CHARGEMATTRTYPE[id].AttrType,
//         attrTypeId: Object.values(CHARGEMATTRVALUE).find(a => a.TypeId === +id).AttrTypeFirstSubtype,
//         groupId: CHARGEMATTRTYPE[id].GroupId,
//         weight: [11, 12].includes(CHARGEMATTRTYPE[id].GroupId) ? JSON.parse(Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === CHARGEMATTRTYPE[id].GroupId).UniqueAttrNumWeight) : Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === CHARGEMATTRTYPE[id].GroupId).Weight / 100 + '%',
//         unlockLevel: Object.values(CHARGEMSLOTCONTROL).find(s => s.AttrGroupId.includes(CHARGEMATTRTYPE[id].GroupId) || s.UniqueAttrGroupId === CHARGEMATTRTYPE[id].GroupId).UnlockLevel,
//         value: Object.values(CHARGEMATTRVALUE).filter(a => a.TypeId === +id).map(a => ({
//             value: a.Value.includes('.') ? iHateFloatingPointNumber(a.Value, '*', 100) + '%' : a.Value,
//             rarity: a.Rarity,
//         })),
//     }
// }

function iHateFloatingPointNumber(a, op, b) {
    const smallest = String(a < b ? a : b);
    const factor = smallest.length - smallest.indexOf('.');

    for (let i = 0; i < factor; i++) {
        a *= 10;
        b *= 10;
    }

    a = Math.round(a);
    b = Math.round(b);
    switch (op) {
        case '+': return (a + b) / (10 ** factor);
        case '-': return (a - b) / (10 ** factor);
        case '*': return (a * b) / (10 ** (factor * 2));
        case '/': return a / b;
    }
}

writeFileSync('./emblem.json', JSON.stringify(emblem, null, 4));

