const { writeFileSync } = require('fs');
const GACHA = require('./EN/bin/Gacha.json');
const GACHAPKG = require('./EN/bin/GachaPkg.json');
const CHARACTER = require('./EN/bin/Character.json');
const ITEM = require('./EN/bin/Item.json');
const LANG_GACHA = require('./EN/language/en_US/Gacha.json');
const LANG_CHARACTER = require('./EN/language/en_US/Character.json');
const LANG_ITEM = require('./EN/language/en_US/Item.json');

const gacha = {};

for (const id in GACHA) {
    gacha[id] = {
        id: +id,
        name: LANG_GACHA[GACHA[id].Name],
        rateUp5Star: getGachaPkg(GACHA[id].ATypeUpPkg),
        rateUp4Star: getGachaPkg(GACHA[id].BTypeUpPkg),
        startTime: GACHA[id].StartTime,
        endTime: GACHA[id].EndTime,
    };
}

writeFileSync('./gacha.json', JSON.stringify(gacha, null, 4));

function getGachaPkg(pkgId) {
    return Object.keys(GACHAPKG)
        .filter(key => GACHAPKG[key].PkgId === pkgId)
        .map(key => {
            const id = GACHAPKG[key].GoodsId;
            return {
                id,
                name: LANG_CHARACTER[CHARACTER[id]?.Name] || LANG_ITEM[ITEM[id]?.Title],
            };
        });
}

