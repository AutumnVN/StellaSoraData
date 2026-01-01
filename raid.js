const { writeFileSync } = require('fs');
const JOINTDRILLAFFIX = require('./EN/bin/JointDrillAffix.json');
const JOINTDRILLCONTROL = require('./EN/bin/JointDrillControl.json');
const JOINTDRILLLEVEL = require('./EN/bin/JointDrillLevel.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const LANG_JOINTDRILLAFFIX = require('./EN/language/en_US/JointDrillAffix.json');
const LANG_JOINTDRILLLEVEL = require('./EN/language/en_US/JointDrillLevel.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');
const { MONSTER_EPIC_TYPE } = require('./utils');

const raid = {};

for (const drillId in JOINTDRILLCONTROL) {
    const drillLevelGroupId = JOINTDRILLCONTROL[drillId].DrillLevelGroupId;
    const drillLevels = Object.values(JOINTDRILLLEVEL).filter(level => level.DrillLevelGroupId === drillLevelGroupId);

    raid[drillLevelGroupId] = {
        name: LANG_MONSTERMANUAL[MONSTERMANUAL[MONSTERSKIN[MONSTER[drillLevels[0].BossId].FAId].MonsterManual].Name],
        icon: drillLevels.map(level => MONSTERMANUAL[MONSTER[level.BossId].FCId]?.Icon).filter(value => value)[0]?.split('/')?.pop(),
        subname: LANG_JOINTDRILLLEVEL[drillLevels[0].SubName],
        type: MONSTER_EPIC_TYPE[MONSTER[drillLevels[0].BossId].EpicLv],
        mechanic: drillLevels[0].BossAffix.map(affixId => ({
            name: LANG_JOINTDRILLAFFIX[JOINTDRILLAFFIX[affixId].Name],
            desc: LANG_JOINTDRILLAFFIX[JOINTDRILLAFFIX[affixId].Desc],
            icon: JOINTDRILLAFFIX[affixId].Icon.split('/').pop(),
        })),
        // weakTo: MONSTERVALUETEMPLETEADJUST[MONSTER[drillLevels[0].BossId].Templete].WeakEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        // resistTo: LANG_UITEXT[`UIText.T_Element_Attr_${MONSTERVALUETEMPLETEADJUST[MONSTER[drillLevels[0].BossId].Templete].EET}.1`],
        weakTo: MONSTERVALUETEMPLETEADJUST[MONSTER[drillLevels[drillLevels.length - 1].BossId].Templete].WeakEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        resistTo: (MONSTERVALUETEMPLETEADJUST[MONSTER[drillLevels[drillLevels.length - 1].BossId].Templete].ResistEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'])[0],
        diff: drillLevels.map((level, index) => {
            const monster = MONSTER[level.BossId];
            const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
            const monsterValueTemplate = Object.values(MONSTERVALUETEMPLETE).filter(templete => templete.TemplateId === monsterValueTemplateAdjust.TemplateId)[index];

            return {
                name: LANG_UITEXT[`UIText.JointDrill_Difficulty_Name_${index + 1}.1`],
                stat: {
                    'HP': Math.floor(monsterValueTemplate.Hp * (1 + (monsterValueTemplateAdjust.HpRatio / 10000 || 0)) + (monsterValueTemplateAdjust.HpFix || 0)),
                    'HP Bar': level.HpBarNum,
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
                    'Resilience': Math.floor(monsterValueTemplate.Toughness * (1 + (monsterValueTemplateAdjust.ToughnessRatio / 10000 || 0)) + (monsterValueTemplateAdjust.ToughnessFix || 0)),
                    'Aqua RES': monsterValueTemplateAdjust.WERFix,
                    'Ignis RES': monsterValueTemplateAdjust.FERFix,
                    'Terra RES': monsterValueTemplateAdjust.SERFix,
                    'Ventus RES': monsterValueTemplateAdjust.AERFix,
                    'Lux RES': monsterValueTemplateAdjust.LERFix,
                    'Umbra RES': monsterValueTemplateAdjust.DERFix,
                }
            }
        })
    };
}

writeFileSync('./raid.json', JSON.stringify(raid, null, 4));
