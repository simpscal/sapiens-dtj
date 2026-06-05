# Issue: TDD

## OUTPUT FORMAT

````markdown
Part of #<requirement_issue_number>

---

# Sprint N — Technical Design Document

## 1. Executive Summary

### Problem Statement
<2–3 sentences: gap/pain, why now>

### Goals
- <What user gains>

---

## 2. Architectural Design

### High-Level Diagram
<ASCII: services, databases, caches, third-party>

### Integration Flows

#### Happy Path
<ASCII sequence diagram. Participants must be high-level system modules only: actors (e.g. Customer, Admin) and major system boundaries (e.g. Web, API, Database, External Service). Omit all implementation details — internal libraries, state managers, hooks, query clients, and sub-components must not appear as participants.>

#### Unhappy Path
<ASCII sequence: failure scenario, system response>

### Technology Stack
<New languages/frameworks/libraries/infrastructure>

### Components Design

#### Backend
<New/existing/modified backend components, their responsibilities, and how they interact — ASCII diagram>

#### Frontend
<High-level components only: UI components, hooks, and services (API clients / data-fetching layers). Show responsibilities and interactions via ASCII diagram. No internal states, variables, or fine-grained implementation details.>

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

<Data migration, cutover, rollback>

### Monitoring & Alerting
<Metrics, thresholds>

````

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `requirement_issue` | yes | e.g. `#38` |
| `sprint` | yes | e.g. `Sprint 5` |
| `problem_statement` | yes | 2-3 sentences: gap/pain, why now |
| `goals` | yes | 2-6 user-centric items |
| `high_level_diagram` | yes | ASCII diagram — label new vs existing |
| `happy_path` | yes | ASCII sequence diagram. Participants: high-level system modules only — actors (Customer, Admin) and major system boundaries (Web, API, Database, External Service). No implementation details (hooks, query clients, state managers, sub-components). |
| `unhappy_path` | yes | ASCII sequence: failure scenario + system response |
| `tech_stack` | yes | New tech only, or `No new technologies — uses existing stack` |
| `components_design` | yes | Two sections — **Backend** and **Frontend**. Backend: new/existing/modified components, responsibilities, interactions via ASCII diagram. Frontend: high-level UI components, hooks, and services only — no internal states or fine-grained details — responsibilities and interactions via ASCII diagram. No sequence diagrams in either section. |
| `infrastructure_design` | yes | Cloud provider resources, networking, deployment topology — ASCII or `N/A` |
| `data_models` | yes | ERD/schema with indexes, or `No new data models — uses existing schema` |
| `api_spec` | yes | Table: Method, Route, Auth, Request, Response, Status Codes |
| `event_schemas` | yes | Table or `N/A` |
| `security` | yes | Auth, authz, encryption at rest and in transit |
| `scalability` | yes | Throughput/latency targets, scaling approach |
| `failure_modes` | yes | Table: Scenario, Impact, Mitigation — min 2 rows |
| `migration` | yes | Cutover + rollback, or `N/A — no data migration required` |
| `monitoring` | yes | Key metrics, alert thresholds |
