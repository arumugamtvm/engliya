# Requirements Document

## Introduction

This document specifies the requirements for refactoring the Engliya Flutter application to follow proper Clean Architecture principles. The current codebase has significant code duplication with phase-specific services (phase1_final_test_service, phase2_final_test_service, etc.), providers, screens, and models. This refactoring will consolidate these into generic, reusable components that handle all phases through configuration rather than duplication.

## Glossary

- **Clean Architecture**: A software design pattern that separates concerns into layers (domain, data, presentation) with clear dependency rules
- **Phase**: A learning stage in the app (Phase 1-5), each containing units and lessons
- **Unit**: A collection of lessons within a phase
- **Final Test**: An assessment at the end of each phase
- **Repository**: A class that abstracts data access and provides a clean API for the domain layer
- **Use Case**: A single business operation that encapsulates application-specific business rules
- **Entity**: Core business objects that are independent of any framework
- **Provider**: State management class using Riverpod for Flutter UI state

## Requirements

### Requirement 1: Domain Layer Structure

**User Story:** As a developer, I want a clear domain layer with entities and use cases, so that business logic is separated from framework-specific code.

#### Acceptance Criteria

1. WHEN the domain layer is accessed THEN the System SHALL provide entity classes for Lesson, Unit, Phase, TestQuestion, and TestResult that are framework-independent
2. WHEN business operations are performed THEN the System SHALL execute them through use case classes that encapsulate single responsibilities
3. WHEN use cases require data THEN the System SHALL access it through repository interfaces defined in the domain layer

### Requirement 2: Unified Phase Service

**User Story:** As a developer, I want a single configurable service to handle all phases, so that I can eliminate duplicate phase-specific service files.

#### Acceptance Criteria

1. WHEN a final test service is needed for any phase THEN the System SHALL provide a single FinalTestService class that accepts phase configuration
2. WHEN loading test questions THEN the System SHALL use the phase parameter to determine the correct data source
3. WHEN calculating test results THEN the System SHALL apply phase-specific scoring rules through configuration rather than separate implementations
4. WHEN a new phase is added THEN the System SHALL require only configuration changes without new service classes

### Requirement 3: Unified Data Models

**User Story:** As a developer, I want generic data models that work across all phases, so that I can eliminate duplicate phase-specific model files.

#### Acceptance Criteria

1. WHEN representing a test question THEN the System SHALL use a single TestQuestion model with a phase identifier field
2. WHEN representing test results THEN the System SHALL use a single TestResult model that accommodates all phase-specific data
3. WHEN representing units THEN the System SHALL use a single Unit model with phase-specific configuration
4. WHEN serializing models to JSON THEN the System SHALL produce consistent output regardless of phase
5. WHEN deserializing models from JSON THEN the System SHALL reconstruct equivalent objects (round-trip consistency)

### Requirement 4: Unified Providers

**User Story:** As a developer, I want generic providers that handle all phases through parameters, so that I can eliminate duplicate phase-specific provider files.

#### Acceptance Criteria

1. WHEN managing unit state THEN the System SHALL use a single UnitProvider that accepts phase as a parameter
2. WHEN managing final test state THEN the System SHALL use a single FinalTestProvider that accepts phase as a parameter
3. WHEN providers are instantiated THEN the System SHALL create phase-specific instances through factory methods or family providers

### Requirement 5: Consolidated Screen Architecture

**User Story:** As a developer, I want reusable screen components that adapt to different phases, so that I can eliminate duplicate phase-specific screen files.

#### Acceptance Criteria

1. WHEN displaying a unit screen THEN the System SHALL use a single UnitScreen widget that accepts phase configuration
2. WHEN displaying a final test screen THEN the System SHALL use a single FinalTestScreen widget that renders phase-appropriate content
3. WHEN displaying test results THEN the System SHALL use a single TestResultScreen widget that formats results based on phase
4. WHEN displaying test review THEN the System SHALL use a single TestReviewScreen widget that shows phase-appropriate review content
5. WHEN navigating between screens THEN the System SHALL pass phase context through route parameters

### Requirement 6: Repository Pattern Implementation

**User Story:** As a developer, I want proper repository abstractions, so that data access is decoupled from business logic.

#### Acceptance Criteria

1. WHEN accessing lesson data THEN the System SHALL use repository interfaces that hide implementation details
2. WHEN accessing test data THEN the System SHALL use a single TestRepository that handles all phases
3. WHEN accessing progress data THEN the System SHALL use a single ProgressRepository with phase-aware methods
4. WHEN repositories are implemented THEN the System SHALL place implementations in the data layer separate from interfaces

### Requirement 7: Folder Structure Organization

**User Story:** As a developer, I want a clear folder structure following clean architecture conventions, so that code is easy to navigate and maintain.

#### Acceptance Criteria

1. WHEN organizing the learn feature THEN the System SHALL structure folders as: domain/ (entities, repositories, use_cases), data/ (models, repositories_impl, datasources), presentation/ (screens, providers, widgets)
2. WHEN placing entity classes THEN the System SHALL locate them in domain/entities/
3. WHEN placing repository interfaces THEN the System SHALL locate them in domain/repositories/
4. WHEN placing repository implementations THEN the System SHALL locate them in data/repositories/
5. WHEN placing screen widgets THEN the System SHALL organize them by function (unit/, test/, lesson/) rather than by phase

### Requirement 8: Phase Configuration System

**User Story:** As a developer, I want a centralized phase configuration system, so that phase-specific behavior is defined in one place.

#### Acceptance Criteria

1. WHEN phase-specific data is needed THEN the System SHALL retrieve it from a PhaseConfig class
2. WHEN phase configuration includes asset paths THEN the System SHALL provide correct paths for each phase's lesson data
3. WHEN phase configuration includes test parameters THEN the System SHALL provide passing scores, question counts, and time limits per phase
4. WHEN adding a new phase THEN the System SHALL require only adding a new PhaseConfig entry
