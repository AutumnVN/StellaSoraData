const { writeFileSync } = require('fs');
const { ITEM_STYPE, ITEM_RARITY } = require('./utils');
const ITEM = require('./EN/bin/Item.json');
const LANG_ITEM = require('./EN/language/en_US/Item.json');

const item = {};

for (const id in ITEM) {
    const itemName = LANG_ITEM[ITEM[id].Title];
    if (!itemName || itemName === '???' || itemName === '!NONEED!') continue;

    item[itemName] = id;
    item[id] = {
        id: +id,
        name: LANG_ITEM[ITEM[id].Title],
        desc: LANG_ITEM[ITEM[id].Desc],
        literary: LANG_ITEM[ITEM[id].Literary],
        type: ITEM_STYPE[ITEM[id].Stype],
        rarity: ITEM_RARITY[ITEM[id].Rarity],
    }
}

writeFileSync('./item.json', JSON.stringify(item, null, 4));
