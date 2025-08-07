import type { NextApiRequest, NextApiResponse } from 'next';
import { LeaderboardEntry } from '@/types/auth';

const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

// Aggressive rate limiting for speed - optimized for parallel requests
const requestQueue: number[] = [];
const RATE_LIMIT_WINDOW = 1000; // 1 second window
const MAX_REQUESTS_PER_WINDOW = 100; // Riot allows 100 requests per 2 minutes, we'll be conservative

async function rateLimit() {
  const now = Date.now();
  // Remove old requests outside the window
  while (requestQueue.length > 0 && requestQueue[0] < now - RATE_LIMIT_WINDOW) {
    requestQueue.shift();
  }
  
  // If we're at the limit, wait until the oldest request expires
  if (requestQueue.length >= MAX_REQUESTS_PER_WINDOW) {
    const waitTime = requestQueue[0] + RATE_LIMIT_WINDOW - now + 10; // Add 10ms buffer
    if (waitTime > 0) {
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
  
  requestQueue.push(Date.now());
}

const logError = (message: string, error?: any) => {
  console.error(`[TFT/LEADERBOARD] ${message}`, error);
};

// Simple cache to avoid repeated summoner name lookups
const nameCache = new Map<string, { name: string; tagLine: string; timestamp: number }>();
const CACHE_TTL = 300000; // 5 minutes

async function fetchSummonerNameByPuuid(puuid: string, region: string): Promise<{ name: string; tagLine: string } | null> {
  const cacheKey = `${puuid}-${region}`;
  const cached = nameCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return { name: cached.name, tagLine: cached.tagLine };
  }
  
  try {
    await rateLimit();
    
    // Get the game name and tag line from Account API using routing region
    const routingRegion = getRoutingRegion(region);
    
    const accountResponse = await fetch(
      `https://${routingRegion}.api.riotgames.com/riot/account/v1/accounts/by-puuid/${puuid}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (accountResponse.ok) {
      const account = await accountResponse.json();
      const result = {
        name: account.gameName || "Unknown Player",
        tagLine: account.tagLine || ""
      };
      
      // Cache the result
      nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
      
      return result;
    }
    
    logError(`Failed to fetch account for PUUID ${puuid}: ${accountResponse.status}`);
    return null;
  } catch (error) {
    logError(`Error fetching summoner name for PUUID ${puuid}:`, error);
    return null;
  }
}

async function fetchSummonerName(summonerId: string, region: string): Promise<{ name: string; tagLine: string } | null> {
  const cacheKey = `${summonerId}-${region}`;
  const cached = nameCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return { name: cached.name, tagLine: cached.tagLine };
  }
  
  try {
    await rateLimit();
    
    // First get the PUUID from summoner ID
    const summonerResponse = await fetch(
      `https://${region}.api.riotgames.com/tft/summoner/v1/summoners/${summonerId}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (!summonerResponse.ok) {
      logError(`Failed to fetch summoner ${summonerId}: ${summonerResponse.status}`);
      return null;
    }
    
    const summoner = await summonerResponse.json();
    
    // Then get the game name and tag line from Account API using routing region
    const routingRegion = getRoutingRegion(region);
    await rateLimit(); // Additional rate limit for second API call
    
    const accountResponse = await fetch(
      `https://${routingRegion}.api.riotgames.com/riot/account/v1/accounts/by-puuid/${summoner.puuid}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (accountResponse.ok) {
      const account = await accountResponse.json();
      const result = {
        name: account.gameName || summoner.name || "Unknown Player",
        tagLine: account.tagLine || ""
      };
      
      // Cache the result
      nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
      
      return result;
    }
    
    // Fallback to summoner name if account API fails
    logError(`Failed to fetch account for PUUID ${summoner.puuid}: ${accountResponse.status}`);
    const result = {
      name: summoner.name || "Unknown Player",
      tagLine: ""
    };
    
    // Cache the result
    nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
    
    return result;
  } catch (error) {
    logError(`Error fetching summoner name for ${summonerId}:`, error);
    return null;
  }
}

function getRoutingRegion(region: string): string {
  const regionRouting: Record<string, string> = {
    'na1': 'americas', 'br1': 'americas', 'la1': 'americas', 'la2': 'americas',
    'euw1': 'europe', 'eun1': 'europe', 'tr1': 'europe', 'ru': 'europe',
    'kr': 'asia', 'jp1': 'asia',
    'oc1': 'sea'
  };
  
  return regionRouting[region] || 'americas';
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { region = 'na1', limit = '50', offset = '0' } = req.query;
    
    if (!RIOT_API_KEY) {
      return res.status(500).json({ error: 'RIOT_API_KEY is not set' });
    }
    
    const regionMapping: Record<string, string> = {
      'na': 'na1', 'na1': 'na1',
      'euw': 'euw1', 'euw1': 'euw1',
      'kr': 'kr', 'jp': 'jp1', 'jp1': 'jp1',
      'br': 'br1', 'br1': 'br1',
      'las': 'la2', 'la2': 'la2',
      'lan': 'la1', 'la1': 'la1',
      'eune': 'eun1', 'eun1': 'eun1',
      'tr': 'tr1', 'tr1': 'tr1',
      'oc': 'oc1', 'oc1': 'oc1', 'oce': 'oc1',
      'ru': 'ru'
    };
    
    const validRegion = regionMapping[region as string] || 'na1';
    const limitNumber = Math.min(parseInt(limit as string) || 50, 300); // Allow up to 300 entries
    const offsetNumber = parseInt(offset as string) || 0;
    
    let leaderboardData: any = null;
    let tier = '';
    
    const tiers = [
      { name: 'CHALLENGER', endpoint: 'challenger' },
      { name: 'GRANDMASTER', endpoint: 'grandmaster' },
      { name: 'MASTER', endpoint: 'master' }
    ];
    
    // Try to get leaderboard data with aggressive timeout
    for (const tierInfo of tiers) {
      try {
        await rateLimit();
        
        const response = await fetch(
          `https://${validRegion}.api.riotgames.com/tft/league/v1/${tierInfo.endpoint}`,
          {
            headers: { 'X-Riot-Token': RIOT_API_KEY },
            signal: AbortSignal.timeout(5000) // Reduced timeout
          }
        );
        
        if (response.ok) {
          leaderboardData = await response.json();
          tier = tierInfo.name;
          break;
        }
      } catch (error) {
        logError(`Failed to fetch ${tierInfo.name} for ${validRegion}`, error);
        continue;
      }
    }
    
    if (!leaderboardData?.entries?.length) {
      return res.status(404).json({ error: `No leaderboard data found for ${validRegion}` });
    }
    
    const allEntries = leaderboardData.entries
      .sort((a: any, b: any) => b.leaguePoints - a.leaguePoints);
    
    const topEntries = allEntries.slice(offsetNumber, offsetNumber + limitNumber);
    
    // Fetch names in parallel with larger batch size for speed
    const batchSize = 20; // Increased batch size for faster processing
    const summonerResults: Array<{ name: string; tagLine: string } | null> = [];
    
    for (let i = 0; i < topEntries.length; i += batchSize) {
      const batch = topEntries.slice(i, i + batchSize);
      const batchPromises = batch.map((entry: any) => {
        // Check if entry has puuid or summonerId
        if (entry.puuid) {
          return fetchSummonerNameByPuuid(entry.puuid, validRegion)
            .catch(() => null);
        } else if (entry.summonerId) {
          return fetchSummonerName(entry.summonerId, validRegion)
            .catch(() => null);
        } else {
          logError("Entry has neither puuid nor summonerId:", entry);
          return Promise.resolve(null);
        }
      });
      
      const batchResults = await Promise.all(batchPromises);
      summonerResults.push(...batchResults);
    }
    
    
    const processedEntries: LeaderboardEntry[] = topEntries.map((entry: any, index: number) => {
      const summonerInfo = summonerResults[index];
      
      return {
        summonerId: entry.summonerId || "",
        summonerName: summonerInfo?.name || entry.summonerName || `Player ${index + 1}`,
        tagLine: summonerInfo?.tagLine || "",
        rank: offsetNumber + index + 1, // Fix: Use offset to calculate correct global rank
        leaguePoints: entry.leaguePoints || 0,
        wins: entry.wins || 0,
        losses: entry.losses || 0,
        tier,
        division: "",
        region: validRegion
      };
    });
    
    // Aggressive caching
    res.setHeader('Cache-Control', 's-maxage=120, stale-while-revalidate=240');
    
    // Return with pagination metadata
    return res.status(200).json({
      entries: processedEntries,
      total: allEntries.length,
      offset: offsetNumber,
      limit: limitNumber,
      hasMore: offsetNumber + limitNumber < allEntries.length
    });
  } catch (error) {
    logError("Leaderboard API Error", error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
