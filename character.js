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

const character = {};

for (const id in CHARACTER) {
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
        normalAtk: {
            id: CHARACTER[id].NormalAtkId,
            name: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Title],
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Desc],
            params: getSkillParams(CHARACTER[id].NormalAtkId),
        },
        skill: {
            id: CHARACTER[id].SkillId,
            name: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Title],
            cooldown: SKILL[CHARACTER[id].SkillId].SkillCD / 10000 + 's',
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Desc],
            params: getSkillParams(CHARACTER[id].SkillId),
        },
        supportSkill: {
            id: CHARACTER[id].AssistSkillId,
            name: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Title],
            cooldown: SKILL[CHARACTER[id].AssistSkillId].SkillCD / 10000 + 's',
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Desc],
            params: getSkillParams(CHARACTER[id].AssistSkillId),
        },
        ultimate: {
            id: CHARACTER[id].UltimateId,
            name: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Title],
            cooldown: SKILL[CHARACTER[id].UltimateId].SkillCD / 10000 + 's',
            energy: SKILL[CHARACTER[id].UltimateId].UltraEnergy / 10000,
            briefDesc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].BriefDesc],
            desc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Desc],
            params: getSkillParams(CHARACTER[id].UltimateId),
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
    const params = Object.keys(SKILL[skillId])
        .filter(key => /^param\d+$/i.test(key))
        .map(key => SKILL[skillId][key]);

    return resolveParam(params);
}

function resolveParam(params) {
    return params.map(param => {
        const p = param.split(',');

        if (p[0] === 'HitDamage') {
            if (!HITDAMAGE[p[2]]) return param;
            return HITDAMAGE[p[2]].SkillPercentAmend.map(v => v / 10000 + '%').join('/');
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
                    return value;
                case '10K':
                    return value / 10000;
                case '10KPct':
                    return value / 10000 + '%';
                case '10KHdPct':
                    return value / 100 + '%';
                case 'Enum':
                    return LANG_UITEXT[`UIText.Enums_Effect_${value}.1`];
                default:
                    return value;
            }
        }

        if (p[1] === 'LevelUp') {
            const results = [];
            let currentId = Number(p[2]) + 10;

            for (; ; currentId += 10) {
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
                        results.push(LANG_UITEXT[`UIText.Enums_Effect_${value}.1`]);
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
    const keys = Object.keys(CHARACTERADVANCE)
        .filter(key => CHARACTERADVANCE[key].Group === +charId);

    return keys.map(key => {
        const a = CHARACTERADVANCE[key];
        const mats = [];

        for (let i = 1; ; i++) {
            const tidKey = `Tid${i}`;
            const qtyKey = `Qty${i}`;

            if (!a[tidKey]) break;

            const tid = a[tidKey];
            const qty = a[qtyKey] || 0;
            const itemTitle = ITEM[tid] && ITEM[tid].Title;
            const name = LANG_ITEM[itemTitle];

            mats.push({
                id: tid,
                name,
                quantity: qty,
            });
        }

        return {
            mats,
            dorra: a.GoldQty,
        };
    }).filter(u => u.mats && u.mats.length > 0);
}

function getSkillUpgrades(charId) {
    const keys = Object.keys(CHARACTERSKILLUPGRADE)
        .filter(key => CHARACTERSKILLUPGRADE[key].Group === +charId);

    return keys.map(key => {
        const a = CHARACTERSKILLUPGRADE[key];
        const mats = [];

        for (let i = 1; ; i++) {
            const tidKey = `Tid${i}`;
            const qtyKey = `Qty${i}`;

            if (!a[tidKey]) break;

            const tid = a[tidKey];
            const qty = a[qtyKey];
            const name = LANG_ITEM[ITEM[tid].Title];

            mats.push({
                id: tid,
                name,
                quantity: qty,
            });
        }

        return {
            mats,
            dorra: a.GoldQty,
        };
    }).filter(u => u.mats && u.mats.length > 0);
}

function getPotentials(charId) {
    const pot = CHARPOTENTIAL[charId];
    if (!pot || !pot.MasterSpecificPotentialIds) return {};

    return {
        mainCore: pot.MasterSpecificPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            params: getPotentialParams(id),
        })),
        mainNormal: pot.MasterNormalPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            params: getPotentialParams(id),
        })),
        common: pot.CommonPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            params: getPotentialParams(id),
        })),
        supportCore: pot.AssistSpecificPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            params: getPotentialParams(id),
        })),
        supportNormal: pot.AssistNormalPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            params: getPotentialParams(id),
        })),
    }
}

function getPotentialParams(potId) {
    const params = Object.keys(POTENTIAL[potId])
        .filter(key => /^param\d+$/i.test(key))
        .map(key => POTENTIAL[potId][key]);

    return resolveParam(params);
}

function getStats(charId) {
    return Object.keys(ATTRIBUTE)
        .filter(key => ATTRIBUTE[key].GroupId === +charId)
        .map(key => {
            const attr = ATTRIBUTE[key];
            return {
                lvl: attr.lvl,
                hp: attr.Hp,
                atk: attr.Atk,
                def: attr.Def,
                critRate: attr.CritRate / 100 + '%',
                critDmg: attr.CritPower / 100 + '%',
            };
        });
}

function getGifts(tagIds) {
    if (!tagIds || tagIds.length === 0) return [];

    return tagIds.map(tagId => {
        const giftIds = Object.keys(AFFINITYGIFT)
            .filter(key => AFFINITYGIFT[key].Tags.includes(tagId));

        return giftIds.map(giftId => ({
            id: +giftId,
            name: LANG_ITEM[ITEM[giftId].Title],
        }));
    }).flat();
}

function getTalents(charId) {
    const talentGroupIds = Object.keys(TALENTGROUP)
        .filter(key => TALENTGROUP[key].CharId === +charId);

    return talentGroupIds.map(groupId => {
        const talentIds = Object.keys(TALENT)
            .filter(key => TALENT[key].GroupId === +groupId);

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
    const params = Object.keys(TALENT[talentId])
        .filter(key => /^param\d+$/i.test(key))
        .map(key => TALENT[talentId][key]);

    return resolveParam(params);
}


