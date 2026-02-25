/*
  Custom Transcript Generator — Generic Reference Schema
  Vendor-neutral, institution-neutral.
*/

CREATE TABLE Students (
  StudentId            INT IDENTITY(1,1) PRIMARY KEY,
  ExternalStudentRef   NVARCHAR(100) NOT NULL,
  DisplayName          NVARCHAR(200) NULL,
  Email                NVARCHAR(255) NULL,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_Students_ExternalRef UNIQUE (ExternalStudentRef)
);

CREATE TABLE TranscriptTypes (
  TranscriptTypeId     INT IDENTITY(1,1) PRIMARY KEY,
  TypeName             NVARCHAR(100) NOT NULL,
  RenderingProfile     NVARCHAR(MAX) NULL,   -- JSON or pointer to rules profile
  IsActive             BIT NOT NULL DEFAULT 1
);

CREATE TABLE TranscriptRequests (
  RequestId            INT IDENTITY(1,1) PRIMARY KEY,
  StudentId            INT NOT NULL,
  TranscriptTypeId     INT NOT NULL,
  RequestedBy          NVARCHAR(255) NULL,
  Status               NVARCHAR(50) NOT NULL DEFAULT 'Previewed',
  RequestedAt          DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  Notes                NVARCHAR(MAX) NULL,
  CONSTRAINT FK_TR_Student FOREIGN KEY (StudentId) REFERENCES Students(StudentId),
  CONSTRAINT FK_TR_Type FOREIGN KEY (TranscriptTypeId) REFERENCES TranscriptTypes(TranscriptTypeId)
);

CREATE TABLE TranscriptDocuments (
  DocumentId           INT IDENTITY(1,1) PRIMARY KEY,
  RequestId            INT NOT NULL,
  FileName             NVARCHAR(255) NOT NULL,
  StorageRef           NVARCHAR(500) NOT NULL,
  HashChecksum         NVARCHAR(128) NULL,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_TD_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId),
  CONSTRAINT UQ_TD_Request UNIQUE (RequestId)
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
  SendStatus           NVARCHAR(50) NOT NULL,    -- Sent/Failed
  ErrorCode            NVARCHAR(50) NULL,
  ErrorMessage         NVARCHAR(400) NULL,
  SentAt               DATETIME2 NULL,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_EL_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId),
  CONSTRAINT FK_EL_Template FOREIGN KEY (TemplateId) REFERENCES EmailTemplates(TemplateId)
);

CREATE TABLE BatchRuns (
  BatchRunId           INT IDENTITY(1,1) PRIMARY KEY,
  ScopeType            NVARCHAR(50) NOT NULL,    -- Course/Section/Cohort/CustomQuery
  ScopeRef             NVARCHAR(200) NOT NULL,   -- sanitized identifier string
  TranscriptTypeId     INT NOT NULL,
  RequestedBy          NVARCHAR(255) NULL,
  StartedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  EndedAt              DATETIME2 NULL,
  TotalCount           INT NOT NULL DEFAULT 0,
  SuccessCount         INT NOT NULL DEFAULT 0,
  FailureCount         INT NOT NULL DEFAULT 0,
  SkippedCount         INT NOT NULL DEFAULT 0,
  CONSTRAINT FK_BR_Type FOREIGN KEY (TranscriptTypeId) REFERENCES TranscriptTypes(TranscriptTypeId)
);

CREATE TABLE BatchRunItems (
  BatchRunItemId       INT IDENTITY(1,1) PRIMARY KEY,
  BatchRunId           INT NOT NULL,
  StudentId            INT NOT NULL,
  RequestId            INT NULL,
  ResultStatus         NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending/Success/Failed/Skipped
  ErrorCode            NVARCHAR(50) NULL,
  ErrorMessage         NVARCHAR(400) NULL,
  CreatedAt            DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_BRI_Batch FOREIGN KEY (BatchRunId) REFERENCES BatchRuns(BatchRunId),
  CONSTRAINT FK_BRI_Student FOREIGN KEY (StudentId) REFERENCES Students(StudentId),
  CONSTRAINT FK_BRI_Request FOREIGN KEY (RequestId) REFERENCES TranscriptRequests(RequestId)
);

-- Suggested indexes
CREATE INDEX IX_TR_Student_RequestedAt ON TranscriptRequests(StudentId, RequestedAt DESC);
CREATE INDEX IX_EL_Request_SentAt ON EmailLogs(RequestId, SentAt DESC);
CREATE INDEX IX_BRI_Batch_Status ON BatchRunItems(BatchRunId, ResultStatus);
CREATE INDEX IX_Students_ExternalRef ON Students(ExternalStudentRef);
