const { writeFileSync } = require('fs');
const DISC = require('./EN/bin/Disc.json');
const DISCTAG = require('./EN/bin/DiscTag.json');
const DISCPROMOTE = require('./EN/bin/DiscPromote.json');
const ITEM = require('./EN/bin/Item.json');
const MAINSKILL = require('./EN/bin/MainSkill.json');
const SECONDARYSKILL = require('./EN/bin/SecondarySkill.json');
const SUBNOTESKILL = require('./EN/bin/SubNoteSkill.json');
const SUBNOTESKILLPROMOTEGROUP = require('./EN/bin/SubNoteSkillPromoteGroup.json');
const ATTRIBUTE = require('./EN/bin/Attribute.json');
const DISCEXTRAATTRIBUTE = require('./EN/bin/DiscExtraAttribute.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const LANG_ITEM = require('./EN/language/en_US/Item.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_DISCTAG = require('./EN/language/en_US/DiscTag.json');
const LANG_MAINSKILL = require('./EN/language/en_US/MainSkill.json');
const LANG_SECONDARYSKILL = require('./EN/language/en_US/SecondarySkill.json');
const LANG_SUBNOTESKILL = require('./EN/language/en_US/SubNoteSkill.json');

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

const disc = {};

for (const id in DISC) {
    if (LANG_ITEM[ITEM[id].Title] === '???') continue;

    disc[id] = {
        id: +id,
        name: LANG_ITEM[ITEM[id].Title],
        star: ITEM[id].Rarity === 1 ? 5 : ITEM[id].Rarity === 2 ? 4 : 3,
        element: LANG_UITEXT[`UIText.T_Element_Attr_${DISC[id].EET}.1`],
        tag: DISC[id].Tags?.map(tagId => LANG_DISCTAG[DISCTAG[tagId].Title]) || [],
        mainSkill: getMainSkill(DISC[id].MainSkillGroupId),
        secondarySkill1: getSeconarySkill(DISC[id].SecondarySkillGroupId1),
        secondarySkill2: getSeconarySkill(DISC[id].SecondarySkillGroupId2),
        supportNote: getSupportNote(DISC[id].SubNoteSkillGroupId),
        stat: getStats(DISC[id].AttrBaseGroupId),
        dupe: getDupes(DISC[id].AttrExtraGroupId),
        upgrade: getUpgrades(DISC[id].PromoteGroupId),
    };
}

writeFileSync('./disc.json', JSON.stringify(disc, null, 4));

function getMainSkill(id) {
    const key = Object.keys(MAINSKILL).find(key => MAINSKILL[key].GroupId === id);
    if (!key) return;

    return {
        name: LANG_MAINSKILL[MAINSKILL[key].Name],
        desc: LANG_MAINSKILL[MAINSKILL[key].Desc],
        effectType: getMainSkillEffectTypes(id),
        params: getMainSkillParams(id),
        icon: MAINSKILL[key].Icon.split('/').pop(),
        iconBg: MAINSKILL[key].IconBg.split('/').pop(),
    }
}

function getMainSkillParams(id) {
    const keys = Object.keys(MAINSKILL).filter(key => MAINSKILL[key].GroupId === id);

    const params = keys.map(key => collectParamsFrom(MAINSKILL[key]));

    if (params.length === 0) return;
    if (params.every(p => p.length === 0)) return;
    if (params.every(p => p === params[0])) return params[0];
    return params.join('/');
}

function getMainSkillEffectTypes(id) {
    const effectTypes = [];

    const key = Object.keys(MAINSKILL).find(key => MAINSKILL[key].GroupId === id);
    if (!key) return effectTypes;

    const effectKeys = MAINSKILL[key].EffectId || [];

    for (const effectKey of effectKeys) {
        let currentId = +effectKey;
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;

        effectTypes.push(LANG_UITEXT[`UIText.Enums_Effect_${type}.1`] || EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]);
    }

    return [...new Set(effectTypes)];
}

function getSeconarySkill(id) {
    const key = Object.keys(SECONDARYSKILL).find(key => SECONDARYSKILL[key].GroupId === id);
    if (!key) return;
    if (LANG_SECONDARYSKILL[SECONDARYSKILL[key].Name] === '!NONEED!') return;

    return {
        name: LANG_SECONDARYSKILL[SECONDARYSKILL[key].Name],
        desc: LANG_SECONDARYSKILL[SECONDARYSKILL[key].Desc],
        effectType: getSeconarySkillEffectTypes(id),
        params: getSecondarySkillParams(id),
        requirements: getNoteRequirements(id),
        icon: SECONDARYSKILL[key].Icon.split('/').pop(),
        iconBg: SECONDARYSKILL[key].IconBg.split('/').pop(),
    }
}

function getSecondarySkillParams(id) {
    const keys = Object.keys(SECONDARYSKILL).filter(key => SECONDARYSKILL[key].GroupId === id);

    const params = keys.map(key => collectParamsFrom(SECONDARYSKILL[key]));

    if (params.length === 0) return;
    if (params.every(p => p.length === 0)) return;
    if (params.every(p => p === params[0])) return params[0];
    return params.join('/');
}

function getSeconarySkillEffectTypes(id) {
    const effectTypes = [];

    const keys = Object.keys(SECONDARYSKILL).find(key => SECONDARYSKILL[key].GroupId === id);
    if (!keys) return effectTypes;

    const effectKeys = SECONDARYSKILL[keys].EffectId || [];

    for (const effectKey of effectKeys) {
        let currentId = +effectKey;
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;

        effectTypes.push(LANG_UITEXT[`UIText.Enums_Effect_${type}.1`] || EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]);
    }

    return [...new Set(effectTypes)];
}

function getNoteRequirements(id) {
    const keys = Object.keys(SECONDARYSKILL).filter(key => SECONDARYSKILL[key].GroupId === id);

    const requirements = keys.map(key => {
        const parsed = JSON.parse(SECONDARYSKILL[key].NeedSubNoteSkills);

        const mapped = {};

        for (const [noteId, qty] of Object.entries(parsed)) {
            mapped[LANG_SUBNOTESKILL[SUBNOTESKILL[noteId].Name]] = qty;
        }

        return mapped;
    });

    return requirements;
}

function getSupportNote(id) {
    const keys = Object.keys(SUBNOTESKILLPROMOTEGROUP).filter(key => SUBNOTESKILLPROMOTEGROUP[key].GroupId === id);

    const notes = keys.map(key => {
        const parsed = JSON.parse(SUBNOTESKILLPROMOTEGROUP[key].SubNoteSkills);

        const mapped = {};

        for (const [noteId, qty] of Object.entries(parsed)) {
            mapped[LANG_SUBNOTESKILL[SUBNOTESKILL[noteId].Name]] = qty;
        }

        return mapped;
    });

    return notes;
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

function getStats(id) {
    return Object.keys(ATTRIBUTE)
        .filter(key => ATTRIBUTE[key].GroupId === +id)
        .map(key => {
            const attr = ATTRIBUTE[key];
            return {
                HP: attr.Hp,
                ATK: attr.Atk,
                "Skill DMG": attr.SKILLDMG ? attr.SKILLDMG / 100 + '%' : undefined,
                "Ultimate DMG": attr.ULTRADMG ? attr.ULTRADMG / 100 + '%' : undefined,
                "Aqua DMG": attr.WEE ? attr.WEE / 100 + '%' : undefined,
                "Ignis DMG": attr.FEE ? attr.FEE / 100 + '%' : undefined,
                "Terra DMG": attr.SEE ? attr.SEE / 100 + '%' : undefined,
                "Ventus DMG": attr.AEE ? attr.AEE / 100 + '%' : undefined,
                "Lux DMG": attr.LEE ? attr.LEE / 100 + '%' : undefined,
                "Umbra DMG": attr.DEE ? attr.DEE / 100 + '%' : undefined,
            };
        });
}

function getDupes(id) {
    return Object.keys(DISCEXTRAATTRIBUTE)
        .filter(key => DISCEXTRAATTRIBUTE[key].GroupId === +id)
        .map(key => {
            const attr = DISCEXTRAATTRIBUTE[key];
            return {
                ATK: attr.Atk,
            };
        });
}

function getUpgrades(id) {
    return Object.keys(DISCPROMOTE)
        .filter(key => key.startsWith(id.toString()))
        .map(key => {
            const p = DISCPROMOTE[key];
            const mats = {};

            for (let i = 1; ; i++) {
                const itemIdKey = `ItemId${i}`;
                const numKey = `Num${i}`;

                if (!p[itemIdKey]) break;

                const itemId = p[itemIdKey];
                const num = p[numKey];

                mats[LANG_ITEM[ITEM[itemId].Title]] = num;
            }

            mats.Dorra = p.ExpenseGold;

            return mats;
        }).filter(mats => Object.keys(mats).length > 1);
}

