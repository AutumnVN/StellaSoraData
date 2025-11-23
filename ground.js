const { writeFileSync } = require('fs');
const WEEKBOSSAFFIX = require('./EN/bin/WeekBossAffix.json');
const WEEKBOSSFLOOR = require('./EN/bin/WeekBossFloor.json');
const WEEKBOSSLEVEL = require('./EN/bin/WeekBossLevel.json');
const WEEKBOSSTYPE = require('./EN/bin/WeekBossType.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const LANG_WEEKBOSSAFFIX = require('./EN/language/en_US/WeekBossAffix.json');
const LANG_WEEKBOSSLEVEL = require('./EN/language/en_US/WeekBossLevel.json');
const LANG_WEEKBOSSTYPE = require('./EN/language/en_US/WeekBossType.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');

const ground = {};

for (const typeId in WEEKBOSSTYPE) {
    const monster = MONSTER[`${typeId}01`] || MONSTER[`${typeId}10`];
    if (!monster) continue;

    const affixIds = Object.keys(WEEKBOSSAFFIX).filter(affixId => affixId.startsWith(typeId));
    const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
    const monsterValueTemplates = Object.values(MONSTERVALUETEMPLETE).filter(templete => templete.TemplateId === monsterValueTemplateAdjust.TemplateId).slice(0, 3);

    ground[typeId] = {
        name: LANG_WEEKBOSSTYPE[WEEKBOSSTYPE[typeId].Name],
        icon: WEEKBOSSTYPE[typeId].Episode.split('/').pop(),
        mechanic: affixIds.map(affixId => ({
            name: LANG_WEEKBOSSAFFIX[WEEKBOSSAFFIX[affixId].Name],
            desc: LANG_WEEKBOSSAFFIX[WEEKBOSSAFFIX[affixId].Desc],
            icon: WEEKBOSSAFFIX[affixId].Icon.split('/').pop(),
        })),
        weakTo: WEEKBOSSTYPE[typeId].EET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        resistTo: LANG_UITEXT[`UIText.T_Element_Attr_${WEEKBOSSTYPE[typeId].AntiEET[0]}.1`],
        diff: monsterValueTemplates.map(monsterValueTemplate => ({
            level: monsterValueTemplate.Lv,
            stat: {
                'HP': Math.floor(monsterValueTemplate.Hp * (1 + (monsterValueTemplateAdjust.HpRatio / 10000 || 0)) + (monsterValueTemplateAdjust.HpFix || 0)),
                'ATK': monsterValueTemplate.Atk,
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
        }))
    };
}

writeFileSync('./ground.json', JSON.stringify(ground, null, 4));
