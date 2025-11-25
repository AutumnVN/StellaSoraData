const { writeFileSync } = require('fs');
const WORD = require('./EN/bin/Word.json');
const LANG_WORD = require('./EN/language/en_US/Word.json');
const { collectParamsFrom, resolveParam } = require('./utils');

const word = {};

for (const id in WORD) {
    if (LANG_WORD[WORD[id].Title] === '!NONEED!' || LANG_WORD[WORD[id].Desc] === '!NONEED!') continue;

    word[id] = {
        name: LANG_WORD[WORD[id].Title],
        desc: LANG_WORD[WORD[id].Desc],
        icon: WORD[id].TitleIcon?.slice(13, -1),
        params: getWordParams(id),
    };
}

writeFileSync('./word.json', JSON.stringify(word, null, 4));

function getWordParams(id) {
    const params = collectParamsFrom(WORD[id]);

    return resolveParam(params);
}
