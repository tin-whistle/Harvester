# Harvester Example App — Specification

This document is the authoritative description of the **features**, **behaviors**, and **invariants** of the Harvester Example app. It exists to be read before any refactor: as long as every item below is still true after your changes, the user-visible behavior is preserved.

This is a single-window iOS app that wraps the [Harvest](https://www.getharvest.com/) time-tracking API via the `Harvester` Swift package (in the same repository). The app is intentionally small: a focused interface for starting, stopping, editing, and reviewing time entries on the go.

---

## 1. Authentication

The app uses **Harvest Personal Access Tokens** (not OAuth) via `PersonalAccessTokenProvider`.

- **First launch (or after sign-out):** the user is presented with an alert titled "Authorization" containing a `TextField` for the token, plus three buttons: **OK**, **Cancel**, and **Open in Safari** (which deep-links to `https://id.getharvest.com/developers`).
- **Token entry:** tapping OK resumes a `CheckedContinuation` (held on `HarvestState`) with the entered string; tapping Cancel resumes it with `AuthorizationProviderError.canceled`.
- **Persistence:** a successful authorization stores `accessToken` and (after account selection) `accountId` in `UserDefaults` via the `@Persistent` property wrapper.
- **Subsequent launches:** if a stored token is present and valid, the app silently authorizes without showing the alert.
- **Sign out:** the "Sign Out" menu item calls `HarvestAPI.deauthorize()`, which clears the stored token and account. The next API call re-triggers the alert flow.

## 2. Account selection

Harvest accounts are independent organizations the user may belong to.

- After authorization, the app fetches accounts via `getAccounts()` in `SelectAccountView`.
- **Single-account users**: `SelectAccountView` shows one row; tapping it sets `currentAccountId` and dismisses.
- **Multi-account users**: same view, multiple rows; user picks one.
- The selected `accountId` persists across launches. The "Select Account" menu item lets the user switch.
- If `currentAccountId == nil`, the main screen shows "No Account Selected" and offers no other actions.

## 3. Main screen — totals header

When at least one time entry exists, the top of `TimeEntriesView` shows three totals side by side:

- **Weekly Average** — total hours across all known entries divided by `(daysSinceOldestEntry / 7)`. Zero if there are no entries or only entries from today.
- **Last 7 Days** — total hours from the last 6 full days plus a linearly **pro-rated** share of the partial current day. Specifically: `recent6 + (1 - elapsedTodayFraction) * day7Hours`, where `day7Hours = recent7 - recent6`. This produces a smoothly-advancing rolling 7-day average rather than a step function.
- **This Week** — total hours for entries within the current `weekOfYear` interval (locale-aware week start).

Each total is rendered through `Double.formattedHours()` from `Formatters.swift`.

## 4. Main screen — "+" menu (recent tasks)

The plus button in the top-left toolbar shows a `Menu` with two parts:

### 4a. Recent-tasks shortcut list

Grouped per client, up to 5 most-frequent `(project, task, notes)` tuples from time entries in the **last 30 days**. The label for each row is the notes if present, otherwise `"<project name> — <task name>"`.

Tapping a row immediately calls `HarvestState.startTimeEntryWith(...)` with today's date and zero hours, restarting against that recent task.

### 4b. Single-project client fallback

Some Harvest clients only have one active project at a time. When the original project of a historical entry is no longer in the client's project assignments **but** the client now has exactly one active project, the recent-tasks list:

1. Still shows the entry (instead of hiding it as stale).
2. **Re-maps** the entry's project to the client's single current project.
3. Collapses any duplicates that map to the same `(currentProject, task, notes)` tuple.

This is the behavior added by commit `3720d43`. Until project assignments have loaded (`projectAssignments.isEmpty == true`), no stale-data filtering is applied — every entry's project is treated as still valid.

### 4c. "New Time Entry…" option

A divider, then a single row that opens `EditTimeEntryView(originalTimeEntry: nil)` as a sheet.

## 5. Main screen — Setup menu

The top-right toolbar shows either the user's avatar (after `loadUser()`) or the text "Setup". The menu contains:

- **Signed out:** "Sign In" (calls `authorize()`).
- **Signed in:** "Sign Out", "Select Account", "Explore API".

## 6. Time-entries list

Rendered by `TimeEntriesView`. Below the totals header:

- Entries are **grouped by `spentDate`** with one section per date.
- Sections are sorted **newest first**.
- Each section header shows the formatted date (`DateFormatter.harvestDateFormatter`) and the day's total hours.
- Each row (a `TimeEntryView`) shows:
  - **Notes** in bold (blue if running, primary otherwise).
  - **Client / Project / Task** newline-joined in caption.
  - A red "circular arrows" icon (`arrow.2.circlepath`) only when `timeEntry.isDirty` is true — i.e., the local optimistic state differs from the most recent server snapshot.
  - The hours value, also bold (blue if running, primary otherwise).
- Tapping the row reveals a `Menu` with **Stop** or **Restart** (depending on `isRunning`), **Edit**, and **Delete**. The menu is hidden while `isDirty` is true so the user doesn't act on stale state.
- **Swipe to delete** any row in any section, including past-date sections. Index handling must be safe even if `timeEntries` shifts between the swipe and the call (defensive index check added in commit `af2a81b`).

### 6a. Polling

A background `Task` re-loads time entries on an interval:
- **10 seconds** when any entry is running.
- **30 seconds** otherwise.

The loop cancels when the view disappears.

### 6b. Scroll-to-top on restart

When a new entry is started (from anywhere — the "+" menu, the Restart action on an existing entry, or "New Time Entry…"), the list animates a scroll to the totals header. This is driven by an integer signal on `HarvestState` that the view observes via `onChange`.

## 7. Edit / Add time entry

Rendered by `EditTimeEntryView`, used for both adding (no original) and editing (with original). Sheet-style modal inside a `NavigationStack`.

### 7a. Fields

- **Date** — `DatePicker` showing date only.
- **Client** — button that opens a `.actionSheet` listing all clients. Disabled when there's ≤ 1 client.
- **Project** — button that opens a `.actionSheet` listing the selected client's projects (sorted by name). Disabled when no client is set or there's ≤ 1 project.
- **Task** — button that opens a `.actionSheet` listing the selected client+project's tasks (sorted by name). Disabled when no project is set or there's ≤ 1 task.
- **Notes** — `TextField` with word capitalization.
- **Hours** — two wheel pickers (hour 0–23, minute 0–59). When `wantsTimestampTimers` is true, the hours pickers are replaced with the placeholder "Timestamp timers are not yet supported."

### 7b. Cascading selection

Selection cascades **client → project → task**:

- When **opening Add** (no original entry, `clients` non-empty, no client yet): `selectClient()` runs once `loadProjectAssignments` finishes. If `clients.count == 1`, the single client is auto-picked and `selectProject()` runs. The cascade continues through project to task. At any tier with > 1 option, the corresponding action sheet is shown.
- **Picking a client** in the action sheet clears project, task, and notes, then runs `selectProject()`.
- **Picking a project** in the action sheet clears task and notes, then runs `selectTask()`.
- **Picking a task** in the action sheet clears notes.

### 7c. Save behavior

- The **Save** button is disabled unless client, project, and task are all set.
- For an **existing entry**: `updateTimeEntry` is called with the new values; `id`, `startedTime`, `endedTime`, and `isRunning` are carried over from the original.
- For a **new entry**: `startTimeEntryWith` is called.
- After save, the sheet is dismissed.

### 7d. Date-change stop rule

A time entry may only be running if its `spentDate` is today.

- **On save of an existing entry:** if the entry was running but its (possibly newly-edited) `spentDate` is not today, the save also issues a server-side stop. Local state reflects `isRunning = false` immediately. (Commit `da6176c`.)
- **On add of a new entry:** if the chosen date is not today, the entry is created with `isRunning = false` and **does not stop any currently running entry**. Only when the date is today does the app first stop any running entry locally and issue a server `restart` on the new one. (Commit `e4b6cd4`.)

## 8. Time-entry mutation invariants (must hold across refactors)

1. **At most one running entry exists at a time.** Whenever a new entry is started for today, every currently-running entry is stopped first (both locally and on the server).
2. **Past-date entries are never running.** New entries for past dates are created stopped; editing a running entry to a past date stops it.
3. **Optimistic local update precedes server sync.** Every mutation (start, stop, update, delete) first changes the local `timeEntries` array, then fires the server call, then calls `loadTimeEntries()` to reconcile. The user sees the change immediately even if the network is slow.
4. **Server reload reconciles divergence.** After every server call, the list reloads. Any entries that differ from the local snapshot are marked `isDirty` until the next refresh confirms them.
5. **Identity is by `id`.** All "find and update" operations use `timeEntries.firstIndex(where: { $0.id == ... })`. Local placeholder entries (for not-yet-confirmed inserts) use a negative random `id` to avoid collisions.

## 9. Other surfaces

- **Account view** (`AccountView`) — minimal display of a single account's fields.
- **Accounts view** (`AccountsView`) — lists all accounts, used inside `ExploreView` for diagnostic purposes.
- **Company view** (`CompanyView`) — shows the active company.
- **User view** (`UserView`) — shows the active user.
- **Projects view** (`ProjectsView`), **Tasks view** (`TasksView`) — listing helpers used in the Explore flow.
- **Explore view** — diagnostic root accessed from the Setup menu.

These views are simple readouts and have no edge-case behaviors of their own; they are out of scope for this spec beyond "must continue to compile and display data".

## 10. Persistent state

Three keys are persisted via `@Persistent` (UserDefaults):
- `Harvester.accessToken` — String?
- `Harvester.accountId` — Int?
- `Harvester.wantsTimestampTimers` — Bool?

No other persistent storage. Time entries, projects, clients, and tasks are fetched fresh from the network on every launch.

## 11. Modal selection (race-condition fix)

The "+" menu and Setup menu both present sheets driven by `@State private var modalSelection: ModalSelection?`. Picking an item from one sheet while another is dismissing was previously racing (commit `9f3ea32`). The current implementation uses a single `Identifiable` enum so SwiftUI handles the transition atomically. Any refactor must keep this single-enum pattern (or a structurally-equivalent one — never two independent `@State Bool` flags for two concurrent sheets).

---

## How to use this spec when refactoring

- Before touching any code, **re-read sections 4b, 7d, 8, and 11** — those four sections describe the recent edge-case fixes most easily broken by careless refactoring.
- After every refactor, walk the **smoke-test checklist** in the implementation plan and confirm each item still works in the running app.
- If you intentionally change a behavior described here, **update this document in the same commit**.
