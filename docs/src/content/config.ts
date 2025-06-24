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
export const versions = {
  '0.1.0': { 
    label: '0.1.0', 
    status: 'beta',
    statusLabel: 'Beta' 
  }
};

// Define the schema for doc frontmatter
const docs = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    version: z.string().default('v1.0'),
    order: z.number().optional(),
    category: z.string().optional(),
    tags: z.array(z.string()).optional(),
    lastUpdated: z.date().optional(),
  }),
});

export const collections = {
  docs,
};