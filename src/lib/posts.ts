import { getCollection, type CollectionEntry } from "astro:content";

export type BlogPost = CollectionEntry<"blog">;

export async function getBlogPosts(): Promise<BlogPost[]> {
  const posts = await getCollection("blog");
  return import.meta.env.PROD
    ? posts.filter((post) => !post.data.draft)
    : posts;
}

export function getLegacyPostPath(post: BlogPost): string {
  const date = post.data.date;
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, "0");
  const day = String(date.getUTCDate()).padStart(2, "0");
  return `/${year}/${month}/${day}/${post.id}/`;
}

const categoryTags = new Set(["数学", "图形渲染", "单元测试"]);

export function getCategories(post: BlogPost): string[] {
  return (post.data.tags ?? []).filter((tag) => categoryTags.has(tag));
}

export function getPostTags(post: BlogPost): string[] {
  return (post.data.tags ?? []).filter((tag) => !categoryTags.has(tag));
}
