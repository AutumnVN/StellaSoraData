const { writeFileSync } = require('fs');
const { MONSTER_EPIC_TYPE } = require('./utils');
const INFINITYTOWER = require('./EN/bin/InfinityTower.json');
const INFINITYTOWERDIFFICULTY = require('./EN/bin/InfinityTowerDifficulty.json');
const INFINITYTOWERFLOOR = require('./EN/bin/InfinityTowerFloor.json');
const INFINITYTOWERAFFIX = require('./EN/bin/InfinityTowerAffix.json');
const PREVIEWMONSTERGROUP = require('./EN/bin/PreviewMonsterGroup.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const LANG_INFINITYTOWER = require('./EN/language/en_US/InfinityTower.json');
const LANG_INFINITYTOWERDIFFICULTY = require('./EN/language/en_US/InfinityTowerDifficulty.json');
const LANG_INFINITYTOWERAFFIX = require('./EN/language/en_US/InfinityTowerAffix.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');

const arena = {};

for (const arenaGroupId in INFINITYTOWER) {
    arena[arenaGroupId] = {
        name: LANG_INFINITYTOWER[INFINITYTOWER[arenaGroupId].Name],
        icon: INFINITYTOWER[arenaGroupId].Bg.split('/').pop(),
        weakTo: LANG_UITEXT[`UIText.T_Element_Attr_${INFINITYTOWER[arenaGroupId].ElementType}.1`],
        openDayDesc: LANG_UITEXT[INFINITYTOWER[arenaGroupId].OpenDayDesc],
        openDay: INFINITYTOWER[arenaGroupId].OpenDay.map(day => ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][day]),
        diff: getArenaDiff(arenaGroupId),
    };
}

writeFileSync('./arena.json', JSON.stringify(arena, null, 4));

function getArenaDiff(arenaGroupId) {
    const arenaDiffIds = Object.keys(INFINITYTOWERDIFFICULTY).filter(key => INFINITYTOWERDIFFICULTY[key].TowerId === +arenaGroupId);

    return arenaDiffIds.map(arenaDiffKey => ({
        name: LANG_INFINITYTOWERDIFFICULTY[INFINITYTOWERDIFFICULTY[arenaDiffKey].Name],
        floor: getArenaFloor(arenaDiffKey),
    }));
}

function getArenaFloor(arenaDiffKey) {
    const arenaFloorIds = Object.keys(INFINITYTOWERFLOOR).filter(key => key.startsWith(arenaDiffKey));

    return arenaFloorIds.map((arenaFloorId, index) => ({
        name: `Floor ${index + 1}`,
        mechanic: INFINITYTOWERFLOOR[arenaFloorId].AffixId.map(affixId => getArenaAffix(affixId)),
        monster: getArenaMonster(INFINITYTOWERFLOOR[arenaFloorId].PreviewMonsterGroupId, INFINITYTOWERFLOOR[arenaFloorId].MonsterLv, INFINITYTOWERFLOOR[arenaFloorId].Stage),
    }));
}

function getArenaAffix(affixId) {
    let desc = LANG_INFINITYTOWERAFFIX[INFINITYTOWERAFFIX[affixId].Desc];

    for (let i = 1; i < 10; i++) {
        desc = desc.replaceAll(`{${i}}`, INFINITYTOWERAFFIX[affixId][`Param${i}`]);
    }

    return {
        name: LANG_INFINITYTOWERAFFIX[INFINITYTOWERAFFIX[affixId].Name],
        desc,
    }
}

function getArenaMonster(previewMonsterGroupId, monsterLv, stage) {
    const monsterIds = PREVIEWMONSTERGROUP[previewMonsterGroupId].MonsterIds;

    return monsterIds.map(monsterId => {
        const monster = MONSTER[monsterId];
        const monsterManual = MONSTERMANUAL[MONSTERSKIN[monster.FAId].MonsterManual];
        const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
        const monsterValueTemplate = MONSTERVALUETEMPLETE[Object.keys(MONSTERVALUETEMPLETE).filter(key => key === `${monsterValueTemplateAdjust.TemplateId * 1000 + monsterLv * 10 + stage}`)[0]];

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
