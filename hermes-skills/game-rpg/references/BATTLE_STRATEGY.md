# Battle AI Strategy Reference

## 1. Damage Formula

```
damage = baseMultiplier × (1 + stat/100) × (1 + 0.03 × (skillLevel-1)) × random(0.9, 1.1) - targetDEF
```

- `stat` = attack for physical skills, magicAttack for magic skills
- `baseMultiplier` is skill-specific
- Random variance: ±10%

## 2. Defense Reduction

```
damageReduction% = min(DEF × 5, 50)
```

DEF value directly reduces damage by up to 50%.

## 3. Turn Order

Speed stat determines turn order. Higher speed = acts first.

## 4. HP/MP Thresholds Strategy

### HP-Based Decisions

| HP% | Action |
|-----|--------|
| >70% | Offensive: use highest damage skill |
| 50-70% | Balanced: use efficient skills |
| 30-50% | Cautious: use defend or heal if available |
| <30% | Critical: heal immediately or defend |

### MP-Based Decisions

| MP Level | Action |
|----------|--------|
| >50% | Use tier 3 skills freely |
| 25-50% | Use tier 2 skills |
| 10-25% | Use tier 1 skills only |
| <10% | Basic attack only |

## 5. Per-Class Strategy

### Dual Blade (Physical AOE hybrid)

- Enemies ≥ 2: Use AOE skills (Storm Blade > Shadow Blade > Whirlwind)
- 1 enemy: Phantom Slash > Whirlwind
- Fastest class, acts first often
- Good against groups

### Great Sword (Physical single-target burst)

- Always target highest threat enemy
- Use World Slash > Mountain Breaker > Heavy Strike
- Best against bosses
- Slow but devastating

### Blade Master (AOE tank)

- Always use AOE skills (Heaven Blade > Sword Aura > Sweep)
- High HP/DEF allows aggressive play
- Heaven Blade gives DEF buff for sustain
- Best crowd clearer

### Sealer (Control)

- Priority: Silence casters > Bind Curse dangerous enemies > Confusion groups
- Seal the highest-threat enemy first
- Lower direct damage, rely on party
- Use Confusion on groups for chaos

### Healer (Support)

- Priority: Heal when any ally <50% HP > Group Heal when multiple hurt
- Revival Light for critical moments
- Between heals, use basic attack
- Never lead with offensive moves

### Elementalist (AOE magic)

- Fire Storm for DoT, Ice Fall for slow, Thunder Strike for stun
- Against groups: always use strongest AOE available
- Thunder Strike 30% stun is highest value
- Ice Fall speed reduction helps team survivability

## 6. Target Selection Priority

1. Lowest HP enemy (finish off)
2. Highest ATK enemy (reduce threat)
3. Enemies with <30% HP (overkill threshold)
4. Closest enemy (default)

## 7. Boss Battle Strategy

- Save MP for burst phases
- Keep HP > 60% at all times
- Use defend when no efficient skill option
- Focus all damage on boss (ignore minions if possible)

### Boss-Specific

| Boss | Strategy |
|------|----------|
| Trial Guardian | Straightforward, just attack |
| Forest Guardian | Watch for Healing Roots, burst before heal |
| Sand King | High ATK, defend during Sandstorm |
| Frost Titan | Very tanky, need sustained damage |
| Dreamweaver | Most dangerous, save MP for burst, heal often |

## 8. Encounter Decision Matrix

| Enemies | Count | Player HP | Recommended Action |
|---------|-------|-----------|-------------------|
| Weak (HP<50) | 1-2 | >50% | AOE to clear fast |
| Weak (HP<50) | 3+ | >50% | Strongest AOE |
| Strong (HP>100) | 1 | >50% | Single target burst |
| Strong (HP>100) | 2+ | >50% | AOE + focus weakest |
| Any | Any | <30% | Heal/Defend |
| Boss | 1 | Any | See boss strategy |
