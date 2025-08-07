import React, { useState, useMemo, useCallback } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import Layout from '@/components/ui/Layout';
import { Search, RefreshCw, Trophy, Loader2, ChevronDown, Globe } from 'lucide-react';
import RegionFilter from '@/components/leaderboard/RegionFilter';
import TopPlayers from '@/components/leaderboard/TopPlayers';
import { LeaderboardEntry } from '@/types/auth';
import { Card } from '@/components/ui';

export default function LeaderboardPage() {
  const queryClient = useQueryClient();
  const [activeRegion, setActiveRegion] = useState('na1');
  const [search, setSearch] = useState('');
  const [allEntries, setAllEntries] = useState<LeaderboardEntry[]>([]);
  const [hasMore, setHasMore] = useState(true);
  const [offset, setOffset] = useState(0);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  
  const regions = [
    { id: 'na1', name: 'NA' },
    { id: 'euw1', name: 'EUW' },
    { id: 'kr', name: 'KR' },
    { id: 'eun1', name: 'EUNE' },
    { id: 'br1', name: 'BR' },
    { id: 'jp1', name: 'JP' },
    { id: 'la1', name: 'LAN' },
    { id: 'la2', name: 'LAS' },
    { id: 'tr1', name: 'TR' },
    { id: 'ru', name: 'RU' },
    { id: 'oc1', name: 'OCE' }
  ];
  
  // Global leader query - cached for longer
  const {
    data: globalLeader,
    isLoading: isLoadingGlobal
  } = useQuery({
    queryKey: ['globalLeaderboard'],
    queryFn: async () => {
      const response = await fetch('/api/tft/leaderboard/global');
      if (!response.ok) throw new Error('Failed to fetch global leader');
      return response.json();
    },
    staleTime: 600000, // 10 minutes
    retry: 1
  });
  
  // Fetch initial data - force fresh fetch every time
  const {
    data: initialData,
    isLoading: isInitialLoading,
    isError,
    error,
    refetch
  } = useQuery<{
    entries: LeaderboardEntry[];
    total: number;
    offset: number;
    limit: number;
    hasMore: boolean;
  }>({
    queryKey: ['leaderboard', activeRegion], // Keep simple key
    queryFn: async () => {
      const endpoint = `/api/tft/leaderboard?region=${activeRegion}&limit=50&offset=0&_t=${Date.now()}`;
      
      const response = await fetch(endpoint);
      if (!response.ok) {
        throw new Error('Failed to fetch leaderboard data');
      }
      
      const data = await response.json();
      
      return data;
    },
    staleTime: 0, // Never consider data stale - always fetch fresh
    cacheTime: 0, // Don't cache at all
    retry: 1,
    refetchOnWindowFocus: false,
    enabled: !!activeRegion // Only run query when we have a region
  });
  
  // Load more function
  const loadMore = useCallback(async () => {
    if (!hasMore || isLoadingMore) return;
    
    setIsLoadingMore(true);
    try {
      const response = await fetch(
        `/api/tft/leaderboard?region=${activeRegion}&limit=50&offset=${allEntries.length}&_t=${Date.now()}`
      );
      
      if (!response.ok) throw new Error('Failed to load more');
      
      const data = await response.json();
      
      // Only append if we got new entries
      if (data.entries && data.entries.length > 0) {
        setAllEntries(prev => [...prev, ...data.entries]);
        setHasMore(data.hasMore);
      } else {
        // No more entries available
        setHasMore(false);
      }
    } catch (error) {
      // Handle error silently but stop trying to load more
      setHasMore(false);
    } finally {
      setIsLoadingMore(false);
    }
  }, [activeRegion, allEntries.length, hasMore, isLoadingMore]);
  
  // Handle region change with proper cleanup
  const handleRegionChange = useCallback((newRegion: string) => {
    if (newRegion !== activeRegion) {
      setActiveRegion(newRegion);
    }
  }, [activeRegion]);
  
  // Update state when initial data loads
  React.useEffect(() => {
    if (initialData && initialData.entries) {
      setAllEntries(initialData.entries);
      setHasMore(initialData.hasMore);
    }
  }, [initialData]);
  
  // Reset when region changes and force refetch
  React.useEffect(() => {
    setAllEntries([]);
    setOffset(0);
    setHasMore(true);
    setSearch('');
    setIsLoadingMore(false);
    
    // Remove all cached data for leaderboard
    queryClient.removeQueries({ queryKey: ['leaderboard'] });
    
    // Manually trigger refetch after a small delay to ensure state is reset
    setTimeout(() => {
      refetch();
    }, 100);
  }, [activeRegion, queryClient, refetch]);
  
  const filteredPlayers = useMemo(() => {
    if (!allEntries || !search.trim()) return allEntries || [];
    
    const searchLower = search.toLowerCase().trim();
    return allEntries.filter(player => 
      player.summonerName.toLowerCase().includes(searchLower) ||
      (player.tagLine && player.tagLine.toLowerCase().includes(searchLower))
    );
  }, [allEntries, search]);
  
  const stats = useMemo(() => {
    if (!allEntries?.length) return null;
    
    const topLocal = allEntries[0];
    const totalGames = allEntries.reduce((sum, player) => sum + player.wins + player.losses, 0);
    const avgLP = Math.round(allEntries.reduce((sum, player) => sum + player.leaguePoints, 0) / allEntries.length);
    const avgWinRate = allEntries.reduce((sum, player) => {
      const total = player.wins + player.losses;
      return sum + (total > 0 ? (player.wins / total) * 100 : 0);
    }, 0) / allEntries.length;
    
    return { 
      globalLeader, 
      topLocal, 
      totalGames, 
      avgLP,
      avgWinRate: avgWinRate.toFixed(1),
      playerCount: initialData?.total || allEntries.length 
    };
  }, [allEntries, globalLeader, initialData]);

  return (
    <Layout title="TFT Leaderboard - Top Ranked Players">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Hero Section with Fight Banner */}
        <motion.div 
          className="relative overflow-hidden rounded-xl mb-8"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-void-core via-eclipse-shadow to-void-core opacity-65"></div>
          <div className="absolute inset-0 bg-[url('/assets/app/fight_banner.jpg')] bg-cover bg-center opacity-30"></div>
          <div className="absolute inset-0 border border-solar-flare/40 rounded-xl"></div>
          
          <div className="relative z-10 px-8 py-16 text-center">
            <motion.h1 
              className="text-3xl md:text-4xl font-display mb-4"
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.3, duration: 0.5 }}
            >
              <span className="text-solar-flare">Global</span>{' '}
              <span className="text-stellar-white">Leaderboard</span>
            </motion.h1>
            
            <motion.p 
              className="text-corona-light/80 max-w-2xl mx-auto text-lg mb-8"
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.4, duration: 0.5 }}
            >
              Track the highest ranked TFT players across all regions and see where you stand in the competitive arena.
            </motion.p>
            
            {/* Stats Cards */}
            {stats && !isInitialLoading && (
              <motion.div 
                className="grid grid-cols-2 md:grid-cols-5 gap-4 max-w-5xl mx-auto"
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.5, duration: 0.5 }}
              >
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {isLoadingGlobal ? (
                      <Loader2 className="h-5 w-5 animate-spin mx-auto" />
                    ) : (
                      globalLeader ? `${globalLeader.leaguePoints.toLocaleString()}` : 'N/A'
                    )}
                  </div>
                  <div className="text-xs text-corona-light/70">
                    {isLoadingGlobal ? 'Loading...' : 'Global #1 LP'}
                  </div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.topLocal.leaguePoints.toLocaleString()}
                  </div>
                  <div className="text-xs text-corona-light/70">
                    {activeRegion.toUpperCase()} #1 LP
                  </div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.avgLP.toLocaleString()}
                  </div>
                  <div className="text-xs text-corona-light/70">Average LP</div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.avgWinRate}%
                  </div>
                  <div className="text-xs text-corona-light/70">Avg Win Rate</div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.playerCount}
                  </div>
                  <div className="text-xs text-corona-light/70">Total Players</div>
                </motion.div>
              </motion.div>
            )}
          </div>
        </motion.div>
        
        {/* Main Content */}
        <Card className="bg-brown-light/10 border-gold/10 overflow-hidden">
          {/* Filters Section */}
          <div className="p-6 border-b border-gold/10">
            <div className="space-y-6">
              {/* Region Selector */}
              <div>
                <div className="flex items-center gap-2 mb-4">
                  <Globe className="h-5 w-5 text-gold" />
                  <h3 className="text-lg font-semibold text-cream">Select Region</h3>
                </div>
                <div className="flex flex-wrap gap-2">
                  {regions.map(region => (
                    <button
                      key={region.id}
                      onClick={() => handleRegionChange(region.id)}
                      disabled={isInitialLoading}
                      className={`px-4 py-2 rounded-lg font-medium transition-all ${
                        activeRegion === region.id
                          ? 'bg-gold text-brown'
                          : 'bg-brown/40 text-cream hover:bg-brown/60'
                      } ${isInitialLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
                    >
                      {region.name}
                    </button>
                  ))}
                </div>
              </div>
              
              {/* Search and Refresh */}
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-cream/50" />
                  <input
                    type="text"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder="Search players..."
                    className="w-full pl-10 pr-4 py-3 bg-brown/30 border border-gold/20 rounded-lg text-cream placeholder-cream/50 focus:outline-none focus:border-gold/40 transition-colors"
                  />
                </div>
                <button
                  onClick={() => refetch()}
                  disabled={isInitialLoading}
                  className="px-6 py-3 bg-brown/40 hover:bg-brown/60 text-cream rounded-lg font-medium transition-colors flex items-center gap-2 disabled:opacity-50"
                >
                  <RefreshCw className={`h-5 w-5 ${isInitialLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </button>
              </div>
            </div>
          </div>
          
          {/* Players List */}
          <div className="relative">
            {isInitialLoading ? (
              <div className="p-8">
                <div className="flex flex-col items-center justify-center space-y-4">
                  <Loader2 className="h-12 w-12 animate-spin text-gold" />
                  <p className="text-cream/70">Loading leaderboard...</p>
                </div>
              </div>
            ) : isError ? (
              <div className="p-8">
                <div className="bg-red-900/20 border border-red-600/30 rounded-lg p-6 text-center">
                  <Trophy className="h-12 w-12 mx-auto text-red-500 mb-4" />
                  <h3 className="text-xl font-semibold text-cream mb-2">Failed to Load Leaderboard</h3>
                  <p className="text-cream/70 mb-4">{(error as Error)?.message || 'Something went wrong'}</p>
                  <button
                    onClick={() => refetch()}
                    className="px-6 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors"
                  >
                    Try Again
                  </button>
                </div>
              </div>
            ) : allEntries.length > 0 ? (
              <>
                <TopPlayers 
                  players={filteredPlayers} 
                  isLoading={false}
                  region={activeRegion}
                />
                
                {/* Load More */}
                {hasMore && !search && allEntries.length > 0 && (
                  <div className="p-6 border-t border-gold/10">
                    <div className="text-center">
                      <button
                        onClick={loadMore}
                        disabled={isLoadingMore}
                        className={`px-8 py-3 rounded-lg font-medium transition-all flex items-center gap-3 mx-auto ${
                          isLoadingMore
                            ? 'bg-brown/30 text-cream/50 cursor-not-allowed'
                            : 'bg-gold text-brown hover:bg-gold-light'
                        }`}
                      >
                        {isLoadingMore ? (
                          <>
                            <Loader2 className="h-5 w-5 animate-spin" />
                            Loading more...
                          </>
                        ) : (
                          <>
                            <ChevronDown className="h-5 w-5" />
                            Load More Players
                            <span className="text-sm opacity-80">
                              ({allEntries.length} of {initialData?.total || '?'})
                            </span>
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                )}
              </>
            ) : (
              <div className="p-8 text-center">
                <Trophy className="h-16 w-16 mx-auto text-gold/50 mb-4" />
                <h3 className="text-xl font-display text-cream mb-2">No Players Found</h3>
                <p className="text-cream/70">
                  This region might not have ranked players yet, or there might be an issue loading the data.
                </p>
              </div>
            )}
          </div>
        </Card>
      </div>
    </Layout>
  );
}
