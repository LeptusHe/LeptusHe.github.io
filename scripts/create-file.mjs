import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

const [kind, slug, ...titleParts] = process.argv.slice(2);
const config = {
  "blog-post": { template: "site/blog-post.typ", output: "content/article" },
  "archive-post": { template: "typ/templates/archive-post.typ", output: "content/archive" },
}[kind];

if (!config || !slug) {
  console.error("Usage: pnpm create:post -- <slug> [title]");
  process.exit(1);
}

if (!/^[\p{L}\p{N}][\p{L}\p{N}/_-]*$/u.test(slug) || slug.includes("..")) {
  console.error("Slug may contain letters, numbers, '/', '_', and '-', but not '..'.");
  process.exit(1);
}

const destination = resolve(config.output, `${slug}.typ`);
if (existsSync(destination)) {
  console.error(`Refusing to overwrite ${destination}`);
  process.exit(1);
}

const date = new Date().toISOString().slice(0, 10);
const title = titleParts.join(" ") || slug.split("/").at(-1).replaceAll("-", " ");
const source = readFileSync(resolve(config.template), "utf8")
  .replace('title: "Title"', `title: ${JSON.stringify(title)}`)
  .replace('date: "1970-01-01"', `date: "${date}"`);

mkdirSync(dirname(destination), { recursive: true });
writeFileSync(destination, source);
console.log(destination);
