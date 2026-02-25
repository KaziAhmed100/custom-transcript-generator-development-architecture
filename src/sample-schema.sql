/*
  Transcript Generator — Generic Sample Schema (Sanitized)
  Intentionally generic. Does not mirror any production identifiers.
*/

CREATE TABLE Students (
  StudentId            INT IDENTITY(1,1) PRIMARY KEY,
  ExternalStudentRef   NVARCHAR(100) NOT NULL,   -- sanitized “student number”
  FirstName            NVARCHAR(100) NULL,
  LastName             NVARCHAR(100) NULL,
  Email                NVARCHAR(255) NULL,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE TranscriptTypes (
  TranscriptTypeId     INT IDENTITY(1,1) PRIMARY KEY,
  TypeName             NVARCHAR(100) NOT NULL,   -- e.g., Standard, FormatA, FormatB
  Description          NVARCHAR(500) NULL
);

CREATE TABLE TranscriptRequests (
  RequestId            INT IDENTITY(1,1) PRIMARY KEY,
  StudentId            INT NOT NULL,
  TranscriptTypeId     INT NOT NULL,
  RequestedBy          NVARCHAR(255) NULL,       -- staff identifier (generic)
  RequestedAt          DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  Status               NVARCHAR(50) NOT NULL DEFAULT 'Previewed', -- Previewed/Generated/Emailed/Failed
  Notes                NVARCHAR(MAX) NULL,
  CONSTRAINT FK_TR_Students FOREIGN KEY (StudentId) REFERENCES Students(StudentId),
  CONSTRAINT FK_TR_Types FOREIGN KEY (TranscriptTypeId) REFERENCES TranscriptTypes(TranscriptTypeId)
);

CREATE TABLE TranscriptDocuments (
  DocumentId           INT IDENTITY(1,1) PRIMARY KEY,
  RequestId            INT NOT NULL,
  FileName             NVARCHAR(255) NOT NULL,
  StorageRef           NVARCHAR(500) NOT NULL,   -- sanitized pointer (not a real URL)
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Doc_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId)
);

CREATE TABLE EmailTemplates (
  TemplateId           INT IDENTITY(1,1) PRIMARY KEY,
  TemplateName         NVARCHAR(200) NOT NULL,
  SubjectTemplate      NVARCHAR(255) NOT NULL,
  BodyTemplate         NVARCHAR(MAX) NOT NULL,
  IsActive             BIT NOT NULL DEFAULT 1,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE EmailLogs (
  EmailLogId           INT IDENTITY(1,1) PRIMARY KEY,
  RequestId            INT NOT NULL,
  TemplateId           INT NULL,
  RecipientEmail       NVARCHAR(255) NOT NULL,
  SubjectUsed          NVARCHAR(255) NULL,
  SendStatus           NVARCHAR(50) NOT NULL,    -- Sent/Failed
  SentAt               DATETIME2 NULL,
  ErrorMessage         NVARCHAR(1000) NULL,
  IsAutomated          BIT NOT NULL DEFAULT 0,
  CONSTRAINT FK_Email_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId),
  CONSTRAINT FK_Email_Template FOREIGN KEY (TemplateId) REFERENCES EmailTemplates(TemplateId)
);

CREATE TABLE BatchRuns (
  BatchRunId           INT IDENTITY(1,1) PRIMARY KEY,
  CourseRef            NVARCHAR(100) NOT NULL,   -- sanitized course identifier
  SectionRef           NVARCHAR(100) NULL,
  TranscriptTypeId     INT NOT NULL,
  StartedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  EndedAt              DATETIME2 NULL,
  RequestedBy          NVARCHAR(255) NULL,
  TotalCount           INT NOT NULL DEFAULT 0,
  SuccessCount         INT NOT NULL DEFAULT 0,
  FailureCount         INT NOT NULL DEFAULT 0,
  CONSTRAINT FK_Batch_Type FOREIGN KEY (TranscriptTypeId) REFERENCES TranscriptTypes(TranscriptTypeId)
);

CREATE TABLE BatchRunItems (
  BatchRunItemId       INT IDENTITY(1,1) PRIMARY KEY,
  BatchRunId           INT NOT NULL,
  StudentId            INT NOT NULL,
  RequestId            INT NULL,
  ResultStatus         NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending/Success/Failed/Skipped
  ErrorMessage         NVARCHAR(1000) NULL,
  CONSTRAINT FK_BRI_Batch FOREIGN KEY (BatchRunId) REFERENCES BatchRuns(BatchRunId),
  CONSTRAINT FK_BRI_Student FOREIGN KEY (StudentId) REFERENCES Students(StudentId),
  CONSTRAINT FK_BRI_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId)
);
