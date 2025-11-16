const { writeFileSync } = require('fs');
const CHARACTER = require('./EN/bin/Character.json');
const CHARACTERADVANCE = require('./EN/bin/CharacterAdvance.json');
const CHARACTERDES = require('./EN/bin/CharacterDes.json');
const CHARACTERSKILLUPGRADE = require('./EN/bin/CharacterSkillUpgrade.json');
const CHARPOTENTIAL = require('./EN/bin/CharPotential.json');
const SKILL = require('./EN/bin/Skill.json');
const HITDAMAGE = require('./EN/bin/HitDamage.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const BUFFVALUE = require('./EN/bin/BuffValue.json');
const SHIELDVALUE = require('./EN/bin/ShieldValue.json');
const ITEM = require('./EN/bin/Item.json');
const POTENTIAL = require('./EN/bin/Potential.json');
const ATTRIBUTE = require('./EN/bin/Attribute.json');
const AFFINITYGIFT = require('./EN/bin/AffinityGift.json');
const TALENT = require('./EN/bin/Talent.json');
const TALENTGROUP = require('./EN/bin/TalentGroup.json');
const DATINGCHARACTEREVENT = require('./EN/bin/DatingCharacterEvent.json');
const DATINGBRANCH = require('./EN/bin/DatingBranch.json');
const ONCEADDITTIONALATTRIBUTEVALUE = require('./EN/bin/OnceAdditionalAttributeValue.json');
const SCRIPTPARAMETERVALUE = require('./EN/bin/ScriptParameterValue.json');
const LANG_CHARACTER = require('./EN/language/en_US/Character.json');
const LANG_CHARACTERTAG = require('./EN/language/en_US/CharacterTag.json');
const LANG_SKILL = require('./EN/language/en_US/Skill.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_ITEM = require('./EN/language/en_US/Item.json');
const LANG_POTENTIAL = require('./EN/language/en_US/Potential.json');
const LANG_TALENT = require('./EN/language/en_US/Talent.json');
const LANG_TALENTGROUP = require('./EN/language/en_US/TalentGroup.json');
const LANG_DATINGCHARACTEREVENT = require('./EN/language/en_US/DatingCharacterEvent.json');
const LANG_DATINGBRANCH = require('./EN/language/en_US/DatingBranch.json');

const DAMAGE_TYPE = {
    1: 'Auto Attack',
    2: 'Skill',
    3: 'Ultimate',
    4: 'Other',
    5: 'Mark',
    6: 'Projectile',
    7: 'Minion'
};

const EFFECT_TYPE = {
    1: 'STATE_CHANGE',
    2: 'CURRENTCD',
    3: 'CD',
    6: 'ADDBUFF',
    7: 'ADD_SKILL_LV',
    8: 'SET_SKILL_LV',
    9: 'IMM_BUFF',
    10: 'ADDSKILLAMOUNT',
    11: 'RESUMSKILLAMOUNT',
    12: 'ATTR_FIX',
    13: 'REMOVE_BUFF',
    14: 'EFFECT_CD_FIX',
    15: 'EFFECT_MAX_CD_FIX',
    16: 'AMEND_NO_COST',
    17: 'DAMAGE_IMM_ACC',
    18: 'EFFECT_MUL',
    19: 'EFFECT_HP_RECOVERY',
    21: 'KILL_IMMEDIATELY',
    22: 'ADD_BUFF_DURATION_EXISTING',
    23: 'HIT_ELEMENT_TYPE_EXTEND',
    24: 'CHANGE_EFFECT_RATE',
    25: 'ADD_TAG',
    27: 'EFFECT_HP_REVERTTO',
    28: 'EFFECT_HP_ABSORB',
    29: 'CHANGE_BUFF_LAMINATEDNUM',
    30: 'CHANGE_BUFF_TIME',
    31: 'EFFECT_REVIVE',
    32: 'EFFECT_POSTREVIVE',
    34: 'SPECIAL_ATTR_FIX',
    35: 'AMMO_FIX',
    36: 'MONSTER_ATTR_FIX',
    37: 'PLAYER_ATTR_FIX',
    38: 'IMMUNE_DEAD',
    39: 'ENTER_TRANSPARENT',
    40: 'UNABLE_RECOVER_ENERGY',
    41: 'CLEAR_MONSTER_AI_BRANCH_CD',
    42: 'ADD_SHIELD',
    43: 'REDUCE_HP_BY_CURRENTHP',
    44: 'REDUCE_HP_BY_MAXHP',
    45: 'HITTED_ADDITIONAL_ATTR_FIX',
    46: 'ATTR_ASSIGNMENT',
    47: 'CAST_AREAEFFECT',
    48: 'PASSIVE_SKILL',
    49: 'IMM_CERTAIN_HITDAMAGEID',
    50: 'STATE_AMOUNT',
    51: 'DROP_ITEM_PICKUP_RANGE_FIX',
};

const ATTR_TYPE = {
    1: 'ATK',
    2: 'DEF',
    3: 'HP',
    4: 'Accuracy',
    5: 'Evasion',
    6: 'Crit Rate',
    7: 'Crit RES',
    8: 'Crit DMG',
    9: 'DEF PEN',
    10: 'Ignore DEF',
    11: 'Aqua RES',
    12: 'Ignis RES',
    13: 'Terra RES',
    14: 'Ventus RES',
    15: 'Lux RES',
    16: 'Umbra RES',
    17: 'Aqua DMG',
    18: 'Ignis DMG',
    19: 'Terra DMG',
    20: 'Ventus DMG',
    21: 'Lux DMG',
    22: 'Umbra DMG',
    23: 'Aqua PEN',
    24: 'Ignis PEN',
    25: 'Terra PEN',
    26: 'Ventus PEN',
    27: 'Lux PEN',
    28: 'Umbra PEN',
    29: 'Ignore Aqua RES',
    30: 'Ignore Ignis RES',
    31: 'Ignore Terra RES',
    32: 'Ignore Ventus RES',
    33: 'Ignore Lux RES',
    34: 'Ignore Umbra RES',
    35: 'Aqua DMG Taken',
    36: 'Ignis DMG Taken',
    37: 'Terra DMG Taken',
    38: 'Ventus DMG Taken',
    39: 'Lux DMG Taken',
    40: 'Umbra DMG Taken',
    41: 'Weight',
    42: 'Resilience',
    43: 'Resilience Break Efficiency',
    44: 'Max Shield',
    45: 'Shield PEN',
    46: 'Movement Speed',
    47: 'Attack Speed',
    48: 'Intensity',
    49: 'DMG Dealt',
    50: 'DMG',
    51: 'Final DMG',
    52: 'Final DMG+',
    53: 'DMG Taken',
    54: 'DMG Taken+',
    55: 'VUL Exploit',
    56: 'Auto Attack Damage',
    57: 'Skill DMG',
    58: 'Ultimate DMG',
    59: 'Other DMG',
    60: 'Auto Attack DMG Taken',
    61: 'Skill DMG Taken',
    62: 'Ultimate DMG Taken',
    63: 'Other DMG Taken',
    64: 'Mark DMG',
    65: 'Mark DMG Taken',
    66: 'Minion DMG',
    67: 'Minion DMG Taken',
    68: 'Derivative DMG',
    69: 'Derivative DMG Taken',
    70: 'Auto Attack Crit Rate',
    71: 'Skill Crit Rate',
    72: 'Ultimate Crit Rate',
    73: 'Mark Crit Rate',
    74: 'Minion Crit Rate',
    75: 'Derivative Crit Rate',
    76: 'Other Crit',
    77: 'Normal Attack Crit DMG',
    78: 'Skill Crit DMG',
    79: 'Ultimate Crit DMG',
    80: 'Mark Crit DMG',
    81: 'Minion Crit DMG',
    82: 'Derivative Crit DMG',
    83: 'Other Crit DMG',
    84: 'Max Energy',
    85: 'Skill Intensity',
    86: 'ADD_SHIELD_STRENGTHEN',
    87: 'BE_ADD_SHIELD_STRENGTHEN',
};

const character = {};

for (const id in CHARACTER) {
    if (LANG_CHARACTER[CHARACTER[id].Name] === '???') continue;

    character[id] = {
        id: +id,
        name: LANG_CHARACTER[CHARACTER[id].Name],
        star: CHARACTER[id].Grade === 1 ? 5 : 4,
        element: LANG_UITEXT[`UIText.T_Element_Attr_${CHARACTER[id].EET}.1`],
        class: LANG_UITEXT[`UIText.Char_JobClass_${CHARACTER[id].Class}.1`],
        attackType: CHARACTER[id].CharacterAttackType === 1 ? 'Melee' : 'Ranged',
        tag: CHARACTERDES[id].Tag.map(tagId => LANG_CHARACTERTAG[`CharacterTag.${tagId}.1`]),
        loveGift: getGifts(CHARACTERDES[id].PreferTags),
        hateGift: getGifts(CHARACTERDES[id].HateTags),
        date: getDates(id),
        normalAtk: {
            name: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Title],
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Desc],
            damageType: getSkillDamageTypes(CHARACTER[id].NormalAtkId),
            effectType: getSkillEffectTypes(CHARACTER[id].NormalAtkId),
            params: getSkillParams(CHARACTER[id].NormalAtkId),
            icon: SKILL[CHARACTER[id].NormalAtkId].Icon.split('/').pop(),
        },
        skill: {
            name: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Title],
            cooldown: SKILL[CHARACTER[id].SkillId].SkillCD / 10000 + 's',
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Desc],
            damageType: getSkillDamageTypes(CHARACTER[id].SkillId),
            effectType: getSkillEffectTypes(CHARACTER[id].SkillId),
            params: getSkillParams(CHARACTER[id].SkillId),
            icon: SKILL[CHARACTER[id].SkillId].Icon.split('/').pop(),
        },
        supportSkill: {
            name: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Title],
            cooldown: SKILL[CHARACTER[id].AssistSkillId].SkillCD / 10000 + 's',
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Desc],
            damageType: getSkillDamageTypes(CHARACTER[id].AssistSkillId),
            effectType: getSkillEffectTypes(CHARACTER[id].AssistSkillId),
            params: getSkillParams(CHARACTER[id].AssistSkillId),
            icon: SKILL[CHARACTER[id].AssistSkillId].Icon.split('/').pop(),
        },
        ultimate: {
            name: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Title],
            cooldown: SKILL[CHARACTER[id].UltimateId].SkillCD / 10000 + 's',
            energy: SKILL[CHARACTER[id].UltimateId].UltraEnergy / 10000,
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Desc],
            damageType: getSkillDamageTypes(CHARACTER[id].UltimateId),
            effectType: getSkillEffectTypes(CHARACTER[id].UltimateId),
            params: getSkillParams(CHARACTER[id].UltimateId),
            icon: SKILL[CHARACTER[id].UltimateId].Icon.split('/').pop(),
        },
        potential: getPotentials(id),
        talent: getTalents(id),
        stat: getStats(id),
        upgrade: getUpgrades(id),
        skillUpgrade: getSkillUpgrades(id),
    };
}

writeFileSync('./character.json', JSON.stringify(character, null, 4));

function getSkillParams(skillId) {
    const params = collectParamsFrom(SKILL[skillId]);
    return resolveParam(params);
}

function resolveParam(params) {
    return params.map(param => {
        const p = param.split(',');

        if (p[0] === 'HitDamage') {
            if (!HITDAMAGE[p[2]]) return param;
            return HITDAMAGE[p[2]].SkillPercentAmend.filter(v => v !== 0).map(v => v / 10000 + '%').join('/');
        }

        if (p[1] === 'NoLevel' || (p[0] === 'Buff' && BUFFVALUE[p[2]])) {
            let value;

            switch (p[0]) {
                case 'Effect':
                case 'EffectValue':
                    if (!EFFECTVALUE[p[2]]) return param;
                    value = EFFECTVALUE[p[2]][p[3]];
                    break;

                case 'Buff':
                case 'BuffValue':
                    if (!BUFFVALUE[p[2]]) return param;
                    value = BUFFVALUE[p[2]][p[3]];
                    break;

                case 'OnceAdditionalAttribute':
                case 'OnceAdditionalAttributeValue':
                    if (!ONCEADDITTIONALATTRIBUTEVALUE[p[2]]) return param;
                    value = ONCEADDITTIONALATTRIBUTEVALUE[p[2]][p[3]];
                    break;

                case 'ScriptParameter':
                case 'ScriptParameterValue':
                    if (!SCRIPTPARAMETERVALUE[p[2]]) return param;
                    value = SCRIPTPARAMETERVALUE[p[2]][p[3]];
                    break;

                case 'Shield':
                case 'ShieldValue':
                    if (!SHIELDVALUE[p[2]]) return param;
                    value = SHIELDVALUE[p[2]][p[3]];
                    break;

                case 'Skill':
                    if (!SKILL[p[2]]) return param;
                    value = LANG_SKILL[SKILL[p[2]][p[3]]];
                    break;

                default:
                    break;
            }

            if (value === undefined || value === null) return param;

            switch (p[4]) {
                case 'HdPct':
                    return iHateFloatingPointNumber(value, '*', 100) + '%';
                case 'Fixed':
                    if (value.toString().startsWith('0.')) return iHateFloatingPointNumber(value, '*', 100) + '%';
                    return value;
                case '10K':
                    return value / 10000;
                case '10KPct':
                    return value / 10000 + '%';
                case '10KHdPct':
                    return value / 100 + '%';
                case 'Enum':
                    return ATTR_TYPE[value];
                case 'Pct':
                    return value + '%';
                default:
                    return value;
            }
        }

        if (p[1] === 'LevelUp') {
            const results = [];
            let currentId = Number(p[2]);

            let source;
            switch (p[0]) {
                case 'Effect':
                case 'EffectValue':
                    source = EFFECTVALUE;
                    break;

                case 'Buff':
                case 'BuffValue':
                    source = BUFFVALUE;
                    break;

                case 'OnceAdditionalAttribute':
                case 'OnceAdditionalAttributeValue':
                    source = ONCEADDITTIONALATTRIBUTEVALUE;
                    break;

                case 'ScriptParameter':
                case 'ScriptParameterValue':
                    source = SCRIPTPARAMETERVALUE;
                    break;

                case 'Shield':
                case 'ShieldValue':
                    source = SHIELDVALUE;
                    break;

                default:
                    break;
            }

            if (!source[currentId]) currentId += 10;

            for (; ; currentId += 10) {
                if (!source || !source[currentId]) break;

                const value = source[currentId][p[3]];

                if (value === undefined || value === null) break;

                switch (p[4]) {
                    case 'HdPct':
                        results.push(iHateFloatingPointNumber(value, '*', 100) + '%');
                        break;
                    case 'Fixed':
                        results.push(value);
                        break;
                    case '10K':
                        results.push(value / 10000);
                        break;
                    case '10KPct':
                        results.push(value / 10000 + '%');
                        break;
                    case '10KHdPct':
                        results.push(value / 100 + '%');
                        break;
                    case 'Enum':
                        results.push(ATTR_TYPE[value]);
                        break;
                    case 'Pct':
                        results.push(value + '%');
                        break;
                    default:
                        results.push(value);
                        break;
                }
            }

            if (results.length === 0) return param;
            if (results.every(r => r === results[0])) return results[0];
            return results.join('/');
        }

        return param;
    });
}

function getSkillDamageTypes(skillId) {
    const damageTypes = [];

    const params = collectParamsFrom(SKILL[skillId]).filter(p => p && p.startsWith('HitDamage'));

    for (const param of params) {
        const p = param.split(',');
        if (!HITDAMAGE[p[2]]) continue;

        const type = HITDAMAGE[p[2]].DamageType;

        damageTypes.push(DAMAGE_TYPE[type]);
    }

    return [...new Set(damageTypes)];
}

function getSkillEffectTypes(skillId) {
    const effectTypes = [];

    const params = collectParamsFrom(SKILL[skillId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');
        let currentId = +p[2];
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;

        effectTypes.push(ATTR_TYPE[type] || EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]);
    }

    return [...new Set(effectTypes)];
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

function getUpgrades(charId) {
    return Object.keys(CHARACTERADVANCE)
        .filter(key => CHARACTERADVANCE[key].Group === +charId).map(key => {
            const a = CHARACTERADVANCE[key];
            const mats = {};

            for (let i = 1; ; i++) {
                const tidKey = `Tid${i}`;
                const qtyKey = `Qty${i}`;

                if (!a[tidKey]) break;

                const tid = a[tidKey];
                const qty = a[qtyKey] || 0;
                const itemTitle = ITEM[tid] && ITEM[tid].Title;
                const name = LANG_ITEM[itemTitle];

                mats[name] = qty;
            }

            mats.Dorra = a.GoldQty;

            return mats;
        }).filter(mats => Object.keys(mats).length > 1);
}

function getSkillUpgrades(charId) {
    return Object.keys(CHARACTERSKILLUPGRADE)
        .filter(key => CHARACTERSKILLUPGRADE[key].Group === +charId).map(key => {
            const a = CHARACTERSKILLUPGRADE[key];
            const mats = {};

            for (let i = 1; ; i++) {
                const tidKey = `Tid${i}`;
                const qtyKey = `Qty${i}`;

                if (!a[tidKey]) break;

                const tid = a[tidKey];
                const qty = a[qtyKey];
                const name = LANG_ITEM[ITEM[tid].Title];

                mats[name] = qty;
            }

            mats.Dorra = a.GoldQty;

            return mats;
        }).filter(mats => Object.keys(mats).length > 1);
}

function getPotentials(charId) {
    const pot = CHARPOTENTIAL[charId];
    if (!pot || !pot.MasterSpecificPotentialIds) return {};

    return {
        mainCore: pot.MasterSpecificPotentialIds.map(id => ({
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            rarity: getPotentialRarity(id),
        })),
        mainNormal: pot.MasterNormalPotentialIds.map(id => ({
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            rarity: getPotentialRarity(id),
        })),
        common: pot.CommonPotentialIds.map(id => ({
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            rarity: getPotentialRarity(id),
        })),
        supportCore: pot.AssistSpecificPotentialIds.map(id => ({
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            rarity: getPotentialRarity(id),
        })),
        supportNormal: pot.AssistNormalPotentialIds.map(id => ({
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            rarity: getPotentialRarity(id),
        })),
    }
}

function getPotentialParams(potId) {
    const params = collectParamsFrom(POTENTIAL[potId]);
    return resolveParam(params);
}

function getPotentialDamageTypes(potId) {
    const damageTypes = [];

    const params = collectParamsFrom(POTENTIAL[potId]).filter(p => p && p.startsWith('HitDamage'));

    for (const param of params) {
        const p = param.split(',');
        if (!HITDAMAGE[p[2]]) continue;

        const type = HITDAMAGE[p[2]].DamageType;

        damageTypes.push(DAMAGE_TYPE[type]);
    }

    return [...new Set(damageTypes)];
}

function getPotentialEffectTypes(potId) {
    const effectTypes = [];

    const params = collectParamsFrom(POTENTIAL[potId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;

        effectTypes.push(ATTR_TYPE[type] || EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]);
    }

    return [...new Set(effectTypes)];
}

function getPotentialRarity(potId) {
    const stype = ITEM[potId].Stype;
    const rarity = ITEM[potId].Rarity;

    if (stype === 42) return 'core';
    if (stype === 41 && rarity === 1) return 'rare';
    if (stype === 41 && rarity === 2) return 'common';
    return 'common';
}

function getStats(charId) {
    return Object.keys(ATTRIBUTE)
        .filter(key => ATTRIBUTE[key].GroupId === +charId)
        .map(key => {
            const attr = ATTRIBUTE[key];
            return {
                hp: attr.Hp,
                atk: attr.Atk,
            };
        });
}

function getGifts(tagIds) {
    if (!tagIds || tagIds.length === 0) return [];

    return tagIds.map(tagId => {
        const giftIds = Object.keys(AFFINITYGIFT)
            .filter(key => AFFINITYGIFT[key].Tags.includes(tagId));

        return giftIds.map(giftId => LANG_ITEM[ITEM[giftId].Title]);
    }).flat();
}

function getTalents(charId) {
    return Object.keys(TALENTGROUP)
        .filter(key => TALENTGROUP[key].CharId === +charId).map(groupId => {
            const talentIds = Object.keys(TALENT)
                .filter(key => TALENT[key].GroupId === +groupId);

            const last = talentIds.pop();
            talentIds.unshift(last);

            return {
                name: LANG_TALENTGROUP[TALENTGROUP[groupId].Title],
                boost: talentIds.map(talentId => ({
                    name: LANG_TALENT[TALENT[talentId].Title],
                    desc: LANG_TALENT[TALENT[talentId].Desc],
                    params: getTalentParams(talentId),
                })),
            };
        });
}

function getTalentParams(talentId) {
    const params = collectParamsFrom(TALENT[talentId]);
    return resolveParam(params);
}

function collectParamsFrom(obj) {
    if (!obj) return [];

    const paramKeys = Object.keys(obj).filter(k => /^param\d+$/i.test(k));
    if (paramKeys.length === 0) return [];

    const indices = paramKeys.map(k => {
        const m = k.match(/^param(\d+)$/i);
        return m ? Number(m[1]) : 0;
    }).filter(n => n > 0);

    if (indices.length === 0) return [];

    const max = Math.max(...indices);
    const params = new Array(max).fill('');

    for (const k of paramKeys) {
        const m = k.match(/^param(\d+)$/i);
        if (!m) continue;
        const idx = Number(m[1]);
        params[idx - 1] = obj[k];
    }

    return params;
}

function getDates(charId) {
    return Object.keys(DATINGCHARACTEREVENT)
        .filter(key => DATINGCHARACTEREVENT[key].DatingEventParams[0] === +charId).map(eventId => {
            return {
                id: +eventId,
                name: LANG_DATINGCHARACTEREVENT[DATINGCHARACTEREVENT[eventId].Name],
                clue: LANG_DATINGCHARACTEREVENT[DATINGCHARACTEREVENT[eventId].Clue],
                secondChoice: LANG_DATINGBRANCH[DATINGBRANCH[`${DATINGCHARACTEREVENT[eventId].DatingEventParams[1]}001`][`Option${DATINGCHARACTEREVENT[eventId].BranchTag}`]],
            }
        });
}

