# Crypto Price API

A lightweight Ruby on Rails JSON API that periodically fetches cryptocurrency prices from the CoinGecko public API and serves the latest available price.

The project was intentionally designed to keep the implementation simple while following Rails conventions, SOLID principles, and clean architecture. The focus is on readability, maintainability, graceful error handling, and testability rather than introducing unnecessary abstractions.

---

# Problem Statement

Build a small Rails API that fetches cryptocurrency prices from a public API (CoinGecko).

## Requirements

- Create an endpoint:

```
GET /prices/:symbol
```

- Return the cached price for the requested cryptocurrency.
- Fetch the latest price every minute using a background job.
- Continue serving the last known price if the external API becomes unavailable.
- Add unit tests for:
  - Job logic
  - Cache behavior
  - Fallback behavior

---

# Tech Stack

| Technology | Version |
|------------|---------|
| Ruby | 3.4.7 |
| Rails | 8.1.3.1 (API Only) |
| Database | SQLite3 |
| HTTP Client | Net::HTTP |
| Serializer | Panko Serializer |
| Background Jobs | Solid Queue |
| Cache | Solid Cache |
| Testing | Minitest |

---

# Why These Technologies?

## Rails API

The assignment only requires REST endpoints.

Using Rails API mode removes unnecessary middleware and view rendering components, making the application smaller, faster, and easier to maintain.

---

## SQLite

SQLite requires almost no setup and is sufficient for this coding assignment.

It allows reviewers to run the project immediately without additional database configuration.

---

## Net::HTTP

Ruby already provides Net::HTTP as part of the standard library.

Since this application communicates with only one external API, introducing additional gems would add unnecessary dependencies.

---

## Solid Queue

The assignment requires a background job that runs periodically.

Rails 8 uses Solid Queue as its default Active Job backend, eliminating the need for Redis.

---

## Solid Cache

Solid Cache provides Rails caching without requiring Redis or Memcached.

It integrates seamlessly with Rails and is sufficient for this application.

---

# Project Structure

```
app
├── controllers
│   ├── application_controller.rb
│   └── prices_controller.rb
│
├── jobs
│   └── fetch_crypto_price_job.rb
│
├── models
│   └── crypto_price.rb
│
├── serializers
│   └── crypto_price_serializer.rb
│
├── services
│   ├── coin_gecko_client.rb
│   ├── price_lookup_service.rb
│   └── refresh_crypto_price_service.rb
│
config

db

test
├── controllers
├── fixtures
├── jobs
├── models
├── serializers
└── services
```

---

# Application Flow

## Background Job Flow

```
                Every Minute
                     │
                     ▼
       FetchCryptoPriceJob
                     │
                     ▼
  RefreshCryptoPriceService
                     │
                     ▼
       CoinGeckoClient
                     │
                     ▼
     CoinGecko Public API
                     │
                     ▼
         Update Database
                     │
                     ▼
          Refresh Cache
```

---

## API Request Flow

```
GET /prices/bitcoin
          │
          ▼
  PricesController
          │
          ▼
 PriceLookupService
          │
          ▼
      Rails Cache
          │
     Cache Miss?
          │
          ▼
      SQLite Database
          │
          ▼
CryptoPriceSerializer
          │
          ▼
     JSON Response
```

---

# Steps Taken to Complete the Assignment

The following approach was used to implement the solution while keeping the application simple, maintainable, and aligned with Rails best practices.

---

### 1. Created the `CryptoPrice` model

A dedicated model stores the latest known cryptocurrency price. Persisting data locally ensures that the application can continue serving previously fetched prices even when the external API is unavailable.

---

### 2. Added model validations and callbacks

Validations help maintain data integrity by preventing invalid records from being stored. Normalizing the cryptocurrency symbol before validation ensures consistent storage and simplifies lookups.

---

### 3. Created a dedicated `CoinGeckoClient`

External API communication was isolated into its own class following the Single Responsibility Principle. This keeps HTTP request logic separate from business logic and makes the client easier to test independently.

---

### 4. Used Ruby's built-in `Net::HTTP`

Since the application only communicates with a single external API, Ruby's standard library is sufficient. This avoids introducing additional dependencies while keeping the implementation straightforward.

---

### 5. Created `RefreshCryptoPriceService`

This service is responsible for refreshing cryptocurrency prices. Separating this logic from controllers and jobs keeps business rules centralized, reusable, and easier to maintain.

Responsibilities include:

- Fetching the latest price.
- Updating the database.
- Refreshing the cache.
- Handling external API failures gracefully.

---

### 6. Created `PriceLookupService`

Reading data is a different responsibility from updating data.

This service retrieves cryptocurrency prices from the cache and falls back to the database when necessary, keeping the controller clean and focused only on handling HTTP requests.

---

### 7. Introduced Rails caching

Caching reduces unnecessary database reads and improves response times for frequently requested cryptocurrency prices.

The cache is refreshed only after a successful API update, ensuring users receive the latest available data while minimizing database access.

---

### 8. Added `FetchCryptoPriceJob`

The assignment requires cryptocurrency prices to be refreshed periodically.

The background job simply delegates work to the refresh service, keeping the job lightweight and avoiding business logic inside background workers.

---

### 9. Used Serializer

Serialization is kept separate from controllers and services to improve code organization and maintain a consistent JSON response structure.

---

### 10. Implemented graceful failure handling

One of the core requirements is to continue serving the last known price when the external API is unavailable.

If the API request fails:

- Existing database records remain unchanged.
- Existing cached data is preserved.
- Users continue receiving the last successfully stored price.

This ensures the API remains functional even during temporary outages.

---

### 11. Wrote unit tests using Minitest

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

### 12. Kept controllers intentionally thin

Controllers should primarily coordinate requests and responses.

Business logic is delegated to services, making controllers easier to understand, maintain, and test.

---

### 13. Followed SOLID principles without over-engineering

The solution aims to balance clean architecture with simplicity.

Instead of introducing unnecessary abstractions or design patterns, only the components required to satisfy the assignment were implemented. This keeps the codebase easy to read, maintain, and extend while remaining appropriate for the project's size.

---

# Running the Application

## 1. Install Dependencies

```bash
bundle install
```

---

## 2. Create and Migrate the Database

```bash
bin/rails db:create
bin/rails db:migrate
```

---

## 3. Create a file inside config folder named master.key and add your key in that file locally

```bash
touch config/master.key
```
---

## 4. Start the Rails Server

```bash
bin/rails server
```

The API will be available at:

```
http://localhost:3000
```

---

## 5. Start the Solid Queue Worker

Open a second terminal and run:

```bash
bin/jobs
```

This process executes background jobs asynchronously.

---

## 6. Enqueue a Job

From another terminal:

```bash
bin/rails console
```

```ruby
FetchCryptoPriceJob.perform_later("bitcoin")
```

---

## 7. Test the API

```http
GET /prices/bitcoin
```

Example:

```bash
curl http://localhost:3000/prices/bitcoin
```

---

## 7. Run the Test Suite

```bash
bin/rails test
```

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
