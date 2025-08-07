import React, { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowUp, ArrowDown, ExternalLink, Trophy, Crown, Medal, Star } from 'lucide-react';
import { useRouter } from 'next/router';
import { LeaderboardEntry } from '@/types/auth';

interface TopPlayersProps {
  players: LeaderboardEntry[];
  isLoading: boolean;
  region: string;
}

type SortField = 'rank' | 'leaguePoints' | 'wins' | 'losses' | 'winRate';
type SortDirection = 'asc' | 'desc';

export default function TopPlayers({ players, isLoading, region }: TopPlayersProps) {
  const router = useRouter();
  const [sort, setSort] = useState<SortField>('rank');
  const [direction, setDirection] = useState<SortDirection>('asc');
  
  const sortedPlayers = useMemo(() => {
    if (!players?.length) return [];
    
    return [...players].sort((a, b) => {
      let aVal: number, bVal: number;
      
      switch (sort) {
        case 'winRate':
          aVal = a.wins + a.losses > 0 ? (a.wins / (a.wins + a.losses)) * 100 : 0;
          bVal = b.wins + b.losses > 0 ? (b.wins / (b.wins + b.losses)) * 100 : 0;
          break;
        default:
          aVal = a[sort] as number;
          bVal = b[sort] as number;
      }
      
      return direction === 'asc' ? aVal - bVal : bVal - aVal;
    });
  }, [players, sort, direction]);
  
  const handleSort = (field: SortField) => {
    if (field === sort) {
      setDirection(direction === 'asc' ? 'desc' : 'asc');
    } else {
      setSort(field);
      setDirection(field === 'rank' ? 'asc' : 'desc');
    }
  };

  const handlePlayerClick = (player: LeaderboardEntry) => {
    router.push(`/player/${player.summonerId}?region=${region}`);
  };
  
  const getRankIcon = (rank: number) => {
    if (rank === 1) return <Crown className="h-5 w-5 text-gold" />;
    if (rank === 2) return <Medal className="h-5 w-5 text-gray-400" />;
    if (rank === 3) return <Trophy className="h-5 w-5 text-orange-600" />;
    if (rank <= 10) return <Star className="h-4 w-4 text-gold" />;
    return null;
  };
  
  const getTierColor = (tier: string) => {
    const colors = {
      IRON: 'text-gray-500',
      BRONZE: 'text-orange-700',
      SILVER: 'text-gray-400',
      GOLD: 'text-yellow-500',
      PLATINUM: 'text-cyan-400',
      DIAMOND: 'text-purple-400',
      MASTER: 'text-purple-600',
      GRANDMASTER: 'text-red-500',
      CHALLENGER: 'text-gold'
    };
    return colors[tier as keyof typeof colors] || 'text-cream';
  };
  
  if (isLoading && !players?.length) {
    return (
      <div className="p-6">
        <div className="space-y-3">
          {[...Array(10)].map((_, i) => (
            <div key={i} className="bg-brown/20 rounded-lg p-4 animate-pulse">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="h-6 w-12 bg-brown/40 rounded"></div>
                  <div className="h-6 w-48 bg-brown/40 rounded"></div>
                </div>
                <div className="flex gap-6">
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }
  
  if (!players?.length) {
    return (
      <div className="p-8 text-center">
        <Trophy className="h-16 w-16 mx-auto text-solar-flare/50 mb-4" />
        <h3 className="text-xl font-display text-stellar-white mb-2">No Players Found</h3>
        <p className="text-corona-light/70">
          This region might not have ranked players yet, or there might be an issue loading the data.
        </p>
      </div>
    );
  }
  
  const columns = [
    { id: 'leaguePoints', name: 'LP', sortable: true },
    { id: 'wins', name: 'Wins', sortable: true },
    { id: 'losses', name: 'Losses', sortable: true },
    { id: 'winRate', name: 'WR%', sortable: true }
  ];
  
  return (
    <div>
      {/* Header */}
      <div className="px-6 py-4 border-b border-gold/10 bg-brown/20">
        <div className="flex items-center">
          <div className="flex-1 grid grid-cols-12 gap-4 text-sm font-medium text-cream/70">
            <div className="col-span-1 text-center">Rank</div>
            <div className="col-span-5">Player</div>
            <div className="col-span-6 grid grid-cols-4 gap-4">
              {columns.map(column => (
                <button 
                  key={column.id} 
                  className={`flex items-center justify-center transition-colors ${
                    sort === column.id ? 'text-gold' : 'hover:text-cream'
                  } ${column.sortable ? 'cursor-pointer' : ''}`}
                  onClick={() => column.sortable && handleSort(column.id as SortField)}
                  disabled={!column.sortable}
                >
                  {column.name}
                  {column.sortable && sort === column.id && (
                    <motion.div
                      initial={{ scale: 0.8, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ duration: 0.2 }}
                    >
                      {direction === 'asc' ? 
                        <ArrowUp className="ml-1 h-3 w-3" /> : 
                        <ArrowDown className="ml-1 h-3 w-3" />
                      }
                    </motion.div>
                  )}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
      
      {/* Player List */}
      <div className="divide-y divide-gold/10">
        <AnimatePresence mode="popLayout">
          {sortedPlayers.map((player, index) => {
            const winRate = player.wins + player.losses > 0 
              ? ((player.wins / (player.wins + player.losses)) * 100).toFixed(1)
              : '0.0';
            
            return (
              <motion.div 
                key={`${player.summonerId}-${player.rank}`}
                className="px-6 py-4 hover:bg-brown/20 transition-colors cursor-pointer group"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2, delay: index * 0.01 }}
                onClick={() => handlePlayerClick(player)}
                layout
              >
                <div className="grid grid-cols-12 gap-4 items-center">
                  {/* Rank */}
                  <div className="col-span-1 flex items-center justify-center">
                    <div className="flex items-center gap-1">
                      {getRankIcon(player.rank)}
                      <span className="font-bold text-lg text-cream">
                        {player.rank}
                      </span>
                    </div>
                  </div>
                  
                  {/* Player Info */}
                  <div className="col-span-5 flex items-center gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-medium text-cream truncate">
                          {player.summonerName || "Unknown"}
                        </span>
                        {player.tagLine && (
                          <span className="text-sm text-cream/60">
                            #{player.tagLine}
                          </span>
                        )}
                        <ExternalLink className="h-4 w-4 text-cream/40 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0" />
                      </div>
                      <div className={`text-sm font-medium ${getTierColor(player.tier)}`}>
                        {player.tier} {player.division}
                      </div>
                    </div>
                  </div>
                  
                  {/* Stats */}
                  <div className="col-span-6 grid grid-cols-4 gap-4 text-sm">
                    <div className="text-center">
                      <div className="font-bold text-gold text-lg">
                        {player.leaguePoints.toLocaleString()}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className="font-medium text-green-500">
                        {player.wins}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className="font-medium text-red-500">
                        {player.losses}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className={`font-medium ${
                        parseFloat(winRate) > 65 ? 'text-gold font-medium' : 
                        parseFloat(winRate) > 55 ? 'text-amber-300 font-medium' : 
                        parseFloat(winRate) < 45 ? 'text-red-400' : 
                        'text-cream'
                      }`}>
                        {winRate}%
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}
