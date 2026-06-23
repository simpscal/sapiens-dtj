# Issue: TDD

## OUTPUT FORMAT

````markdown
Part of #<requirement_issue_number>

---

# Sprint N — Technical Design Document

## 1. Executive Summary

### Problem Statement
<gap/pain, why now>

### Goals
- <user gain>

---

## 2. Architectural Design

### High-Level Diagram
<ASCII: services, databases, caches, third-party>

### Integration Flows

#### Happy Path
<ASCII sequence diagram — success path>

#### Unhappy Path
<ASCII sequence: failure scenario, system response>

### Technology Stack
<New languages/frameworks/libraries/infrastructure>

### Components Design

#### Backend
<ASCII box-and-arrow diagram: actors tagged [NEW]/[MODIFIED]/existing, with design-decision notes>

#### Frontend
<ASCII box-and-arrow diagram: actors tagged [NEW]/[MODIFIED]/existing, with design-decision notes>

### Infrastructure Design
<Cloud provider resources, networking, deployment topology — ASCII or N/A>

---

## 3. Data & Interface Contracts

### Data Models
<ERD or JSON schema, include indexes>

### API Specification
| Method | Route | Auth | Request Body | Response | Status Codes |

### Event Schemas
<Topic, event structure, producer, consumer, or N/A>

---

## 4. Risk & Trade-offs

### Security
<Auth, authz, encryption>

### Scalability & Performance
<Throughput, latency targets, scaling strategy>

### Failure Modes
| Scenario | Impact | Mitigation |

---

## 5. Migration Plan

<Data migration, cutover, rollback. If migrations — per migration in apply order:>

**<migration name>** `[NEW|MODIFIED]`

_Up (cutover):_
```sql
<cutover DDL>
```

_Down (rollback):_
```sql
<rollback DDL>
```

<If none: `N/A — no data migration required`>

### Monitoring & Alerting
<Metrics, thresholds>

````

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `requirement_issue` | yes | e.g. `#38` |
| `sprint` | yes | e.g. `Sprint 5` |
| `problem_statement` | yes | gap/pain, why now |
| `goals` | yes | 2-6 user-centric items |
| `high_level_diagram` | yes | ASCII diagram — label new vs existing |
| `happy_path` | yes | ASCII sequence diagram — success path |
| `unhappy_path` | yes | ASCII sequence diagram — failure path |
| `tech_stack` | yes | New tech only, or `No new technologies — uses existing stack` |
| `components_design` | yes | **Backend** and **Frontend** sections — each an ASCII box-and-arrow diagram with actors tagged [NEW]/[MODIFIED]/existing, plus design-decision notes |
| `infrastructure_design` | yes | Cloud provider resources, networking, deployment topology — ASCII or `N/A` |
| `data_models` | yes | ERD/schema with indexes, or `No new data models — uses existing schema` |
| `api_spec` | yes | Table: Method, Route, Auth, Request, Response, Status Codes |
| `event_schemas` | yes | Table or `N/A` |
| `security` | yes | Auth, authz, encryption at rest and in transit |
| `scalability` | yes | Throughput/latency targets, scaling approach |
| `failure_modes` | yes | Table: Scenario, Impact, Mitigation — min 2 rows |
| `migration` | yes | Per migration in apply order: fenced ```sql Up (cutover) + Down (rollback) DDL. Or `N/A — no data migration required` |
| `monitoring` | yes | Key metrics, alert thresholds |
