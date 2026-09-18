# Blog authoring guide

## Scope

- Articles are authored in `content/article/**/*.typ`.
- New public images go in `public/images/articles/<slug>/`.
- Existing migrated images may remain beside their legacy articles.
- Treat `typ/` and `packages/tylant/` as pinned upstream submodules. Do not edit them for ordinary article work.
- Do not publish, push, merge, or change GitHub Pages settings unless the user explicitly asks.

## Article contract

- Import `"/site/blog.typ": *` and use `main-zh` for Chinese articles.
- Provide `title`, `desc`, ISO `date`, `draft`, and `tags`.
- Reuse tags from `blog-tags` in `site/blog.typ`; add a deliberate canonical tag there instead of creating spelling variants.
- New posts start with `draft: true`. Production builds exclude drafts; local development includes them. Set `draft: false` only when the article is ready to publish.
- Keep the article id/path stable after publication. Public permalinks are derived as `/<year>/<month>/<day>/<article-id>/` to preserve the former Hexo URLs.

## Writing style

- Write concise Chinese technical prose with source-faithful English identifiers.
- Separate observed evidence, interpretation, and conclusion. State uncertainty and validation boundaries explicitly.
- Prefer semantic headings, figures, equations, links, and code blocks over visual spacing tricks.
- Add alt/caption text that explains why an image matters.

## Validation

- Run `pnpm build` after changing articles, templates, routes, or metadata.
- Check the generated article body, images, equations, internal links, canonical URL, RSS entry, and sitemap entry.
- Preserve existing content and unrelated user changes. Avoid large stylistic rewrites during a migration or compatibility fix.
