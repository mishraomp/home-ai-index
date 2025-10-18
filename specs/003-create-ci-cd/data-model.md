# Data Model: CI/CD Pipeline

**Date**: 2025-10-17  
**Feature**: CI/CD Pipeline Implementation  
**Phase**: 1 - Design & Contracts

## Overview

This document defines the data structures and state models for the CI/CD pipeline. While CI/CD infrastructure doesn't have traditional "entities" like application code, it has well-defined data structures for configuration, artifacts, and state management.

## Core Entities

### 1. Workflow Configuration

**Purpose**: Defines CI/CD workflow behavior and triggers

**Structure**:
```yaml
name: String               # Workflow name (e.g., "CI Pipeline")
on: TriggerConfig          # Trigger conditions
jobs: Map<String, Job>     # Named jobs to execute
env: Map<String, String>   # Environment variables
```

**Attributes**:
- `name`: Human-readable workflow identifier
- `on`: Trigger configuration (push, pull_request, workflow_dispatch, tags)
- `jobs`: Collection of jobs with dependencies
- `env`: Global environment variables shared across jobs

**Validation Rules**:
- Name must be unique within repository
- At least one trigger must be defined
- At least one job must be defined
- Job names must be valid YAML keys

**State Transitions**:
```
[Defined] -> [Triggered] -> [Queued] -> [Running] -> [Completed]
                                                  -> [Failed]
                                                  -> [Cancelled]
```

---

### 2. Job

**Purpose**: Represents a single execution unit within a workflow

**Structure**:
```yaml
name: String                    # Job display name
runs-on: String                 # Runner type (ubuntu-latest, macos-latest)
needs: List<String>             # Job dependencies
strategy: Strategy              # Matrix/parallel execution config
steps: List<Step>               # Sequential steps to execute
timeout-minutes: Integer        # Job timeout (default: 360)
if: String                      # Conditional execution expression
env: Map<String, String>        # Job-specific environment variables
```

**Attributes**:
- `name`: Human-readable job identifier
- `runs-on`: GitHub-hosted runner or self-hosted label
- `needs`: Array of job names that must complete before this job runs
- `strategy`: Matrix configuration for parallel execution
- `steps`: Ordered list of actions/commands to execute
- `timeout-minutes`: Maximum execution time before cancellation
- `if`: Boolean expression for conditional execution
- `env`: Job-scoped environment variables

**Validation Rules**:
- `runs-on` must reference valid runner
- `needs` references must exist in same workflow
- `timeout-minutes` must be between 1 and 360
- Steps array must not be empty

**Relationships**:
- Belongs to one Workflow
- Contains multiple Steps
- May depend on other Jobs (via `needs`)

---

### 3. Step

**Purpose**: Represents a single action or command within a job

**Structure**:
```yaml
name: String                    # Step display name
uses: String                    # Action reference (e.g., actions/checkout@v4)
with: Map<String, String>       # Action input parameters
run: String                     # Shell command to execute
env: Map<String, String>        # Step-specific environment variables
continue-on-error: Boolean      # Allow step failure without failing job
timeout-minutes: Integer        # Step timeout
if: String                      # Conditional execution expression
```

**Attributes**:
- `name`: Human-readable step identifier
- `uses`: GitHub Action reference (owner/repo@version) - mutually exclusive with `run`
- `with`: Input parameters for actions
- `run`: Shell command to execute - mutually exclusive with `uses`
- `env`: Step-scoped environment variables
- `continue-on-error`: If true, step failure doesn't fail the job
- `timeout-minutes`: Maximum execution time for this step
- `if`: Boolean expression for conditional execution

**Validation Rules**:
- Must specify either `uses` OR `run`, not both
- Action references must use valid format (owner/repo@ref)
- `timeout-minutes` must be less than job timeout

**Relationships**:
- Belongs to one Job
- Executes sequentially within job

---

### 4. Artifact

**Purpose**: Stores build outputs, test reports, and coverage data

**Structure**:
```yaml
name: String                    # Artifact identifier
path: String                    # File/directory path to upload
retention-days: Integer         # How long to retain artifact (1-90)
if-no-files-found: String       # Behavior when path matches no files (warn, error, ignore)
```

**Attributes**:
- `name`: Unique identifier for artifact within workflow run
- `path`: Glob pattern or specific path to files/directories
- `retention-days`: Storage duration (default: 90 days)
- `if-no-files-found`: Error handling strategy

**Validation Rules**:
- Name must be unique within workflow run
- Path must be valid glob pattern or file path
- Retention days must be between 1 and 90
- Artifact size must be under 10 GB (GitHub limit)

**State Transitions**:
```
[Created] -> [Uploading] -> [Available] -> [Expired]
                        -> [Failed]
```

**Metadata**:
- Upload timestamp
- Size in bytes
- Workflow run ID
- Job ID
- Uploader (GitHub actor)

---

### 5. Secret

**Purpose**: Stores sensitive credentials and configuration

**Structure** (Logical - not exposed in YAML):
```
name: String                    # Secret name (e.g., ANDROID_KEYSTORE_BASE64)
value: String                   # Encrypted secret value
scope: Enum                     # Repository, Environment, or Organization
created_at: DateTime            # Creation timestamp
updated_at: DateTime            # Last update timestamp
```

**Attributes**:
- `name`: Uppercase identifier with underscores (e.g., `API_KEY`)
- `value`: Encrypted and never exposed in logs
- `scope`: Access scope (repository-wide, environment-specific, org-level)
- `created_at`: When secret was created
- `updated_at`: Last modification time

**Validation Rules**:
- Name must match pattern: `^[A-Z_][A-Z0-9_]*$`
- Value is encrypted at rest
- Cannot be read via API (write-only)
- Automatically masked in logs

**Access Control**:
- Repository secrets: Available to all workflows
- Environment secrets: Available only to jobs with environment specified
- Organization secrets: Available to selected repositories

**Security Considerations**:
- Rotate quarterly (documented procedure)
- Use environment secrets for production credentials
- Limit permissions to minimum required
- Monitor access via audit logs

---

### 6. Build Metadata

**Purpose**: Tracks build version and metadata

**Structure**:
```yaml
version: String                 # Semantic version (e.g., 1.0.0)
build_number: Integer           # Auto-incremented build number
git_sha: String                 # Commit SHA that triggered build
git_ref: String                 # Branch or tag reference
build_date: DateTime            # When build was created
runner: String                  # Runner type (ubuntu-latest, macos-latest)
flutter_version: String         # Flutter SDK version used
```

**Attributes**:
- `version`: Semantic version from pubspec.yaml
- `build_number`: Unique integer per build (derived from Git commit count or timestamp)
- `git_sha`: Full commit SHA (40 characters)
- `git_ref`: Branch name or tag (e.g., `refs/heads/main`, `refs/tags/v1.0.0`)
- `build_date`: ISO 8601 timestamp
- `runner`: GitHub runner identifier
- `flutter_version`: Flutter SDK version (e.g., 3.35.6)

**Generation**:
```bash
# Extract from Git
BUILD_NUMBER=$(git rev-list --count HEAD)
GIT_SHA=$(git rev-parse HEAD)
GIT_REF=${GITHUB_REF}

# Extract from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)

# Current timestamp
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Flutter version
FLUTTER_VERSION=$(flutter --version | head -n1 | awk '{print $2}')
```

**Storage**: Embedded in build artifacts, logged in workflow output, optionally stored in artifact metadata

---

### 7. Coverage Report

**Purpose**: Stores code coverage metrics

**Structure** (lcov format):
```
source_file: String             # Source file path
lines_found: Integer            # Total executable lines
lines_hit: Integer              # Lines executed by tests
functions_found: Integer        # Total functions
functions_hit: Integer          # Functions executed by tests
branches_found: Integer         # Total branches
branches_hit: Integer           # Branches executed by tests
line_coverage: Float            # Percentage (0-100)
function_coverage: Float        # Percentage (0-100)
branch_coverage: Float          # Percentage (0-100)
```

**Attributes**:
- `source_file`: Relative path from repository root
- Coverage counts per category (lines, functions, branches)
- Percentage calculations

**Validation Rules**:
- Line coverage must be ≥80% to pass quality gate
- All metrics must be non-negative
- Percentages must be between 0 and 100

**Aggregation**:
```bash
# Total coverage calculation
lcov --summary coverage/lcov.info
```

**Output Formats**:
- `lcov.info`: Machine-readable coverage data
- HTML report: Human-readable visualization
- Badge: Shields.io badge for README

---

## State Management

### Workflow Execution State

**States**:
1. **Queued**: Workflow triggered, waiting for runner
2. **In Progress**: At least one job is running
3. **Completed**: All jobs finished successfully
4. **Failed**: At least one required job failed
5. **Cancelled**: Manually cancelled by user

**Transitions**:
```
[Triggered] -> [Queued] -> [In Progress] -> [Completed]
                                        -> [Failed]
                                        -> [Cancelled]
```

**Persistence**: GitHub stores workflow run history for 90 days

---

### Job Execution State

**States**:
1. **Queued**: Waiting for dependencies and runner
2. **Running**: Executing steps
3. **Success**: All steps completed successfully
4. **Failure**: At least one step failed
5. **Cancelled**: Job cancelled before completion
6. **Skipped**: Conditional execution prevented running

**Transitions**:
```
[Queued] -> [Running] -> [Success]
                     -> [Failure]
                     -> [Cancelled]
         -> [Skipped] (if condition not met)
```

---

### Artifact Lifecycle

**States**:
1. **Creating**: Being uploaded
2. **Available**: Stored and downloadable
3. **Expired**: Retention period exceeded

**Retention Policy**:
- Feature branch artifacts: 7 days
- Main branch artifacts: 30 days
- Release artifacts: 90 days

**Cleanup**: Automatic deletion after retention period

---

## Environment Variables

### Global Environment Variables

**Purpose**: Shared configuration across all workflows

```yaml
env:
  FLUTTER_VERSION: '3.35.6'
  JAVA_VERSION: '17'
  RUBY_VERSION: '3.1'
  NODE_VERSION: '18'
```

---

### Secret-Based Environment Variables

**Purpose**: Inject secrets into workflow execution

**Android**:
```yaml
env:
  ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
  ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
  ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
```

**iOS**:
```yaml
env:
  IOS_CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
  APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
  APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
```

---

## File Formats

### 1. Workflow YAML Schema

**Format**: YAML (GitHub Actions workflow syntax)
**Location**: `.github/workflows/*.yml`
**Validation**: GitHub validates on push
**Documentation**: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions

---

### 2. Coverage Report (lcov)

**Format**: lcov text format
**Location**: `coverage/lcov.info`
**Generation**: `flutter test --coverage`
**Parsing**: `lcov` command-line tool

---

### 3. Build Artifacts

**Android**:
- `app-debug.apk`: Debug APK
- `app-release.apk`: Signed release APK
- `app-release.aab`: Signed release App Bundle

**iOS**:
- `Runner.app`: Debug iOS app
- `Runner.ipa`: Signed release IPA

**Metadata**:
- `build-info.json`: Build metadata in JSON format

---

## Validation Rules Summary

### Workflow Level
- ✅ At least one trigger defined
- ✅ At least one job defined
- ✅ All job dependencies exist
- ✅ No circular dependencies

### Job Level
- ✅ Valid runner specified
- ✅ Timeout within limits (1-360 minutes)
- ✅ At least one step defined
- ✅ Matrix variables properly defined

### Artifact Level
- ✅ Unique name per workflow run
- ✅ Valid path pattern
- ✅ Retention within limits (1-90 days)
- ✅ Size under 10 GB

### Coverage Level
- ✅ Minimum 80% line coverage
- ✅ All percentages between 0-100
- ✅ Valid lcov format

---

## Relationships Diagram

```
Workflow (1) ──┬──> (N) Jobs
               │
               └──> TriggerConfig (1)

Job (1) ────────┬──> (N) Steps
                │
                ├──> Strategy (0..1)
                │
                └──> Dependencies (N) Jobs

Step (1) ───────┬──> Action (0..1)
                │
                └──> Command (0..1)

Job ────────────> (N) Artifacts (upload)

Workflow Run ───> (N) Artifacts (storage)

Secret (N) <────── Jobs (reference)
```

---

## Conclusion

This data model provides a comprehensive structure for the CI/CD pipeline, defining all entities, their attributes, validation rules, and relationships. The model ensures consistency, enables validation, and provides clear contracts for workflow implementation.

**Next Steps**: Create API contracts defining workflow interfaces and script specifications in the `contracts/` directory.
