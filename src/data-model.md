# Data Model

This model supports transcript generation, storage, emailing, templates, and batch operations.

## Core Entities

### Student
Represents the person receiving a transcript (stored minimally; often referenced by external identifier).
In the real system, student/course completion data came from an existing grading/records source. 

### CourseCompletion
Represents completed course data used to populate transcripts (usually retrieved from the external system).

### TranscriptRequest
Represents a request to generate a transcript (single student) and stores parameters like transcript type/format.

### TranscriptDocument
Represents the generated PDF document metadata (filename, storage path reference, creation timestamp).

### EmailTemplate
Reusable email templates for sending transcripts.

### EmailLog
Tracks email events (to/from, subject, status, timestamp) without exposing content publicly.

### BatchRun
Represents a batch transcript operation for a course/section.

### BatchRunItem
Tracks per-student batch result (success/failure, error code, etc.).

## Relationships (Conceptual)

- Student 1..n TranscriptRequest
- TranscriptRequest 1..1 TranscriptDocument (when generated)
- TranscriptRequest 0..n EmailLog (if emailed multiple times)
- EmailTemplate 0..n EmailLog (template used)
- BatchRun 1..n BatchRunItem
- BatchRunItem references Student + TranscriptRequest/Document metadata

## Transcript Types (Conceptual)

The system supports multiple transcript formats (e.g., “standard”, “format A”, “format B”) with different rendering rules and preview screens. :contentReference[oaicite:9]{index=9}
