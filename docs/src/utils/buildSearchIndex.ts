import { getCollection } from 'astro:content';
import type { CollectionEntry } from 'astro:content';

export interface SearchIndexItem {
  slug: string;
  title: string;
  description: string;
  body: string;
  category: string;
  version: string;
  url: string;
}

export async function buildSearchIndex(): Promise<SearchIndexItem[]> {
  const docs = await getCollection('docs');
  
  const indexData: SearchIndexItem[] = docs.map((doc: CollectionEntry<'docs'>) => {
    // Extract text content from markdown body (remove markdown syntax)
    const cleanBody = doc.body
      .replace(/```[\s\S]*?```/g, '') // Remove code blocks
      .replace(/`[^`]*`/g, '') // Remove inline code
      .replace(/#+\s/g, '') // Remove headers
      .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1') // Extract link text
      .replace(/[*_]{1,2}([^*_]*)[*_]{1,2}/g, '$1') // Remove bold/italic
      .replace(/\n+/g, ' ') // Replace newlines with spaces
      .replace(/\s+/g, ' ') // Normalize spaces
      .trim();

    return {
      slug: doc.slug,
      title: doc.data.title,
      description: doc.data.description,
      body: cleanBody,
      category: doc.data.category || 'General',
      version: doc.data.version || '0.2.0',
      url: `/docs/${doc.slug}`,
    };
  });

  return indexData;
}
