const CHARACTER = require('./EN/bin/Character.json');
const HITDAMAGE = require('./EN/bin/HitDamage.json');
const EFFECT = require('./EN/bin/Effect.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const BUFFVALUE = require('./EN/bin/BuffValue.json');
const ONCEADDITTIONALATTRIBUTEVALUE = require('./EN/bin/OnceAdditionalAttributeValue.json');
const SCRIPTPARAMETERVALUE = require('./EN/bin/ScriptParameterValue.json');
const SHIELDVALUE = require('./EN/bin/ShieldValue.json');
const SKILL = require('./EN/bin/Skill.json');
const LANG_CHARACTER = require('./EN/language/en_US/Character.json');
const LANG_SKILL = require('./EN/language/en_US/Skill.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');

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
    86: 'TOUGHNESS_BROKEN_DMG',
    87: 'ADD_SHIELD_STRENGTHEN',
    88: 'BE_ADD_SHIELD_STRENGTHEN',
};

const PARAM_TYPE = {
    1: 'BASE',
    2: 'PERCENTAGE',
    3: 'ABSOLUTE'
};

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

const CORNER_TYPE = {
    1: 'Diamond',
    2: 'Triangle',
    3: 'Round',
};

const ITEM_STYPE = {
    1: 'Res',
    2: 'Item',
    3: 'Char',
    4: 'Energy',
    5: 'WorldRankExp',
    6: 'CharShard',
    8: 'Disc',
    9: 'TalentStrengthen',
    12: 'DiscStrengthen',
    13: 'DiscPromote',
    17: 'TreasureBox',
    18: 'GearTreasureBox',
    19: 'SubNoteSkill',
    24: 'SkillStrengthen',
    25: 'CharacterLimitBreak',
    30: 'MonthlyCard',
    31: 'EnergyItem',
    32: 'ComCYO',
    33: 'OutfitCYO',
    34: 'RandomPackage',
    35: 'Equipment',
    37: 'FateCard',
    38: 'EquipmentExp',
    40: 'DiscLimitBreak',
    41: 'Potential',
    42: 'SpecificPotential',
    43: 'Honor',
    44: 'CharacterYO',
    45: 'PlayHead',
    46: 'CharacterSkin',
    47: 'SouvenirEnergyItem'
};

const ITEM_RARITY = {
    1: 'SSR',
    2: 'SR',
    3: 'R',
    4: 'M',
    5: 'N'
};

const TRIGGER_TYPE = {
    1: 'NOTHING',
    2: 'HITTING',
    3: 'BEHIT',
    4: 'KILLENEMY',
    5: 'CRIT',
    6: 'CASTSKILL',
    7: 'GETBUFF',
    8: 'REMOVEBUFF',
    9: 'ENTERBATTLE',
    10: 'LEAVEBATTLE',
    11: 'BECRIT',
    12: 'BEGIN_RELOAD',
    13: 'FINISH_RELOAD',
    18: 'EFFECT_EXECUTE',
    19: 'CERTAIN_TIME_INTERVAL',
    20: 'CASTSKILLEND',
    21: 'HP_CHANGE',
    22: 'ON_IMMUNE_DEAD',
    23: 'DAMAGE_CAUSE_DEAD',
    24: 'PERFECT_DODGE',
    25: 'BATTLE_WIN',
    26: 'SWICH_PLAYER',
    27: 'TO_BREAK_ALLSHIELD',
    28: 'BE_BREAK_ALLSHIELD',
    29: 'BE_BREAK_CERTAINSHIELD',
    30: 'BE_FINISH_CERTAINSHIELD',
    31: 'BREAK_TOUGHNESS',
    32: 'TRIGGER_MARK',
    33: 'ULTIMATE_ENERGY_CHANGE',
    34: 'ATTACKING',
    35: 'BEATTACK',
    36: 'SUMMONED_DIED',
    37: 'SUMMON',
    38: 'ADD_SHIELD',
    39: 'GET_SHIELD',
    40: 'IN_BATTLE_STATE',
    41: 'ANY_ACTOR_TRIGGER_MARK'
};

const TARGET_TYPE = {
    1: 'SELF',
    2: 'ENEMY',
    3: 'FULL_TEAM',
    4: 'TEAMMATE',
    5: 'FULL_ENEMY',
    6: 'MAINCONTROL_PLAYER',
    7: 'ASSISTANT_PLAYER',
    8: 'TEAM_SUMMONED',
    9: 'FULL_TEAM_AND_SUMMONED',
    10: 'SELF_AND_SUMMONED'
};

const CONDITION_TYPE = {
    1: 'DEFAULT',
    2: 'HEALTHUP',
    3: 'HEALTHDOWN',
    4: 'CARRYBUFFID',
    5: 'CARRYBUFFGROUP',
    6: 'CARRYBUFFIDENTIFYING',
    7: 'SKILLSLOTTYPE',
    8: 'HITELEMENTTYPE',
    9: 'DISTANCETYPE',
    10: 'ACTORELEMENTTYPE',
    11: 'CERTAINBUFFID',
    12: 'CERTAINBUFFGROUPID',
    13: 'CERTAINBUFFTAG',
    14: 'CERTAINSHIELDID',
    15: 'NEARBY_ACTOR_LARGE_OR_EQUAL',
    16: 'NEARBY_ACTOR_LESS_OR_EQUAL',
    17: 'CERTAIN_SKILL_ID',
    18: 'HAVE_SHIELD',
    19: 'NO_SHIELD',
    20: 'LEAVE_STAGE',
    21: 'HIT_TARGET_MOREOREQUAL_THAN',
    22: 'HIT_TARGET_LESSOREQUAL_THAN',
    23: 'BUFF_NUM',
    24: 'PROBOBILITY_UP',
    25: 'CERTAIN_LEVEL_TYPE',
    26: 'CERTAIN_EFFECT_ID',
    27: 'CERTAIN_EFFECT_TAG',
    28: 'CERTAIN_MONSTER_EPICTYPE',
    29: 'TIME_INTERVAL',
    30: 'CHARACTER_JOBCLASS',
    31: 'ROGUELIKE_LEVELSTYLE',
    32: 'CERTAIN_MONSTER_TAG',
    33: 'TARGET_CONTAIN_TAG',
    34: 'DAMAGE_CONTAIN_TAG',
    35: 'DISTANCE_LESSOREQUAL_THAN',
    36: 'DISTANCE_MOREOREQUAL_THAN',
    37: 'CERTAIN_FACTION_TYPE',
    38: 'IN_FORWARDAREA',
    39: 'CERTAIN_HITDAMAGEID',
    40: 'HAVE_FRIENDLY_SUMMONS',
    41: 'SELF_BE_MAINCONTROL',
    42: 'SELF_BE_ASSISTANT',
    43: 'CERTAIN_TYPE_ASSISTANT_IN_BATTLE',
    44: 'CERTAIN_MARK_ELEMENT_TYPE',
    45: 'ULTIMATE_ENERGY_MOREOREQUAL_THAN',
    46: 'SELF_HP_PERCENT_MOREOREQUAL_THAN',
    47: 'ULTIMATE_ENERGY_LESSOREQUAL_THAN',
    48: 'IS_TOUGHNESS_BROKEN',
    49: 'DAMAGE_NOT_NORMAL',
    50: 'WEAKELEMENTTYPE',
    51: 'CERTAIN_MARK_TYPE',
    52: 'BE_MAINCONTROL',
    53: 'BE_ASSISTANT'
};

const LOGIC_TYPE = {
    1: 'AND',
    2: 'OR',
};

function collectParamsFrom(obj) {
    if (!obj) return [];

    const paramKeys = Object.keys(obj).filter(k => k.match(/^param\d+$/i));

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

function resolveParam(params) {
    return params.map(param => {
        const p = param.split(',');

        if (p[0] === 'HitDamage') {
            if (!HITDAMAGE[p[2]]) return param;
            return HITDAMAGE[p[2]].SkillPercentAmend.filter(v => v !== 0).map(v => v / 10000 + '%').join('/');
        }

        if (p[0] === 'Character') {
            if (!CHARACTER[p[2]]) return param;
            return LANG_CHARACTER[CHARACTER[p[2]][p[3]]];
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

function getEffectData(effectId) {
    const effect = EFFECT[effectId];
    if (!effect) return;

    const trigger = TRIGGER_TYPE[effect.Trigger];
    const triggerTarget = TARGET_TYPE[effect.TriggerTarget];
    const triggerCondition1 = CONDITION_TYPE[effect.TriggerCondition1];
    const triggerParam1 = triggerCondition1?.includes('ELEMENT') ? LANG_UITEXT[`UIText.T_Element_Attr_${effect.TriggerParam1}.1`] : effect.TriggerParam1;
    const triggerTarget2 = TARGET_TYPE[effect.TriggerTarget2];
    const triggerCondition2 = CONDITION_TYPE[effect.TriggerCondition2];
    const triggerParam2 = triggerCondition2?.includes('ELEMENT') ? LANG_UITEXT[`UIText.T_Element_Attr_${effect.TriggerParam2}.1`] : effect.TriggerParam2;
    const triggerLogicType = triggerTarget2 && LOGIC_TYPE[effect.TriggerLogicType];

    const takeEffectTarget1 = TARGET_TYPE[effect.TakeEffectTarget1];
    const takeEffectCondition1 = CONDITION_TYPE[effect.TakeEffectCondition1];
    const takeEffectParam1 = takeEffectCondition1?.includes('ELEMENT') ? LANG_UITEXT[`UIText.T_Element_Attr_${effect.TakeEffectParam1}.1`] : effect.TakeEffectParam1;
    const takeEffectTarget2 = TARGET_TYPE[effect.TakeEffectTarget2];
    const takeEffectCondition2 = CONDITION_TYPE[effect.TakeEffectCondition2];
    const takeEffectParam2 = takeEffectCondition2?.includes('ELEMENT') ? LANG_UITEXT[`UIText.T_Element_Attr_${effect.TakeEffectParam2}.1`] : effect.TakeEffectParam2;
    const takeEffectLogicType = takeEffectTarget2 && LOGIC_TYPE[effect.TakeEffectLogicType];

    const target1 = TARGET_TYPE[effect.Target1];
    const targetCondition1 = CONDITION_TYPE[effect.TargetCondition1];
    const targetParam1 = targetCondition1?.includes('ELEMENT') ? LANG_UITEXT[`UIText.T_Element_Attr_${effect.TargetParam1}.1`] : effect.TargetParam1;

    let triggerLine = [trigger, triggerTarget, triggerCondition1, triggerParam1, triggerLogicType, triggerTarget2, triggerCondition2, triggerParam2].filter(v => v).join(', ');
    let takeEffectLine = [takeEffectTarget1, takeEffectCondition1, takeEffectParam1, takeEffectLogicType, takeEffectTarget2, takeEffectCondition2, takeEffectParam2].filter(v => v).join(', ');
    let targetLine = [target1, targetCondition1, targetParam1].filter(v => v).join(', ');

    const result = [triggerLine, takeEffectLine, targetLine].join(' | ');

    if (result === 'NOTHING, SELF, DEFAULT | SELF, DEFAULT | SELF, DEFAULT') return;

    return result;
}

function formatEffectType(id, type, paramType) {
    let result = '';
    const effectTypeStr = EFFECT_TYPE[EFFECTVALUE[id].EffectType];
    const attrTypeStr = ATTR_TYPE[type];
    const paramTypeStr = PARAM_TYPE[paramType];

    result += effectTypeStr;

    if (attrTypeStr) {
        if (['ATTR_FIX', 'HITTED_ADDITIONAL_ATTR_FIX', 'ADDBUFF'].includes(effectTypeStr)) {
            result += `:${attrTypeStr}`;
        } else {
            result += `:${type}`;
        }

        if (['ATTR_FIX', 'HITTED_ADDITIONAL_ATTR_FIX'].includes(effectTypeStr)) {
            result += `:${paramTypeStr}`;
        }
    }

    return result;
}

module.exports = {
    collectParamsFrom,
    iHateFloatingPointNumber,
    resolveParam,
    getEffectData,
    formatEffectType,
    ATTR_TYPE,
    PARAM_TYPE,
    DAMAGE_TYPE,
    EFFECT_TYPE,
    CORNER_TYPE,
    ITEM_STYPE,
    ITEM_RARITY,
    TRIGGER_TYPE,
    TARGET_TYPE,
    CONDITION_TYPE,
    LOGIC_TYPE,
};
