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

        let currentId = +p[2];
        if (!EFFECTVALUE[currentId]) currentId += 10;
        if (!EFFECTVALUE[currentId]) continue;

        let type = EFFECTVALUE[currentId].EffectTypeFirstSubtype;
        if (!type) type = EFFECTVALUE[EFFECTVALUE[currentId].EffectTypeParam1]?.EffectTypeFirstSubtype;
        const paramType = EFFECTVALUE[currentId].EffectTypeSecondSubtype;

        effectTypes.push(formatEffectType(currentId, type, paramType));
    }

    return [...new Set(effectTypes)];
}

function getWordAddAttrType(id) {
    const addAttrTypes = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && p.startsWith('OnceAdditionalAttribute'));

    for (const param of params) {
        const p = param.split(',');

        let currentId = +p[2];
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) currentId += 10;
        if (!ONCEADDITTIONALATTRIBUTEVALUE[currentId]) continue;

        const type = ONCEADDITTIONALATTRIBUTEVALUE[currentId].AttributeType1;
        const paramType = ONCEADDITTIONALATTRIBUTEVALUE[currentId].ParameterType1;

        addAttrTypes.push(formatAddAttrType(type, paramType));
    }

    return [...new Set(addAttrTypes)];
}

function getWordEffectData(id) {
    const effectDatas = [];

    const params = collectParamsFrom(WORD[id]).filter(p => p && p.startsWith('Effect'));

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

