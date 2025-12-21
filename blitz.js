const { writeFileSync } = require('fs');
const SCOREBOSSLEVEL = require('./EN/bin/ScoreBossLevel.json');
const SCOREBOSSGETCONTROL = require('./EN/bin/ScoreBossGetControl.json');
const SCOREBOSSABILITY = require('./EN/bin/ScoreBossAbility.json');
const SCOREGETSWITCH = require('./EN/bin/ScoreGetSwitch.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const MONSTERVALUETEMPLETEMODIFY = require('./EN/bin/MonsterValueTempleteModify.json');
const LANG_SCOREBOSSGETCONTROL = require('./EN/language/en_US/ScoreBossGetControl.json');
const LANG_SCOREBOSSABILITY = require('./EN/language/en_US/ScoreBossAbility.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');
const { MONSTER_EPIC_TYPE } = require('./utils');

const blitz = {};

for (const id in SCOREBOSSLEVEL) {
    const scoreBossLevel = SCOREBOSSLEVEL[id];
    const scoreGetSwitch = SCOREGETSWITCH[`${scoreBossLevel.ScoreGetSwitchGroup}001`];
    const monster = MONSTER[scoreBossLevel.MonsterId];
    const monsterManual = MONSTERMANUAL[MONSTERSKIN[monster.FAId].MonsterManual];
    const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
    const monsterValueTemplate = Object.values(MONSTERVALUETEMPLETE).filter(templete => templete.TemplateId === monsterValueTemplateAdjust.TemplateId)[0];
    const monsterValueTemplateModify = Object.values(MONSTERVALUETEMPLETEMODIFY).filter(modify => modify.GroupId === +(scoreBossLevel.MonsterId.toString().slice(2, 6)));

    blitz[id] = {
        name: LANG_MONSTERMANUAL[monsterManual.Name],
        icon: scoreBossLevel.Episode.split('/').pop(),
        type: MONSTER_EPIC_TYPE[monster.EpicLv],
        mechanic: [
            {
                name: LANG_SCOREBOSSGETCONTROL[SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].Name],
                desc: LANG_SCOREBOSSGETCONTROL[SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].BehaviorDes],
                icon: SCOREBOSSGETCONTROL[scoreBossLevel.NonDamageScoreGet].IconSource.split('/').pop(),
            },
            {
                name: LANG_SCOREBOSSABILITY[SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Name],
                desc: LANG_SCOREBOSSABILITY[SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Desc].replaceAll('&Param1&', SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Value1 + '%').replaceAll('&Param2&', SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].Value2 + '%'),
                icon: SCOREBOSSABILITY[scoreBossLevel.ScoreBossAbility].IconSource.split('/').pop(),
            }
        ],
        weakTo: monsterValueTemplateAdjust.WeakEET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
        resistTo: LANG_UITEXT[`UIText.T_Element_Attr_${monsterValueTemplateAdjust.EET}.1`],
        stat: monsterValueTemplateModify.map((modify, index) => {
            const cumulativeHpFix = monsterValueTemplateModify.slice(0, index + 1).reduce((sum, curr) => sum + (curr.HpFix || 0), 0);
            const cumulativeAtkFix = monsterValueTemplateModify.slice(0, index + 1).reduce((sum, curr) => sum + (curr.AtkFix || 0), 0);
            const cumulativeToughnessFix = monsterValueTemplateModify.slice(0, index + 1).reduce((sum, curr) => sum + (curr.ToughnessFix || 0), 0);

            function cumulativeHp(index) {
                let index2 = 0;
                let totalHp = 0;
                while (index2 <= index) {
                    const cumulativeHpFixOfThisIndex = monsterValueTemplateModify.slice(0, index2 + 1).reduce((sum, curr) => sum + (curr.HpFix || 0), 0);
                    totalHp += Math.floor((monsterValueTemplate.Hp * (1 + (monsterValueTemplateAdjust.HpRatio / 10000 || 0) + (cumulativeHpFixOfThisIndex || 0)) + (monsterValueTemplateAdjust.HpFix || 0)));
                    index2++;
                }
                return totalHp;
            }

            return {
                'Level': modify.Lv,
                'HP': Math.floor((monsterValueTemplate.Hp * (1 + (monsterValueTemplateAdjust.HpRatio / 10000 || 0) + (cumulativeHpFix || 0)) + (monsterValueTemplateAdjust.HpFix || 0))),
                'Cumulative HP': cumulativeHp(index),
                'Estimated Score Damage': [Math.floor(cumulativeHp(index - 1) / scoreGetSwitch.SwitchRate), Math.floor(cumulativeHp(index) / scoreGetSwitch.SwitchRate)].map(value => value.toLocaleString()).join(' - '),
                'Damage Per Score': scoreGetSwitch.SwitchRate,
                'ATK': Math.floor(monsterValueTemplate.Atk * (1 + (monsterValueTemplateAdjust.AtkRatio / 10000 || 0) + (cumulativeAtkFix || 0)) + (monsterValueTemplateAdjust.AtkFix || 0)),
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
                'Resilience': Math.floor(monsterValueTemplate.Toughness * (1 + (monsterValueTemplateAdjust.ToughnessRatio / 10000 || 0) + (cumulativeToughnessFix || 0)) + (monsterValueTemplateAdjust.ToughnessFix || 0)),
                'Aqua RES': monsterValueTemplateAdjust.WERFix,
                'Ignis RES': monsterValueTemplateAdjust.FERFix,
                'Terra RES': monsterValueTemplateAdjust.SERFix,
                'Ventus RES': monsterValueTemplateAdjust.AERFix,
                'Lux RES': monsterValueTemplateAdjust.LERFix,
                'Umbra RES': monsterValueTemplateAdjust.DERFix,
            }
        })
    }
}

writeFileSync('./blitz.json', JSON.stringify(blitz, null, 4));
