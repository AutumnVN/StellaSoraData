const { writeFileSync } = require('fs');
const { MONSTER_EPIC_TYPE } = require('./utils');
const STARTOWER = require('./EN/bin/StarTower.json');
const STARTOWERGROUP = require('./EN/bin/StarTowerGroup.json');
const PREVIEWMONSTERGROUP = require('./EN/bin/PreviewMonsterGroup.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const LANG_STARTOWER = require('./EN/language/en_US/StarTower.json');
const LANG_STARTOWERGROUP = require('./EN/language/en_US/StarTowerGroup.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');

const ascension = {};

for (const ascensionGroupId in STARTOWERGROUP) {
    ascension[ascensionGroupId] = {
        name: LANG_STARTOWERGROUP[STARTOWERGROUP[ascensionGroupId].Name],
        icon: STARTOWERGROUP[ascensionGroupId].CoverImage.split('/').pop(),
        weakTo: STARTOWERGROUP[ascensionGroupId].EET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        diff: getAscensionDiff(ascensionGroupId),
    };
}

writeFileSync('./ascension.json', JSON.stringify(ascension, null, 4));

function getAscensionDiff(ascensionGroupId) {
    const ascensionDiffKeys = Object.keys(STARTOWER).filter(key => STARTOWER[key].GroupId === +ascensionGroupId);

    return ascensionDiffKeys.map(ascensionDiffKey => ({
        name: `[${LANG_STARTOWER[STARTOWER[ascensionDiffKey].Name]}] Difficulty ${STARTOWER[ascensionDiffKey].Difficulty}`,
        icon: STARTOWER[ascensionDiffKey].Image.split('/').pop(),
        diff: STARTOWER[ascensionDiffKey].Difficulty,
        weakTo: STARTOWER[ascensionDiffKey].EET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        resistTo: STARTOWER[ascensionDiffKey].NotEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        monster: getAscensionMonster(STARTOWER[ascensionDiffKey].PreviewMonsterGroupId, ascensionGroupId, STARTOWER[ascensionDiffKey].ValueDifficulty),
    }));
}

function getAscensionMonster(previewMonsterGroupId, ascensionGroupId, valueDifficulty) {
    const monsterIds = PREVIEWMONSTERGROUP[previewMonsterGroupId].MonsterIds;

    monsterIds.sort((a, b) => {
        const epicDiff = MONSTER[b].EpicLv - MONSTER[a].EpicLv;
        return epicDiff !== 0 ? epicDiff : a - b;
    });

    return monsterIds.map(monsterId => {
        const monster = MONSTER[monsterId];
        const monsterManual = MONSTERMANUAL[MONSTERSKIN[monster.FAId].MonsterManual];
        const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
        const monsterValueTemplate = MONSTERVALUETEMPLETE[Object.keys(MONSTERVALUETEMPLETE).filter(key => key === `${monsterValueTemplateAdjust.TemplateId * 1000 + ascensionGroupId * 10 + valueDifficulty}`)[0]];

        return {
            name: LANG_MONSTERMANUAL[monsterManual.Name],
            icon: monsterManual.Icon.split('/').pop(),
            type: MONSTER_EPIC_TYPE[monster.EpicLv],
            weakTo: monsterValueTemplateAdjust.WeakEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
            resistTo: LANG_UITEXT[`UIText.T_Element_Attr_${monsterValueTemplateAdjust.EET}.1`],
            stat: {
                'HP': Math.floor(monsterValueTemplate.Hp * (1 + (monsterValueTemplateAdjust.HpRatio / 10000 || 0)) + (monsterValueTemplateAdjust.HpFix || 0)),
                'ATK': Math.floor(monsterValueTemplate.Atk * (1 + (monsterValueTemplateAdjust.AtkRatio / 10000 || 0)) + (monsterValueTemplateAdjust.AtkFix || 0)),
                'DEF': monsterValueTemplate.Def,
                'Hit Rate': monsterValueTemplate.HitRate / 100 + '%',
                'Attack Speed': monsterValueTemplate.AtkSpd / 100 + '%',
                'Aqua DMG': monsterValueTemplate.WEE / 100 + '%',
                'Ignis DMG': monsterValueTemplate.FEE / 100 + '%',
                'Terra DMG': monsterValueTemplate.SEE / 100 + '%',
                'Ventus DMG': monsterValueTemplate.AEE / 100 + '%',
                'Lux DMG': monsterValueTemplate.LEE / 100 + '%',
                'Umbra DMG': monsterValueTemplate.DEE / 100 + '%',
                'Mark DMG Taken': monsterValueTemplate.RCDMARKDMG / 100 + '%',
                'Resilience': Math.floor(monsterValueTemplate.Toughness * (1 + (monsterValueTemplateAdjust.ToughnessRatio / 10000 || 0)) + (monsterValueTemplateAdjust.ToughnessFix || 0)) || undefined,
                'Aqua RES': monsterValueTemplateAdjust.WERFix,
                'Ignis RES': monsterValueTemplateAdjust.FERFix,
                'Terra RES': monsterValueTemplateAdjust.SERFix,
                'Ventus RES': monsterValueTemplateAdjust.AERFix,
                'Lux RES': monsterValueTemplateAdjust.LERFix,
                'Umbra RES': monsterValueTemplateAdjust.DERFix,
            },
        };
    });
}
