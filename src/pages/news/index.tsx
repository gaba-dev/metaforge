import React, { useState } from 'react';
import { Layout, Card } from '@/components/ui';
import { HeaderBanner } from '@/components/common';
import { StatsCarousel } from '@/components/common';
import { 
  Calendar, 
  Tag, 
  Clock, 
  FileBarChart, 
  Trophy, 
  Star, 
  Puzzle, 
  Zap, 
  Slack,
  Eye,
  Cpu,
  Info
} from 'lucide-react';

// Define types for the TFT data
interface TFTCurrentData {
  currentSet: string;
  currentSetName: string;
  currentPatch: string;
  releaseDate: string;
  nextSetDate: string;
  nextSetName: string;
  nextPatchDate: string;
  nextPatchName: string;
}

interface TimelineEvent {
  date: string;
  name: string;
  type: string;
  description: string;
  highlights: string[];
}

interface Tournament {
  name: string;
  date: string;
  region: string;
  importance: string;
  prizePool: string;
  description: string;
}

interface SetData {
  name: string;
  startDate: string;
  endDate: string;
  theme: string;
  mechanic: string;
  description: string;
}

interface RevivalData {
  name: string;
  startDate: string;
  endDate: string;
  description: string;
}

interface TimelineData {
  patches: TimelineEvent[];
  tournaments: Tournament[];
  sets: SetData[];
  revivals: RevivalData[];
}

interface KeyChange {
  title: string;
  description: string;
}

interface OpeningEncounter {
  character?: string;
  type?: string;
  effect: string;
  chance: string;
}

interface PowerUpEncounter {
  type: string;
  effect: string;
  rarity: string;
}

interface EmblemChange {
  name: string;
  effect: string;
}

interface Cosmetic {
  name: string;
  description: string;
}

interface BugFix {
  bug: string;
  fix: string;
}

interface AugmentChange {
  name: string;
  change: string;
}

interface ChampionChange {
  name: string;
  change: string;
}

interface Sections {
  opening_encounters?: {
    title: string;
    content: OpeningEncounter[];
  };
  power_ups?: {
    title: string;
    content: PowerUpEncounter[];
  };
  augment_changes?: {
    title: string;
    removed_augments?: string[];
    returning_augments?: string[];
    adjusted_silver?: Record<string, string>;
    adjusted_gold?: Record<string, string>;
    adjusted_prismatic?: Record<string, string>;
    other_changes?: Record<string, string>;
    content?: AugmentChange[];
  };
  emblem_changes?: {
    title: string;
    content: EmblemChange[];
  };
  cosmetics?: {
    title: string;
    content: Cosmetic[];
  };
  ranked?: {
    title: string;
    content: string;
  };
  champion_changes?: {
    title: string;
    content: ChampionChange[];
  };
  role_revamp?: {
    title: string;
    description: string;
  };
  bug_fixes?: {
    title: string;
    content: BugFix[];
  };
  system_changes?: {
    title: string;
    content: string;
  };
  [key: string]: any;
}

interface PatchNoteData {
  title: string;
  date: string;
  overview: string;
  keyChanges: KeyChange[];
  sections: Sections;
}

interface PatchNotesData {
  [key: string]: PatchNoteData;
}

interface PowerUpCategory {
  category: string;
  description: string;
  examples: {
    name: string;
    description: string;
  }[];
}

interface PowerUpsData {
  description: string;
  types: PowerUpCategory[];
}

interface Trait {
  name: string;
  description: string;
  champions?: string;
}

// Interface for props
interface PatchNoteSectionProps {
  section: string;
  data: PatchNoteData;
}

interface NavTabProps {
  title: string;
  isActive: boolean;
  onClick: () => void;
  icon?: React.ReactNode;
}

interface TimelineTabProps {
  title: string;
  isActive: boolean;
  onClick: () => void;
}

interface PowerUpDetailsModalProps {
  show: boolean;
  onClose: () => void;
}

const TFTPatchNotes = () => {
  const [activeSection, setActiveSection] = useState<string>('overview');
  const [activePatch, setActivePatch] = useState<string>('15.1');
  const [activeTimeline, setActiveTimeline] = useState<string>('patches');
  const [showInfoModal, setShowInfoModal] = useState<boolean>(false);
  
  // Current TFT state based on official data - UPDATED FOR AUGUST 2025
  const currentTFTData: TFTCurrentData = {
    currentSet: "Set 15",
    currentSetName: "K.O. Coliseum",
    currentPatch: "15.1",
    releaseDate: "July 30, 2025",
    nextSetDate: "November 19, 2025",
    nextSetName: "Set 16",
    nextPatchDate: "August 13, 2025",
    nextPatchName: "15.2"
  };
  
  // Timeline Data - Official 2025 TFT Schedule
  const timelineData: TimelineData = {
    patches: [
      { 
        date: "July 30, 2025", 
        name: "15.1", 
        type: "Major", 
        description: "Set 15: K.O. Coliseum release", 
        highlights: ["New anime tournament theme", "Power Ups mechanic", "Role revamped system", "120+ new augments"]
      },
      { 
        date: "August 13, 2025", 
        name: "15.2", 
        type: "Balance", 
        description: "First balance patch for K.O. Coliseum", 
        highlights: ["Champion balance adjustments", "Power Up tweaks", "Meta stabilization"]
      },
      { 
        date: "August 27, 2025", 
        name: "15.3", 
        type: "Balance", 
        description: "Continued K.O. Coliseum balance updates", 
        highlights: ["Trait adjustments", "TFT Pro Circuit optimization", "New augments"]
      },
      { 
        date: "September 10, 2025", 
        name: "15.4", 
        type: "Content", 
        description: "Mid-set content update", 
        highlights: ["New cosmetics", "Power Up expansions", "System improvements"]
      },
      { 
        date: "September 24, 2025", 
        name: "15.5", 
        type: "Balance", 
        description: "Mid-set balance update", 
        highlights: ["Major trait rebalancing", "Champion reworks", "Meta diversity push"]
      },
      { 
        date: "October 8, 2025", 
        name: "15.6", 
        type: "Balance", 
        description: "Late-set balance adjustments", 
        highlights: ["Final major changes", "Competitive tuning"]
      },
      { 
        date: "October 22, 2025", 
        name: "15.7", 
        type: "Balance", 
        description: "Pre-Paris Open patch", 
        highlights: ["Tournament-focused balance", "Stability improvements"]
      },
      { 
        date: "November 5, 2025", 
        name: "15.8", 
        type: "Fun", 
        description: "K.O. Coliseum finale patch", 
        highlights: ["Fun adjustments", "PBE release of Set 16"]
      },
      { 
        date: "November 19, 2025", 
        name: "16.1", 
        type: "Major", 
        description: "Set 16 release", 
        highlights: ["New set theme", "New mechanics and champions", "Ranked reset"]
      }
    ],
    tournaments: [
      {
        name: "TFT Pro Circuit Event 1",
        date: "August 29 - September 1, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$200,000",
        description: "First TFT Pro Circuit event featuring top 32 players from each region"
      },
      {
        name: "TFT Pro Circuit Event 2",
        date: "September 19-22, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$200,000",
        description: "Second Pro Circuit event with regional qualifications"
      },
      {
        name: "TFT Pro Circuit Event 3",
        date: "October 17-20, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$200,000",
        description: "Final Pro Circuit event before Regional Finals"
      },
      {
        name: "K.O. Coliseum Regional Finals - APAC",
        date: "November 1-3, 2025",
        region: "APAC",
        importance: "Championship",
        prizePool: "$150,000",
        description: "APAC Regional Finals for K.O. Coliseum"
      },
      {
        name: "K.O. Coliseum Regional Finals - EMEA",
        date: "November 1-3, 2025",
        region: "EMEA",
        importance: "Championship",
        prizePool: "$150,000",
        description: "EMEA Regional Finals for K.O. Coliseum"
      },
      {
        name: "K.O. Coliseum Regional Finals - Americas",
        date: "November 1-3, 2025",
        region: "Americas",
        importance: "Championship",
        prizePool: "$150,000",
        description: "Americas Regional Finals for K.O. Coliseum"
      },
      {
        name: "TFT Paris Open 2025",
        date: "December 2025",
        region: "Global",
        importance: "Championship",
        prizePool: "$500,000",
        description: "TFT's largest global tournament with 768 player slots at Porte de Versailles"
      }
    ],
    sets: [
      {
        name: "Set 15: K.O. Coliseum",
        startDate: "July 30, 2025",
        endDate: "November 18, 2025",
        theme: "Anime fighting tournament",
        mechanic: "Power Ups",
        description: "Over-the-top anime battle arena with magical girls, Shonen heroes, and giant mechs"
      },
      {
        name: "Set 16",
        startDate: "November 19, 2025",
        endDate: "March 2026",
        theme: "TBA",
        mechanic: "TBA",
        description: "Next major set, theme to be announced"
      }
    ],
    revivals: [
      {
        name: "No Active Revivals",
        startDate: "N/A",
        endDate: "N/A",
        description: "No set revivals currently active. Previous Remix Rumble revival ended with Set 14"
      }
    ]
  };
  
  // Patch Notes Data - UPDATED with accurate 15.1 info
  const patchNotesData: PatchNotesData = {
    "15.1": {
      title: "Set 15: K.O. Coliseum Launch",
      date: "July 30, 2025",
      overview: "Round up your dream team and join us in K.O. Coliseum! Welcome to TFT's ultimate anime fighting tournament set, where Power Ups let you supercharge your favorite units and Role Revamped changes how every champion functions. This is our biggest system overhaul yet!",
      keyChanges: [
        {
          title: "New Set Mechanic: Power Ups",
          description: "Power Snax are the most sought-after bite of the summer! Twice per game (rounds 1-3 and 3-6), you'll unlock the hidden potential of any champion with powerful Power Up effects. Each champion has their own unique pool of available Power Ups."
        },
        {
          title: "Role Revamped System",
          description: "All units now have 1 of 6 roles with unique passives. Most importantly, champions no longer generate mana from taking damage by default - roles now determine how each unit gains mana. Only Tanks generate mana from damage taken."
        },
        {
          title: "Support Items Removed",
          description: "Support items have been completely removed from K.O. Coliseum. While useful, they added complexity for relatively low excitement. We're exploring other ways to provide these effects in more satisfying ways."
        },
        {
          title: "Hyper Roll Retired",
          description: "We're saying goodbye to Hyper Roll with the release of K.O. Coliseum. We're thankful for all players who loved TFT's first-ever game mode and are committed to exploring new ways to play TFT."
        }
      ],
      sections: {
        opening_encounters: {
          title: "Opening Encounters",
          content: [
            {
              character: "Yasuo",
              effect: "Go for the gold with three Gold augments!",
              chance: "16.1%"
            },
            {
              character: "Gwen",
              effect: "It's the ultimate showdown! All augments are Prismatic this game.",
              chance: "8.1%"
            },
            {
              character: "Zyra",
              effect: "Zyra swaps the last augment to prismatic this game.",
              chance: "8.1%"
            }
          ]
        },
        role_revamp: {
          title: "Role Revamped System",
          description: "All champions now have 1 of 6 roles with unique gameplay passives: Tank (gains mana from damage), Fighter (8-20% Omnivamp), Assassin (less likely targeted), Caster (2 mana per second), Marksman (less likely targeted), Specialist (unique mechanics)."
        },
        system_changes: {
          title: "Major System Changes",
          content: "3-star 5-costs are now immune to Crowd Control and gain 20 Mana Regen. Planning phase at 2-1 has been extended for Power Up decisions. Team Planner now allows filtering by Traits."
        }
      }
    },
    "14.8": {
      title: "Cyber City Finale & K.O. Coliseum Preview",
      date: "July 15, 2025",
      overview: "The final patch of Cyber City brings balance changes, the return of Choncc's Treasures, and marks the end of Hyper Roll as a permanent game mode. Get ready for K.O. Coliseum!",
      keyChanges: [
        {
          title: "Hyper Roll Final Patch",
          description: "14.8 marks Hyper Roll's final patch as a permanent TFT Game Mode. We're thankful for all the players who loved TFT's first-ever game mode."
        },
        {
          title: "Choncc's Treasures Return",
          description: "Choncc's Treasure makes a return for the final patch of Cyber City. What are you waiting for?"
        },
        {
          title: "K.O. Coliseum Preview",
          description: "Get ready! K.O. Coliseum releases with patch 15.1 on July 30th. Check out the dev drop for all the latest on the new anime fighting tournament set."
        }
      ],
      sections: {
        champion_changes: {
          title: "Champion Changes",
          content: [
            {
              name: "Cypher Emblem",
              change: "New Cypher Emblem available, enabling Cypher (6) comps with massive Intel stockpiling potential."
            },
            {
              name: "Gragas (Chug Bug)",
              change: "Empowered Damage: 465/700/1050 ⇒ 500/750/1200. Heal: 300/375/450 ⇒ 315/395/475"
            },
            {
              name: "Think Fast",
              change: "Black Market Augment has been re-enabled after being temporarily disabled for competitive integrity."
            }
          ]
        }
      }
    }
  };
  
  // Set 15 Mechanics - Power Up System Details
  const powerUpsData: PowerUpsData = {
    description: "In K.O. Coliseum, Power Ups let you supercharge your favorite units with Power Snax - special consumables that unlock powerful upgrade choices. You get Power Snax twice per game (rounds 1-3 and 3-6) and can use them on ANY champion to open an armory of 3 unique Power Ups tailored to that champion.",
    types: [
      {
        category: "Trait Improvements",
        description: "Power Ups that enhance or modify a champion's existing traits and synergies.",
        examples: [
          {
            name: "Soul Fighter Mastery",
            description: "Enhanced Soul Fighter effects with faster stacking and higher damage caps."
          },
          {
            name: "Star Guardian Harmony",
            description: "Star Guardian spells cost less mana and provide additional team effects."
          }
        ]
      },
      {
        category: "Team-Ups & Duos",
        description: "Power Ups that create special partnerships between champions.",
        examples: [
          {
            name: "Dynamic Duo",
            description: "Certain champions gain special bonuses when positioned near their designated partner."
          },
          {
            name: "Mentor Bond",
            description: "Enhanced effects when multiple Mentor champions work together."
          }
        ]
      },
      {
        category: "Ability Transformations",
        description: "Power Ups that fundamentally change how a champion's ability works.",
        examples: [
          {
            name: "Ultimate Evolution",
            description: "Champion abilities gain additional effects or completely new functionality."
          },
          {
            name: "Combo Finisher",
            description: "Abilities chain together for devastating combo attacks."
          }
        ]
      },
      {
        category: "Perma-Stacking",
        description: "Power Ups that allow champions to permanently grow stronger throughout the game.",
        examples: [
          {
            name: "Endless Growth",
            description: "Champion permanently gains stats after each takedown or ability cast."
          },
          {
            name: "Power Accumulation",
            description: "Stack power over time that never resets between rounds."
          }
        ]
      },
      {
        category: "Role Specialization",
        description: "Power Ups that enhance or modify a champion's role-specific mechanics.",
        examples: [
          {
            name: "Tank Mastery",
            description: "Enhanced tanking abilities with improved mana generation and damage reduction."
          },
          {
            name: "Carry Potential",
            description: "Transform non-carry champions into viable damage dealers."
          }
        ]
      }
    ]
  };
  
  // Key Traits from Set 15
  const traitData: Trait[] = [
    {
      name: "Soul Fighter",
      description: "Soul Fighters gain bonus Health. They also gain stacking Attack Damage and Ability Power every second in combat.",
      champions: "Kalista (1g), Naafiri (1g), Lux (2g), Xin Zhao (2g), Viego (3g), Samira (4g), Sett (4g), Gwen (5g)"
    },
    {
      name: "Star Guardian",
      description: "Star Guardians gain Ability Power. Whenever a Star Guardian casts, all Star Guardians gain mana.",
      champions: "Rell (1g), Xayah (2g), Ahri (3g), Jinx (4g), Poppy (4g), Seraphine (5g)"
    },
    {
      name: "Battle Academia",
      description: "Battle Academia champions gain Potential each round. Their abilities scale with Potential.",
      champions: "Ezreal (1g), Garen (1g), Katarina (2g), Rakan (2g), Caitlyn (3g), Jayce (3g), Leona (4g), Yuumi (4g)"
    },
    {
      name: "Monster Trainer",
      description: "Lulu summons a chosen monster (Kog'Maw, Rammus, or Smolder) that levels up and evolves throughout the game.",
      champions: "Lulu (3g)"
    },
    {
      name: "The Champ",
      description: "Braum's unique trait. Player victories grant Poro-fans that reduce Tactician damage on losses.",
      champions: "Braum (5g)"
    },
    {
      name: "Heavyweight",
      description: "Your team gains bonus Health. Heavyweights gain additional Health and Attack Damage based on their Health.",
      champions: "Aatrox (1g), Zac (1g), Kobuko (2g), Darius (3g), Jayce (3g), Poppy (4g)"
    }
  ];
  
  // Component to display patch note sections
  const PatchNoteSection = ({ section, data }: PatchNoteSectionProps) => {
    if (!data || !data.sections || !data.sections[section]) return null;
    
    const sectionData = data.sections[section];
    
    // Different renders based on section type
    if (section === 'opening_encounters') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {sectionData.content.map((encounter: OpeningEncounter, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 flex items-start border border-gold/20">
                  <div className="mr-3 font-medium text-gold-light min-w-20">
                    {encounter.character || encounter.type}
                  </div>
                  <div className="flex-1">
                    <div className="text-sm mb-1 text-cream">{encounter.effect}</div>
                    <div className="text-xs text-cream/70">Chance: {encounter.chance}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'role_revamp') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="text-sm text-cream">{sectionData.description}</div>
          </div>
        </div>
      );
    }
    
    if (section === 'system_changes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="text-sm text-cream">{sectionData.content}</div>
          </div>
        </div>
      );
    }
    
    if (section === 'champion_changes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="space-y-3">
              {sectionData.content.map((champion: ChampionChange, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                  <div className="font-medium text-gold-light mb-1">{champion.name}</div>
                  <div className="text-sm text-cream">{champion.change}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    return null;
  };
  
  // Navigation tabs for different sections
  const NavTab = ({ title, isActive, onClick, icon }: NavTabProps) => {
    return (
      <button
        className={`px-4 py-2 rounded-lg text-sm font-medium transition-all flex items-center ${
          isActive 
            ? 'bg-void-core/40 text-gold shadow-md border border-gold/30' 
            : 'bg-void-core/20 text-cream/80 hover:bg-void-core/30 border border-gold/10 hover:border-gold/20'
        }`}
        onClick={onClick}
      >
        {icon && <div className={`mr-2 ${isActive ? 'text-gold' : 'text-cream/70'}`}>{icon}</div>}
        {title}
      </button>
    );
  };
  
  // Timeline section tabs
  const TimelineTab = ({ title, isActive, onClick }: TimelineTabProps) => {
    return (
      <button
        className={`px-6 py-3 text-sm font-medium transition-all border-b-2 ${
          isActive 
            ? 'border-gold text-gold' 
            : 'border-transparent text-cream/70 hover:text-cream hover:border-gold/30'
        }`}
        onClick={onClick}
      >
        {title}
      </button>
    );
  };
  
  // Current Set Overview section
  const CurrentSetOverview = () => (
    <div className="animate-fadeIn">
      {/* Section Title - centered with gold lines */}
      <div className="mb-6">
        <div className="flex items-center justify-center">
          <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
          <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
            <h2 className="text-2xl font-bold text-gold text-center">Overview</h2>
          </div>
          <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
        </div>
      </div>
      
      {/* Content boxes */}
      <div className="flex flex-col md:flex-row gap-4 mb-4">
        <div className="flex-1 bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Tag size={18} className="mr-2" />
            Current Patch
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">{currentTFTData.currentPatch}</div>
          <div className="text-sm text-cream/70">Released on July 30, 2025</div>
        </div>
        <div className="flex-1 bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Calendar size={18} className="mr-2" />
            Next Patch
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">{currentTFTData.nextPatchName}</div>
          <div className="text-sm text-cream/70">Coming on {currentTFTData.nextPatchDate}</div>
        </div>
        <div className="flex-1 bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Trophy size={18} className="mr-2" />
            TFT Pro Circuit
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">Starts Aug 29</div>
          <div className="text-sm text-cream/70">New Tier 1 tournament series</div>
        </div>
      </div>
        
      <div className="bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-4 border border-gold/20 mb-4">
        <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
          <Zap size={18} className="mr-2" />
          Set Mechanic: Power Ups
        </h3>
        <p className="text-cream">{powerUpsData.description}</p>
        <div className="mt-4">
          <button 
            className="px-4 py-2 bg-void-core/30 text-gold rounded-lg text-md font-medium hover:bg-void-core/40 transition-all border border-gold/30 flex items-center"
            onClick={() => setShowInfoModal(true)}
          >
            <Info size={16} className="mr-2" />
            View Power Up Details
          </button>
        </div>
      </div>
      
      <div className="bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
        <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
          <Puzzle size={18} className="mr-2" />
          Key Traits
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-2">
          {traitData.map((trait, index) => (
            <div key={index} className="bg-void-core/25 p-3 rounded-lg border border-gold/20">
              <div className="font-medium text-gold-light mb-1">{trait.name}</div>
              <div className="text-sm text-cream mb-1">{trait.description}</div>
              {trait.champions && (
                <div className="text-xs text-cream/70 mt-1">
                  <span className="font-medium">Champions:</span> {trait.champions}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
  
  // Patch Notes section
  const PatchNotesSection = () => (
    <div className="animate-fadeIn">
      {/* Section Title - centered with gold lines */}
      <div className="mb-6">
        <div className="flex items-center justify-center">
          <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
          <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
            <h2 className="text-2xl font-bold text-gold text-center">Patch Notes</h2>
          </div>
          <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
        </div>
      </div>
      
      <div className="bg-void-core/25 backdrop-filter backdrop-blur-md rounded-lg overflow-hidden shadow-lg border border-gold/20 mb-8">
        
        <div className="px-6 py-4">
          {/* Patch selector for mobile */}
          <div className="md:hidden mb-4">
            <select 
              className="w-full p-2 bg-void-core/15 text-cream rounded-lg border border-gold/20"
              value={activePatch}
              onChange={(e) => setActivePatch(e.target.value)}
            >
              {Object.keys(patchNotesData).map(patch => (
                <option key={patch} value={patch}>Patch {patch}: {patchNotesData[patch].title}</option>
              ))}
            </select>
          </div>
          
          {/* Patch selector for desktop */}
          <div className="hidden md:flex md:flex-wrap gap-2 mb-6">
            {Object.keys(patchNotesData).map(patch => (
              <NavTab 
                key={patch}
                title={`Patch ${patch}`}
                isActive={activePatch === patch}
                onClick={() => setActivePatch(patch)}
              />
            ))}
          </div>
          
          {patchNotesData[activePatch] && (
            <>
              <div className="bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-gold/20 mb-6">
                <h1 className="text-2xl font-bold text-gold mb-2">{patchNotesData[activePatch].title}</h1>
                <div className="text-sm text-cream/70 mb-4">Released on {patchNotesData[activePatch].date}</div>
                <p className="text-cream">{patchNotesData[activePatch].overview}</p>
              </div>
              
              <div className="bg-void-core/15 backdrop-blur-sm rounded-lg p-6 border border-gold/20 mb-6">
                <h2 className="text-xl font-bold text-gold mb-4">Key Changes</h2>
                <div className="space-y-4">
                  {patchNotesData[activePatch].keyChanges.map((change, index) => (
                    <div key={index} className="bg-void-core/25 rounded-lg p-4 border border-gold/20">
                      <h3 className="text-lg font-semibold text-gold-light mb-2">{change.title}</h3>
                      <p className="text-cream text-sm">{change.description}</p>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Dynamic patch note sections */}
              {patchNotesData[activePatch].sections && Object.keys(patchNotesData[activePatch].sections).map(section => (
                <PatchNoteSection 
                  key={section} 
                  section={section} 
                  data={patchNotesData[activePatch]} 
                />
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  );
  
  // TFT Timeline section
const TimelineSection = () => (
  <div className="animate-fadeIn">
    {/* Section Title - centered with gold lines */}
    <div className="mb-6">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
        <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
          <h2 className="text-2xl font-bold text-gold text-center">2025 Timeline</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
      </div>
    </div>
    
    <div className="bg-void-core/25 backdrop-blur-sm rounded-lg overflow-hidden shadow-lg border border-gold/20 mb-8">
      
      {/* Replace TimelineTab with NavTab for consistent styling */}
      <div className="px-6 py-4">
        <div className="flex flex-wrap gap-2 mb-6">
          <NavTab 
            title="Patch Schedule" 
            isActive={activeTimeline === 'patches'} 
            onClick={() => setActiveTimeline('patches')}
            icon={<Calendar size={18} />}
          />
          <NavTab 
            title="Tournaments" 
            isActive={activeTimeline === 'tournaments'} 
            onClick={() => setActiveTimeline('tournaments')}
            icon={<Trophy size={18} />}
          />
          <NavTab 
            title="Sets & Revivals" 
            isActive={activeTimeline === 'sets'} 
            onClick={() => setActiveTimeline('sets')}
            icon={<Slack size={18} />}
          />
        </div>
        </div>
        
        <div className="px-6 py-4">
          {activeTimeline === 'patches' && (
            <div className="space-y-6">
              <div className="overflow-x-auto">
                <table className="min-w-full bg-void-core/15 rounded-lg overflow-hidden">
                  <thead className="bg-void-core/30">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Patch</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Type</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Description</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Highlights</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gold/10">
                    {timelineData.patches.map((patch, index) => (
                      <tr key={index} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                        <td className="px-4 py-3 text-sm font-medium text-cream">{patch.date}</td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                            patch.type === 'Major' ? 'bg-void-core/40 text-gold' : 
                            patch.type === 'Balance' ? 'bg-void-core/30 text-gold-light' : 
                            patch.type === 'Fun' ? 'bg-void-core/30 text-gold-light' : 
                            'bg-void-core/30 text-gold-light'
                          }`}>
                            {patch.name}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm text-cream">{patch.type}</td>
                        <td className="px-4 py-3 text-sm text-cream">{patch.description}</td>
                        <td className="px-4 py-3 text-sm">
                          <ul className="list-disc list-inside text-cream">
                            {patch.highlights.map((highlight, i) => (
                              <li key={i}>{highlight}</li>
                            ))}
                          </ul>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
          
          {activeTimeline === 'tournaments' && (
            <div className="space-y-6">
              <div className="overflow-x-auto">
                <table className="min-w-full bg-void-core/15 rounded-lg overflow-hidden">
                  <thead className="bg-void-core/30">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Tournament</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Region</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Prize Pool</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Description</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gold/10">
                    {timelineData.tournaments.map((tournament, index) => (
                      <tr key={index} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                        <td className="px-4 py-3 text-sm font-medium text-cream">{tournament.date}</td>
                        <td className="px-4 py-3">
                          <span className={`text-sm font-medium ${
                            tournament.importance === 'Championship' ? 'text-gold' : 
                            tournament.importance === 'Major' ? 'text-gold-light' : 
                            'text-gold-light'
                          }`}>
                            {tournament.name}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            tournament.region === 'Global' ? 'bg-void-core/40 text-gold' : 
                            tournament.region === 'EMEA' ? 'bg-void-core/30 text-gold-light' : 
                            tournament.region === 'APAC' ? 'bg-void-core/30 text-gold-light' : 
                            'bg-void-core/30 text-gold-light'
                          }`}>
                            {tournament.region}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm text-gold font-medium">{tournament.prizePool}</td>
                        <td className="px-4 py-3 text-sm text-cream">{tournament.description}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
          
          {activeTimeline === 'sets' && (
            <div className="space-y-8">
              <div>
                <h3 className="text-xl font-bold text-gold mb-4">Current & Upcoming Sets</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {timelineData.sets.map((set, index) => (
                    <div key={index} className="bg-void-core/15 rounded-lg overflow-hidden border border-gold/20">
                      <div className={`p-4 ${
                        index === 0 ? 'bg-gradient-to-r from-void-core/30 to-void-core/20' : 
                        'bg-gradient-to-r from-void-core/30 to-void-core/20'
                      }`}>
                        <h4 className="text-lg font-bold text-gold">{set.name}</h4>
                      </div>
                      <div className="p-4">
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Dates:</span>
                          <div className="text-cream font-medium">{set.startDate} - {set.endDate}</div>
                        </div>
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Theme:</span>
                          <div className="text-cream font-medium">{set.theme}</div>
                        </div>
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Set Mechanic:</span>
                          <div className={`text-cream font-medium ${set.mechanic === 'TBA' ? 'text-cream/50' : ''}`}>
                            {set.mechanic}
                          </div>
                        </div>
                        <div>
                          <span className="text-cream/70 text-sm">Description:</span>
                          <div className="text-cream text-sm mt-1">{set.description}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-bold text-gold mb-4">Set Revivals</h3>
                <div className="bg-void-core/15 rounded-lg p-6 border border-gold/20">
                  <div className="text-center">
                    <div className="text-cream/70 mb-2">No Active Revivals</div>
                    <div className="text-cream text-sm">
                      The Remix Rumble revival ended with Set 14. Future revivals will be announced closer to their release dates.
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
  
  // Modal for Power Up System Details
  const PowerUpDetailsModal = ({ show, onClose }: PowerUpDetailsModalProps) => {
    if (!show) return null;
    
    return (
      <div 
        className="fixed inset-0 bg-void-core bg-opacity-50 z-50 flex items-center justify-center p-4 animate-fadeIn backdrop-filter"
        onClick={onClose}
      >
        <div 
          className="bg-void-core/30 backdrop-blur-md rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto border border-gold/20 shadow-xl"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="sticky top-0 bg-gradient-to-r from-void-core/30 to-void-core/20 px-6 py-4 flex justify-between items-center border-b border-gold/20 backdrop-filter backdrop-blur-sm">
            <h2 className="text-2xl font-bold text-gold flex items-center">
              <Cpu className="mr-2" />
              Set 15 Mechanic: Power Ups System
            </h2>
            <button 
              className="p-2 rounded-full bg-void-core/40 text-cream hover:bg-void-core/60 hover:text-white transition-all"
              onClick={onClose}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          
          <div className="px-6 py-4">
            <p className="text-cream mb-6">{powerUpsData.description}</p>
            
            <div className="space-y-6">
              {powerUpsData.types.map((type, index) => (
                <div key={index} className="bg-void-core/20 rounded-lg p-5 border border-gold/20">
                  <h3 className="text-xl font-bold text-gold mb-3">{type.category}</h3>
                  <p className="text-cream mb-4">{type.description}</p>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {type.examples.map((example, i) => (
                      <div key={i} className="bg-void-core/30 rounded-lg p-4 border border-gold/20">
                        <div className="font-medium text-gold-light mb-2">{example.name}</div>
                        <div className="text-sm text-cream">{example.description}</div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="bg-void-core/20 px-6 py-4 flex justify-end border-t border-gold/20">
            <button
              className="px-4 py-2 bg-void-core/30 text-gold rounded-lg text-sm font-medium hover:bg-void-core/40 transition-all border border-gold/30"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </div>
      </div>
    );
  };
  
  return (
    <Layout title="News">

      <div className="container mx-auto py-8">
        {/* Main Banner with Navigation - Using homepage style background */}
        <div className="relative mb-8 overflow-hidden rounded-lg border border-gold/20 shadow-lg">
          {/* Gradient background layer */}
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
          
          {/* Image background layer */}
          <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          
          {/* Subtle border glow - optional, from homepage */}
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          {/* Content container */}
          <div className="relative z-20 p-5">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gold mb-1">
                  Set 15: <span className="text-gold-light">K.O. Coliseum</span> News
                </h1>
                <p className="text-cream">Your tournament arc starts now in TFT's ultimate anime fighting tournament</p>
              </div>
              <div className="flex mt-3 md:mt-0 space-x-4">
                <div className="bg-void-core/50 backdrop-filter backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Clock size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Current Patch: {currentTFTData.currentPatch}</span>
                </div>
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Calendar size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Next Patch: {currentTFTData.nextPatchDate}</span>
                </div>
              </div>
            </div>
            
            {/* Navigation inside the banner */}
            <div className="overflow-x-auto">
              <div className="flex justify-center space-x-3 min-w-max">
                <NavTab 
                  title="Overview" 
                  isActive={activeSection === 'overview'} 
                  onClick={() => setActiveSection('overview')}
                  icon={<Eye size={18} />}
                />
                <NavTab 
                  title="Patch Notes" 
                  isActive={activeSection === 'patchnotes'} 
                  onClick={() => setActiveSection('patchnotes')}
                  icon={<FileBarChart size={18} />}
                />
                <NavTab 
                  title="Timeline" 
                  isActive={activeSection === 'timeline'} 
                  onClick={() => setActiveSection('timeline')}
                  icon={<Calendar size={18} />}
                />
              </div>
            </div>
          </div>
        </div>
          
        {/* Main Content Area */}
        <div>
          {activeSection === 'overview' && <CurrentSetOverview />}
          {activeSection === 'patchnotes' && <PatchNotesSection />}
          {activeSection === 'timeline' && <TimelineSection />}
        </div>
        
        {/* Power Ups System Modal */}
        <PowerUpDetailsModal show={showInfoModal} onClose={() => setShowInfoModal(false)} />
      </div>
    </Layout>
  );
};

export default TFTPatchNotes;
