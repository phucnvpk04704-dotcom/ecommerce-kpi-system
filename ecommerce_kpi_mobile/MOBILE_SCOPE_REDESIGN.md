# Mobile Scope Redesign: Manager Mobile Application

This document outlines the architectural and UI scope shift of the mobile application from an **Admin Portal** to a **Manager Mobile Application**. The goal is to streamline the mobile experience, prioritizing KPI monitoring, read-only team metrics, and rapid performance lookups while deprecating complex CRUD management workflows to keep the mobile UX clean and focused.

---

## 1. Removed Modules and Workflows

To optimize the application for a mobile-first manager experience, several administrative modules will be removed or converted to read-only forms:

* **Employees Management (CRUD)**:
  - **Removed**: Creating, updating, deleting, or editing employee credentials or system rules on mobile.
  - **Converted**: Replaced with a read-only **Team Performance** screen focusing on KPI scores and sales contributions.
* **Blacklist Management**:
  - **Removed**: Dedicated CRUD screen for customer blacklists from the primary navigation hierarchy.
  - **Relocated**: Fraud risks or blacklist summaries are only accessible via nested analytics report dashboards if critical.
* **System Settings**:
  - **Removed**: Dedicated settings tab.
  - **Relocated**: Merged basic profile preferences (e.g., theme toggle) directly into the **Profile** screen.

---

## 2. New Navigation Structure

The primary application navigation will be simplified into a 5-tab Bottom Navigation bar:

```
[ Bottom Navigation Bar ]
  ├── 1. Dashboard  (Home metrics overview)
  ├── 2. KPI        (Personal & team KPI metrics)
  ├── 3. Revenue    (Store sales trends)
  ├── 4. Alerts     (Notifications, warnings & rewards)
  └── 5. Profile    (User info, basic options, team summary, logout)
```

---

## 3. Updated Screen Map

* **`/login`**: Unchanged credentials validation.
* **`/dashboard`** (Home):
  - Today's Revenue overview card.
  - Personal/Store KPI progress bar.
  - Team Performance quick link.
  - Platform metrics quick statistics.
* **`/kpi`**:
  - Personal KPI progress details.
  - KPI Ranking list (leaderboard).
  - Monthly achievement breakdown.
* **`/revenue`**:
  - Sales trends over time (daily/monthly charts).
  - Target comparisons.
  - Platform breakdown (Shopee, Lazada, TikTok, Tiki).
* **`/notifications`**:
  - Warnings & system notifications.
  - KPI progress alerts.
  - Reward achievements.
* **`/profile`**:
  - User details & role classification.
  - Team summary view.
  - Merged user settings (theme preference, notification toggles).
  - Logout trigger.
* **`/team-performance`** (Nested / Secondary Route):
  - Read-only ranking list of employees under management.
  - Access to detailed individual KPI details (read-only).

---

## 4. Manager-Focused Workflow

Managers require real-time visibility and instant access rather than complex administrative inputs. The redesign optimizes the following user flows:

1. **Morning Check-In**:
   - Opens Dashboard → Reviews today's revenue numbers, store-wide KPI averages, and any critical platform alerts.
2. **KPI Reviews**:
   - Taps KPI tab → Inspects ranking standings, checks individual metrics contributing to their team score, and accesses historical progress.
3. **Sales Analysis**:
   - Taps Revenue tab → Evaluates platform breakdown to see which channels are meeting targets and which require manager attention.
4. **Actionable Alerts**:
   - Receives push alerts on KPI warnings or blacklist alerts → Reviews details in the Notifications panel.
5. **Self-Service & Profile Management**:
   - Taps Profile → Checks their personal role, reviews overall team summary, adjusts app preferences (e.g., theme), and logs out if needed.

---

## 5. Estimated Development Impact

Adjusting the application scope involves localized UI adjustments on the frontend. The backend FastAPI code remains completely untouched.

### Affected Frontend Files:

* **[app_router.dart](file:///d:/ecommerce_kpi_mobile/lib/core/theme/app_router.dart)**:
  - **Refactor**: Remove routes for `/settings`, `/blacklist`, and `/employees`.
  - **Add/Modify**: Ensure `/team-performance` exists as a sub-route or helper screen.
* **Navigation Shell/UI components**:
  - **Refactor**: Rebuild bottom navigation bar layout to list only the 5 specified tabs. Remove left-hand drawer links or admin shortcuts.
* **[employees_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/features/employees/employees_screen.dart)**:
  - **Rename/Refactor**: Rename to `TeamPerformanceScreen` and strip out create, edit, delete forms, input validators, and action buttons. Keep only grid/list views of team members and scores.
* **[profile_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/features/settings/settings_screen.dart) / [settings_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/features/settings/settings_screen.dart)**:
  - **Refactor**: Merge the theme-switching and preference widgets into the user profile views.
