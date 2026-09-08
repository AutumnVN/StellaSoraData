const { writeFileSync } = require('fs');

const AVGCHARACTER_URL = 'https://github.com/MakoStar/ss-lua/raw/refs/heads/main/Lua/Game/UI/Avg/_en/Preset/AvgCharacter.lua';

const characterId = {};

fetch(AVGCHARACTER_URL)
    .then(response => response.text())
    .then(AVGCHARACTER => {
        AVGCHARACTER.matchAll(/id = "avg1_(\d{3})",\r?\n?.{0,10}name = "([^"]+)"/g).forEach(([, id, name]) => {
            characterId[id] = name;
        });

        writeFileSync('characterid.json', JSON.stringify(characterId, null, 4));
    });
