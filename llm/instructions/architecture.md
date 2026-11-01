# MICROSERVICE ARCHITECTURE STANDARDS AND OPERATING PROCEDURES

**Document Status:** Active
**Target Audience:** Engineering Leads, Architects, and Developers

## 1. EXECUTIVE SUMMARY AND PHILOSOPHY

The objective of this architecture is to scale development teams, deliver high-quality software, and support future features without incurring technical debt that paralyzes velocity. We prioritize long-term maintainability over near-term shortcuts.

### 1.1 Core Principles

- **Automation over Manual Process:** If a task is performed more than once, it must be scripted or automated.
- **Isolation:** Services must share nothing but defined interfaces (APIs and Events).
- **Consistency:** The entire platform should feel as though it was written by a single developer, regardless of the team size.
- **Standardization over Choice:** We restrict the number of programming languages and frameworks to maximize tooling investment. Polyglot programming is discouraged as it fragments tooling and slows velocity.

---

## 2. API DESIGN AND SPECIFICATION

The API specification is the absolute source of truth for the platform. No code shall be written until the interface is defined and approved.

### 2.1 The API-First Workflow

1.  **External Definition:** APIs must be defined in a language-neutral format (e.g., JSON or YAML) in a dedicated repository. API definitions must never be generated from code annotations.
2.  **Review Process:** Changes to an API are made via Pull Request to the specification repository. This allows for design review before implementation costs are incurred.
3.  **Automated Linting:** Continuous Integration (CI) must run linters on the API specification to enforce:
    - **Naming Conventions:** Consistent casing (e.g., snake_case vs camelCase) and resource naming.
    - **URL Structure:** Standardized resource paths (e.g., `/users/:id`).
    - **Breaking Changes:** The CI pipeline must fail if a breaking change is detected.

### 2.2 Breaking Changes Policy

Breaking changes to published APIs are strictly prohibited. If a change is required that breaks the contract, a new version of the endpoint or a new resource must be created.

### 2.3 Compliance and Annotations

Use the API specification to handle cross-cutting concerns. For example, fields containing Personally Identifiable Information (PII) must be annotated in the spec (e.g., `annotations: ["personal_data"]`). This allows for programmatic generation of compliance reports (such as GDPR) by scanning the specifications.

---

## 3. CODE GENERATION STRATEGY

To ensure the implementation adheres strictly to the design, we rely on code generation. This is not optional; manual boilerplate writing is prohibited.

### 3.1 Server-Side Generation

The build pipeline must generate the server-side routing and controller interfaces from the API spec. Developers are responsible only for implementing the business logic behind these interfaces. This guarantees that the code matches the spec.

### 3.2 Client Library Generation

Client libraries for all supported languages must be auto-generated. Developers should never write manual HTTP requests to consume internal services.

### 3.3 Mock Client Generation

For every service, a fully functional Mock Client must be generated. This mock must adhere to the API contract and is to be used in integration testing to simulate dependencies without network overhead.

---

## 4. DATA ARCHITECTURE AND ISOLATION

### 4.1 Database Sovereignty

- **Strict Isolation:** Each microservice must own its own database.
- **No Shared Access:** No service is permitted to connect to another service's database. There are no exceptions.
- **Access Pattern:** If Service A requires data from Service B, it must request it via Service B's API or subscribe to Service B's event stream.

### 4.2 Schema Management via Metadata

Database schemas should not be managed via raw SQL scripts written by hand.

- **Metadata Definition:** Define storage requirements (table names, columns, indexes, retention policies) in a metadata format.
- **Generation:** Use tooling to generate the SQL schema creation scripts and the Data Access Objects (DAOs) from this metadata.
- **Optimization:** Ensure the generated code handles common optimizations, such as computing a hash of the record content to prevent unnecessary writes if the data has not changed.

### 4.3 Infrastructure Automation

Database provisioning must be handled via a standardized Command Line Interface (CLI). Developers should not log into consoles to create resources. A command such as `dev rds --app user-service` should provision the database with standard security groups, backups, and naming conventions.

---

## 5. EVENT-DRIVEN ARCHITECTURE

Internal communication between services should primarily be asynchronous to decouple availability and performance.

### 5.1 Event Schema

Events are public interfaces. They must be defined in the API specification repository with the same rigor as REST APIs.

- **Structure:** Events should follow a standard envelope structure (e.g., `event_id`, `timestamp`, `organization_id`, `data`).
- **Ownership:** An event stream is owned by exactly one service.

### 5.2 The Journal Pattern (Producer Guarantee)

To guarantee **At-Least-Once Delivery**, services must never publish directly to the message bus (e.g., Kinesis/Kafka) from the application logic.

1.  **Transaction:** When a record is updated, the service must insert the record _and_ a corresponding "Journal Entry" into a local database table within the same ACID transaction.
2.  **Publisher:** A separate background process polls the Journal table and publishes the events to the message bus.
3.  **Result:** If the database write succeeds, the event is guaranteed to be published eventually.

### 5.3 Consumer Reliability

- **Idempotency:** Consumers must be designed to handle duplicate messages without side effects.
- **Local Buffering:** Consumers should read events from the stream and persist them to a local temporary table before processing. This allows for:
  - Transactionality during processing.
  - Easy debugging and replaying of failed events locally without rewinding the global stream.
- **Error Handling:** Failed events must be logged to a centralized monitoring system.

---

## 6. TESTING STANDARDS

Testing must be high-fidelity and fast. We achieve this by leveraging the generated artifacts.

### 6.1 End-to-End Integration Testing

Tests should verify the full lifecycle of a request using the generated Mock Clients.

- **Scenario:** A test should create a resource via the API, assert that the resource exists, and assert that the corresponding event was published to the mock stream.
- **No Network Dependencies:** These tests should run in-memory or against local containerized databases, avoiding external network calls to other services.

### 6.2 TDD in Production

When a bug is discovered in production:

1.  Write a test case locally that reproduces the bug using the Mock Clients.
2.  Fix the bug in the code.
3.  Verify the test passes.
4.  Deploy.
    This methodology ensures that the test suite constantly evolves to cover edge cases found in the real world.

---

## 7. DEPLOYMENT AND CONTINUOUS DELIVERY

Continuous Delivery is a prerequisite for managing a microservice architecture. Manual releases are prohibited.

### 7.1 The Deployment Pipeline

- **Trigger:** Deployments are triggered automatically by Git tags or merges to the master branch.
- **Automation:** The pipeline must build the Docker image, run all tests, and update the orchestration layer (e.g., ECS/Kubernetes) without human intervention.
- **Policy:** "Green means Go." If the build passes, it goes to production. We do not wait for manual approvals.

### 7.2 Configuration

Service configuration (CPU, Memory, Ports) must be defined in a simple, version-controlled format (e.g., a 6-line YAML file). Complex configuration management systems should be abstracted away from the developer.

### 7.3 Standardized Health Checks

Every service must implement a standard health check endpoint (e.g., `/internal/healthcheck`). The load balancer and deployment orchestrator must use this to determine if a service is ready to receive traffic.

---

## 8. DEPENDENCY MANAGEMENT

Outdated dependencies are a security risk and a source of technical debt.

### 8.1 Automated Updates

We pay the "upgrade tax" continuously rather than in large batches.

- **Tooling:** Implement automation that scans all repositories for outdated libraries on a weekly basis.
- **Auto-PR:** The tooling should generate Pull Requests for these updates.
- **Auto-Merge:** If the comprehensive test suite passes, the system should automatically merge and deploy the update.

---

## 9. OPERATIONAL METRICS

### 9.1 Developer Efficiency

We do not measure developers by the number of services they maintain. We measure the _time_ spent on maintenance.

- **Target:** Maintenance should consume less than 5% of engineering time.
- **Action:** If maintenance time exceeds this threshold, immediate investment in automation and tooling is required.

### 9.2 Latency

While event-driven architectures introduce latency, it must be monitored. The target end-to-end latency for event propagation (Producer -> Stream -> Consumer) should be sub-second (e.g., < 500ms).

---

**Adherence to these instructions is mandatory. Deviations must be approved by the Architecture Review Board.**
