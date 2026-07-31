const { readFileSync, writeFileSync } = require('fs');

const AVGCHARACTER = readFileSync('./_Lua/Game/UI/Avg/_en/Preset/AvgCharacter.lua', 'utf-8');

const characterId = {};

AVGCHARACTER.matchAll(/id = "avg1_(\d{3})",\r?\n?.{0,10}name = "([^"]+)"/g).forEach(([, id, name]) => {
    characterId[id] = name;
});

writeFileSync('characterid.json', JSON.stringify(characterId, null, 4));
