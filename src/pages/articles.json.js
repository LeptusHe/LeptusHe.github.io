import { getBlogPosts, getLegacyPostPath } from "$lib/posts";

export async function GET() {
  const rawPosts = await getBlogPosts();

  // only export specified fields
  const posts = rawPosts.map((post) => ({
    id: post.id,
    url: getLegacyPostPath(post),
    collection: post.collection,
    data: {
      title: post.data.title,
    },
  }));

  return Response.json(posts);
}
