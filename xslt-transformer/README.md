XSLT Transformer module
=======================

This module helps with transformations of Liquibase generated changelog.

|*File*|*Function*|
|------|----------|
|[liquibase-changelog-remarks-fix.xslt](src/main/resources/liquibase-changelog-remarks-fix.xslt)|Moves all remarks which are generated in `createTable[@remarks]` or in `createTable/column[@remarks]` to separate changeSet (one changeSet for all remarks) which consists of `setTableRemarks` and `setColumnRemarks`|
|[liquibase-changelog-unique-constraint-fix.xslt](src/main/resources/liquibase-changelog-unique-constraint-fix.xslt)|If changeSet contains `createIndex` and `addUniqueConstraint` changes this xslt moves them to separate changeSets. From `addUniqueConstraint` is removed attribute `forIndexName` and it's content is moved to `modifySql` change as it works only for oracle |
|[liquibase-changelog-create-sequence-fix.xslt](src/main/resources/liquibase-changelog-create-sequence-fix.xslt)|If `createSequence` change contains `ordered="true"` attribute, this xslt adds `modifySql` change because it is specific to oracle|