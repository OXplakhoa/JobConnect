<!-- SEED — re-run $impeccable document once there's code to capture the actual tokens and components. -->

---
name: JobConnect
description: AI-powered job matching for Vietnamese students and fresh graduates
---

# Design System: JobConnect

## 1. Overview

**Creative North Star: "The Clear Path"**

Every screen is a step forward. JobConnect's visual system is built around the conviction that a career tool for young Vietnamese graduates should feel like a well-lit path: you always see where you're going, the ground underfoot is solid, and the environment is alive without being distracting. The system draws restraint from Linear's purposeful whitespace, trust from Wise's clean financial clarity, and warmth from Raycast's ability to make a power tool feel human.

The design rejects noise as a design failure. Where TopCV fills screens with competing banners and saturated CTAs, JobConnect strips to the essential action. Where LinkedIn buries meaning in a feed, JobConnect surfaces progress. Where VietnamWorks ports desktop layouts to mobile, JobConnect is mobile-native from the first pixel.

Light theme, not by default, but by scene: a student on a bus in Saigon afternoon sun, glancing at their phone between stops. Dark surfaces wash out; bright ambient light demands a warm, high-contrast light canvas. The teal-green accent reads as a clear signal against warm neutrals, not a decorative choice.

**Key Characteristics:**
- Restrained color: tinted neutrals with a single teal-green accent used sparingly and deliberately
- Task-first hierarchy: every screen has one clear primary action visible within 2 seconds
- Mobile-native density: designed for one-handed use on mid-range Android in bright ambient light
- Warm professionalism: approachable enough for a 21-year-old, trustworthy enough for career decisions
- Responsive motion: meaningful feedback on every interaction, no choreographed entrances, reduced motion respected

## 2. Colors: The Clear Path Palette

A restrained palette anchored in teal-green, surrounded by warm-tinted neutrals. Every neutral carries a faint teal tint (chroma 0.005-0.01) so the surface feels cohesive, never sterile.

### Primary
- **Forward Teal** (oklch ~55% 0.14 175 — [to be resolved during implementation]): The singular accent color. Represents growth and forward motion. Used exclusively for primary CTAs, active states, progress indicators, and match score highlights. Its rarity is its power.

### Neutral
- **Warm Stone** ([to be resolved]): Primary background. A warm off-white tinted toward the teal hue. The canvas everything sits on.
- **Deep Ink** ([to be resolved]): Primary text. A warm near-black tinted toward teal. Never pure black.
- **Soft Ash** ([to be resolved]): Secondary text, metadata, borders, dividers. Maintains warmth at lower contrast.
- **Cloud** ([to be resolved]): Elevated surface background (cards, bottom sheets). Distinguishable from page background through subtle lightness shift, not shadow.

### Semantic (functional)
- **Success** ([to be resolved]): Skill match confirmed, application accepted. Shares the teal family.
- **Warning** ([to be resolved]): Skill gap, expiring post. Warm amber, not TopCV orange.
- **Error** ([to be resolved]): Failed action, rejected application. Muted red, never saturated.

**The Rarity Rule.** The teal-green accent appears on ≤10% of any given screen's surface area. If an element doesn't represent the single most important action or state, it doesn't get the accent. Two teal CTAs competing on the same screen is a design failure.

**The Warm Neutral Rule.** No pure white (#fff) backgrounds, no pure black (#000) text. Every neutral is tinted toward hue 175 at chroma 0.005-0.01. The warmth is felt, not seen.

## 3. Typography

**Body & Display Font:** Plus Jakarta Sans (with system sans-serif fallback)

**Character:** A single humanist sans-serif that carries both warmth and clarity. Plus Jakarta Sans reads well at small mobile sizes, supports Vietnamese diacritics natively, and has enough weight range (400-800) to build hierarchy through weight contrast alone. Warmer than Inter, more structured than Nunito, professional without being cold. Vietnamese diacritics (ă, â, ê, ô, ơ, ư, đ) need vertical room; line-height must never drop below 1.4 for body text.

### Hierarchy
- **Display** (ExtraBold 800, [size to be resolved], line-height 1.1): Screen titles on hero surfaces only. Used sparingly, never more than once per screen.
- **Headline** (Bold 700, [size to be resolved], line-height 1.25): Section headers within a screen. The entry point for scanning.
- **Title** (SemiBold 600, [size to be resolved], line-height 1.3): Card titles, list item primary text, job post titles.
- **Body** (Regular 400, [size to be resolved], line-height 1.5): All running text, job descriptions, profile content.
- **Label** (Medium 500, [size to be resolved], letter-spacing 0.02em): Buttons, chips, metadata, status tags, timestamps. Never uppercase.

**The Weight Ladder Rule.** Hierarchy is built through weight contrast (≥2 steps between adjacent levels), not size alone. A 14sp/700 title and a 14sp/400 body are distinguishable. Two items at 500 are not.

**The Diacritics Rule.** No text smaller than 12sp anywhere in the app. Vietnamese diacritics stack vertically (ệ, ặ, ở); cramped line-heights make them illegible. Body line-height ≥ 1.4 is enforced, not suggested.

## 4. Elevation

Flat by default. Depth is conveyed through **tonal layering**: subtle background lightness shifts between surfaces. A card sits on its page by being slightly lighter than its parent, not by floating above it.

Shadows are reserved for **transient surfaces only**: bottom sheets, dropdown menus, snackbars, FABs. These surfaces are temporary and need visual separation from the page they float above. Persistent surfaces (cards, sections, list items) never have shadows.

**The Grounded Rule.** If a surface is always visible, it stays flat. Shadows are earned by surfaces that come and go.

## 5. Components

[Omitted. No components exist yet. Will be populated on next `$impeccable document` run after implementation begins.]

## 6. Do's and Don'ts

### Do:
- **Do** use Forward Teal only for the single primary action on each screen. Count teal elements; if there are two, one is wrong.
- **Do** tint every neutral toward hue 175 (chroma 0.005-0.01). Warmth is structural, not decorative.
- **Do** respect `AccessibilityFeatures.reduceMotion` in Flutter. When the flag is set, all transitions and feedback animations are disabled, no exceptions.
- **Do** maintain ≥ 4.5:1 contrast ratio on all text (WCAG AA).
- **Do** pair every status color (success, warning, error) with an icon or text label. Color alone is never sufficient.
- **Do** design every screen for one-handed use on a 6-inch Android phone. Primary actions within thumb reach.
- **Do** make the primary CTA identifiable within 2 seconds of seeing any screen. If you can't find it, the screen is too noisy.
- **Do** use responsive motion: state transitions (150-300ms), press feedback, toggle animations. Every tap should acknowledge itself.

### Don't:
- **Don't** use saturated orange or red for CTAs. That is TopCV's territory, and TopCV is the clearest example of what JobConnect must not become: ad-injected content, saturated CTAs competing with each other, desktop-ported layout on mobile.
- **Don't** use corporate blue (#0A66C2 or similar). LinkedIn owns that space. JobConnect is not a social network and must never feel like one.
- **Don't** inject promotional or secondary content between task-relevant content. The user came for job matches, not banners.
- **Don't** port desktop layouts to mobile. Every screen is designed mobile-first. If it looks like VietnamWorks on a phone, it has failed.
- **Don't** use typography smaller than 12sp for any readable content. Vietnamese diacritics need vertical space.
- **Don't** animate list item entrances. Lists appear fully formed. Scroll performance on mid-range Android is the priority, not choreography.
- **Don't** use `border-left` or `border-right` > 1px as colored accent stripes on cards, list items, or status indicators.
- **Don't** apply glassmorphism, gradient text, or the hero-metric template (big number + small label + gradient accent).
- **Don't** create identical card grids with icon + heading + text repeated endlessly. Vary card structure by content type; a job post card, a company card, and a skill gap card should look structurally different.
- **Don't** use em dashes in UI copy. Commas, colons, semicolons, periods, or parentheses only.
- **Don't** use modals as the first solution. Exhaust inline and progressive disclosure alternatives before reaching for a modal.
