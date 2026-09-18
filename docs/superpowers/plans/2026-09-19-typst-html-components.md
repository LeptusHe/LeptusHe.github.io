# Typst HTML Components Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore Typst article emphasis, numbered headings, and mathematical callouts in the HTML build while preserving the existing paged Typst output.

**Architecture:** The public Typst helper files branch on `std.target()`. Their HTML path emits minimal, classed semantic elements with `html.elem`; their paged path retains the existing Typst layout primitives. Scoped styles in the Typography theme render these stable elements, and a Node test checks the built article’s exported structure.

**Tech Stack:** Astro 6, astro-typst, Typst HTML export, Node’s built-in test runner, CSS.

---

### Task 1: Create a failing build-artifact contract test

**Files:**
- Create: `tests/typst-html-components.test.mjs`
- Modify: `package.json`

- [ ] **Step 1: Write the failing test**

```js
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
```

Add a `test:typst-html` script that runs `node --test tests/typst-html-components.test.mjs`.

- [ ] **Step 2: Run the build and test to verify it fails**

Run: `corepack pnpm@10.28.1 build; corepack pnpm@10.28.1 test:typst-html`

Expected: build succeeds; the test fails because current HTML uses a `strong` element and has no `typst-*` component classes.

### Task 2: Add target-aware semantic Typst helpers

**Files:**
- Modify: `content/article/typst-inc/blog-inc.typc`
- Modify: `content/article/typst-inc/math/math-env.typc`

- [ ] **Step 1: Add an HTML branch for `im` and headings**

In `blog-inc.typc`, keep `set heading(numbering: "1.")`. When `std.target() == "html"`, add a heading show rule that emits the existing heading level, a `span.typst-heading-number` produced from `counter(heading).display(it.numbering)`, and `it.body`. Replace `im`’s HTML branch with:

```typst
#if std.target() == "html" {
  html.elem("span", content, attrs: (class: "typst-important"))
} else {
  set text(fill: blue.lighten(50%))
  content
}
```

The paged branch remains the existing blue text setting.

- [ ] **Step 2: Add semantic callout helpers for HTML**

In `math-env.typc`, keep each existing Paged/SVG implementation unchanged behind an `else` branch. For the HTML target, render `proof`, `note`, `problem`, and `custom_math_env` as `aside` elements with an inner label and body div. Use exactly these class contracts:

```typst
html.elem("aside", [
  #html.elem("div", [#label], attrs: (class: "typst-environment-label"))
  #html.elem("div", [#body], attrs: (class: "typst-environment-body"))
], attrs: (class: "typst-environment typst-definition"))
```

`proof` uses `typst-proof`; named environments use an ASCII class derived from their helper (`typst-definition`, `typst-theorem`, and so on), while their labels retain Chinese display names and existing counter values.

- [ ] **Step 3: Rebuild and run the contract test**

Run: `corepack pnpm@10.28.1 build; corepack pnpm@10.28.1 test:typst-html`

Expected: both commands pass, and the generated page contains the expected semantic HTML.

### Task 3: Style the semantic HTML components in the article scope

**Files:**
- Modify: `src/styles/typography.css`

- [ ] **Step 1: Add scoped component styles**

Add rules below the existing `.post-content` typography rules. Use the approved visual mapping: `.typst-important` has a soft blue foreground and normal weight; `.typst-heading-number` is an inline blue-grey prefix; `.typst-proof` has orange accent and the label “证明如下：”; `.typst-environment` uses a quiet dark panel with a left rule; type classes apply green/orange/blue/mauve accents. The rules must use `max-width: 100%`, `overflow-wrap: anywhere`, and only selectors rooted at `.post-content`.

- [ ] **Step 2: Rebuild and run the contract test**

Run: `corepack pnpm@10.28.1 build; corepack pnpm@10.28.1 test:typst-html; git diff --check`

Expected: all commands succeed without whitespace errors.

### Task 4: Verify the real article in the local preview

**Files:**
- Verify only: `dist/2024/09/21/fourier-transform/fourier-transform-02-fourier-series/index.html`

- [ ] **Step 1: Start the development server**

Run: `corepack pnpm@10.28.1 dev --host 127.0.0.1`

Expected: Astro reports a local URL, normally `http://127.0.0.1:4321/`.

- [ ] **Step 2: Inspect the Fourier article**

Open: `http://127.0.0.1:4321/2024/09/21/fourier-transform/fourier-transform-02-fourier-series/`

Expected: ordinary body text remains LXGW WenKai at the tuned article scale; “非周期函数” is blue and not bold; headings display their number; definition and proof content render as balanced dark cards without overflow.
