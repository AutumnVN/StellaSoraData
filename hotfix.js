const API_URL = 'https://api.github.com/repos/MorphTheMoth/Stella-Sora-Combat-Logger/contents/decompilation/hotfix';
const RAW_URL = 'https://github.com/MorphTheMoth/Stella-Sora-Combat-Logger/raw/refs/heads/main/decompilation/hotfix';

const ELEMENTS = { WE: 1, FE: 2, SE: 3, AE: 4, LE: 5, DE: 6 };

function parse(block) {
    const elements = new Set();
    for (const [, code] of block.matchAll(/\belementType\.([A-Z]{2})\b/g)) {
        if (ELEMENTS[code]) elements.add(ELEMENTS[code]);
    }

    const proc = block.includes('TriggerElementMarkEvent');
    const apply = /[^0-9][1-6]011[^0-9]/.test(block);

    return {
        element: elements.size === 1 ? [...elements][0] : 0,
        class: proc ? (apply ? 2 : 1) : (apply ? 3 : 0),
    };
}

async function getHotfixData() {
    const list = await (await fetch(API_URL)).json();
    const version = list.map(entry => entry.name).filter(name => /^\d+(\.\d+)*$/.test(name)).sort((a, b) => a.localeCompare(b, undefined, { numeric: true })).pop();
    const lines = (await (await fetch(`${RAW_URL}/${version}/Hotfix.decompiled.cs`)).text()).split(/\r?\n/);

    const characters = {};
    let depth = 0, id = 0, start = 0;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].replace(/"(?:[^"\\]|\\.)*"/g, '""');
        const namespace = /^namespace AIScript\.Character\._(\d{3})01/.exec(line);
        if (namespace) id = +namespace[1];
        if (depth === 1 && /^\s*(?:public|internal)\s+(?:sealed |abstract |partial )*class ActionScript\b/.test(line)) start = i;
        if (!line.includes('{') && !line.includes('}')) continue;

        for (const char of line) {
            if (char === '{') depth++;
            else if (char === '}' && --depth < 1 && start) {
                if (id) characters[id] = parse(lines.slice(start, i + 1).join('\n'));
                start = 0;
            }
        }
    }

    return characters;
}

module.exports = { getHotfixData };
