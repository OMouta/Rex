// Utility for managing documentation version links
// Update LATEST_VERSION when releasing new versions

export const LATEST_VERSION = '0.2';

// Helper function to generate links to the latest documentation
export function getLatestDocsUrl(page = 'introduction') {
  return `/docs/${LATEST_VERSION}/${page}`;
}

// Helper function to get the latest version
export function getLatestVersion() {
  return LATEST_VERSION;
}

// Common documentation links using latest version
export const DOCS_LINKS = {
  introduction: getLatestDocsUrl('introduction'),
  quickStart: getLatestDocsUrl('quick_start_guide'),
  yourFirstComponent: getLatestDocsUrl('your_first_component'),
  stateManagement: getLatestDocsUrl('state_management_basics'),
  apiReference: {
    state: getLatestDocsUrl('api_reference/state'),
    rendering: getLatestDocsUrl('api_reference/rendering'),
    context: getLatestDocsUrl('api_reference/context'),
  },
  examples: {
    simpleCounter: getLatestDocsUrl('examples/simple_counter'),
    dynamicList: getLatestDocsUrl('examples/dynamic_list'),
  },
  coreSpanConcepts: {
    components: getLatestDocsUrl('core_concepts/components'),
    states: getLatestDocsUrl('core_concepts/states'),
    reactivity: getLatestDocsUrl('core_concepts/reactivity'),
    lifecycleHooks: getLatestDocsUrl('core_concepts/lifecycle_hooks'),
    eventHandling: getLatestDocsUrl('core_concepts/event_handling'),
  },
  advancedFeatures: {
    deepReactivity: getLatestDocsUrl('advanced_features/deep_reactivity'),
    asyncState: getLatestDocsUrl('advanced_features/async_state'),
    memoization: getLatestDocsUrl('advanced_features/memoization'),
  }
};
