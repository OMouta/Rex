import { defineCollection, z } from 'astro:content';

// Define category ordering
export const categoryOrder = {
  'Getting Started': 1,
  'Core Concepts': 2,
  'API Reference': 3,
  'Advanced Features': 4,
  'Design Choices': 5,
  'Examples': 6,
  'General': 999,
};

// Define versions with their status
// Status can be 'stable', 'beta', 'prerelease', 'outdated' or 'experimental'
export const versions = {
  '0.2': {
    label: '0.2',
    status: 'stable',
    statusLabel: 'stable'
  },
  '0.3': {
    label: '0.3',
    status: 'prerelease',
    statusLabel: 'prerelease'
  }
};

// Define the schema for doc frontmatter
const docs = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    order: z.number().optional(),
    category: z.string().optional(),
    tags: z.array(z.string()).optional(),
    lastUpdated: z.date().optional(),
  }),
});

export const collections = {
  docs,
};