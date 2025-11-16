const { writeFileSync } = require('fs');
const CHARGEMSLOTCONTROL = require('./EN/bin/CharGemSlotControl.json');
const CHARGEMATTRTYPE = require('./EN/bin/CharGemAttrType.json');
const CHARGEMATTRGROUP = require('./EN/bin/CharGemAttrGroup.json');
const CHARGEMATTRVALUE = require('./EN/bin/CharGemAttrValue.json');

const MAP = {
    '攻击力': 'ATK',
    '防御力': 'DEF',
    '生命上限': 'HP',

    '暴击': 'Crit Rate',

    '暴击伤害': 'Crit DMG',

    '水系伤害': 'Elemental DMG',
    '火系伤害': 'Elemental DMG',
    '地系伤害': 'Elemental DMG',
    '风系伤害': 'Elemental DMG',
    '光系伤害': 'Elemental DMG',
    '暗系伤害': 'Elemental DMG',

    '水系穿透': 'Elemental PEN',
    '火系穿透': 'Elemental PEN',
    '地系穿透': 'Elemental PEN',
    '风系穿透': 'Elemental PEN',
    '光系穿透': 'Elemental PEN',
    '暗系穿透': 'Elemental PEN',

    '普攻伤害': 'Auto Attack DMG',
    '技能伤害': 'Skill DMG',
    '绝招伤害': 'Ultimate DMG',

    '印记伤害': 'Mark DMG',

    '仆从伤害': 'Minion DMG',

    '衍射物伤害': 'Derivative DMG',

    '普攻暴击': 'Auto Attack Crit Rate',
    '技能暴击': 'Skill Crit Rate',
    '绝招暴击': 'Ultimate Crit Rate',
    '印记暴击': 'Mark Crit Rate',
    '仆从暴击': 'Minion Crit Rate',
    '衍生物暴击': 'Derivative Crit Rate',

    '支援能量获取效率': 'Charge Efficiency (Support)',
    '主控能量获取效率': 'Charge Efficiency (Main)',

    '普通攻击等级提升': 'Auto Attack',
    '技能等级提升': 'Main Skill',
    '支援技能等级提升': 'Support Skill',
    '必杀等级提升': 'Ultimate',

    '5号潜能提升': 'Potential',
    '6号潜能提升': 'Potential',
    '7号潜能提升': 'Potential',
    '8号潜能提升': 'Potential',
    '9号潜能提升': 'Potential',
    '10号潜能提升': 'Potential',
    '11号潜能提升': 'Potential',
    '12号潜能提升': 'Potential',
    '13号潜能提升': 'Potential',
    '25号潜能提升': 'Potential',
    '26号潜能提升': 'Potential',
    '27号潜能提升': 'Potential',
    '28号潜能提升': 'Potential',
    '29号潜能提升': 'Potential',
    '30号潜能提升': 'Potential',
    '31号潜能提升': 'Potential',
    '32号潜能提升': 'Potential',
    '33号潜能提升': 'Potential',
    '41号潜能提升': 'Potential',
    '42号潜能提升': 'Potential',
    '43号潜能提升': 'Potential',
}

const emblem = {};

for (const id in CHARGEMSLOTCONTROL) {
    emblem[`lv${CHARGEMSLOTCONTROL[id].UnlockLevel}`] = {
        attrGroup: CHARGEMSLOTCONTROL[id].AttrGroupId.map(gid => {
            const group = Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === gid);
            return {
                weight: group.Weight ? group.Weight / 100 + '%' : undefined,
                uniqueAttrNumWeight: group.UniqueAttrNumWeight ? Object.fromEntries(Object.entries(JSON.parse(group.UniqueAttrNumWeight)).map(([k, v]) => [k, v / 100 + '%'])) : undefined,
                attr: [...new Set(Object.values(CHARGEMATTRTYPE).filter(t => t.GroupId === gid).map(t => `${MAP[t.AttrType] || t.AttrType}: ${Object.values(CHARGEMATTRVALUE).filter(a => a.TypeId === t.Id).map(a => a.Value.includes('.') ? iHateFloatingPointNumber(a.Value, '*', 100) + '%' : a.Value).join(' / ')}`))],
            };
        }),
        uniqueAttrGroup: CHARGEMSLOTCONTROL[id].UniqueAttrGroupId ? (() => {
            const group = Object.values(CHARGEMATTRGROUP).find(g => g.GroupId === CHARGEMSLOTCONTROL[id].UniqueAttrGroupId);
            return {
                weight: group.Weight ? group.Weight / 100 + '%' : undefined,
                uniqueAttrNumWeight: group.UniqueAttrNumWeight ? Object.fromEntries(Object.entries(JSON.parse(group.UniqueAttrNumWeight)).map(([k, v]) => [k, v / 100 + '%'])) : undefined,
                attr: [...new Set(Object.values(CHARGEMATTRTYPE).filter(t => t.GroupId === CHARGEMSLOTCONTROL[id].UniqueAttrGroupId).map(t => `${MAP[t.AttrType] || t.AttrType}: ${Object.values(CHARGEMATTRVALUE).filter(a => a.TypeId === t.Id).map(a => a.Value.includes('.') ? iHateFloatingPointNumber(a.Value, '*', 100) + '%' : a.Value).join(' / ')}`))],
            };
        })() : undefined,
    }
}

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

