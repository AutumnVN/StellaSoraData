const { writeFileSync } = require('fs');
const { collectParamsFrom, resolveParam, ATTR_TYPE, DAMAGE_TYPE, EFFECT_TYPE, CORNER_TYPE, getEffectData, PARAM_TYPE } = require('./utils');
const CHARACTER = require('./EN/bin/Character.json');
const CHARACTERADVANCE = require('./EN/bin/CharacterAdvance.json');
const CHARACTERDES = require('./EN/bin/CharacterDes.json');
const CHARACTERSKILLUPGRADE = require('./EN/bin/CharacterSkillUpgrade.json');
const CHARPOTENTIAL = require('./EN/bin/CharPotential.json');
const SKILL = require('./EN/bin/Skill.json');
const HITDAMAGE = require('./EN/bin/HitDamage.json');
const EFFECT = require('./EN/bin/Effect.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const ITEM = require('./EN/bin/Item.json');
const POTENTIAL = require('./EN/bin/Potential.json');
const ATTRIBUTE = require('./EN/bin/Attribute.json');
const AFFINITYGIFT = require('./EN/bin/AffinityGift.json');
const TALENT = require('./EN/bin/Talent.json');
const TALENTGROUP = require('./EN/bin/TalentGroup.json');
const DATINGCHARACTEREVENT = require('./EN/bin/DatingCharacterEvent.json');
const DATINGBRANCH = require('./EN/bin/DatingBranch.json');
const ONCEADDITTIONALATTRIBUTEVALUE = require('./EN/bin/OnceAdditionalAttributeValue.json');
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
const LANG_FORCE = require('./EN/language/en_US/Force.json');
const LANG_CHARACTERDES = require('./EN/language/en_US/CharacterDes.json');
const LANG_CHARACTERARCHIVEBASEINFO = require('./EN/language/en_US/CharacterArchiveBaseInfo.json');

const character = {};

!async function () {
    for (const id in CHARACTER) {
        if (LANG_CHARACTER[CHARACTER[id].Name] === '???') continue;

        character[id] = {
            id: +id,
            name: LANG_CHARACTER[CHARACTER[id].Name],
            desc: LANG_CHARACTERDES[CHARACTERDES[id].CharDes],
            star: CHARACTER[id].Grade === 1 ? 5 : 4,
            element: LANG_UITEXT[`UIText.T_Element_Attr_${CHARACTER[id].EET}.1`],
            class: LANG_UITEXT[`UIText.Char_JobClass_${CHARACTER[id].Class}.1`],
            attackType: CHARACTER[id].CharacterAttackType === 1 ? 'Melee' : 'Ranged',
            style: LANG_CHARACTERTAG[`CharacterTag.${CHARACTERDES[id].Tag[1]}.1`],
            force: LANG_FORCE[`Force.${CHARACTERDES[id].Force}.1`],
            tag: CHARACTERDES[id].Tag.map(tagId => LANG_CHARACTERTAG[`CharacterTag.${tagId}.1`]),
            cnCv: LANG_CHARACTERDES[CHARACTERDES[id].CnCv],
            jpCv: LANG_CHARACTERDES[CHARACTERDES[id].JpCv],
            birthday: LANG_CHARACTERARCHIVEBASEINFO[`CharacterArchiveBaseInfo.${id}02.2`],
            loveGift: getGifts(CHARACTERDES[id].PreferTags),
            hateGift: getGifts(CHARACTERDES[id].HateTags),
            date: getDates(id),
            normalAtk: {
                id: CHARACTER[id].NormalAtkId,
                name: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Title],
                briefDesc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].BriefDesc],
                desc: LANG_SKILL[SKILL[CHARACTER[id].NormalAtkId].Desc],
                damageType: getSkillDamageTypes(CHARACTER[id].NormalAtkId),
                effectType: getSkillEffectTypes(CHARACTER[id].NormalAtkId),
                addAttrType: getSkillAddAttrTypes(CHARACTER[id].NormalAtkId),
                effectData: getSkillEffectData(CHARACTER[id].NormalAtkId),
                params: getSkillParams(CHARACTER[id].NormalAtkId),
                icon: SKILL[CHARACTER[id].NormalAtkId].Icon.split('/').pop(),
            },
            skill: {
                id: CHARACTER[id].SkillId,
                name: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Title],
                cooldown: SKILL[CHARACTER[id].SkillId].SkillCD / 10000 + 's',
                briefDesc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].BriefDesc],
                desc: LANG_SKILL[SKILL[CHARACTER[id].SkillId].Desc],
                damageType: getSkillDamageTypes(CHARACTER[id].SkillId),
                effectType: getSkillEffectTypes(CHARACTER[id].SkillId),
                addAttrType: getSkillAddAttrTypes(CHARACTER[id].SkillId),
                effectData: getSkillEffectData(CHARACTER[id].SkillId),
                params: getSkillParams(CHARACTER[id].SkillId),
                icon: SKILL[CHARACTER[id].SkillId].Icon.split('/').pop(),
            },
            supportSkill: {
                id: CHARACTER[id].AssistSkillId,
                name: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Title],
                cooldown: SKILL[CHARACTER[id].AssistSkillId].SkillCD / 10000 + 's',
                briefDesc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].BriefDesc],
                desc: LANG_SKILL[SKILL[CHARACTER[id].AssistSkillId].Desc],
                damageType: getSkillDamageTypes(CHARACTER[id].AssistSkillId),
                effectType: getSkillEffectTypes(CHARACTER[id].AssistSkillId),
                addAttrType: getSkillAddAttrTypes(CHARACTER[id].AssistSkillId),
                effectData: getSkillEffectData(CHARACTER[id].AssistSkillId),
                params: getSkillParams(CHARACTER[id].AssistSkillId),
                icon: SKILL[CHARACTER[id].AssistSkillId].Icon.split('/').pop(),
            },
            ultimate: {
                id: CHARACTER[id].UltimateId,
                name: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Title],
                cooldown: SKILL[CHARACTER[id].UltimateId].SkillCD / 10000 + 's',
                energy: SKILL[CHARACTER[id].UltimateId].UltraEnergy / 10000,
                briefDesc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].BriefDesc],
                desc: LANG_SKILL[SKILL[CHARACTER[id].UltimateId].Desc],
                damageType: getSkillDamageTypes(CHARACTER[id].UltimateId),
                effectType: getSkillEffectTypes(CHARACTER[id].UltimateId),
                addAttrType: getSkillAddAttrTypes(CHARACTER[id].UltimateId),
                effectData: getSkillEffectData(CHARACTER[id].UltimateId),
                params: getSkillParams(CHARACTER[id].UltimateId),
                icon: SKILL[CHARACTER[id].UltimateId].Icon.split('/').pop(),
            },
            special: await getSpecialSkills(id),
            potential: getPotentials(id),
            talent: getTalents(id),
            stat: getStats(id),
            upgrade: getUpgrades(id),
            skillUpgrade: getSkillUpgrades(id),
        };
    }

    writeFileSync('./character.json', JSON.stringify(character, null, 4));
}();

function getSkillParams(skillId) {
    const params = collectParamsFrom(SKILL[skillId]);
    return resolveParam(params);
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
        const paramType = EFFECTVALUE[currentId].EffectTypeSecondSubtype;

        effectTypes.push(`${EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]}${ATTR_TYPE[type] ? `:${['ATTR_FIX', 'ADDBUFF'].includes(EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]) ? ATTR_TYPE[type] : type}:${PARAM_TYPE[paramType]}` : ''}`);
    }

    return [...new Set(effectTypes)];
}

function getSkillAddAttrTypes(skillId) {
    const addAttrTypes = [];

    const params = collectParamsFrom(SKILL[skillId]).filter(p => p && p.startsWith('OnceAdditionalAttribute'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) currentId += 10;
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) continue;

        addAttrTypes.push(ATTR_TYPE[ONCEADDITTIONALATTRIBUTEVALUE[currentId].AttributeType1]);
    }

    return [...new Set(addAttrTypes)];
}

function getSkillEffectData(skillId) {
    const effectDatas = [];

    const params = collectParamsFrom(SKILL[skillId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');
        let currentId = +p[2];
        if (!EFFECT[currentId]) continue;

        const data = getEffectData(currentId);
        if (!data) continue;

        effectDatas.push(data);
    }

    return [...new Set(effectDatas)];
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
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            addAttrType: getPotentialAddAttrTypes(id),
            effectData: getPotentialEffectData(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            corner: CORNER_TYPE[POTENTIAL[id].Corner],
            rarity: getPotentialRarity(id),
        })),
        mainNormal: pot.MasterNormalPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            addAttrType: getPotentialAddAttrTypes(id),
            effectData: getPotentialEffectData(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            corner: CORNER_TYPE[POTENTIAL[id].Corner],
            rarity: getPotentialRarity(id),
        })),
        common: pot.CommonPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            addAttrType: getPotentialAddAttrTypes(id),
            effectData: getPotentialEffectData(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            corner: CORNER_TYPE[POTENTIAL[id].Corner],
            rarity: getPotentialRarity(id),
        })),
        supportCore: pot.AssistSpecificPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            addAttrType: getPotentialAddAttrTypes(id),
            effectData: getPotentialEffectData(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            corner: CORNER_TYPE[POTENTIAL[id].Corner],
            rarity: getPotentialRarity(id),
        })),
        supportNormal: pot.AssistNormalPotentialIds.map(id => ({
            id,
            name: LANG_ITEM[ITEM[id].Title],
            briefDesc: LANG_POTENTIAL[POTENTIAL[id].BriefDesc],
            desc: LANG_POTENTIAL[POTENTIAL[id].Desc],
            damageType: getPotentialDamageTypes(id),
            effectType: getPotentialEffectTypes(id),
            addAttrType: getPotentialAddAttrTypes(id),
            effectData: getPotentialEffectData(id),
            params: getPotentialParams(id),
            icon: ITEM[id].Icon.split('/').pop(),
            corner: CORNER_TYPE[POTENTIAL[id].Corner],
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
        const paramType = EFFECTVALUE[currentId].EffectTypeSecondSubtype;

        effectTypes.push(`${EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]}${ATTR_TYPE[type] ? `:${['ATTR_FIX', 'ADDBUFF'].includes(EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]) ? ATTR_TYPE[type] : type}:${PARAM_TYPE[paramType]}` : ''}`);
    }

    return [...new Set(effectTypes)];
}

function getPotentialAddAttrTypes(potId) {
    const addAttrTypes = [];

    const params = collectParamsFrom(POTENTIAL[potId]).filter(p => p && p.startsWith('OnceAdditionalAttribute'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) currentId += 10;
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) continue;

        addAttrTypes.push(ATTR_TYPE[ONCEADDITTIONALATTRIBUTEVALUE[currentId].AttributeType1]);
    }

    return [...new Set(addAttrTypes)];
}

function getPotentialEffectData(potId) {
    const effectDatas = [];

    const params = collectParamsFrom(POTENTIAL[potId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!EFFECT[currentId]) continue;

        const data = getEffectData(currentId);
        if (!data) continue;

        effectDatas.push(data);
    }

    return [...new Set(effectDatas)];
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
                lv: attr.lvl,
                hp: attr.Hp,
                atk: attr.Atk,
                def: attr.Def,
                critRate: attr.CritRate / 100 + '%',
                critDmg: attr.CritPower / 100 + '%',
                resilienceBreakEfficiency: attr.ToughnessDamageAdjust / 100 + '%',
                vul: attr.Suppress ? attr.Suppress / 100 + '%' : '0%',
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
                    effectType: getTalentEffectTypes(talentId),
                    effectData: getTalentEffectData(talentId),
                })),
            };
        });
}

function getTalentParams(talentId) {
    const params = collectParamsFrom(TALENT[talentId]);
    return resolveParam(params);
}

function getTalentEffectTypes(talentId) {
    const effectTypes = [];

    const params = collectParamsFrom(TALENT[talentId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;
        const paramType = EFFECTVALUE[currentId].EffectTypeSecondSubtype;

        effectTypes.push(`${EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]}${ATTR_TYPE[type] ? `:${['ATTR_FIX', 'ADDBUFF'].includes(EFFECT_TYPE[EFFECTVALUE[currentId].EffectType]) ? ATTR_TYPE[type] : type}:${PARAM_TYPE[paramType]}` : ''}`);
    }

    return [...new Set(effectTypes)];
}

function getTalentEffectData(talentId) {
    const effectDatas = [];

    const params = collectParamsFrom(TALENT[talentId]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!EFFECT[currentId]) continue;

        const data = getEffectData(currentId);
        if (!data) continue;

        effectDatas.push(data);
    }

    return [...new Set(effectDatas)];
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

async function getSpecialSkills(id) {
    const hitdamage = HITDAMAGE[`${CHARACTER[id].SpecialSkillId}1`] || HITDAMAGE[`${CHARACTER[id].DodgeId}1`];
    if (!hitdamage) return;

    const type = HITDAMAGE[`${CHARACTER[id].SpecialSkillId}1`] ? 'Special' : 'Dodge';
    const params = hitdamage.SkillPercentAmend.filter(v => v !== 0).map(v => v / 10000 + '%');

    return {
        id: type === 'Special' ? CHARACTER[id].SpecialSkillId : CHARACTER[id].DodgeId,
        type,
        name: `${await translateText(hitdamage.HitdamageInfo)} (${hitdamage.HitdamageInfo})`,
        params: params.every(v => v === params[0]) ? params[0] : params.join('/'),
        damageType: DAMAGE_TYPE[hitdamage.DamageType],
    };

}

async function translateText(text) {
    const GOOGLE_TRANSLATE_URL = "https://translate-pa.googleapis.com/v1/translate?" + new URLSearchParams({
        "params.client": "gtx",
        "dataTypes": "TRANSLATION",
        "key": "AIzaSyDLEeFI5OtFBwYBIoK_jj5m32rZK5CkCXA",
        "query.sourceLanguage": "zh-CN",
        "query.targetLanguage": "en",
        "query.text": text,
    });

    const response = await fetch(GOOGLE_TRANSLATE_URL);
    const data = await response.json();

    return data.translation;
}
