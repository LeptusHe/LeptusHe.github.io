import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const article = new URL(
  "../dist/2024/09/21/fourier-transform/fourier-transform-02-fourier-series/index.html",
  import.meta.url,
);

test("Typst HTML exports semantic typography components", async () => {
  const html = await readFile(article, "utf8");

  assert.match(html, /class="typst-important"[^>]*>非周期函数<\/span>/);
  assert.doesNotMatch(html, /<strong>非周期函数<\/strong>/);
  assert.match(html, /class="typst-heading-number"/);
  assert.match(html, /class="typst-environment typst-definition"/);
});
