# Data Model Specification: Custom Transcript Generator

**Document Type:** Data Model Spec  
**Includes:** Entity definitions, relationships, constraints, indices, lifecycle notes  
**Note:** Generic and safe for public sharing.

---

## 1. Entity Overview (Domain Map)

**Primary entities**
- Student
- TranscriptType
- TranscriptRequest
- TranscriptDocument

**Operational entities**
- EmailTemplate
- EmailLog
- BatchRun
- BatchRunItem

**Optional entities (recommended for scaling)**
- StaffUser / StaffRole
- AuditEvent
- ErrorCatalog (normalized error codes)

---

## 2. Entities (Definitions)

### 2.1 Student
**Purpose:** Minimal student reference for requests/logging  
**Key fields**
- ExternalStudentRef (unique, required)
- Email (optional)
- DisplayName (optional)

**Notes**
- Do not store sensitive academic data here.

---

### 2.2 TranscriptType
**Purpose:** Represents transcript formats (Standard, FormatA, etc.)  
**Key fields**
- TypeName
- RenderingProfile (json/text pointer)
- IsActive

---

### 2.3 TranscriptRequest
**Purpose:** Tracks each attempt to preview/generate/email a transcript  
**Key fields**
- StudentId
- TranscriptTypeId
- RequestedBy (staff ref)
- Status (Previewed/Generated/Emailed/Failed)
- RequestedAt

**Notes**
- Keep request immutable-ish; update status and timestamps only.

---

### 2.4 TranscriptDocument
**Purpose:** Tracks generated PDF metadata  
**Key fields**
- RequestId
- StorageRef (not a raw internal URL in public examples)
- FileName
- CreatedAt
- HashChecksum (optional)

---

### 2.5 EmailTemplate
**Purpose:** Reusable templates for transcript emails  
**Key fields**
- TemplateName
- SubjectTemplate
- BodyTemplate
- IsActive

---

### 2.6 EmailLog
**Purpose:** Audit trail of email deliveries  
**Key fields**
- RequestId
- TemplateId (nullable)
- RecipientEmail
- SendStatus (Sent/Failed)
- ErrorCode (nullable)
- SentAt

---

### 2.7 BatchRun
**Purpose:** A batch job (course/section/cohort scope)  
**Key fields**
- ScopeType (Course/Section/Cohort/CustomQuery)
- ScopeRef (string)
- TranscriptTypeId
- StartedAt/EndedAt
- Summary counts

---

### 2.8 BatchRunItem
**Purpose:** Per-student outcome inside a batch  
**Key fields**
- BatchRunId
- StudentId
- RequestId (nullable)
- ResultStatus (Success/Failed/Skipped)
- ErrorCode (nullable)

---

## 3. Relationships

- Student 1..N TranscriptRequest
- TranscriptRequest 0..1 TranscriptDocument
- TranscriptRequest 0..N EmailLog
- EmailTemplate 0..N EmailLog
- BatchRun 1..N BatchRunItem
- BatchRunItem N..1 Student
- BatchRunItem 0..1 TranscriptRequest

---

## 4. Constraints & Indexing Recommendations

### Constraints
- `Student.ExternalStudentRef` must be unique
- `TranscriptDocument.RequestId` should be unique (one PDF per request) unless you support multiple versions

### Indexes
- TranscriptRequest(StudentId, RequestedAt DESC)
- EmailLog(RequestId, SentAt DESC)
- BatchRunItem(BatchRunId, ResultStatus)
- Student(ExternalStudentRef)

---

## 5. Data Retention (generic guidance)

- Transcript PDFs: retention policy depends on organization, but treat as sensitive documents
- Email logs: keep minimal metadata (status, timestamps), avoid storing full body if possible
- Requests/batch logs: keep for operational auditing; archive older records if needed
