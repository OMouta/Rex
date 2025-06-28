import type { APIRoute } from 'astro';
import { buildSearchIndex } from '../../utils/buildSearchIndex';

export const GET: APIRoute = async () => {
  try {
    const searchIndex = await buildSearchIndex();
    
    return new Response(JSON.stringify(searchIndex), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=3600', // Cache for 1 hour
      },
    });
  } catch (error) {
    console.error('Error building search index:', error);
    return new Response(JSON.stringify({ error: 'Failed to build search index' }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
};
