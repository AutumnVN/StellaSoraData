const { writeFileSync } = require('fs');
const { MONSTER_EPIC_TYPE, ATTR_TYPE, EFFECT_TYPE } = require('./utils');
const TRAVELERDUELBOSSLEVEL = require('./EN/bin/TravelerDuelBossLevel.json');
const TRAVELERDUELCHALLENGEDIFFICULTY = require('./EN/bin/TravelerDuelChallengeDifficulty.json');
const PREVIEWMONSTERGROUP = require('./EN/bin/PreviewMonsterGroup.json');
const MONSTER = require('./EN/bin/Monster.json');
const MONSTERMANUAL = require('./EN/bin/MonsterManual.json');
const MONSTERSKIN = require('./EN/bin/MonsterSkin.json');
const MONSTERVALUETEMPLETE = require('./EN/bin/MonsterValueTemplete.json');
const MONSTERVALUETEMPLETEADJUST = require('./EN/bin/MonsterValueTempleteAdjust.json');
const EFFECTVALUE = require('./EN/bin/EffectValue.json');
const LANG_TRAVELERDUELBOSSLEVEL = require('./EN/language/en_US/TravelerDuelBossLevel.json');
const LANG_UITEXT = require('./EN/language/en_US/UIText.json');
const LANG_MONSTERMANUAL = require('./EN/language/en_US/MonsterManual.json');

const duel = {};

for (const id in TRAVELERDUELBOSSLEVEL) {
    if (!MONSTER[PREVIEWMONSTERGROUP[TRAVELERDUELBOSSLEVEL[id].PreviewMonsterGroupId].MonsterIds[0]]) continue;

    const monsterId = PREVIEWMONSTERGROUP[TRAVELERDUELBOSSLEVEL[id].PreviewMonsterGroupId].MonsterIds[0];
    const monster = MONSTER[monsterId];
    const monsterManual = MONSTERMANUAL[MONSTERSKIN[monster.FAId].MonsterManual];
    const monsterValueTemplateAdjust = MONSTERVALUETEMPLETEADJUST[monster.Templete];
    const monsterValueTemplate = MONSTERVALUETEMPLETE[Object.keys(MONSTERVALUETEMPLETE).filter(key => key === `${monsterValueTemplateAdjust.TemplateId * 1000 + 1 * 10 + 1}`)[0]];

    duel[id] = {
        name: `[${LANG_TRAVELERDUELBOSSLEVEL[TRAVELERDUELBOSSLEVEL[id].Name]}] ${LANG_MONSTERMANUAL[monsterManual.Name]}`,
        icon: monsterManual.Icon.split('/').pop(),
        type: MONSTER_EPIC_TYPE[monster.EpicLv],
        weakTo: TRAVELERDUELBOSSLEVEL[id].EET?.map(type => LANG_UITEXT[`UIText.T_Element_Attr_${type}.1`]) || ['None'],
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
        diff: Object.values(TRAVELERDUELCHALLENGEDIFFICULTY).slice(0, 151).map(diff => {
            if (!diff.EffectId) return {};

            const effects = Object.fromEntries(diff.EffectId.filter(effectId => EFFECT_TYPE[EFFECTVALUE[effectId].EffectType] === 'ATTR_FIX').map(effectId => {
                const effect = EFFECTVALUE[effectId];
                return [ATTR_TYPE[effect.EffectTypeFirstSubtype], +effect.EffectTypeParam1];
            }))

            return effects;
        })
    };
}

writeFileSync('./duel.json', JSON.stringify(duel, null, 4));
