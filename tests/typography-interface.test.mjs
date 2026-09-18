import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const builtPage = (path) => new URL(`../dist/${path}/index.html`, import.meta.url);

test("taxonomy pages expose useful article links instead of count-only labels", async () => {
  const [categories, tags] = await Promise.all([
    readFile(builtPage("categories"), "utf8"),
    readFile(builtPage("tags"), "utf8"),
  ]);

  assert.match(categories, /class="taxonomy-group"[^>]*id="数学"/);
  assert.match(categories, /class="taxonomy-posts"/);
  assert.match(categories, /href="\/2024\/09\/21\/fourier-transform\/fourier-transform-02-fourier-series\/"/);

  assert.match(tags, /class="taxonomy-jump-list"/);
  assert.match(tags, /href="#傅里叶变换"/);
  assert.match(tags, /class="taxonomy-posts"/);
});

test("mobile layout rules stack the identity and contain horizontal content", async () => {
  const css = await readFile(new URL("../src/styles/typography.css", import.meta.url), "utf8");

  assert.match(css, /\.side-container,\s*\.site-title-links\s*\{\s*display:\s*contents;/);
  assert.match(css, /\.site-title span\s*\{[^}]*display:\s*block;/s);
  assert.match(css, /\.main-container\s*\{[^}]*padding:\s*18px[^}]*overflow:\s*hidden;/s);
});

test("home cards preserve the original dimensional surface", async () => {
  const css = await readFile(new URL("../src/styles/typography.css", import.meta.url), "utf8");

  assert.match(css, /\.post-container\s*\{[^}]*border-radius:\s*30px;/s);
  assert.match(css, /\.post-container\s*\{[^}]*background:\s*#253549;/s);
  assert.match(css, /\.post-container\s*\{[^}]*box-shadow:\s*2px 2px 2px 2px #161823;/s);
});
