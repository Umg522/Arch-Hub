# Arch Hub demo

A browser-only prototype for review and feedback. It has no build step and needs no server: open `index.html` in a modern browser, or open `arch-hub-standalone.html` as one self-contained file.

## Files

- `index.html` — app structure and entry point.
- `styles.css` — responsive styles.
- `app.js` — demo data and interactive behavior.
- `arch-hub-standalone.html` — the same demo in one file.

## Included workflows

- Project dashboard, project list, issues, drawings register, site updates, team, profile and settings.
- Create and edit projects, issues, site updates, drawing records and team members.
- Search and filter project records; save demo changes in this browser using local storage.
- Site study form with a local image preview, project context, generic concept prompts and missing-information checklist.
- Engineering tools with discipline-specific investigation prompts. Submitting a problem creates a project issue and an in-app alert for all listed demo team members.
- Notification inbox that shows who would receive each alert in the demo.

## Important prototype limits

- The site photo is previewed locally; the demo does not run image recognition or generate site-specific design advice.
- Engineering checklists are generic prompts, not calculations, code checks, or approved designs. A qualified professional must make and verify engineering decisions.
- Notifications are local in-app demo records only. No phone, email, or push messages are sent.
- The team list is not an account system. There is no backend, cloud sync, access control, or collaboration across devices.
- Drawing uploads are not stored as shared files. The register saves document metadata only.
- Demo content is sample information and must not be used for construction decisions.

## Reset

Use **Settings → Reset demo** to restore sample data in that browser. Or clear the browser's site data for this local file.
