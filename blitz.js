const { writeFileSync } = require('fs');
const SCOREBOSSLEVEL = require('./EN/bin/ScoreBossLevel.json');
const SCOREBOSSGETCONTROL = require('./EN/bin/ScoreBossGetControl.json');
const SCOREBOSSABILITY = require('./EN/bin/ScoreBossAbility.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const LANG_SCOREBOSSGETCONTROL = require('./EN/language/en_US/ScoreBossGetControl.json');
const LANG_SCOREBOSSABILITY = require('./EN/language/en_US/ScoreBossAbility.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');

const blitz = {};

for (const id in SCOREBOSSLEVEL) {
    const scoreBossLevel = SCOREBOSSLEVEL[id];
    const monster = MONSTER[scoreBossLevel.MonsterId];
    const monsterManual = MONSTERMANUAL[MONSTERSKIN[monster.FAId].MonsterManual];
    const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
    const monsterValueTemplate = Object.values(MONSTERVALUETEMPLETE).filter(templete => templete.TemplateId === monsterValueTemplateAdjust.TemplateId)[0];

    blitz[id] = {
        name: LANG_MONSTERMANUAL[monsterManual.Name],
        icon: scoreBossLevel.Episode.split('/').pop(),
        mechanic: [
            {
                name: LANG_SCOREBOSSGETCONTROL[SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].Name],
                desc: LANG_SCOREBOSSGETCONTROL[SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].BehaviorDes],
                icon: SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].IconSource.split('/').pop(),
            },
            {
                name: LANG_SCOREBOSSABILITY[SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Name],
                desc: LANG_SCOREBOSSABILITY[SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Desc],
                icon: SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].IconSource.split('/').pop(),
            }
        ],
        weakTo: monsterValueTemplateAdjust.WeakEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        resistTo: LANG_UITEXT[`UIText.T_Element_Attr_${monsterValueTemplateAdjust.EET}.1`],
        stat: {
            'HP': monsterValueTemplate.Hp,
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
            'Resilience': monsterValueTemplate.Toughness,
            'Aqua RES': monsterValueTemplateAdjust.WERFix,
            'Ignis RES': monsterValueTemplateAdjust.FERFix,
            'Terra RES': monsterValueTemplateAdjust.SERFix,
            'Ventus RES': monsterValueTemplateAdjust.AERFix,
            'Lux RES': monsterValueTemplateAdjust.LERFix,
            'Umbra RES': monsterValueTemplateAdjust.DERFix,
        }
    }
}

writeFileSync('./blitz.json', JSON.stringify(blitz, null, 4));
