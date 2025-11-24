const CHARACTER = require('./EN/bin/Character.json');
const HITDAMAGE = require('./EN/bin/HitDamage.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const BUFFVALUE = require('./EN/bin/BuffValue.json');
const ONCEADDITTIONALATTRIBUTEVALUE = require('./EN/bin/OnceAdditionalAttributeValue.json');
const SCRIPTPARAMETERVALUE = require('./EN/bin/ScriptParameterValue.json');
const SHIELDVALUE = require('./EN/bin/ShieldValue.json');
const SKILL = require('./EN/bin/Skill.json');
const LANG_CHARACTER = require('./EN/language/en_US/Character.json');
const LANG_SKILL = require('./EN/language/en_US/Skill.json');

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

module.exports = {
    collectParamsFrom,
    iHateFloatingPointNumber,
    resolveParam,
    ATTR_TYPE,
    DAMAGE_TYPE,
    EFFECT_TYPE,
    CORNER_TYPE,
};
