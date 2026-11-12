#  # ExpenseApp

A SwiftUI expense-tracking portfolio app demonstrating modern iOS
development with MVVM, dependency injection, SwiftData persistence,
asynchronous networking, XCTest

## Features

-   Dashboard with current-month spending total, category breakdown, and
    recent expenses
-   Transaction list with search, category filtering, swipe-to-delete,
    and pull-to-refresh
-   Add, edit, and inspect expense records
-   SwiftData persistence for locally stored expenses and offline access
-   URLSession, Codable, and async/await remote import using
    JSONPlaceholder
-   Loading, error, and empty states
-   VoiceOver labels and Dynamic Type-friendly SwiftUI layouts
-   Appearance settings with System, Light, and Dark themes

## Requirements

-   Xcode 15 or later
-   iOS 17 or later
-   Optional: [XcodeGen](https://github.com/yonaskolb/XcodeGen) to
    generate the Xcode project

## Setup

1.  Clone this repository.
2.  From the repository root, run `xcodegen generate` if the project
    uses an XcodeGen `project.yml` file.
3.  Open `ExpenseApp.xcodeproj` in Xcode.
4.  Select an iOS 17+ simulator or device and run the `ExpenseApp`
    scheme.

If the repository does not include a generated Xcode project, create a
new iOS App project in Xcode named `ExpenseApp` (SwiftUI, Swift), add
the application source folders to the app target, and add the unit-test 
folders to their corresponding test targets.

No API key is required. The demo sync reads posts from
`https://jsonplaceholder.typicode.com/posts`. JSONPlaceholder is a mock
API; imported amounts and categories are deterministic demo values
derived from record IDs, not real financial data. The app persists
imported and user-created expenses locally using SwiftData. Sync is an
import-only demonstration and does not upload local edits to a server.

## Architecture

``` text
ExpenseApp
  |
  +-- App / RootTabView
  |     |
  |     +-- DashboardView
  |     +-- TransactionListView
  |     +-- ExpenseFormView
  |     +-- AppearanceSettingsView
  |
  +-- ExpenseListViewModel (@MainActor)
        |
        +-- ExpenseRepositoryProtocol
        |     |
        |     +-- ExpenseRepository
        |           |
        |           +-- SwiftData
        |
        +-- ExpenseAPIProtocol
              |
              +-- ExpenseAPI
                    |
                    +-- URLSession
```

-   **Views** render state and forward user actions.
-   **ExpenseListViewModel** owns presentation state, filtering, totals,
    and asynchronous sync orchestration.
-   **ExpenseRepositoryProtocol** abstracts persistence and makes the
    view model testable.
-   **ExpenseAPIProtocol** abstracts the remote service and supports
    test doubles.
-   **SwiftData** is the source of truth for locally available
    transactions.
-   **Appearance settings** persist the selected System, Light, or Dark
    appearance using `@AppStorage`. System appearance follows the device
    setting.

The app remains useful offline after records have been saved or synced.
Remote synchronization requires a network connection.

## Testing

Run tests from Xcode using **Product \> Test** or `Cmd + U`.

The test suite includes coverage for:

-   ViewModel loading, adding, updating, and deleting expenses
-   Repository failure handling and ViewModel error states
-   Search and category filtering, including combined filters and
    no-result cases
-   Current-month spending totals
-   Successful remote sync, API failures, and import failures
-   API response decoding, unsuccessful HTTP status codes, invalid JSON,
    and transport errors
-   
Use in-memory SwiftData containers for isolated repository and ViewModel
tests. Test doubles such as stubs, mocks, and spies can be used to
control API responses and verify interactions.

To measure code coverage, enable **Gather coverage for** in the Xcode
test scheme's **Test** action, run the test suite, and inspect the
Coverage report. Coverage depends on which targets and code paths are
included in the test run; verify the reported percentage in Xcode rather
than assuming a target percentage.

