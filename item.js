const { writeFileSync } = require('fs');
const LANG_ITEM = require('./EN/language/en_US/Item.json');

const item = {};

for (let id = 1; id < 100000; id++) {
    const itemName = LANG_ITEM[`Item.${id}.1`];
    if (!itemName || itemName === '???' || itemName === '!NONEED!') continue;

    item[itemName] = id;
}

writeFileSync('./item.json', JSON.stringify(item, null, 4));
