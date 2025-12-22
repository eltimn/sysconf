---
name: testing-strategy
description: Guidelines for writing effective tests in this project
---

# Testing Guidelines

## Unit Tests
- Test one thing per test
- Use descriptive test names: `test_user_creation_fails_with_invalid_email`
- Mock external dependencies

## Integration Tests
- Test API endpoints with realistic data
- Verify database state changes
- Clean up test data after each test

## Running Tests
- `npm test` — Run all tests
- `npm test:unit` — Unit tests only
- `npm test:integration` — Integration tests (requires database)
