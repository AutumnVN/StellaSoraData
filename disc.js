const { writeFileSync } = require('fs');
const DISC = require('./EN/bin/Disc.json');
const DISCTAG = require('./EN/bin/DiscTag.json');
const DISCPROMOTE = require('./EN/bin/DiscPromote.json');
const ITEM = require('./EN/bin/Item.json');
const MAINSKILL = require('./EN/bin/MainSkill.json');
const SECONDARYSKILL = require('./EN/bin/SecondarySkill.json');
const SUBNOTESKILL = require('./EN/bin/SubNoteSkill.json');
const SUBNOTESKILLPROMOTEGROUP = require('./EN/bin/SubNoteSkillPromoteGroup.json');
const ATTRIBUTE = require('./EN/bin/Attribute.json');
const DISCEXTRAATTRIBUTE = require('./EN/bin/DiscExtraAttribute.json');
const LANG_ITEM = require('./EN/language/en_US/Item.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_DISCTAG = require('./EN/language/en_US/DiscTag.json');
const LANG_MAINSKILL = require('./EN/language/en_US/MainSkill.json');
const LANG_SECONDARYSKILL = require('./EN/language/en_US/SecondarySkill.json');
const LANG_SUBNOTESKILL = require('./EN/language/en_US/SubNoteSkill.json');

const disc = {};

for (const id in DISC) {
    if (LANG_ITEM[ITEM[id].Title] === '???') continue;

    disc[id] = {
        id: +id,
        name: LANG_ITEM[ITEM[id].Title],
        star: ITEM[id].Rarity === 1 ? 5 : ITEM[id].Rarity === 2 ? 4 : 3,
        element: LANG_UITEXT[`UIText.T_Element_Attr_${DISC[id].EET}.1`],
        tag: DISC[id].Tags?.map(tagId => LANG_DISCTAG[DISCTAG[tagId].Title]) || [],
        mainSkill: getMainSkill(DISC[id].MainSkillGroupId),
        secondarySkill1: getSeconarySkill(DISC[id].SecondarySkillGroupId1),
        secondarySkill2: getSeconarySkill(DISC[id].SecondarySkillGroupId2),
        supportNote: getSupportNote(DISC[id].SubNoteSkillGroupId),
        stat: getStats(DISC[id].AttrBaseGroupId),
        dupe: getDupes(DISC[id].AttrExtraGroupId),
        upgrade: getUpgrades(DISC[id].PromoteGroupId),
    };
}

writeFileSync('./disc.json', JSON.stringify(disc, null, 4));

function getMainSkill(id) {
    const key = Object.keys(MAINSKILL).find(key => MAINSKILL[key].GroupId === id);
    if (!key) return;

    return {
        name: LANG_MAINSKILL[MAINSKILL[key].Name],
        desc: LANG_MAINSKILL[MAINSKILL[key].Desc],
        params: getMainSkillParams(id),
    }
}

function getMainSkillParams(id) {
    const keys = Object.keys(MAINSKILL).filter(key => MAINSKILL[key].GroupId === id);

    const params = keys.map(key => {
        return Object.keys(MAINSKILL[key])
            .filter(k => /^param\d+$/i.test(k))
            .map(k => MAINSKILL[key][k]);
    });

    if (params.length === 0) return;
    if (params.every(p => p.length === 0)) return;
    if (params.every(p => p === params[0])) return params[0];
    return params.join('/');
}

function getSeconarySkill(id) {
    const key = Object.keys(SECONDARYSKILL).find(key => SECONDARYSKILL[key].GroupId === id);
    if (!key) return;
    if (LANG_SECONDARYSKILL[SECONDARYSKILL[key].Name] === '!NONEED!') return;

    return {
        name: LANG_SECONDARYSKILL[SECONDARYSKILL[key].Name],
        desc: LANG_SECONDARYSKILL[SECONDARYSKILL[key].Desc],
        params: getSecondarySkillParams(id),
        requirements: getNoteRequirements(id),
    }
}

function getSecondarySkillParams(id) {
    const keys = Object.keys(SECONDARYSKILL).filter(key => SECONDARYSKILL[key].GroupId === id);

    const params = keys.map(key => {
        return Object.keys(SECONDARYSKILL[key])
            .filter(k => /^param\d+$/i.test(k))
            .map(k => SECONDARYSKILL[key][k]);
    });

    if (params.length === 0) return;
    if (params.every(p => p.length === 0)) return;
    if (params.every(p => p === params[0])) return params[0];
    return params.join('/');
}

function getNoteRequirements(id) {
    const keys = Object.keys(SECONDARYSKILL).filter(key => SECONDARYSKILL[key].GroupId === id);

    const requirements = keys.map(key => {
        const parsed = JSON.parse(SECONDARYSKILL[key].NeedSubNoteSkills);

        const mapped = {};

        for (const [noteId, qty] of Object.entries(parsed)) {
            mapped[LANG_SUBNOTESKILL[SUBNOTESKILL[noteId].Name]] = qty;
        }

        return mapped;
    });

    return requirements;
}

function getSupportNote(id) {
    const keys = Object.keys(SUBNOTESKILLPROMOTEGROUP).filter(key => SUBNOTESKILLPROMOTEGROUP[key].GroupId === id);

    const notes = keys.map(key => {
        const parsed = JSON.parse(SUBNOTESKILLPROMOTEGROUP[key].SubNoteSkills);

        const mapped = {};

        for (const [noteId, qty] of Object.entries(parsed)) {
            mapped[LANG_SUBNOTESKILL[SUBNOTESKILL[noteId].Name]] = qty;
        }

        return mapped;
    });

    return notes;
}

function getStats(id) {
    return Object.keys(ATTRIBUTE)
        .filter(key => ATTRIBUTE[key].GroupId === +id)
        .map(key => {
            const attr = ATTRIBUTE[key];
            return {
                LVL: attr.lvl,
                HP: attr.Hp,
                ATK: attr.Atk,
                "Skill DMG": attr.SKILLDMG ? attr.SKILLDMG / 100 + '%' : undefined,
                "Ultimate DMG": attr.ULTRADMG ? attr.ULTRADMG / 100 + '%' : undefined,
                "Aqua DMG": attr.WEE ? attr.WEE / 100 + '%' : undefined,
                "Ignis DMG": attr.FEE ? attr.FEE / 100 + '%' : undefined,
                "Terra DMG": attr.SEE ? attr.SEE / 100 + '%' : undefined,
                "Ventys DMG": attr.AEE ? attr.AEE / 100 + '%' : undefined,
                "Lux DMG": attr.LEE ? attr.LEE / 100 + '%' : undefined,
                "Umbra DMG": attr.DEE ? attr.DEE / 100 + '%' : undefined,
            };
        });
}

function getDupes(id) {
    return Object.keys(DISCEXTRAATTRIBUTE)
        .filter(key => DISCEXTRAATTRIBUTE[key].GroupId === +id)
        .map(key => {
            const attr = DISCEXTRAATTRIBUTE[key];
            return {
                ATK: attr.Atk,
            };
        });
}

function getUpgrades(id) {
    return Object.keys(DISCPROMOTE)
        .filter(key => key.startsWith(id.toString()))
        .map(key => {
            const p = DISCPROMOTE[key];
            const mats = {};

            for (let i = 1; ; i++) {
                const itemIdKey = `ItemId${i}`;
                const numKey = `Num${i}`;

                if (!p[itemIdKey]) break;

                const itemId = p[itemIdKey];
                const num = p[numKey];

                mats[LANG_ITEM[ITEM[itemId].Title]] = num;
            }

            mats.Dorra = p.ExpenseGold;

            return mats;
        }).filter(mats => Object.keys(mats).length > 1);
}

