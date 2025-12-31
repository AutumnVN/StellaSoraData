const { writeFileSync } = require('fs');
const WORD = require('./EN/bin/Word.json');
const EFFECT = require('./EN/bin/Effect.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const ONCEADDITTIONALATTRIBUTEVALUE = require('./EN/bin/OnceAdditionalAttributeValue.json');
const BUFF = require('./EN/bin/Buff.json');
const LANG_WORD = require('./EN/language/en_US/Word.json');
const { collectParamsFrom, resolveParam, formatEffectType, formatAddAttrType, getEffectData } = require('./utils');

const word = {};

for (const id in WORD) {
    if (LANG_WORD[WORD[id].Title] === '!NONEED!' || LANG_WORD[WORD[id].Desc] === '!NONEED!') continue;

    word[id] = {
        name: LANG_WORD[WORD[id].Title],
        desc: LANG_WORD[WORD[id].Desc],
        icon: WORD[id].TitleIcon?.slice(13, -1),
        params: getWordParams(id),
        effectType: getWordEffectType(id),
        addAttrType: getWordAddAttrType(id),
        effectData: getWordEffectData(id),
        buffIcons: getWordBuffIcons(id),
    };
}

writeFileSync('./word.json', JSON.stringify(word, null, 4));

function getWordParams(id) {
    const params = collectParamsFrom(WORD[id]);

    return resolveParam(params);
}

function getWordEffectType(id) {
    const effectTypes = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');

        let effectId = +p[2];
        if (!EFFECTVALUE[effectId]) effectId += 10;
        if (!EFFECTVALUE[effectId]) continue;

        let type = EFFECTVALUE[effectId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[effectId].EffectTypeParam1]?.EffectTypeFirstSubtype;
        const paramType = EFFECTVALUE[effectId].EffectTypeSecondSubtype;

        effectTypes.push(formatEffectType(effectId, type, paramType));
    }

    return [...new Set(effectTypes)];
}

function getWordAddAttrType(id) {
    const addAttrTypes = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && p.startsWith('OnceAdditionalAttribute'));

    for (const param of params) {
        const p = param.split(',');

        let addAttrId = +p[2];
        if (!ONCEADDITTIONALATTRIBUTEVALUE[addAttrId]) addAttrId += 10;
        if (!ONCEADDITTIONALATTRIBUTEVALUE[addAttrId]) continue;

        const type = ONCEADDITTIONALATTRIBUTEVALUE[addAttrId].AttributeType1;
        const paramType = ONCEADDITTIONALATTRIBUTEVALUE[addAttrId].ParameterType1;
        const type2 = ONCEADDITTIONALATTRIBUTEVALUE[addAttrId].AttributeType2;
        const paramType2 = ONCEADDITTIONALATTRIBUTEVALUE[addAttrId].ParameterType2;

        addAttrTypes.push(formatAddAttrType(type, paramType));
        if (type2 && paramType2) addAttrTypes.push(formatAddAttrType(type2, paramType2));
    }

    return [...new Set(addAttrTypes)];
}

function getWordEffectData(id) {
    const effectDatas = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && p.startsWith('Effect'));

    for (const param of params) {
        const p = param.split(',');
        let effectId = +p[2];
        if (!EFFECT[effectId]) continue;

        const data = getEffectData(effectId);
        if (!data) continue;

        effectDatas.push(data);
    }

    return [...new Set(effectDatas)];
}

function getWordBuffIcons(id) {
    const buffIcons = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && (p.startsWith('Buff') || p.startsWith('Effect')));

    for (const param of params) {
        const p = param.split(',');
        const buffId = +p[2];
        if (!BUFF[buffId]) continue;

        const icon = BUFF[buffId].Icon ? BUFF[buffId].Icon.split('/').pop() : 'No Icon'

        buffIcons.push(icon);
    }

    return [...new Set(buffIcons)];
}

