---
name: "module-brief-file-harmonizer"
code: "fh"
status: "ready-for-creation"
created: "2026-02-02"
version: "1.0.0"
---

# 📋 Module Brief: File Harmonizer

**Module Code:** `fh`  
**Module Name:** File Harmonizer  
**Status:** Ready for Creation  
**Created:** February 2, 2026

---

## 🎯 **Executive Summary**

The **File Harmonizer** module analyzes BMAD repository structures to identify all file types and naming inconsistencies, then systematically harmonizes them according to BMAD standards. It discovers blocked file extensions and non-standard names, facilitates intelligent renaming, and updates all documentation references to maintain repository coherence.

---

## 🔍 **The Problem**

BMAD repositories can develop inconsistent file naming conventions and unsupported file types over time:
- Multiple file extensions for the same type of content (e.g., `.config.yaml`, `.config.yml`, `.config.json`)
- Non-standard naming patterns that don't follow BMAD conventions
- Unknown file types that can't be read by standard tools
- Orphaned documentation references pointing to renamed or restructured files
- Manual, error-prone renaming processes that break references

**Impact:** Reduced maintainability, confusion about canonical file types, broken documentation links, and wasted developer time on repetitive harmonization tasks.

---

## ✨ **What This Module Does**

### Core Capabilities

1. **Discovery Phase**
   - Recursively scan repository for all file types (extensions)
   - Build comprehensive inventory of distinct file types and naming patterns
   - Attempt to read one sample of each file type using `read_file` tool
   - Identify "blocked extensions" — types that cannot be read or are non-standard

2. **Analysis Phase**
   - Catalog all blocked file extensions
   - Identify blocked file names (e.g., generic "config" instead of standardized names)
   - Prompt user for known blocked names and patterns
   - Generate harmonization recommendations

3. **Harmonization Phase**
   - Rename blocked extensions to BMAD-compliant equivalents
   - Rename blocked file names to standardized patterns (e.g., `config` → `bmad-config`)
   - Preserve file contents and integrity during renaming
   - Create detailed change log

4. **Documentation Update Phase**
   - Scan _bmad documentation for references to renamed files
   - Update all documentation links and file references
   - Verify referential integrity across the repository
   - Generate verification report

---

## 👥 **Who Is This For?**

- **Repository Maintainers** — Keep repository structures clean and standardized
- **BMAD Module Developers** — Ensure their modules follow naming conventions
- **DevOps/Infrastructure Teams** — Enforce organization-wide file standards
- **Documentation Stewards** — Maintain accurate reference links

---

## 🌟 **Value Proposition**

- **Automation** — What used to be manual error-prone work is now guided and systematic
- **Visibility** — Complete inventory of repository file types and naming patterns
- **Safety** — Dry-run mode to preview changes before committing
- **Traceability** — Detailed logs of all changes and their impact
- **Compliance** — Ensures repository adheres to BMAD file standards

---

## 🧠 **Agents Required**

### Agent 1: Scout
- **Role:** File System Analyzer
- **Responsibilities:**
  - Recursively scan repository structure
  - Catalog file types and extensions
  - Attempt reads on sample files
  - Generate file inventory report
- **Key Skills:** File system traversal, data collection, categorization

### Agent 2: Harmonizer
- **Role:** Renaming & Standardization Specialist
- **Responsibilities:**
  - Analyze blocked extensions and names
  - Propose standardization mappings
  - Execute file renaming operations
  - Update references in renamed files
- **Key Skills:** File manipulation, pattern matching, reference updating

### Agent 3: Scribe
- **Role:** Documentation & Reference Manager
- **Responsibilities:**
  - Scan documentation for file references
  - Update all documentation links
  - Generate change logs and reports
  - Verify referential integrity
- **Key Skills:** Text analysis, documentation management, reporting

---

## 🔄 **Workflows**

### Workflow 1: Analyze Repository
**Trigger:** User initiates analysis  
**Process:**
1. Scout scans entire repository
2. Generates file type inventory
3. Attempts to read one sample of each type
4. Identifies blocked extensions
5. Returns comprehensive report with categorization

**Output:** 
- File type inventory (JSON/CSV)
- Blocked extensions list
- Sample file read failures (with reasons)
- Categorized file summary

### Workflow 2: Gather Harmonization Rules
**Trigger:** After analysis complete  
**Process:**
1. Present blocked extensions to user
2. Ask for known blocked file names (defaults: `config.*` → `bmad-config`)
3. Gather additional harmonization rules from user
4. Compile standardization mapping table
5. Request user approval before proceeding

**Output:**
- Harmonization mapping table
- User-approved renaming plan
- Dry-run preview of changes

### Workflow 3: Execute Harmonization
**Trigger:** User approves harmonization plan  
**Process:**
1. Harmonizer renames blocked extensions to standards
2. Updates file references within renamed files
3. Creates backup records of old names
4. Logs all rename operations
5. Generates detailed change log

**Output:**
- Renamed files in repository
- Change log with before/after mappings
- Backup reference documentation

### Workflow 4: Update Documentation
**Trigger:** Harmonization complete  
**Process:**
1. Scribe scans _bmad documentation
2. Identifies all file references
3. Updates references to new file names/extensions
4. Verifies all links are valid
5. Generates verification report

**Output:**
- Updated documentation files
- Verification report
- Broken link report (if any)
- Referential integrity status

---

## 🛠️ **Tools & Integrations**

### Built-in Tools
- `read_file` — Read file contents to test readability
- `grep_search` — Search for file references in documentation
- `file_search` — Locate files by pattern
- `run_in_terminal` — Execute rename operations safely

### Data Structures
- File type inventory (extension → count, sample files)
- Blocked extensions catalog
- Harmonization mapping (old → new)
- Change log (timestamp, operation, before, after)
- Verification report (success count, errors, warnings)

---

## 📊 **Key Scenarios**

### Scenario 1: First-Time Repository Analysis
**User Goal:** Understand what file types exist in their repository  
**Module Flow:**
1. Run Scout to scan repository
2. Receive categorized inventory
3. Review file type distribution
4. Identify any unexpected file types

### Scenario 2: Standardizing Configuration Files
**User Goal:** Rename all `config.*` files to `bmad-config.*`  
**Module Flow:**
1. User specifies blocking pattern: `config`
2. Scout finds all matching files
3. Harmonizer renames with user approval
4. Scribe updates all documentation references

### Scenario 3: Handling Unsupported File Types
**User Goal:** Identify and resolve unreadable files  
**Module Flow:**
1. Scout identifies files that can't be read
2. User provides mapping rules (e.g., `.bin` → `.yaml`)
3. Harmonizer converts or renames files
4. Verify content integrity after conversion

### Scenario 4: Repository Cleanup After Migration
**User Goal:** Harmonize repository after copying/merging structures  
**Module Flow:**
1. Full analysis reveals duplicates and inconsistencies
2. Generate harmonization plan
3. Execute renaming and deduplication
4. Update all references and documentation

---

## ✅ **Success Criteria**

- ✅ Complete file type inventory generated and categorized
- ✅ All blocked extensions identified and logged
- ✅ User-approved harmonization mapping created
- ✅ All file renamings executed successfully
- ✅ All documentation references updated
- ✅ Zero broken links in _bmad documentation
- ✅ Detailed change log available for audit
- ✅ Repository structure is standardized and maintainable

---

## 📦 **Module Deliverables**

```
file-harmonizer/
├── README.md                          # Module overview
├── TODO.md                            # Development checklist
├── module.yaml                        # Module metadata
├── _module-installer/
│   └── installer.js                   # Installation script
├── agents/
│   ├── scout.md                       # File system analyzer
│   ├── harmonizer.md                  # Renaming specialist
│   └── scribe.md                      # Documentation manager
├── workflows/
│   ├── analyze-repository.md          # Discovery workflow
│   ├── gather-harmonization-rules.md  # Rule collection workflow
│   ├── execute-harmonization.md       # Renaming workflow
│   └── update-documentation.md        # Reference updating workflow
├── resources/
│   ├── file-type-standards.yaml       # Extension mappings
│   ├── naming-conventions.yaml        # Name standardization rules
│   └── templates/
│       ├── inventory-report.md        # Report template
│       └── change-log-template.md     # Change tracking template
└── docs/
    ├── architecture.md                # Module design
    ├── user-guide.md                  # How to use
    └── examples.md                    # Example use cases
```

---

## 🚀 **Implementation Priority**

1. **Phase 1 (Core):** Scout agent + Analyze Repository workflow
2. **Phase 2 (Harmonization):** Harmonizer agent + Execute Harmonization workflow
3. **Phase 3 (Documentation):** Scribe agent + Update Documentation workflow
4. **Phase 4 (Polish):** Dry-run mode, reporting, safety mechanisms

---

## 🎨 **Module Personality**

**Character:** The File Harmonizer is methodical, thorough, and safety-conscious. It's like having a meticulous librarian who wants everything organized perfectly but won't make changes without your approval.

**Communication Style:** Clear, detailed, with dry-run previews and confirmation steps. Emphasizes safety and transparency.

**Special Touch:** Provides before/after visualizations and detailed impact analyses so you understand exactly what will change.

---

## 📝 **Notes & Considerations**

- **Safety First:** Always provide dry-run mode and user approval before any file operations
- **Backup Strategy:** Consider creating change logs/backups for rollback capability
- **Performance:** For large repositories, implement batch processing for Scout phase
- **Integration:** Ensure harmonization works with version control (Git) workflows
- **Extensibility:** Design agents to be reusable for other harmonization tasks

---

## ✨ **Ready for Creation**

This brief captures the complete vision for the File Harmonizer module. It's ready to move into the **Create Module** phase where we'll build:
- Complete agent implementations
- Fully functional workflows
- Module infrastructure and configuration
- Documentation and examples

**Next Steps:** Would you like me to create the complete module structure now?
