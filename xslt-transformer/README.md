XSLT Transformer module
=======================

This module helps with transformations of Liquibase generated changelog.

|*File*|*Function*|
|------|----------|
|[liquibase-changelog-remarks-fix.xslt](src/main/resources/liquibase-changelog-remarks-fix.xslt)|Moves all remarks which are generated in `createTable[@remarks]` or in `createTable/column[@remarks]` to separate changeSet (one changeSet for all remarks) which consists of `setTableRemarks` and `setColumnRemarks`|