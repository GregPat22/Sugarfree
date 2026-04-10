# Sugarfree Innovation Spec (Phase 1)

## Signature Loop

Sugarfree's signature differentiator is the **Smart Swap Loop**:

1. User scans a product.
2. Sugarfree predicts same-day budget impact and streak risk.
3. Sugarfree proposes lower-sugar alternatives in context.
4. User logs either original product or a swap.
5. Dashboard reflects conversion, swap adoption, and streak recovery.

This loop turns Sugarfree from passive logging into in-the-moment decision coaching.

## Implemented Features

### Predictive Sugar Budget
- Pre-log budget impact and risk state in scanner results.
- Manual entry shows "After save" budget impact before commit.

### Streak Insurance
- Goal model stores insurance credits and usage count.
- Users can refresh earned credits (1 credit per 10 streak days) and spend a credit to protect progress.

### Smart Swap Engine
- Rule-based suggestions generated from product/category context.
- Suggestions show estimated sugar grams and can be logged with one tap.

### Metrics Taxonomy
- Persisted events:
  - `scan_found`
  - `scan_not_found`
  - `swap_shown`
  - `swap_tapped`
  - `entry_saved`
  - `rescue_started`
  - `insurance_used`
- Dashboard shows 7-day:
  - Scan-to-log conversion
  - Swap adoption
  - Active-day retention proxy
  - Streak recovery rate
  - Average daily sugar

## Data Model Deltas

### `FoodEntry`
- `swapRecommendationUsed: Bool`
- `predictedRemainingAfterEntry: Double?`
- `riskAtLogTime: String?`

### `SugarGoal`
- `streakInsuranceCredits: Int`
- `streakInsuranceUses: Int`

### `DailyLog`
- `forecastRemainingGrams: Double`
- `riskLevel: String`
- `usedRescueMode: Bool`
- `usedInsurance: Bool`

### `FeatureEvent` (new)
- `name: String`
- `metadata: String?`
- `timestamp: Date`

## Notes
- The Smart Swap engine is deterministic and local-first.
- Future versions can replace suggestion heuristics with personalized ranking.
