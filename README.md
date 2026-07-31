# Steps Taken to Complete the Assignment

The following approach was used to implement the solution while keeping the application simple, maintainable, and aligned with Rails best practices.

### 1. Created a Rails API-only application

**Why?**

The assignment only requires REST endpoints and does not involve server-rendered HTML pages. Using Rails API mode removes unnecessary middleware and keeps the application lightweight.

---

### 2. Used SQLite as the database

**Why?**

SQLite requires minimal setup and is sufficient for a coding assignment. It allows the application to run immediately without installing or configuring a separate database server.

---

### 3. Created the `CryptoPrice` model

**Why?**

A dedicated model stores the latest known cryptocurrency price. Persisting data locally ensures that the application can continue serving previously fetched prices even when the external API is unavailable.

---

### 4. Added model validations and callbacks

**Why?**

Validations help maintain data integrity by preventing invalid records from being stored. Normalizing the cryptocurrency symbol before validation ensures consistent storage and simplifies lookups.

---

### 5. Created a dedicated `CoinGeckoClient`

**Why?**

External API communication was isolated into its own class following the Single Responsibility Principle. This keeps HTTP request logic separate from business logic and makes the client easier to test independently.

---

### 6. Used Ruby's built-in `Net::HTTP`

**Why?**

Since the application only communicates with a single external API, Ruby's standard library is sufficient. This avoids introducing additional dependencies while keeping the implementation straightforward.

---

### 7. Created `RefreshCryptoPriceService`

**Why?**

This service is responsible for refreshing cryptocurrency prices. Separating this logic from controllers and jobs keeps business rules centralized, reusable, and easier to maintain.

Responsibilities include:

- Fetching the latest price.
- Updating the database.
- Refreshing the cache.
- Handling external API failures gracefully.

---

### 8. Created `PriceLookupService`

**Why?**

Reading data is a different responsibility from updating data.

This service retrieves cryptocurrency prices from the cache and falls back to the database when necessary, keeping the controller clean and focused only on handling HTTP requests.

---

### 9. Introduced Rails caching

**Why?**

Caching reduces unnecessary database reads and improves response times for frequently requested cryptocurrency prices.

The cache is refreshed only after a successful API update, ensuring users receive the latest available data while minimizing database access.

---

### 10. Added `FetchCryptoPriceJob`

**Why?**

The assignment requires cryptocurrency prices to be refreshed periodically.

The background job simply delegates work to the refresh service, keeping the job lightweight and avoiding business logic inside background workers.

---

### 11. Used Serializer

**Why?**

Serialization is kept separate from controllers and services to improve code organization and maintain a consistent JSON response structure.

---

### 12. Implemented graceful failure handling

**Why?**

One of the core requirements is to continue serving the last known price when the external API is unavailable.

If the API request fails:

- Existing database records remain unchanged.
- Existing cached data is preserved.
- Users continue receiving the last successfully stored price.

This ensures the API remains functional even during temporary outages.

---

### 13. Wrote unit tests using Minitest

**Why?**

Rails includes Minitest by default, making it a lightweight choice without introducing additional dependencies.

Tests focus on each component's responsibility rather than duplicating behavior across multiple layers.

Covered components include:

- Models
- Services
- Background Jobs
- Controllers
- Serializer
- External API Client

---

### 14. Kept controllers intentionally thin

**Why?**

Controllers should primarily coordinate requests and responses.

Business logic is delegated to services, making controllers easier to understand, maintain, and test.

---

### 15. Followed SOLID principles without over-engineering

**Why?**

The solution aims to balance clean architecture with simplicity.

Instead of introducing unnecessary abstractions or design patterns, only the components required to satisfy the assignment were implemented. This keeps the codebase easy to read, maintain, and extend while remaining appropriate for the project's size.

---

# Overall Design Philosophy

Throughout the implementation, the focus was on:

- Keeping the solution simple and easy to understand.
- Following Rails conventions wherever possible.
- Giving each class a single, well-defined responsibility.
- Writing code that is easy to test and maintain.
- Avoiding unnecessary dependencies and abstractions.
- Building a solution that can be extended in the future without significant refactoring.

The objective was not only to satisfy the functional requirements but also to demonstrate clean software engineering practices suitable for a production-quality Rails application.
