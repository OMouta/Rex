/**
 * Utility functions for handling version conversions between display format and slug format
 */

/**
 * Convert version from display format (0.2, 0.3, 1.0, etc.) to slug format (02, 03, 10, etc.)
 */
export function convertVersionToSlug(version: string): string {
  if (/^\d+\.\d+$/.test(version)) {
    const [major, minor] = version.split('.').map(Number);
    return `${major}${minor.toString().padStart(1, '0')}`.padStart(2, '0');
  }
  return version;
}

/**
 * Convert version from slug format (02, 03, 10, etc.) to display format (0.2, 0.3, 1.0, etc.)
 */
export function convertSlugToVersion(slugVersion: string): string {
  if (/^\d{2,}$/.test(slugVersion)) {
    if (slugVersion.length === 2 && slugVersion.startsWith('0')) {
      // Handle "02" -> "0.2", "03" -> "0.3"
      return `0.${parseInt(slugVersion.slice(1), 10)}`;
    } else {
      // Handle "10" -> "1.0", "11" -> "1.1", etc.
      const major = Math.floor(parseInt(slugVersion, 10) / 10);
      const minor = parseInt(slugVersion, 10) % 10;
      return `${major}.${minor}`;
    }
  }
  // If already in display format or unknown format, return as is
  return slugVersion;
}

/**
 * Extract version from a document slug
 */
export function extractVersionFromSlug(slug: string): string {
  const parts = slug.split('/');
  if (parts.length >= 1) {
    return convertSlugToVersion(parts[0]);
  }
  return slug;
}

/**
 * Convert a document slug to a user-friendly URL
 */
export function convertSlugToFriendlyUrl(slug: string): string {
  const parts = slug.split('/');
  if (parts.length >= 2) {
    const slugVersion = parts[0];
    const displayVersion = convertSlugToVersion(slugVersion);
    return `/docs/${slug.replace(`${slugVersion}/`, `${displayVersion}/`)}`;
  }
  return `/docs/${slug}`;
}

/**
 * Detect version from current URL path
 */
export function detectVersionFromUrl(pathname: string): string | null {
  if (pathname.startsWith('/docs/')) {
    const pathParts = pathname.split('/');
    if (pathParts.length >= 3) {
      const potentialVersion = pathParts[2];
      // Match semantic version pattern (0.2, 0.3, 1.0, etc.)
      if (/^\d+\.\d+$/.test(potentialVersion)) {
        return potentialVersion;
      }
    }
  }
  return null;
}
