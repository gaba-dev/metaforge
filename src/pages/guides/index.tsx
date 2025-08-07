import React, { useState } from 'react';
import { Layout, Card } from '@/components/ui';
import { FeatureBanner, HeaderBanner } from '@/components/common';
import { 
  BookOpen, 
  Info, 
  Star, 
  ShoppingBag, 
  Layers, 
  Users, 
  Activity, 
  Shield,
  Swords,
  Calendar,
  Clock,
  Puzzle
} from 'lucide-react';

// ACTUAL Set 15: K.O. Coliseum data based on real information
const guidesData = {
  set_info: {
    name: "K.O. Coliseum",
    number: 15,
    current_patch: "15.1",
    patch_date: "July 30, 2025",
    next_patch: "15.2",
    next_patch_date: "August 13, 2025"
  },
  champion_tiers: {
    description: "Champions in TFT are divided into cost tiers from 1 to 5, with higher cost units being more powerful but rarer to find. The champion pool is shared among all players, making champion availability a strategic consideration.",
    tiers: [1, 2, 3, 4, 5],
    pool_size_per_champion: {
      "1": 29,
      "2": 22,
      "3": 18,
      "4": 12,
      "5": 10
    },
    drop_rates: {
      level_1: { "1": "100%", "2": "0%", "3": "0%", "4": "0%", "5": "0%" },
      level_2: { "1": "100%", "2": "0%", "3": "0%", "4": "0%", "5": "0%" },
      level_3: { "1": "75%", "2": "25%", "3": "0%", "4": "0%", "5": "0%" },
      level_4: { "1": "55%", "2": "30%", "3": "15%", "4": "0%", "5": "0%" },
      level_5: { "1": "45%", "2": "33%", "3": "20%", "4": "2%", "5": "0%" },
      level_6: { "1": "30%", "2": "40%", "3": "25%", "4": "5%", "5": "0%" },
      level_7: { "1": "19%", "2": "35%", "3": "35%", "4": "10%", "5": "1%" },
      level_8: { "1": "15%", "2": "25%", "3": "35%", "4": "20%", "5": "5%" },
      level_9: { "1": "10%", "2": "15%", "3": "30%", "4": "30%", "5": "15%" },
      level_10: { "1": "5%", "2": "10%", "3": "20%", "4": "40%", "5": "25%" },
      level_11: { "1": "1%", "2": "2%", "3": "12%", "4": "50%", "5": "35%" }
    }
  },
  champion_star_levels: {
    description: "Combining three copies of the same champion creates a stronger 2-star version. Combining three 2-star champions creates an even more powerful 3-star version, which is the maximum level a unit can reach.",
    combination_rules: "To upgrade a champion to 2-star, you need three 1-star copies. To upgrade to 3-star, you need three 2-star copies (a total of nine 1-star copies). Upgrading combines the champions automatically.",
    stat_scaling: {
      attack_damage: {
        "two_star": "180% of 1-star",
        "three_star": "324% of 1-star (180% of 2-star)"
      },
      health: {
        "two_star": "180% of 1-star",
        "three_star": "324% of 1-star (180% of 2-star)"
      },
      ability: "Ability power effects typically scale by approximately 180% at 2-star and 324% at 3-star, but can vary by champion."
    },
    costs: {
      "tier_1": {
        "1_star": 1,
        "2_star": 3,
        "3_star": 9,
        "4_star": "N/A"
      },
      "tier_2": {
        "1_star": 2,
        "2_star": 6,
        "3_star": 18,
        "4_star": "N/A"
      },
      "tier_3": {
        "1_star": 3,
        "2_star": 9,
        "3_star": 27,
        "4_star": "N/A"
      },
      "tier_4": {
        "1_star": 4,
        "2_star": 12,
        "3_star": 36,
        "4_star": "N/A"
      },
      "tier_5": {
        "1_star": 5,
        "2_star": 15,
        "3_star": 45,
        "4_star": "N/A"
      }
    },
    selling: "Selling a champion returns its full gold value. Selling a 2-star returns the equivalent of three 1-stars, and selling a 3-star returns the equivalent of nine 1-stars."
  },
  champion_store: {
    description: "The champion store refreshes automatically at the start of each round and can be manually refreshed for 2 gold. Each shop offers 5 champions based on your level and the current odds.",
    mechanics: [
      "Each shop refresh costs 2 gold",
      "Champions in the shop are drawn from the shared pool",
      "Higher level increases chances for higher-cost units",
      "The game tracks all champions offered to you in shop",
      "If you see a 3-cost champion at level 4, it has slightly increased odds to appear again",
      "This 'bad luck protection' helps you find specific champions",
      "There is also 'streak protection' for extremely unlucky streaks"
    ],
    special_mechanics: "In Set 15, you can now filter by Traits on Team Planner (PC), making it easier to plan compositions and understand trait synergies before committing to a build."
  },
  champion_items: {
    inventory: "Champions can hold up to 3 items. Extra items can be stored on your bench or applied directly to champions on the board.",
    combination: "Basic items can be combined to create powerful completed items. Drag one item onto another to combine them, either in your item inventory or on a champion.",
    selling: "When you sell a champion, all items return to your item inventory. If your inventory is full, items will appear on the closest bench space.",
    source: "In Set 15, Support Items have been completely removed. Starting mana has been replaced with mana per second, and several core items have been reworked to fit the new role system.",
    item_changes: "Six existing Core Items have been reworked, one new Artifact has been added, and all items now work with the new mana per second system instead of starting mana."
  },
  champion_traits: {
    description: "K.O. Coliseum introduces anime-themed traits that pay tribute to beloved anime tropes. Vertical traits now have Prismatic objectives that must be completed to unlock their most powerful forms, rather than simply stacking more units.",
    key_traits: {
      "star_guardian": "Star Guardians have a unique Teamwork bonus that is granted to all Star Guardians. Every Star Guardian fielded increases the bonus! Prismatic: Spend 20000 mana. THE STARS AWAKEN.",
      "soul_fighter": "Soul Fighters gain bonus Health, and gain Attack Damage and Ability Power every second up to 8 stacks. At max stacks, deal bonus true damage. Prismatic: Defeat 10 players in combat. MAXIMUM SOUL POWER.",
      "battle_academia": "Battle Academia champions upgrade their abilities and gain Potential. Potential improves their abilities. Prismatic: Earn 1 point for every Completed item used in combat. Graduate at 175 points.",
      "crystal_gambit": "Gain Gem Power each time an ally dies and after each round. Every 4 player combats choose to convert Gem Power into rewards or Double Down. While Double Down is active gain 100% more Gem Power, but losing reduces your Gem Power by 50%.",
      "luchador": "Luchadors gain bonus Attack Damage. At 50% health, Luchadors cleanse negative effects, heal, and leap back into the fight, knocking up enemies in a 1-hex radius for 1 second.",
      "mighty_mech": "Gain The Mighty Mech. Mighty Mechs heal it for 10% of the damage they deal. Prismatic: Unlock the Mightiest Mech! Mighty Mech champions jump into the massive unit."
    }
  },
  champion_roles: {
    description: "Set 15 brings a permanent revamp to unit roles. All units in TFT now have 1 of 6 roles. Roles have unique passives that affect the unit's gameplay and determine how each unit gains mana.",
    purpose: "Roles now determine mana generation and targeting priority, creating more strategic depth in team composition and positioning.",
    types: {
      tank: "Tanks gain 5 Mana per attack. Gain Mana from taking damage. More likely to be targeted.",
      fighter: "Fighters gain 10 Mana per attack. Gain 10% Omnivamp.",
      assassin: "Assassins gain 10 Mana per attack. Less likely to be targeted.",
      marksman: "Marksmen gain 10 Mana per attack.",
      caster: "Casters gain 7 mana per attack. Generate 2 Mana per second.",
      specialist: "Specialists generate resources in unique ways depending on the champion."
    },
    info: "Previously, if there are two units equal distance away, it was a 50/50 toss up as to who would take aggro. With Roles Revamped, we're adjusting champion targeting. For tiebreakers, units will target based on priority: Tanks > Fighters/Marksman/Caster/Specialists > Assassins."
  },
  game_mechanics: {
    mana_changes: "Champions no longer generate mana based on damage taken by default. Roles will now determine how each unit gains mana. This solves weird edge cases like a front line fighter casting infinitely by soaking damage and healing it all back up.",
    three_star_five_costs: "3* 5-costs are now immune to Crowd Control and gain 20 Mana Regen to ensure they will definitely cast before something unfortunate happens.",
    crowd_control: {
      stun: "Prevents the target from moving, attacking, or using abilities for the duration.",
      knockup: "Similar to stun, but explicitly cannot be reduced by tenacity.",
      silence: "Prevents casting abilities but allows movement and basic attacks.",
      disarm: "Prevents basic attacks but allows movement and ability casting.",
      root: "Prevents movement but allows attacking and ability casting."
    },
    bench: "Your bench can hold up to 9 units at a time. If your bench is full, you cannot buy new champions from the shop or receive champions from various rewards.",
    planning_phase: "With Power Ups and numerous other changes coming to K.O. Coliseum, we're increasing the 2-1 planning phase duration so you have enough time to pick your augment, scout, read through your Power Ups."
  },
  power_ups_mechanic: {
    description: "Power Ups are powerful effects that you can grant to ANY champion through a Power Snax consumable. You are granted a Power Snax twice per game, once at Round 1-3 and again at Round 3-6. Using a Power Snax on a champion opens an armory of 3 Power Ups for them.",
    frequency: "You get two Power Snax in all—one in the early stages of the match (Round 1-3), and one in the later stages (Round 3-6).",
    mechanics: [
      "Each Champion has their own pool of available Power Ups that work for them or enhance them uniquely",
      "Power Ups are only active when the champion is fielded (like traits)",
      "No repeats: Once you've seen a Power Up, it won't show up again",
      "Power Ups can be removed by selling the champion anytime or by using a Power Remover",
      "Power Remover is acquired once per stage (can stack)",
      "Power Snax don't take a slot on the champion's inventory. Instead, they become part of their traits!"
    ],
    flexibility: "You can use the Power Snax on a champion to open an armory of empowering options for that champion. This should let you make any champion a superstar, and, when you're bored of them or find an even more exciting unit, you can pop off the Power Up and use it to Power Up the new champion!"
  },
  meta_compositions: {
    star_guardian_saga: {
      description: "Star Guardian composition focusing on teamwork bonuses and ultimate friendship power. Seraphine leads as the 5-cost magical girl with her Ultimate Friendship Bomb spell.",
      core_champions: ["Seraphine", "Ahri", "Jinx", "Poppy", "Neeko", "Rell", "Syndra", "Xayah"],
      key_traits: ["Star Guardian (8)", "Sorcerer", "Protector"],
      carry_items: "AP items on Seraphine, focusing on maximizing her Power of Friendship scaling"
    },
    soul_fighters: {
      description: "Soul Fighters have been training all their lives for this tournament. They gain bonus health and stacking Attack Damage and Ability Power every second up to 8 stacks, unlocking true damage at max power.",
      core_champions: ["Gwen", "Sett", "Viego", "Samira"],
      key_traits: ["Soul Fighter (8)", "Edgelord", "Juggernaut"],
      carry_items: "Mixed damage items on Gwen, focusing on her thread-weaving mechanics"
    },
    academia_assembly: {
      description: "Battle Academia units are constantly learning, unlocking their true potential, and upgrading their abilities through the Potential system.",
      core_champions: ["Ezreal", "Garen", "Katarina", "Caitlyn", "Leona", "Jayce", "Yuumi"],
      key_traits: ["Battle Academia (7)", "Bastion", "Sniper"],
      carry_items: "Flexible items on Ezreal due to his mixed damage scaling"
    }
  }
};

export default function GuidesPage() {
  const [activeSection, setActiveSection] = useState<string | null>('champion_tiers');

  const toggleSection = (section: string) => {
    setActiveSection(activeSection === section ? null : section);
  };

  return (
    <Layout title="Guides">
      
      <div className="container mx-auto py-8">
        {/* Updated Patch Indicator Banner with Navigation */}
        <div className="relative mb-8 overflow-hidden rounded-lg border border-gold/20 shadow-lg">
          {/* Gradient background layer */}
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
          
          {/* Image background layer */}
          <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          
          {/* Subtle border glow */}
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          {/* Content container */}
          <div className="relative z-20 p-5">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gold mb-1">
                  Set 15 <span className="text-gold-light">K.O. Coliseum</span> Guides
                </h1>
                <p className="text-cream">Master the anime fighting tournament and Power Up system</p>
              </div>
              <div className="flex mt-3 md:mt-0 space-x-4">
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Clock size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Patch {guidesData.set_info.current_patch}</span>
                </div>
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Calendar size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">{guidesData.set_info.patch_date}</span>
                </div>
              </div>
            </div>
            
            {/* Navigation inside the banner */}
            <div className="overflow-x-auto">
              <div className="flex justify-center space-x-3 min-w-max">
                <NavCard 
                  title="Champion Tiers" 
                  icon={<Users />}
                  isActive={activeSection === 'champion_tiers'}
                  onClick={() => toggleSection('champion_tiers')}
                />
                <NavCard 
                  title="Star Levels" 
                  icon={<Star />}
                  isActive={activeSection === 'champion_star_levels'}
                  onClick={() => toggleSection('champion_star_levels')}
                />
                <NavCard 
                  title="Store" 
                  icon={<ShoppingBag />}
                  isActive={activeSection === 'champion_store'}
                  onClick={() => toggleSection('champion_store')}
                />
                <NavCard 
                  title="Items" 
                  icon={<Swords />}
                  isActive={activeSection === 'champion_items'}
                  onClick={() => toggleSection('champion_items')}
                />
                <NavCard 
                  title="Traits" 
                  icon={<Puzzle />}
                  isActive={activeSection === 'champion_traits'}
                  onClick={() => toggleSection('champion_traits')}
                />
                <NavCard 
                  title="Roles & Mechanics" 
                  icon={<BookOpen />}
                  isActive={activeSection === 'game_mechanics'}
                  onClick={() => toggleSection('game_mechanics')}
                />
                <NavCard 
                  title="Power Ups" 
                  icon={<Shield />}
                  isActive={activeSection === 'power_ups'}
                  onClick={() => toggleSection('power_ups')}
                />
              </div>
            </div>
          </div>
        </div>
        
        {/* Content Sections */}
        <div className="space-y-8">
          {/* Champion Tiers Section */}
          {activeSection === 'champion_tiers' && (
            <section>
              <SectionHeader 
                title="Champion Tiers" 
                subtitle="Understanding champion costs and pool distribution"
                icon={<Info size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/35 backdrop-filter backdrop-blur-md">
                <div className="space-y-6">
                  <div className="bg-void-core/25 p-4 rounded-lg text-cream backdrop-filter backdrop-blur-sm shadow-inner">
                    <p className="text-cream">{guidesData.champion_tiers.description}</p>
                  </div>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Pool Size per Champion</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10 backdrop-filter backdrop-blur-sm">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-6 py-3 text-left text-sm font-medium text-gold-light">Champion Tier</th>
                            <th className="px-6 py-3 text-left text-sm font-medium text-gold-light">Pool Size</th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_tiers.pool_size_per_champion).map(([tier, size], index) => (
                            <tr key={tier} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-6 py-3 whitespace-nowrap text-sm text-cream">{tier}★ Cost</td>
                              <td className="px-6 py-3 whitespace-nowrap text-sm font-mono bg-void-core/25 rounded-lg inline-block ml-4 text-cream">{size}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Champion Drop Rates</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10 backdrop-filter backdrop-blur-sm">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-4 py-3 text-left text-sm font-medium text-gold-light">Level</th>
                            {guidesData.champion_tiers.tiers.map(tier => (
                              <th key={tier} className="px-4 py-3 text-center text-sm font-medium text-gold-light">Tier {tier}</th>
                            ))}
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_tiers.drop_rates).map(([level, rates], index) => (
                            <tr key={level} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-cream">{level.replace('level_', '')}</td>
                              {guidesData.champion_tiers.tiers.map(tier => (
                                <td key={tier} className="px-4 py-3 text-center text-sm text-cream">
                                  {rates[tier.toString() as keyof typeof rates]}
                                </td>
                              ))}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Star Levels Section */}
          {activeSection === 'champion_star_levels' && (
            <section>
              <SectionHeader 
                title="Champion Star Levels" 
                subtitle="Champion upgrades and stat scaling"
                icon={<Star size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/35 backdrop-blur-md">
                <div className="space-y-6">
                  <p className="bg-void-core/25 p-4 rounded-lg text-cream">{guidesData.champion_star_levels.description}</p>
                  <p className="bg-void-core/25 p-4 rounded-lg text-cream">{guidesData.champion_star_levels.combination_rules}</p>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Stat Scaling</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Attack Damage</h4>
                        <div className="space-y-3">
                          {Object.entries(guidesData.champion_star_levels.stat_scaling.attack_damage).map(([level, scaling]) => (
                            <div key={level} className="flex justify-between items-center p-3 bg-void-core/25 rounded-lg">
                              <span className="text-cream">{level.replace('_', ' ')}</span>
                              <span className="text-gold text-sm font-mono bg-void-core/35 px-3 py-1 rounded">{scaling}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                      
                      <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Health</h4>
                        <div className="space-y-3">
                          {Object.entries(guidesData.champion_star_levels.stat_scaling.health).map(([level, scaling]) => (
                            <div key={level} className="flex justify-between items-center p-3 bg-void-core/25 rounded-lg">
                              <span className="text-cream">{level.replace('_', ' ')}</span>
                              <span className="text-gold text-sm font-mono bg-void-core/35 px-3 py-1 rounded">{scaling}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                    <div className="mt-3 text-sm italic bg-void-core/25 p-4 rounded-lg text-cream">
                      {guidesData.champion_star_levels.stat_scaling.ability}
                    </div>
                  </div>

                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Champion Upgrade Costs</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-4 py-3 text-left text-sm font-medium text-gold-light">Tier</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">1★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">2★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">3★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">4★ Cost</th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_star_levels.costs).map(([tier, costs], index) => (
                            <tr key={tier} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-cream">{tier.replace('tier_', '')}</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['1_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['2_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['3_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['4_star']}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                  
                  <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Selling Champions</h4>
                    <p className="text-cream">{guidesData.champion_star_levels.selling}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Store Section */}
          {activeSection === 'champion_store' && (
            <section>
              <SectionHeader 
                title="Champion Store" 
                subtitle="Shop mechanics and refresh strategies"
                icon={<ShoppingBag size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/40">
                <div className="space-y-6">
                  <p className="bg-void-core/30 p-4 rounded-lg text-cream">{guidesData.champion_store.description}</p>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Store Mechanics</h3>
                    <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10">
                      <ul className="space-y-3">
                        {guidesData.champion_store.mechanics.map((mechanic, index) => (
                          <li key={index} className="flex items-start bg-void-core/30 p-4 rounded-lg group hover:bg-void-core/40 transition-colors">
                            <div className="w-6 h-6 flex-shrink-0 rounded-full bg-void-core/40 flex items-center justify-center mr-3 border border-gold/20 group-hover:border-gold/50 transition-colors">
                              <span className="text-sm font-bold text-gold">{index + 1}</span>
                            </div>
                            <div className="text-cream">{mechanic}</div>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Set 15 Quality of Life Updates</h4>
                    <p className="text-cream">{guidesData.champion_store.special_mechanics}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Items Section */}
          {activeSection === 'champion_items' && (
            <section>
              <SectionHeader 
                title="Champion Items" 
                subtitle="Item mechanics and new changes"
                icon={<Layers size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/40">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Inventory</h4>
                    <p className="text-cream">{guidesData.champion_items.inventory}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Combination</h4>
                    <p className="text-cream">{guidesData.champion_items.combination}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Selling</h4>
                    <p className="text-cream">{guidesData.champion_items.selling}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Set 15 Changes</h4>
                    <p className="text-cream">{guidesData.champion_items.source}</p>
                  </div>
                </div>
                
                <div className="mt-6 bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                  <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Major Item System Changes</h4>
                  <p className="text-cream">{guidesData.champion_items.item_changes}</p>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Traits Section */}
          {activeSection === 'champion_traits' && (
            <section>
              <SectionHeader 
                title="Champion Traits" 
                subtitle="Anime-themed synergies and Prismatic objectives"
                icon={<Users size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 mb-4">
                  <p className="text-sm">{guidesData.champion_traits.description}</p>
                </div>
                
                <h3 className="text-lg font-medium text-gold mb-3">Key K.O. Coliseum Traits</h3>
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                  {Object.entries(guidesData.champion_traits.key_traits).map(([trait, description]) => (
                    <div key={trait} className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">{formatTraitName(trait)}</h4>
                      <p className="text-xs">{description}</p>
                    </div>
                  ))}
                </div>
                
                <div className="bg-gold/10 rounded-lg p-4 mt-4 shadow-md border border-gold/20">
                  <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Prismatic Trait System</h4>
                  <p className="mb-3 text-xs">Vertical traits now require completing specific objectives to unlock their Prismatic forms, making them more strategic and rewarding to pursue compared to simply stacking more units.</p>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div className="bg-void-core/20 p-3 rounded-lg">
                      <h5 className="font-medium text-gold text-xs mb-1">Star Guardian Example</h5>
                      <p className="text-xs text-cream/90">Field 8 Star Guardians → Spend 20,000 mana → THE STARS AWAKEN</p>
                    </div>
                    <div className="bg-void-core/20 p-3 rounded-lg">
                      <h5 className="font-medium text-gold text-xs mb-1">Soul Fighter Example</h5>
                      <p className="text-xs text-cream/90">Field 8 Soul Fighters → Defeat 10 players → MAXIMUM SOUL POWER</p>
                    </div>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Roles & Game Mechanics Section */}
          {activeSection === 'game_mechanics' && (
            <section>
              <SectionHeader 
                title="Roles & Game Mechanics" 
                subtitle="Revamped role system and core mechanics"
                icon={<Activity size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="space-y-6">
                  <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                    <h3 className="text-lg font-medium text-gold mb-2">Role Revamp</h3>
                    <p className="mb-3 text-sm">{guidesData.champion_roles.description}</p>
                    <p className="text-sm text-cream/90">{guidesData.champion_roles.purpose}</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-medium text-gold mb-3">Champion Roles & Mana Generation</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                      {Object.entries(guidesData.champion_roles.types).map(([role, description]) => (
                        <div key={role} className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                          <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">{formatRoleName(role)}</h4>
                          <p className="text-xs">{description}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                  
                  <div className="bg-void-core/15 rounded-lg p-4 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Targeting Priority Changes</h4>
                    <p className="text-sm text-cream">{guidesData.champion_roles.info}</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-medium text-gold mb-3">Important Mechanical Changes</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Mana System Overhaul</h4>
                        <p className="text-xs">{guidesData.game_mechanics.mana_changes}</p>
                      </div>
                      
                      <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">3★ 5-Cost Buffs</h4>
                        <p className="text-xs">{guidesData.game_mechanics.three_star_five_costs}</p>
                      </div>
                      
                      <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Planning Phase Extension</h4>
                        <p className="text-xs">{guidesData.game_mechanics.planning_phase}</p>
                      </div>
                      
                      <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Bench Capacity</h4>
                        <p className="text-xs">{guidesData.game_mechanics.bench}</p>
                      </div>
                    </div>
                  </div>
                  
                  <h3 className="text-lg font-medium text-gold mb-3">Crowd Control Effects</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
                    {Object.entries(guidesData.game_mechanics.crowd_control).map(([cc, description]) => (
                      <div key={cc} className="bg-void-core/20 rounded-lg p-3 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-xs mb-1 pb-1 border-b border-gold/20">{formatCCName(cc)}</h4>
                        <p className="text-xs">{description}</p>
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            </section>
          )}
          
          {/* Power Ups Section */}
          {activeSection === 'power_ups' && (
            <section>
              <SectionHeader 
                title="Power Ups" 
                subtitle="The core mechanic of K.O. Coliseum"
                icon={<Shield size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="space-y-6">
                  <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                    <h3 className="text-lg font-medium text-gold mb-2">Power Ups: Supercharge Your Champions</h3>
                    <p className="mb-3 text-sm">{guidesData.power_ups_mechanic.description}</p>
                    <p className="text-sm text-cream/90">{guidesData.power_ups_mechanic.flexibility}</p>
                  </div>
                  
                  <div className="bg-void-core/40 p-3 rounded-lg border border-gold/20 text-sm">
                    <div className="font-medium text-gold-light mb-1">Timing</div>
                    <p className="text-xs">{guidesData.power_ups_mechanic.frequency}</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-medium text-gold mb-3">Power Up Mechanics</h3>
                    <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10">
                      <ul className="space-y-3">
                        {guidesData.power_ups_mechanic.mechanics.map((mechanic, index) => (
                          <li key={index} className="flex items-start bg-void-core/30 p-4 rounded-lg group hover:bg-void-core/40 transition-colors">
                            <div className="w-6 h-6 flex-shrink-0 rounded-full bg-void-core/40 flex items-center justify-center mr-3 border border-gold/20 group-hover:border-gold/50 transition-colors">
                              <span className="text-sm font-bold text-gold">{index + 1}</span>
                            </div>
                            <div className="text-cream text-sm">{mechanic}</div>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Flexibility</h4>
                      <p className="text-xs text-cream/90">Transfer Power Ups between champions as your board evolves, allowing for dynamic strategy adaptation throughout the game.</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Uniqueness</h4>
                      <p className="text-xs text-cream/90">Each champion has their own pool of Power Ups tailored to their abilities and role, creating unique enhancement opportunities.</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Strategy</h4>
                      <p className="text-xs text-cream/90">Power Ups integrate into your champion's traits, requiring strategic thinking about which units to enhance and when.</p>
                    </div>
                  </div>
                  
                  <div className="bg-gold/10 rounded-lg p-4 shadow-md border border-gold/20">
                    <h3 className="text-lg font-medium text-gold mb-2">Key Strategic Tips</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div className="bg-void-core/20 p-3 rounded-lg">
                        <h4 className="font-medium text-gold-light text-sm mb-2">Early Game Power Ups</h4>
                        <p className="text-xs text-cream/90">Use your first Power Snax on a strong early carry to stabilize your board and win streak through the early stages.</p>
                      </div>
                      <div className="bg-void-core/20 p-3 rounded-lg">
                        <h4 className="font-medium text-gold-light text-sm mb-2">Late Game Optimization</h4>
                        <p className="text-xs text-cream/90">Save Power Removers for the late game when you find your final carry, allowing you to stack both Power Ups on your most important unit.</p>
                      </div>
                      <div className="bg-void-core/20 p-3 rounded-lg">
                        <h4 className="font-medium text-gold-light text-sm mb-2">Flexible Transitions</h4>
                        <p className="text-xs text-cream/90">Don't be afraid to move Power Ups between champions as you pivot compositions - they're meant to be transferred freely.</p>
                      </div>
                      <div className="bg-void-core/20 p-3 rounded-lg">
                        <h4 className="font-medium text-gold-light text-sm mb-2">Meta Adaptation</h4>
                        <p className="text-xs text-cream/90">Power Ups allow any champion to become a potential carry, opening up more diverse team compositions than ever before.</p>
                      </div>
                    </div>
                  </div>
                </div>
              </Card>
            </section>
          )}
        </div>
      </div>
    </Layout>
  );
}

// Helper Components
interface NavCardProps {
  title: string;
  icon: React.ReactNode;
  isActive: boolean;
  onClick: () => void;
}

function NavCard({ title, icon, isActive, onClick }: NavCardProps) {
  return (
    <div 
      className={`flex items-center px-4 py-2 rounded-lg cursor-pointer transition-all ${
        isActive 
          ? 'bg-gradient-to-br from-void-core/40 to-void-core/20 shadow-md border border-gold/50 backdrop-blur-sm' 
          : 'bg-void-core/40 hover:bg-void-core/40 shadow border border-gold/10 hover:border-gold/30 backdrop-blur-sm'
      }`}
      onClick={onClick}
    >
      <div className={`p-1.5 rounded-full mr-2 ${isActive ? 'bg-gold/20' : 'bg-void-core/50'}`}>
        {React.cloneElement(icon as React.ReactElement, { 
          size: 18, 
          className: isActive ? 'text-gold' : 'text-gold/60' 
        })}
      </div>
      <span className={`text-sm font-semibold ${isActive ? 'text-gold' : 'text-cream/90'}`}>{title}</span>
    </div>
  );
}

interface SectionHeaderProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
}

function SectionHeader({ title, subtitle, icon }: SectionHeaderProps) {
  return (
    <div className="mb-6">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
        <div className="bg-void-core/70 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
          <h2 className="text-2xl font-bold text-gold text-center">{title}</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
      </div>
      <p className="text-sm text-cream/90 mt-2 text-center">{subtitle}</p>
    </div>
  );
}

// Formatting Helpers
function formatTraitName(trait: string): string {
  return trait
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase())
    .replace(/\b\w/g, c => c.toUpperCase());
}

function formatRoleName(role: string): string {
  return role
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase())
    .replace(/\b\w/g, c => c.toUpperCase());
}

function formatCCName(cc: string): string {
  return cc
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase());
}
