const { readFileSync, writeFileSync } = require('fs');

const AVGCHARACTER = readFileSync('lua/game/ui/avg/_en/preset/avgcharacter.lua', 'utf-8');

const characterId = {};

AVGCHARACTER.matchAll(/id = "avg1_(\d{3})",\r\n\t\tname = "([^"]+)"/g).forEach(([, id, name]) => {
    characterId[id] = name;
});

writeFileSync('characterid.json', JSON.stringify(characterId, null, 4));
